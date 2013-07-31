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

// References:
//
// The code follows the article
// Goffe, William L. (1996) "SIMANN: A Global Optimization Algorithm
//	using Simulated Annealing " Studies in Nonlinear Dynamics & Econometrics
//  	Oct96, Vol. 1 Issue 3.
//
// The code uses the same names for control variables,
// for the most part. A notable difference is that the initial
// temperature is found automatically to ensure that the active
// bounds when the temperature begins to reduce cover the entire
// parameter space (defined as a n-dimensional
// rectangle that is the Cartesian product of the
// (lb_i, ub_i), i = 1,2,..n
//
// Also of note:
// Corana et. al., (1987) "Minimizing Multimodal Functions of Continuous
//	Variables with the "Simulated Annealing" Algorithm",
// 	ACM Transactions on Mathematical Software, V. 13, N. 3.
//
// Goffe, et. al. (1994) "Global Optimization of Statistical Functions
// 	with Simulated Annealing", Journal of Econometrics,
// 	V. 60, N. 1/2.

#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>
#include <octave/oct-rand.h>
#include <float.h>
#include "error.h"

// define argument checks
static bool any_bad_argument(const octave_value_list& args)
{

	// objective function name is a string?
	if (!args(0).is_string()) {
		error("samin: first argument must be string holding objective function name");
		return true;
	}

	// are function arguments contained in a cell?
	if (!args(1).is_cell()) {
		error("samin: second argument must cell array of function arguments");
		return true;
	}

	// is control a cell?
	Cell control (args(2).cell_value());
	if (error_state) {
		error("samin: third argument must cell array of algorithm controls");
		return true;
	}

	// does control have proper number of elements?
	if (!(control.length() == 11)) {
		error("samin: third argument must be a cell array with 11 elements");
		return true;
	}

	// now check type of each element of control
	if (!(control(0).is_real_matrix()) && !(control(0).is_real_scalar())) {
		error("samin: 1st element of controls must be LB: a vector of lower bounds");
		return true;
	}

	if ((control(0).is_real_matrix()) && (control(0).columns() != 1)) {
		error("samin: 1st element of controls must be LB: a vector of lower bounds");
		return true;
	}

	if (!(control(1).is_real_matrix()) && !(control(1).is_real_scalar())) {
		error("samin: 1st element of controls must be UB: a vector of lower bounds");
		return true;
	}

	if ((control(1).is_real_matrix()) && (control(1).columns() != 1)) {
		error("samin: 2nd element of controls must be UB: a vector of lower bounds");
		return true;
	}

	int tmp = control(2).int_value();
	if (error_state || tmp < 1) {
		error("samin: 3rd element of controls must be NT: positive integer\n\
loops per temperature reduction");
		return true;
	}

	tmp = control(3).int_value();
	if (error_state || tmp < 1) {
		error("samin: 4th element of controls must be NS: positive integer\n\
loops per stepsize adjustment");
		return true;
	}

	double tmp2 = control(4).double_value();
	if (error_state || tmp < 0) {
		error("samin: 5th element of controls must be RT:\n\
temperature reduction factor, RT > 0");
		return true;
	}

	tmp2 = control(5).double_value();
	if (error_state || tmp < 0) {
		error("samin: 6th element of controls must be integer MAXEVALS > 0 ");
		return true;
	}

	tmp = control(6).int_value();
	if (error_state || tmp < 0) {
		error("samin: 7th element of controls must be NEPS: positive integer\n\
number of final obj. values that must be within EPS of eachother ");
		return true;
	}

	tmp2 = control(7).double_value();if (error_state || tmp2 < 0) {
		error("samin: 8th element of controls must must be FUNCTOL (> 0)\n\
used to compare the last NEPS obj values for convergence test");
	 	return true;
	}

 	tmp2 = control(8).double_value();
	if (error_state || tmp2 < 0) {
		error("samin: 9th element of controls must must be PARAMTOL (> 0)\n\
used to compare the last NEPS obj values for convergence test");
   		return true;
	}

	tmp = control(9).int_value();
	if (error_state || tmp < 0 || tmp > 2) {
		error("samin: 9th element of controls must be VERBOSITY (0, 1, or 2)");
		return true;
	}

	tmp = control(10).int_value();
	if (error_state || tmp < 0) {
		error("samin: 10th element of controls must be MINARG (integer)\n\
		position of argument to minimize wrt");
		return true;
	}

	// make sure that minarg points to an existing element
	if ((tmp > args(1).length())||(tmp < 1)) {
		error("bfgsmin: 4th argument must be a positive integer that indicates \n\
which of the elements of the second argument is the one minimization is over");
		return true;
	}

	return false;
}

