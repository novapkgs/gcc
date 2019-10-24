/* PR rtl-optimization/87759 */
/* { dg-do compile { target int128 } } */
/* { dg-options "-O2 -w -fschedule-insns -fselective-scheduling -ftrapv -fno-dce -fno-expensive-optimizations -fno-ipa-ra -fno-tree-dce -fno-tree-ter" } */

int cc;

void
rc (__int128 *oi)
{
  __int128 qz = (__int128)2 << cc;

  if (qz != 0)
    {
      if (cc != 0)
        {
          __int128 zp = 1;

          for (;;)
            {
              unsigned __int128 *ar = &cc;
              int y5;

              if (oi != 0)
                {
 y3:
                  zp = *oi + *ar;
                }

              y5 = (cc + 1) == ((*ar /= *oi) << ((zp >>= 128) / cc));
              qz += !!y5 ? 1 : qz == (*ar ^ zp + 1);
              ++*oi;
            }
        }
      else
        ++qz;
    }

  goto y3;
}
