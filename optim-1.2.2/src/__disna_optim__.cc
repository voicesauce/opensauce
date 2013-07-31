// Copyright (C) 2011 Olaf Till <olaf.till@uni-jena.de>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

// This function has also been submitted to Octave (bug #33503).

#include <octave/oct.h>
#include "f77-fcn.h"

extern "C"
{
  F77_RET_T
  F77_FUNC (ddisna, DDISNA) (F77_CONST_CHAR_ARG_DECL,
                             const octave_idx_type&,
                             const octave_idx_type&,
                             const double*,
                             double*,
                             octave_idx_type&);

  F77_RET_T
  F77_FUNC (sdisna, SDISNA) (F77_CONST_CHAR_ARG_DECL,
                             const octave_idx_type&,
                             const octave_idx_type&,
                             const float*,
                             float*,
                             octave_idx_type&);
}

DEFUN_DLD (__disna_optim__, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{rcond} =} __disna__ (@var{job}, @var{d})\n\
@deftypefnx {Loadable Function} {@var{rcond} =} __disna__ (@var{job}, @var{d}, @var{m}, @var{n})\n\
Undocumented internal function.\n\
@end deftypefn")
{
  /*
    Interface to DDISNA and SDISNA of LAPACK.

    If job is 'E', no third or fourth argument are given. If job is 'L'
    or 'R', M and N are given.
  */

  std::string fname ("__disna__");

  octave_value retval;

  if (args.length () != 2 && args.length () != 4)
    print_usage ();

  std::string job_str (args(0).string_value ());

  char job;

  if (job_str.length () != 1)
    error ("%s: invalid job label", fname.c_str ());
  else
    job = job_str[0];

  octave_idx_type m, n, l;
  bool single;
  octave_value d;

  if (args(1).is_single_type ())
    {
      single = true;
      d = args(1).float_column_vector_value ();
    }
  else
    {
      single = false;
      d = args(1).column_vector_value ();
    }

  if (! error_state)
    {
      l = d.length ();
      switch (job)
        {
        case 'E' :
          if (args.length () != 2)
            error ("%s: with job label 'E' only two arguments are allowed",
                   fname.c_str ());
          else
            m = l;
          break;
        case 'L' :
        case 'R' :
          if (args.length () != 4)
            error ("%s: with job labels 'L' or 'R', four arguments must be given",
                   fname.c_str ());
          else
            {
              m = args(2).idx_type_value ();
              n = args(3).idx_type_value ();
              if (! error_state)
                {
                  octave_idx_type md = m < n ? m : n;
                  if (l != md)
                    error ("%s: given dimensions don't match length of second argument",
                           fname.c_str ());
                }
            }
          break;
        default :
          error ("%s: job label not correct", fname.c_str ());
        }
    }

  if (error_state)
    {
      error ("%s: invalid arguments", fname.c_str ());
      return retval;
    }

  octave_idx_type info;

  if (single)
    {
      FloatColumnVector srcond (l);

      F77_XFCN (sdisna, SDISNA, (F77_CONST_CHAR_ARG2 (&job, 1),
                                 m, n,
                                 d.float_column_vector_value ().fortran_vec (),
                                 srcond.fortran_vec (),
                                 info));

      retval = srcond;
    }
  else
    {
      ColumnVector drcond (l);

      F77_XFCN (ddisna, DDISNA, (F77_CONST_CHAR_ARG2 (&job, 1),
                                 m, n,
                                 d.column_vector_value ().fortran_vec (),
                                 drcond.fortran_vec (),
                                 info));

      retval = drcond;
    }

  if (info < 0)
    error ("%s: LAPACK routine says %i-th argument had an illegal value",
           fname.c_str (), -info);

  return retval;
}
