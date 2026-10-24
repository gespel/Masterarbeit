# FlexIO Tutorial
The following tutorial demonstrates how to use the FlexIO library to create a simple application that utilizes Infiniband for communication.
The following header files are required to use the FlexIO library:
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <infiniband/verbs.h>
#include <libflexio/flexio_ver.h>
#define FLEXIO_VER_USED FLEXIO_VER(26, 4, 0)
#include <libflexio/flexio.h>
```
```c 
struct ibv_context *ctx = NULL;
```
The Infiniband context gets opened via assignment by id from the list of ibv_devices.

```c
int num_devices;
struct ibv_device **dev_list = ibv_get_device_list(&num_devices);

for (int i = 0; i < num_devices; i++) {
    if (strcmp(ibv_get_device_name(dev_list[i]), "mlx5_0") == 0) {
        ctx = ibv_open_device(dev_list[i]);
        break;
    }
}
ibv_free_device_list(dev_list);
```
This Infiniband context is now used to create a flexio application:

```c
struct flexio_app *app; // One app struct per application
struct flexio_process *proc; //multiple processes can be created per application

struct flexio_app_select_attr sel = { // Select attributes for the application
    .app_name = "my_app", // Name of the application
    .hw_model_id = FLEXIO_MODEL_DEF, // Hardware model ID
    .ibv_ctx = ctx, // pass the Infiniband context to the application
};
```
Now all of the necessary attributes are set to create a flexio application.

The following code creates the application and a process within that application:

```c
flexio_version_set(FLEXIO_VER_USED); // set the version of the flexio library to use
flexio_app_get(&sel, &app); // create the application
flexio_process_create(ctx, app, NULL, &proc); // create a process within the application
```

In order to send log messages to the host, a log stream must be created.

```c
struct flexio_msg_stream *stream;
flexio_msg_stream_attr_t stream_attr = {
    .data_bsize = 4096, // size of the logging buffer
    .sync_mode = FLEXIO_MSG_DEV_SYNC_MODE_SYNC, // synchronous logging mode
    .level = FLEXIO_MSG_LEVEL_INFO, // log level
};
flexio_msg_stream_create(proc, &stream_attr, stdout, NULL, &stream); // create the log stream
```

Now that everything is set up, we can finally start our rpc functions via the following code:

```c
flexio_process_call(proc, &stream_attr, &ret, 2, 3); // call the rpc function with arguments 2 and 3
```
Note that rpc functions must always return an integer value, which is stored in the variable `ret` in this case.

RPC functions can be defined in the following way:
```c
__dpa_rpc__ uint64_t add(uint64_t a, uint64_t b) {
    flexio_dev_print("This is a log message from the DPA!\n");
    return a + b;
}
```
> **_NOTE:_**  A function must be forward defined in the host source code in order to be callable. This can be done the following way:
```c
extern flexio_func_t add;
```
The name of the function must match the name of the function defined in the DPA source code.

The source code for the DPA should be a file called `kernel.c` and the source code for the host should be a file called `host.c`.