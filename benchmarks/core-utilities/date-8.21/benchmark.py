#!/usr/bin/python
import subprocess

def execute(cmd):
    print('running ', cmd)
    p = subprocess.Popen(cmd, shell=True)
    return p.communicate()


def train_run(BIN, arg):
    cmd = BIN + ' ' + arg
    return execute(cmd)


def test_run(BIN, arg):
    cmd = BIN + ' ' + arg
    return execute(cmd)

# out_train = list of outputs of train cases (in order)
# out_test = list of outputs of test cases (in order)


def verify(out_train, out_test):
    if len(out_train) != len(out_test):
        return -1

    for i in range(len(out_train)):
        if out_train[i] != out_test[i]:
            return -1
    return 0


def train(BIN, tests):
    out_train = []
    for f in tests:
        t = train_run(BIN, f)
        out_train.append(t)
    return out_train


def test(BIN, tests):
    out_test = []
    for f in tests:
        t = test_run(BIN, f)
        out_test.append(t)
    return out_test
