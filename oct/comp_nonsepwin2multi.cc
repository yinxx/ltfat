#include <stdio.h>
#include <octave/oct.h>
#include "config.h"
#include "ltfat.h"

static inline int ltfat_round(double x)
{
  return (int)(x+.5); 
}

DEFUN_DLD (comp_nonsepwin2multi, args, ,
  "This function calls the C-library\n\
  c=comp_nonsepwin2multi(g,a,M,lt);\n")
{

   const ComplexMatrix g = args(0).complex_matrix_value();
   const int    a        = args(1).int_value();
   const double M        = args(2).int_value();
   const Matrix lt       = args(3).matrix_value();
   
   const int L = g.rows();
   const int lt1 = ltfat_round(lt(0));
   const int lt2 = ltfat_round(lt(1));

   ComplexMatrix mwin(L,lt2);

   nonsepwin2multi((const ltfat_complex*)g.fortran_vec(),
		   L,a,M,lt1,lt2,
		   (ltfat_complex*)mwin.data());
        
   return octave_value (mwin);
}