//-------------- The annealing algorithm --------------
DEFUN_DLD(samin, args, , "samin: simulated annealing minimization of a function. See samin_example.m\n\
\n\
usage: [x, obj, convergence, details] = samin(\"f\", {args}, {control})\n\
\n\
Arguments:\n\
* \"f\": function name (string)\n\
* {args}: a cell array that holds all arguments of the function,\n\
* {control}: a cell array with 11 elements\n\
	* LB  - vector of lower bounds\n\
	* UB - vector of upper bounds\n\
	* nt - integer: # of iterations between temperature reductions\n\
	* ns - integer: # of iterations between bounds adjustments\n\
	* rt - (0 < rt <1): temperature reduction factor\n\
	* maxevals - integer: limit on function evaluations\n\
	* neps - integer:  number of values final result is compared to\n\
	* functol -   (> 0): the required tolerance level for function value\n\
	                   comparisons\n\
	* paramtol -  (> 0): the required tolerance level for parameters\n\
	* verbosity - scalar: 0, 1, or 2.\n\
		* 0 = no screen output\n\
		* 1 = only final results to screen\n\
		* 2 = summary every temperature change\n\
	* minarg - integer: which of function args is minimization over?\n\
\n\
Returns:\n\
* x: the minimizer\n\
* obj: the value of f() at x\n\
* convergence:\n\
	0 if no convergence within maxevals function evaluations\n\
	1 if normal convergence to a point interior to the parameter space\n\
	2 if convergence to point very near bounds of parameter space\n\
	  (suggest re-running with looser bounds)\n\
* details: a px3 matrix. p is the number of times improvements were found.\n\
           The columns record information at the time an improvement was found\n\
           * first: cumulative number of function evaluations\n\
           * second: temperature\n\
           * third: function value\n\
\n\
Example: see samin_example\n\
")
{
	int nargin = args.length();
	if (!(nargin == 3)) {
		error("samin: you must supply 3 arguments");
		return octave_value_list();
	}

	// check the arguments
	if (any_bad_argument(args)) return octave_value_list();

	std::string obj_fn (args(0).string_value());
	Cell f_args_cell = args(1).cell_value (); // args to obj fn come in as a cell to allow arbitrary number
	Cell control (args(2).cell_value());

	octave_value_list f_args;
	octave_value_list f_return; // holder for feval returns

	int m, i, j, k, h, n, nacc, func_evals;
	int nup, nrej, nnew, ndown, lnobds;
	int converge, test, coverage_ok;

	// user provided controls
	const ColumnVector lb (control(0).column_vector_value());
	const ColumnVector ub (control(1).column_vector_value());
	const int nt (control(2).int_value());
	const int ns (control(3).int_value());
	const double rt (control(4).double_value());
	const int maxevals (control(5).int_value());
	const int neps (control(6).int_value());
	const double functol (control(7).double_value());
	const double paramtol (control(8).double_value());
	const int verbosity (control(9).int_value());
	const int minarg (control(10).int_value());

	// type checking for minimization parameter done here, since we don't know minarg
	// until now
	if (!(f_args_cell(minarg - 1).is_real_matrix() || (f_args_cell(minarg - 1).is_real_scalar()))) {
		error("samin: minimization must be with respect to a column vector");
		return octave_value_list();
	}
	if ((f_args_cell(minarg - 1).is_real_matrix()) && (f_args_cell(minarg - 1).columns() != 1)) {
        	error("samin: minimization must be with respect to a column vector");
        	return octave_value_list();
	}

	double f, fp, p, pp, fopt, rand_draw, ratio, t;

	Matrix details(1,3); // record function evaluations, temperatures and function values
	RowVector info(3);

	// copy cell contents over to octave_value_list to use feval()
	k = f_args_cell.length();
	f_args(k); // resize only once
	for (i = 0; i<k; i++) f_args(i) = f_args_cell(i);

	ColumnVector x  = f_args(minarg - 1).column_vector_value();
	ColumnVector bounds = ub - lb;
	n = x.rows();
	ColumnVector xopt = x;
	ColumnVector xp(n);
	ColumnVector nacp(n);

	//  Set initial values
	nacc = 0; // total accepted trials
	t = 1000.0; // temperature - will initially rise or fall to cover parameter space. Then it will fall
	converge = 0; // convergence indicator 0 (failure), 1 (normal success), or 2 (convergence but near bounds)
	coverage_ok = 0; // has parameter space been covered? When turns to 1, temperature starts to fall
	// most recent values, to compare to when checking convergend
	ColumnVector fstar(neps,1);
	fstar.fill(DBL_MAX);
	octave_rand::distribution("uniform");  // we'll be using draws from U(0,1)

	// check for out-of-bounds starting values
	for(i = 0; i < n; i++) {
		if(( x(i) > ub(i)) || (x(i) < lb(i))) {
			error("samin: initial parameter %d out of bounds", i+1);
			return octave_value_list();
		}
	}

	// Initial obj_value
	f_return = feval(obj_fn, f_args);
	f = f_return(0).double_value();
	fopt = f; // give it something to compare to
	func_evals = 0; // total function evaluations (limited by maxeval)
	details(0,0) = func_evals;
	details(0,1) = t;
	details(0,2) = fopt;

	// main loop, first increase temperature until parameter space covered, then reduce until convergence
	while(converge==0)
	{
		// statistics to report at each temp change, set back to zero
		nup = 0;
		nrej = 0;
		nnew = 0;
		ndown = 0;
		lnobds = 0;

		// repeat nt times then adjust temperature
		for(m = 0;m < nt;m++) {
			// repeat ns times, then adjust bounds
			for(j = 0;j < ns;j++) {
				// generate new point by taking last and adding a random value
				// to each of elements, in turn
				for(h = 0;h < n;h++) {
					// new Sept 2011, if bounds are same, skip the search for that vbl. Allows restrictions without complicated programming
					if (lb(h) != ub(h)) {
						xp = x;
						rand_draw = octave_rand::scalar();
						xp(h) = x(h) + (2.0 * rand_draw - 1.0) * bounds(h);
						if((xp(h) < lb(h)) || (xp(h) > ub(h))) {
							rand_draw = octave_rand::scalar(); // change 07-Nov-2007: avoid correlation with hitting bounds
							xp(h) = lb(h) + (ub(h) - lb(h)) * rand_draw;
							lnobds = lnobds + 1;
						}
						// Evaluate function at new point
						f_args(minarg - 1) = xp;
						f_return = feval(obj_fn, f_args);
						fp = f_return(0).double_value();
						func_evals = func_evals + 1;
						//  Accept the new point if the function value decreases
						if(fp <= f) {
							x = xp;
							f = fp;
							nacc = nacc + 1; // total number of acceptances
							nacp(h) = nacp(h) + 1; // acceptances for this parameter
							nup = nup + 1;
							//  If lower than any other point, record as new optimum
							if(fp < fopt) {
								xopt = xp;
								fopt = fp;
								nnew = nnew + 1;
								info(0) = func_evals;
								info(1) = t;
								info(2) = fp;
								details = details.stack(info);
							}
						}
						// If the point is higher, use the Metropolis criteria to decide on
						// acceptance or rejection.
						else {
							p = exp(-(fp - f) / t);
							rand_draw = octave_rand::scalar();
							if(rand_draw < p) {
								x = xp;
								f = fp;
								nacc = nacc + 1;
								nacp(h) = nacp(h) + 1;
								ndown = ndown + 1;
							}
							else nrej = nrej + 1;
						}
					}
					// If maxevals exceeded, terminate the algorithm
					if(func_evals >= maxevals) {
						if(verbosity >= 1) {
							printf("\n================================================\n");
							printf("SAMIN results\n");
							printf("NO CONVERGENCE: MAXEVALS exceeded\n");
							printf("================================================\n");
							printf("Convergence tolerances: Func. tol. %e	Param. tol. %e\n", functol, paramtol);
							printf("Obj. fn. value %f\n\n", fopt);
							printf("	   parameter	    search width\n");
							for(i = 0; i < n; i++) printf("%20f%20f\n", xopt(i), bounds(i));
						}
						f_return(3) = details;
						f_return(2) = 0;
						f_return(1) = fopt;
						f_return(0) = xopt;
						return octave_value_list(f_return);
					}
				}
			}
			//  Adjust bounds so that approximately half of all evaluations are accepted
			test = 0;
			for(i = 0;i < n;i++) {
				if (lb(i) != ub(i)) {
					ratio = nacp(i) / ns;
					if(ratio > 0.6) bounds(i) = bounds(i) * (1.0 + 2.0 * (ratio - 0.6) / 0.4);
							else if(ratio < .4) bounds(i) = bounds(i) / (1.0 + 2.0 * ((0.4 - ratio) / 0.4));
					// keep within initial bounds
					if(bounds(i) >= (ub(i) - lb(i))) {
						bounds(i) = ub(i) - lb(i);
						test = test + 1;
					}
				}
				else test = test + 1; // make sure coverage check passes for the fixed parameters
			}
			nacp.fill(0.0);
			// check if we cover parameter space. if we have yet to do so
			if (!coverage_ok) coverage_ok = (test == n);
		}
		// intermediate output, if desired
		if(verbosity == 2) {
			printf("\nsamin: intermediate results before next temperature change\n");
			printf("\ntemperature  %e", t);
			printf("\ncurrent best function value %f", fopt);
			printf("\ntotal evaluations so far %d", func_evals);
			printf("\ntotal moves since last temperature reduction  %d", nup + ndown + nrej);
			printf("\ndownhill  %d", nup);
			printf("\naccepted uphill %d", ndown);
			printf("\nrejected uphill %d", nrej);
			printf("\nout of bounds trials %d", lnobds);
			printf("\nnew minima this temperature %d", nnew);
			printf("\n\n	       parameter	search width\n");
			for(i = 0; i < n; i++) printf("%20f%20f\n", xopt(i), bounds(i));
			printf("\n");
		}
		// Check for convergence, if we have covered the parameter space
		if (coverage_ok) {
			// last value close enough to last neps values?
			fstar(0) = f;
			test = 0;
			for (i = 1; i < neps; i++) test = test + fabs(f - fstar(i)) > functol;
			test = (test > 0); // if different from zero, function conv. has failed
			// last value close enough to overall best?
			if (((fopt - f) <= functol) && (!test)) {
				// check for bound narrow enough for parameter convergence
				for (i = 0;i < n;i++) {
					if (bounds(i) > paramtol) {
						converge = 0; // no conv. if bounds too wide
						break;
					}
					else converge = 1;
				}
			}
			// check if optimal point is near boundary of parameter space, and change convergence message if so
			if (converge) if (lnobds > 0) converge = 2;
			// Like to see the final results?
			if (converge > 0) {
				if (verbosity >= 1) {
					printf("\n================================================\n");
					printf("SAMIN results\n\n");
					if (converge == 1) printf("==> Normal convergence <==\n\n");
					if (converge == 2)
					{
						printf("==> WARNING <==: Last point satisfies convergence criteria,\n");
						printf("but is near boundary of parameter space.\n");
						printf("%d out of  %d evaluations were out-of-bounds in the last round.\n", lnobds, (nup+ndown+nrej));
						printf("Expand bounds and re-run, unless this is a constrained minimization.\n\n");
					}
					printf("Convergence tolerances:\nFunction: %e\nParameters: %e\n", functol, paramtol);
					printf("\nObjective function value at minimum: %f\n\n", fopt);
					printf("	   parameter	    search width\n");
					for(i = 0; i < n; i++) printf("%20f%20f\n", xopt(i), bounds(i));
					printf("================================================\n");
				}
				f_return(3) = details;
				f_return(2) = converge;
				f_return(1) = fopt;
				f_return(0) = xopt;
				return f_return; // this breaks out, if we get here
			}
			// Reduce temperature, record current function value in the
			// list of last "neps" values, and loop again
			t = rt * t;
			for(i = neps-1; i > 0; i--) fstar(i) = fstar(i-1);
			f = fopt;
			x = xopt;
		}
		else { // coverage not ok - increase temperature quickly to expand search area, to cover parameter space
			t = t*t;
			for(i = neps-1; i > 0; i--) fstar(i) = fstar(i-1);
			f = fopt;
			x = xopt;
		}
	}
}
