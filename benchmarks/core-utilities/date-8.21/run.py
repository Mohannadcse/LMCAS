
from __future__ import print_function
import benchmark
import os
import subprocess
import sys

sys.path.append(os.path.join(os.path.dirname(
    os.path.realpath(__file__)), os.pardir))

sys.path.append(os.path.join(os.path.dirname(
    os.path.realpath(__file__)), os.pardir + "/binaries"))

BIN_PATH = sys.path[-1]
# print(sys.path, BIN_PATH)


def original_run(arg):
    BIN = './date.orig'
    cmd = BIN + ' ' + arg
    return execute(cmd)


def debloated_run():
    BIN = './date.debloated'
    cmd = BIN
    return execute(cmd)


def usage():
    print('python run.py clean|original|debloated|debloat|extend_debloat|get_debloated_traces\n')
    sys.exit(1)


def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        usage()

    ORIG_BIN = BIN_PATH + '/date.orig'
    DEBLOATED_BIN = BIN_PATH + '/date.debloated'

    if sys.argv[1] == 'original':
        originaled = benchmark.original(ORIG_BIN, ['-R'])

    elif sys.argv[1] == 'debloated':
        debloateded = benchmark.debloated(DEBLOATED_BIN, [''])

    elif sys.argv[1] == 'verify':
        originaled = benchmark.original(ORIG_BIN, ['-R'])
        debloateded = benchmark.debloated(DEBLOATED_BIN, [''])

        ret = benchmark.verify(originaled, debloateded)

    else:
        usage()


if __name__ == '__main__':
    main()
