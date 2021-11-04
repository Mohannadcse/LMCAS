#!/usr/bin/python
from subprocess import PIPE, Popen


def execute(cmd):
    print('Running:\t', cmd)
    with Popen(cmd, stdout=PIPE, stderr=None, shell=True) as process:
        output = process.communicate()[0].decode("utf-8")
    print('Output:\t', output)
    return output


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
