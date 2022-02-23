#!/usr/bin/python
from subprocess import PIPE, Popen
import re

T_STRING = "wall"
M_STRING = "resident"

MAX_ITERATIONS = 100


def execute(cmd):
    print('Running:\t', cmd)
    with Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True) as process:
        output = process.communicate()[0].decode("utf-8")
    print('Output:\t', output)
    return output


def execute_err(cmd):
    print('Running:\t', cmd)
    with Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True) as process:
        output = process.communicate()[1].decode("utf-8")
    return output


def original_run_err(BIN, arg):
    cmd = BIN + ' ' + arg
    return execute_err(cmd)


def debloated_run_err(BIN, arg):
    cmd = BIN + ' ' + arg
    return execute_err(cmd)


def original_run(BIN, arg):
    cmd = BIN + ' ' + arg
    return execute(cmd)


def debloated_run(BIN, arg):
    cmd = BIN + ' ' + arg
    return execute(cmd)

# out_original = list of outputs of original cases (in order)
# out_debloated = list of outputs of debloated cases (in order)


def verify(out_original, out_debloated):
    assert len(out_original) > 0
    assert len(out_debloated) > 0
    assert len(out_original) == len(out_debloated)

    for i in range(len(out_original)):
        if out_original[i] != out_debloated[i]:
            print("Verification failed!")
            return -1
    print("Verification success!")
    return 0


def to_seconds(timestr):
    seconds = 0
    for part in timestr.split(':'):
        seconds = seconds*60 + int(part, 10)
    return seconds


def get_time(s):
    return to_seconds(s[4].split("):")[1].strip().replace(".", ":"))


def get_mem(s):
    return int(s[9].split("):")[1].strip())


def cal_average(num):
    sum_num = 0
    for t in num:
        sum_num = sum_num + t

    avg = sum_num / len(num)
    return avg

# out_original = list of outputs of original cases (in order)
# out_debloated = list of outputs of debloated cases (in order)


def measure(out_original, out_debloated):
    assert len(out_original) > 0
    assert len(out_debloated) > 0
    assert len(out_original) == len(out_debloated)

    times_og = []
    times_d = []
    mems_og = []
    mems_d = []

    for n in range(MAX_ITERATIONS):
        for i in range(len(out_original)):
            out_og = out_original[i].split('\n')
            out_d = out_debloated[i].split('\n')

            og_time = get_time(out_og)
            d_time = get_time(out_d)

            times_og.append(og_time)
            times_d.append(d_time)

            og_mem = get_mem(out_og)
            d_mem = get_mem(out_d)

            mems_og.append(og_mem)
            mems_d.append(d_mem)

    print("\nTotal iterations ", MAX_ITERATIONS)

    # average
    avg_time_og = cal_average(times_og)
    avg_time_d = cal_average(times_d)
    print("Average Time OG (in seconds) = ", avg_time_og)
    print("Average Time Debloated (in seconds) = ", avg_time_d)

    avg_mem_og = cal_average(mems_og)
    avg_mem_d = cal_average(mems_d)
    print("Average Memory OG (in kbytes) = ", avg_mem_og)
    print("Average Memory Debloated (in kbytes) = ", avg_mem_d)

    return 0


def original_err(BIN, args):
    out_original = []
    for f in args:
        t = original_run_err(BIN, f)
        out_original.append(t)
    return out_original


def debloated_err(BIN, args):
    out_debloated = []
    for f in args:
        t = debloated_run_err(BIN, f)
        out_debloated.append(t)
    return out_debloated


def original(BIN, args):
    out_original = []
    for f in args:
        t = original_run(BIN, f)
        out_original.append(t)
    return out_original


def debloated(BIN, args):
    out_debloated = []
    for f in args:
        t = debloated_run(BIN, f)
        out_debloated.append(t)
    return out_debloated


def clean():
    for fname in os.listdir('./'):
        if fname == "run.py":
            continue

        if fname == 'debloated' or fname == 'original' or fname == "backup":
            continue

        if fname == "date.orig" or fname == "date-8.21.c.orig.c":
            continue

        execute('rm -rf ./' + fname)
