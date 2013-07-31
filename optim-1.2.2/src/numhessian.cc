// Copyright (C) 2004, 2006 Michael Creel <michael.creel@uab.es>
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

// numhessian: numeric second derivative

#include <oct.h>
#include <octave/parse.h>
#include <octave/lo-mappers.h>
#include <octave/Cell.h>
#include <float.h>

// argument checks
static bool
any_bad_argument(const octave_value_list& args)
{
	if (!args(0).is_string())
	{
		error("numhessian: first argument must be string holding objective function name");
		return true;
	}

	if (!args(1).is_cell())
	{
		error("numhessian: second argument must cell array of function arguments");
		return true;
	}

	// minarg, if provided
	if (args.length() == 3)
	{
		int tmp = args(2).int_value();
		if (error_state)
		{
			error("numhessian: 3rd argument, if supplied,  must an integer\n\
that specifies the argument wrt which differentiation is done");
			return true;
		}
		if ((tmp > args(1).length())||(tmp < 1))
		{
			error("numhessian: 3rd argument must be a positive integer that indicates \n\
which of the elements of the second argument is the\n\
one to differentiate with respect to");
			return true;
		}
	}
	return false;
}



DEFUN_DLD(numhessian, args, ,
	  "numhessian(f, {args}, minarg)\n\
\n\
Numeric second derivative of f with respect\n\
to argument \"minarg\".\n\
* first argument: function name (string)\n\
* second argument: all arguments of the function (cell array)\n\
* third argument: (optional) the argument to differentiate w.r.t.\n\
	(scalar, default=1)\n\
\n\
If the argument\n\
is a k-vector, the Hessian will be a kxk matrix\n\
\n\
function a = f(x, y)\n\
	a = x'*x + log(y);\n\
endfunction\n\
\n\
numhessian(\"f\", {ones(2,1), 1})\n\
ans =\n\
\n\
    2.0000e+00   -7.4507e-09\n\
   -7.4507e-09    2.0000e+00\n\
\n\
Now, w.r.t. second argument:\n\
numhessian(\"f\", {ones(2,1), 1}, 2)\n\
ans = -1.0000\n\
")
{
	int nargin = args.length();
	if (!((nargin == 2)|| (nargin == 3)))
	{
		error("numhessian: you must supply 2 or 3 arguments");
		return octave_value_list();
	}

	// check the arguments
	if (any_bad_argument(args)) return octave_value_list();

	std::string f (args(0).string_value());
	Cell f_args_cell (args(1).cell_value());
	octave_value_list f_args, f_return;
	int i, j, k, minarg;
	bool test;
	double di, hi, pi, dj, hj, pj, hia, hja, fpp, fmm, fmp, fpm, obj_value, SQRT_EPS, diff;

	// Default values for controls
	minarg = 1; // by default, first arg is one over which we minimize

	// copy cell contents over to octave_value_list to use feval()
	k = f_args_cell.length();
	f_args.resize (k); // resize only once
	for (i = 0; i<k; i++) f_args(i) = f_args_cell(i);

	// check which arg w.r.t which we need to differentiate
	if (args.length() == 3) minarg = args(2).int_value();
	Matrix parameter = f_args(minarg - 1).matrix_value();
	k = parameter.rows();
	Matrix derivative(k, k);

	f_return = feval(f, f_args);
	if (f_return.length () > 0 && f_return(0).is_double_type ())
      obj_value = f_return(0).double_value();
    else {
        error ("numhessian: function must return a scalar of class 'double'");
        return octave_value_list ();
    }

	diff = exp(log(DBL_EPSILON)/4);
	SQRT_EPS = sqrt(DBL_EPSILON);


	for (i = 0; i<k;i++) {	// approximate 2nd deriv. by central difference
		pi = parameter(i);
		test = (fabs(pi) + SQRT_EPS) * SQRT_EPS > diff;
		if (test) hi = (fabs(pi) + SQRT_EPS) * SQRT_EPS;
		else hi = diff;


		for (j = 0; j < i; j++) { // off-diagonal elements
			pj = parameter(j);
			test = (fabs(pj) + SQRT_EPS) * SQRT_EPS > diff;
			if (test) hj = (fabs(pj) + SQRT_EPS) * SQRT_EPS;
			else hj = diff;

			// +1 +1
			parameter(i) = di = pi + hi;
			parameter(j) = dj = pj + hj;
			hia = di - pi;
			hja = dj - pj;
			f_args(minarg - 1) = parameter;
			f_return = feval(f, f_args);
		    if (f_return.length () > 0 && f_return (0).is_double_type ())
              fpp = f_return(0).double_value();
            else {
                error ("numhessian: function must return a scalar of class 'double'");
                return octave_value_list ();
            }

			// -1 -1
			parameter(i) = di = pi - hi;
			parameter(j) = dj = pj - hj;
			hia = hia + pi - di;
			hja = hja + pj - dj;
			f_args(minarg - 1) = parameter;
			f_return = feval(f, f_args);
		    if (f_return.length () > 0 && f_return (0).is_double_type ())
			    fmm = f_return(0).double_value();
            else {
                error ("numhessian: function must return a scalar of class 'double'");
                return octave_value_list ();
            }

			// +1 -1
			parameter(i) = pi + hi;
			parameter(j) = pj - hj;
			f_args(minarg - 1) = parameter;
			f_return = feval(f, f_args);
		    if (f_return.length () > 0 && f_return (0).is_double_type ())
    			fpm = f_return(0).double_value();
            else {
                error ("numhessian: function must return a scalar of class 'double'");
                return octave_value_list ();
            }

			// -1 +1
			parameter(i) = pi - hi;
			parameter(j) = pj + hj;
			f_args(minarg - 1) = parameter;
			f_return = feval(f, f_args);
		    if (f_return.length () > 0 && f_return (0).is_double_type ())
    			fmp = f_return(0).double_value();
            else {
                error ("numhessian: function must return a scalar of class 'double'");
                return octave_value_list ();
            }

			derivative(j,i) = ((fpp - fpm) + (fmm - fmp)) / (hia * hja);
			derivative(i,j) = derivative(j,i);
			parameter(j) = pj;
		}

		// diagonal elements

		// +1 +1
		parameter(i) = di = pi + 2 * hi;
		f_args(minarg - 1) = parameter;
		f_return = feval(f, f_args);
        if (f_return.length () > 0 && f_return (0).is_double_type ())
    		fpp = f_return(0).double_value();
        else {
            error ("numhessian: function must return a scalar of class 'double'");
            return octave_value_list ();
        }
		hia = (di - pi) / 2;

		// -1 -1
		parameter(i) = di = pi - 2 * hi;
		f_args(minarg - 1) = parameter;
		f_return = feval(f, f_args);
        if (f_return.length () > 0 && f_return (0).is_double_type ())
    		fmm = f_return(0).double_value();
        else {
            error ("numhessian: function must return a scalar of class 'double'");
            return octave_value_list ();
        }
		hia = hia + (pi - di) / 2;

		derivative(i,i) = ((fpp - obj_value) + (fmm - obj_value)) / (hia * hia);
		parameter(i) = pi;
	}

	return octave_value(derivative);
}
