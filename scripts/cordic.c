#include <math.h>
#include <stdio.h>

#define INV_K 0x26DD3B6A
#define SCALE 1073741824.0
#define N_TAB 32

int CTAB[] = {0x3243F6A8, 0x1DAC6705, 0x0FADBAFC, 0x07F56EA6, 0x03FEAB76,
              0x01FFD55B, 0x00FFFAAA, 0x007FFF55, 0x003FFFEA, 0x001FFFFD,
              0x000FFFFF, 0x0007FFFF, 0x0003FFFF, 0x0001FFFF, 0x0000FFFF,
              0x00007FFF, 0x00003FFF, 0x00001FFF, 0x00000FFF, 0x000007FF,
              0x000003FF, 0x000001FF, 0x000000FF, 0x0000007F, 0x0000003F,
              0x0000001F, 0x0000000F, 0x00000008, 0x00000004, 0x00000002,
              0x00000001, 0x00000000};

int cordic(int theta) {
    int x = INV_K;
    int y = 0;
    int z = theta;

    for (int i = 0; i < N_TAB; ++i) {
        int d = z >= 0 ? 0 : -1;

        int tx = x - (((y >> i) ^ d) - d);
        int ty = y + (((x >> i) ^ d) - d);
        int tz = z - ((CTAB[i] ^ d) - d);

        x = tx;
        y = ty;
        z = tz;
    }

    return y;
}

void test(double theta) {
    printf("input: %d,\toutput: %d,\tcordic: %f,\tsin: %f\n",
           (unsigned int)(theta * SCALE), cordic(theta * SCALE),
           cordic(theta * SCALE) / SCALE, sin(theta));
}

int main() {
    test(0);
    test(M_PI / 6);
    test(M_PI / 4);
    test(M_PI / 3);
    test(M_PI / 2);
    return 0;
}
