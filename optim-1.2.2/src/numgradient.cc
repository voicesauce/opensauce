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

// numgradient: numeric central difference gradient

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
		error("numgradient: first argument must be string holding objective function name");
		return true;
	}

	if (!args(1).is_cell())
	{
		error("numgradient: second argument must cell array of function arguments");
		return true;
	}

	// minarg, if provided
	if (args.length() == 3)
	{
		int tmp = args(2).int_value();
		if (error_state)
		{
			error("numgradient: 3rd argument, if supplied,  must an integer\n\
that specifies the argument wrt which differentiation is done");
			return true;
		}
		if ((tmp > args(1).length())||(tmp < 1))
		{
			error("numgradient: 3rd argument must be a positive integer that indicates \n\
which of the elements of the second argument is the\n\
one to differentiate with respect to");
			return true;
		}
	}
	return false;
}


DEFUN_DLD(numgradient, args, , "numgradient(f, {args}, minarg)\n\
\n\
Numeric central difference gradient of f with respect\n\
to argument \"minarg\".\n\
* first argument: function name (string)\n\
* second argument: all arguments of the function (cell array)\n\
* third argument: (optional) the argument to differentiate w.r.t.\n\
	(scalar, default=1)\n\
\n\
\"f\" may be vector-valued. If \"f\" returns\n\
an n-vector, and the argument is a k-vector, the gradient\n\
will be an nxk matrix\n\
\n\
Example:\n\
function a = f(x);\n\
	a = [x'*x; 2*x];\n\
endfunction\n\
numgradient(\"f\", {ones(2,1)})\n\
ans =\n\
\n\
  2.00000  2.00000\n\
  2.00000  0.00000\n\
  0.00000  2.00000\n\
")
{
	int nargin = args.length();
	if (!((nargin == 2)|| (nargin == 3))) {
		error("numgradient: you must supply 2 or 3 arguments");
		return octave_value_list();
	}

	// check the arguments
	if (any_bad_argument(args)) return octave_value_list();

	std::string f (args(0).string_value());
	Cell f_args_cell (args(1).cell_value());
	octave_value_list f_args, f_return;
	Matrix obj_value, obj_left, obj_right;
	double SQRT_EPS, p, delta, diff;
	int i, j, k, n, minarg, test;

	// Default values for controls
	minarg = 1; // by default, first arg is one over which we minimize

	// copy cell contents over to octave_value_list to use feval()
	k = f_args_cell.length();
	f_args(k); // resize only once
	for (i = 0; i<k; i++) f_args(i) = f_args_cell(i);

	// check which arg w.r.t which we need to differentiate
	if (args.length() == 3) minarg = args(2).int_value();
	Matrix parameter = f_args(minarg - 1).matrix_value();

	// initial function value
	f_return = feval(f, f_args);
	obj_value = f_return(0).matrix_value();

	n = obj_value.rows(); // find out dimension
	k = parameter.rows();
	Matrix derivative(n, k);
	Matrix columnj;

	for (j=0; j<k; j++) { // get 1st derivative by central difference
		p = parameter(j);

		// determine delta for finite differencing
		SQRT_EPS = sqrt(DBL_EPSILON);
		diff = exp(log(DBL_EPSILON)/3);
		test = (fabs(p) + SQRT_EPS) * SQRT_EPS > diff;
		if (test) delta = (fabs(p) + SQRT_EPS) * SQRT_EPS;
		else delta = diff;

		// right side
		parameter(j) = p + delta;
		f_args(minarg - 1) = parameter;
		f_return = feval(f, f_args);
		obj_right = f_return(0).matrix_value();

		// left size
		parameter(j) = p - delta;
		f_args(minarg - 1) = parameter;
		f_return = feval(f, f_args);
		obj_left = f_return(0).matrix_value();

		parameter(j) = p;  // restore original parameter
		columnj = (obj_right - obj_left) / (2*delta);
		for (i=0; i<n; i++) derivative(i, j) = columnj(i);
	}

	return octave_value(derivative);
}
