/* { dg-do run { target { aarch64_sve_hw } } } */
/* { dg-options "-O2 -ftree-vectorize" } */

#include "var_stride_8.c"
#include "var_stride_1.h"

int
main (void)
{
  for (int n = -10; n < 10; ++n)
    for (int offset = -33; offset <= 33; ++offset)
      test (1, n, offset);
  return 0;
}
