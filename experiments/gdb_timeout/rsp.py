#!/usr/bin/env python3
"""Minimal GDB Remote Serial Protocol client for dpa-gdbserver.

There is no RISC-V capable gdb on the BlueField (only aarch64 gdb; gdb-multiarch
is not installed), and the experiment needs exact, scripted timing anyway, so
this speaks RSP directly.

Modes (all print timestamped events to stdout):
  attach      connect, report stop reason + threads, continue, stay connected
              for --hold seconds without touching the target
  interrupt   connect, continue, then every --period s: interrupt (^C), stay
              halted for --halt s, continue; for --hold seconds in total
  bp          connect, set a breakpoint at --addr, continue; on every hit
              continue again; for --hold seconds in total
  halt        connect (gdbserver halts the target) and stay halted for
              --hold seconds, then continue and detach
"""
import argparse
import socket
import sys
import time

T0 = time.monotonic()


def log(msg):
    print(f"[{time.monotonic() - T0:8.3f}] {msg}", flush=True)


class Rsp:
    def __init__(self, host, port, timeout):
        self.s = socket.create_connection((host, port), timeout=timeout)
        self.buf = b""
        self.noack = False

    def _read(self, timeout=None):
        if timeout is not None:
            self.s.settimeout(timeout)
        data = self.s.recv(4096)
        if not data:
            raise EOFError("gdbserver closed the connection")
        self.buf += data

    def send(self, payload):
        cs = sum(payload.encode()) & 0xFF
        self.s.sendall(f"${payload}#{cs:02x}".encode())
        if not self.noack:
            self._wait_ack()

    def _wait_ack(self):
        while True:
            while self.buf[:1] in (b"+",):
                self.buf = self.buf[1:]
                return
            if self.buf[:1] == b"-":
                raise RuntimeError("gdbserver NAKed packet")
            if self.buf:
                # a packet arrived before the ack (should not happen); keep it
                return
            self._read()

    def recv(self, timeout=None):
        """Return the next packet payload (str); None on timeout."""
        deadline = None if timeout is None else time.monotonic() + timeout
        while True:
            self.buf = self.buf.lstrip(b"+")
            start = self.buf.find(b"$")
            if start >= 0:
                end = self.buf.find(b"#", start)
                if end >= 0 and len(self.buf) >= end + 3:
                    payload = self.buf[start + 1:end].decode(errors="replace")
                    self.buf = self.buf[end + 3:]
                    if not self.noack:
                        self.s.sendall(b"+")
                    return payload
            if deadline is not None:
                left = deadline - time.monotonic()
                if left <= 0:
                    return None
                try:
                    self._read(left)
                except socket.timeout:
                    return None
            else:
                self._read(None)

    def cmd(self, payload, timeout=10):
        self.send(payload)
        return self.recv(timeout)

    def interrupt(self):
        self.s.sendall(b"\x03")

    def close(self):
        try:
            self.s.close()
        except OSError:
            pass


def connect(args):
    last = None
    for _ in range(int(args.connect_timeout * 10)):
        try:
            r = Rsp(args.host, args.port, 10)
            break
        except OSError as e:
            last = e
            time.sleep(0.1)
    else:
        sys.exit(f"cannot connect to {args.host}:{args.port}: {last}")
    log(f"connected to {args.host}:{args.port}")
    log(f"qSupported -> {r.cmd('qSupported:swbreak+;hwbreak+')}")
    if "QStartNoAckMode+" in (r.cmd("QStartNoAckMode") or ""):
        pass
    r.noack = True
    log(f"?           -> {r.cmd('?')}")
    threads = r.cmd('qfThreadInfo') or ""
    log(f"qfThreadInfo-> {threads}")
    # dpa-gdbserver rejects a bare "vCont;c" (needs ":<thread-id>"); continue
    # every thread of the (single) process: p<pid>.-1
    pid = threads[1:].split(",")[0].split(".")[0] if threads.startswith("m") else "p1"
    r.cont_pkt = f"vCont;c:{pid}.-1"
    log(f"vCont?      -> {r.cmd('vCont?')}")
    log(f"pc          -> {read_pc(r)}")
    return r


