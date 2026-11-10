import fileinput
import sys
import subprocess
import tqdm
import os

def replaceAll(file, searchExp, replaceExp):
    for line in fileinput.input(file, inplace=1):
        if line.startswith(searchExp):
            line = replaceExp + "\n"
        sys.stdout.write(line)

def replaceLineByLinenumber(file, line_number, new_line):
    with open(file, 'r') as f:
        lines = f.readlines()

    if 0 <= line_number < len(lines):
        lines[line_number] = new_line + "\n"
    else:
        print(f"Line number {line_number} is out of range for file {file}.")
        return

    with open(file, 'w') as f:
        f.writelines(lines)

def build_and_run(byte_size, experiment_type):
    if not os.path.exists(f"measurements/hash_table_size/{experiment_type}"):
        os.makedirs(f"measurements/hash_table_size/{experiment_type}")
    try:
        subprocess.run(f"make && sudo ./huginn > measurements/hash_table_size/{experiment_type}/{byte_size}b_ft.txt", shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while building and running for byte_size {byte_size}: {e}")

for i in tqdm.tqdm(range(8, 24)):
    replaceAll("common.h", "#define LOG_FLOW_ENTRIES", f"#define LOG_FLOW_ENTRIES {i}")
    build_and_run(i, "bucket_handling")
