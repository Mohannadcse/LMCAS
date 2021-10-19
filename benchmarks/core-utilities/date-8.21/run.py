
from __future__ import print_function
import os
import subprocess
import sys
# sys.path.append('../')
import benchmark

def train_run(arg):
    BIN = './date.orig'
    cmd = BIN + ' ' + arg
    return execute(cmd)


def test_run():
    BIN = './date.debloated'
    cmd = BIN
    return execute(cmd)


def clean():
    for fname in os.listdir('./'):
        if fname == "run.py":
            continue

        if fname == 'test' or fname == 'train' or fname == "backup":
            continue

        if fname == "date.orig" or fname == "date-8.21.c.orig.c":
            continue

        execute('rm -rf ./' + fname)


def usage():
    print('python run.py clean|train|test|debloat|extend_debloat|get_test_traces\n')
    sys.exit(1)


def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        usage()

    ORIG_BIN = './date.orig'
    trained = []
    DEBLOATED_BIN = './date.debloated'
    tested = []
    
    if sys.argv[1] == 'train':
        trained = benchmark.train(ORIG_BIN, ['-R'])

    elif sys.argv[1] == 'test':
        tested = benchmark.test(DEBLOATED_BIN, [''])

    elif sys.argv[1] == 'verify':
        verify(trained, tested)

    # elif sys.argv[1] == 'debloat':
    #     debloat('logs', 'date')

    # elif sys.argv[1] == 'extend_debloat':
    #     if len(sys.argv) != 3:
    #         print("Please specify heuristic level (i.e., 1 ~ 4).")
    #         sys.exit(1)
    #     heuristic_level = int(sys.argv[2])
    #     extend_debloat('date', heuristic_level)

    # elif sys.argv[1] == 'clean':
    #     clean()

    else:
        usage()


if __name__ == '__main__':
    main()
