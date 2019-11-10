import argparse
import math


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("scale")
    args = parser.parse_args()

    scale = int(args.scale)
    k = 0.6072529350088812561694
    print("1/k:", int(scale * k))

    print("angles:")
    for i in range(50):
        print(int(scale * math.atan(2**-i)))


if __name__ == "__main__":
    main()