def read_pc(r):
    """RISC-V 'g' packet: x0..x31 then pc, 8 bytes each, little endian hex."""
    g = r.cmd("g") or ""
    if len(g) < 33 * 16:
        return f"? ({g[:40]})"
    return "0x" + bytes.fromhex(g[32 * 16:33 * 16])[::-1].hex()


def cont(r):
    r.send(r.cont_pkt)
    log("continue")


def wait_stop(r, timeout):
    p = r.recv(timeout)
    if p is not None:
        log(f"stop        -> {p!r}")
    return p


def mode_attach(r, a):
    cont(r)
    end = time.monotonic() + a.hold
    while time.monotonic() < end:
        p = wait_stop(r, end - time.monotonic())
        if p and p[0] in "TS":
            log("unexpected stop, continuing")
            cont(r)
        elif p and p[0] in "WX":
            log("target exited")
            return


def mode_interrupt(r, a):
    cont(r)
    end = time.monotonic() + a.hold
    while time.monotonic() + a.period < end:
        p = wait_stop(r, a.period)
        if p and p[0] in "WX":
            log("target exited")
            return
        r.interrupt()
        log("^C sent")
        wait_stop(r, 10)
        log(f"pc          -> {read_pc(r)}")
        time.sleep(a.halt)
        cont(r)
    wait_stop(r, max(0.0, end - time.monotonic()))


def mode_bp(r, a):
    addr = int(a.addr, 0)
    log(f"Z0,{addr:x},{a.kind} -> {r.cmd(f'Z0,{addr:x},{a.kind}')}")
    cont(r)
    hits = 0
    end = time.monotonic() + a.hold
    while time.monotonic() < end:
        p = r.recv(end - time.monotonic())
        if p is None:
            break
        if p and p[0] in "WX":
            log(f"target exited: {p}")
            break
        hits += 1
        # T05thread:p01.8001; -> step exactly this thread over the breakpoint
        tid = p.split("thread:")[1].split(";")[0] if "thread:" in p else None
        verbose = hits <= 3 or hits % 10 == 0
        if verbose and tid:
            r.cmd(f"Hg{tid}")
            log(f"hit #{hits}: {p} pc={read_pc(r)}")
        if a.halt:
            time.sleep(a.halt)
        # what gdb does: remove bp, single-step the thread, reinsert, continue
        r.cmd(f"z0,{addr:x},{a.kind}")
        if tid:
            r.send(f"vCont;s:{tid}")
            s = r.recv(10)
            if verbose:
                log(f"  step -> {s!r}")
        r.cmd(f"Z0,{addr:x},{a.kind}")
        r.send(r.cont_pkt)
    log(f"breakpoint hits: {hits}")
    r.interrupt()
    wait_stop(r, 5)
    log(f"z0 -> {r.cmd(f'z0,{addr:x},{a.kind}')}")


def mode_halt(r, a):
    log(f"target halted, holding for {a.hold} s")
    time.sleep(a.hold)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["attach", "interrupt", "bp", "halt"])
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=1981)
    ap.add_argument("--connect-timeout", type=float, default=20)
    ap.add_argument("--hold", type=float, default=150, help="session length in s")
    ap.add_argument("--period", type=float, default=30, help="interrupt mode: s between ^C")
    ap.add_argument("--halt", type=float, default=1, help="s to stay halted per stop")
    ap.add_argument("--addr", help="bp mode: breakpoint address")
    ap.add_argument("--kind", type=int, default=2, help="bp mode: breakpoint kind (2=c.ebreak)")
    a = ap.parse_args()

    r = connect(a)
    try:
        {"attach": mode_attach, "interrupt": mode_interrupt,
         "bp": mode_bp, "halt": mode_halt}[a.mode](r, a)
    except EOFError as e:
        log(str(e))
        return
    log("detach")
    try:
        log(f"D -> {r.cmd('D', 5)}")
    except (EOFError, OSError) as e:
        log(f"detach: {e}")
    r.close()


if __name__ == "__main__":
    main()
