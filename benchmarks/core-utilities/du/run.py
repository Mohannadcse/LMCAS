import os, sys

sys.path.append(os.path.join(os.path.dirname(
    os.path.realpath(__file__)), os.pardir))
import benchmark

sys.path.append(os.path.join(os.path.dirname(
    os.path.realpath(__file__)), os.pardir + "/binaries"))

BIN_PATH = sys.path[-1]

def usage():
    print('python run.py original|debloated\n')
    sys.exit(1)


def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        usage()

    ORIG_BIN = BIN_PATH + '/du_orig'
    DEBLOATED_BIN = BIN_PATH + '/du_cu'
    
    original_test_cases = ['-h .']
    debloated_test_cases = ['.']

    if sys.argv[1] == 'original':
        originaled = benchmark.original(ORIG_BIN, original_test_cases)

    elif sys.argv[1] == 'debloated':
        debloateded = benchmark.debloated(DEBLOATED_BIN, debloated_test_cases)

    elif sys.argv[1] == 'verify':
        originaled = benchmark.original(ORIG_BIN, original_test_cases)
        debloateded = benchmark.debloated(DEBLOATED_BIN, debloated_test_cases)

        ret = benchmark.verify(originaled, debloateded)

    else:
        usage()


if __name__ == '__main__':
    main()
