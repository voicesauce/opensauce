// Copyright (C) 2004,2005,2006,2007,2010 Michael Creel <michael.creel@uab.es>
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

// the functions defined in this file are:
// __bfgsmin_obj: bulletproofed objective function that allows checking for availability of analytic gradient
// __numgradient: numeric gradient, used only if analytic not supplied
// __bisectionstep: fallback stepsize algorithm
// __newtonstep: default stepsize algorithm
// __bfgsmin: the DLD function that does the minimization, to be called from bfgsmin.m

#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>
#include <float.h>
#include "error.h"

int __bfgsmin_obj(double &obj, const std::string f, const octave_value_list f_args, const ColumnVector theta, const int minarg)
{
	octave_value_list f_return, f_args_new;
	int success = 1;
	f_args_new = f_args;
	f_args_new(minarg - 1) = theta;
	f_return = feval(f, f_args_new);
	obj = f_return(0).double_value();
	// bullet-proof the objective function
	if (error_state) {
		warning("__bfgsmin_obj: objective function could not be evaluated - setting to DBL_MAX");
		obj = DBL_MAX;
		success = 0;
	}
	return success;
}


// __numgradient: numeric central difference gradient for bfgs.
// This is the same as numgradient, except the derivative is known to be a vector, it's defined as a column,
// and the finite difference delta is incorporated directly rather than called from a function
int __numgradient(ColumnVector &derivative, const std::string f, const octave_value_list f_args, const int minarg)
{
	double SQRT_EPS, diff, delta, obj_left, obj_right, p;
	int j, test, success;
	ColumnVector parameter = f_args(minarg - 1).column_vector_value();
	int k = parameter.rows();
	ColumnVector g(k);
	SQRT_EPS = sqrt(DBL_EPSILON);
	diff = exp(log(DBL_EPSILON)/3.0);
	 // get 1st derivative by central difference
	for (j=0; j<k; j++) {
		p = parameter(j);
		// determine delta for finite differencing
		test = (fabs(p) + SQRT_EPS) * SQRT_EPS > diff;
		if (test) delta = (fabs(p) + SQRT_EPS) * SQRT_EPS;
		else delta = diff;
		// right side
		parameter(j) = p + delta;
		success = __bfgsmin_obj(obj_right, f, f_args, parameter, minarg);
		if (!success) error("__numgradient: objective function failed, can't compute numeric gradient");
		// left size
		parameter(j) = p - delta;
		success = __bfgsmin_obj(obj_left, f, f_args, parameter, minarg);
		if (!success) error("__numgradient: objective function failed, can't compute numeric gradient");		parameter(j) = p;  // restore original parameter for next round
		g(j) = (obj_right - obj_left) / (2.0*delta);
	}
	derivative = g;
	return success;
}

int __bfgsmin_gradient(ColumnVector &derivative, const std::string f, octave_value_list f_args, const ColumnVector theta, const int minarg, int try_analytic_gradient, int &have_analytic_gradient) {
	octave_value_list f_return;
	int k = theta.rows();
	int success;
	ColumnVector g(k);
	Matrix check_gradient(k,1);
	if (have_analytic_gradient) {
		f_args(minarg - 1) = theta;
		f_return = feval(f, f_args);
		g = f_return(1).column_vector_value();
	}
	else if (try_analytic_gradient) {
		f_args(minarg - 1) = theta;
		f_return = feval(f, f_args);
		if (f_return.length() > 1) {
			if (f_return(1).is_real_matrix()) {
        			if ((f_return(1).rows() == k) & (f_return(1).columns() == 1)) {
					g = f_return(1).column_vector_value();
					have_analytic_gradient = 1;
				}
				else have_analytic_gradient = 0;
			}
			else have_analytic_gradient = 0;
		}
		else have_analytic_gradient = 0;
		if (!have_analytic_gradient) __numgradient(g, f, f_args, minarg);
	}
	else __numgradient(g, f, f_args, minarg);
	// check that gradient is ok
	check_gradient.column(0) = g;
	if (check_gradient.any_element_is_inf_or_nan()) {
		error("__bfgsmin_gradient: gradient contains NaNs or Inf");
		success = 0;
	}
	else success = 1;
	derivative = g;
	return success;
}


// this is the lbfgs direction, used if control has 5 elements
ColumnVector lbfgs_recursion(const int memory, const Matrix sigmas, const Matrix gammas, ColumnVector d)
{
	if (memory == 0) {
    		const int n = sigmas.columns();
    		ColumnVector sig = sigmas.column(n-1);
    		ColumnVector gam = gammas.column(n-1);
    		// do conditioning if there is any memory
    		double cond = gam.transpose()*gam;
    		if (cond > 0)
		{
	  		cond = (sig.transpose()*gam) / cond;
	  		d = cond*d;
		}
   		 return d;
  	}
  	else {
    		const int k = d.rows();
    		const int n = sigmas.columns();
    		int i, j;
    		ColumnVector sig = sigmas.column(memory-1);
    		ColumnVector gam = gammas.column(memory-1);
   	 	double rho;
    		rho = 1.0 / (gam.transpose() * sig);
    		double alpha;
    		alpha = rho * (sig.transpose() * d);
    		d = d - alpha*gam;
    		d = lbfgs_recursion(memory - 1, sigmas, gammas, d);
    		d = d + (alpha - rho * gam.transpose() * d) * sig;
  	}
  	return d;
}

// __bisectionstep: fallback stepsize method if __newtonstep fails
int __bisectionstep(double &step, double &obj, const std::string f, const octave_value_list f_args, const ColumnVector x, const ColumnVector dx, const int minarg, const int verbose)
{
	double best_obj, improvement, improvement_0;
	int found_improvement;
	ColumnVector trial;
	// initial values
	best_obj = obj;
        improvement_0 = 0.0;
	step = 1.0;
	trial = x + step*dx;
	__bfgsmin_obj(obj, f, f_args, trial, minarg);
	if (verbose) printf("bisectionstep: trial step: %g  obj value: %g\n", step, obj);
	// this first loop goes until an improvement is found
	while (obj >= best_obj) {
		if (step < 2.0*DBL_EPSILON) {
			if (verbose) warning("bisectionstep: unable to find improvement, setting step to zero");
			step = 0.0;
			return 0;
		}
		step = 0.5*step;
		trial = x + step*dx;
		__bfgsmin_obj(obj, f, f_args, trial, minarg);
		if (verbose) printf("bisectionstep: trial step: %g  obj value: %g  best_value: %g\n", step, obj, best_obj);
	}
	// now keep going until rate of improvement is too low, or reach max trials
	best_obj = obj;
	while (step > 2.0*DBL_EPSILON) {
		step = 0.5*step;
		trial = x + step*dx;
		__bfgsmin_obj(obj, f, f_args, trial, minarg);
		if (verbose) printf("bisectionstep: trial step: %g  obj value: %g\n", step, obj);
		// if improved, record new best and try another step
		if (obj < best_obj) {
			improvement = best_obj - obj;
			best_obj = obj;
			if (improvement > 0.5*improvement_0) {
				improvement_0 = improvement;
			}
			else break;
		}
		else {
			step = 2.0*step; // put it back to best found
			obj = best_obj;
			break;
		}
	}
	return 1;
}

// __newtonstep: default stepsize algorithm
int __newtonstep(double &step, double &obj, const std::string f, const octave_value_list f_args, const ColumnVector x, const ColumnVector dx, const int minarg, const int verbose)
{
	double obj_0, obj_left, obj_right, delta, inv_delta_sq, gradient, hessian;
	int found_improvement = 0;
	obj_0 = obj;
	delta = 0.001; // experimentation shows that this is a good choice
	inv_delta_sq = 1.0 / (delta*delta);
	ColumnVector x_right = x + delta*dx;
	ColumnVector x_left = x  - delta*dx;
	// right
	__bfgsmin_obj(obj_right, f, f_args, x_right, minarg);
	// left
	__bfgsmin_obj(obj_left, f, f_args, x_left, minarg);
	gradient = (obj_right - obj_left) / (2.0*delta);  // take central difference
	hessian =  inv_delta_sq*(obj_right - 2.0*obj_0 + obj_left);
	hessian = fabs(hessian); // ensures we're going in a decreasing direction
	if (hessian < 2.0*DBL_EPSILON) hessian = 1.0; // avoid div by zero
	step = - gradient / hessian;  // hessian inverse gradient: the Newton step
//	step = (step < 1.0)*step + 1.0*(step >= 1.0); // maximum stepsize is 1.0 - conservative
	// ensure that this is improvement, and if not, fall back to bisection
	__bfgsmin_obj(obj, f, f_args, x + step*dx, minarg);
        if (verbose) printf("newtonstep: trial step: %g  obj value: %g\n", step, obj);
        if (obj > obj_0) {
		obj = obj_0;
	        if (verbose) warning("__stepsize: no improvement with Newton step, falling back to bisection");
		found_improvement = __bisectionstep(step, obj, f, f_args, x, dx, minarg, verbose);
	}
	else found_improvement = 1;
	if (xisnan(obj)) {
		obj = obj_0;
		if (verbose) warning("__stepsize: objective function crash in Newton step, falling back to bisection");
		found_improvement = __bisectionstep(step, obj, f, f_args, x, dx, minarg, verbose);
	}
	else found_improvement = 1;
	return found_improvement;
}

DEFUN_DLD(__bfgsmin, args, ,"__bfgsmin: backend for bfgs minimization\n\
Users should not use this directly. Use bfgsmin.m instead") {
	std::string f (args(0).string_value());
  	Cell f_args_cell (args(1).cell_value());
	octave_value_list f_args, f_return; // holder for return items

	int max_iters, verbosity, criterion, minarg, convergence, iter, memory, \
		gradient_ok, i, j, k, conv_fun, conv_param, conv_grad, have_gradient, \
		try_gradient, warnings;
	double func_tol, param_tol, gradient_tol, stepsize, obj_value, obj_in, \
		last_obj_value, obj_value2, denominator, test;
	Matrix H, H1, H2;
	ColumnVector thetain, d, g, g_new, p, q, sig, gam;

	// controls
	Cell control (args(2).cell_value());
	max_iters = control(0).int_value();
	if (max_iters == -1) max_iters = INT_MAX;
	verbosity = control(1).int_value();
	criterion = control(2).int_value();
	minarg = control(3).int_value();
	memory = control(4).int_value();
	func_tol = control(5).double_value();
	param_tol = control(6).double_value();
	gradient_tol = control(7).double_value();

	// want to see warnings?
	warnings = 0;
	if (verbosity == 3) warnings = 1;

	// copy cell contents over to octave_value_list to use feval()
	k = f_args_cell.length();
	f_args(k); // resize only once
	for (i = 0; i<k; i++) f_args(i) = f_args_cell(i);

	// get the minimization argument
	ColumnVector theta  = f_args(minarg - 1).column_vector_value();
	k = theta.rows();

	// containers for items in limited memory version
	Matrix sigmas(k, memory);
	Matrix gammas(k, memory);
	sigmas.fill(0.0);
	gammas.fill(0.0);

	// initialize things
	have_gradient = 0; // have analytic gradient
	try_gradient = 1;  // try to get analytic gradient
	convergence = -1; // if this doesn't change, it means that maxiters were exceeded
	thetain = theta;
	H = identity_matrix(k,k);

	// Initial obj_value
	__bfgsmin_obj(obj_in, f, f_args, theta, minarg);
	if (warnings) printf("initial obj_value %g\n", obj_in);

	// Initial gradient (try analytic, and use it if it's close enough to numeric)
	__bfgsmin_gradient(g, f, f_args, theta, minarg, 1, have_gradient);	// try analytic
        if (have_gradient) {					// check equality if analytic available
		if (warnings) printf("function claims to provide analytic gradient\n");
		have_gradient = 0;				// force numeric
		__bfgsmin_gradient(g_new, f, f_args, theta, minarg, 0, have_gradient);
		p = g - g_new;
		have_gradient = sqrt(p.transpose() * p) < gradient_tol;
		if (have_gradient && warnings) printf("function claims to provide analytic gradient, and it agrees with numeric - using analytic\n");
		if (!have_gradient && warnings) printf("function claims to provide analytic gradient, but it does not agree with numeric - using numeric\n");
	}

	last_obj_value = obj_in; // initialize, is updated after each iteration
	// MAIN LOOP STARTS HERE
	for (iter = 0; iter < max_iters; iter++) {
    		if(memory > 0) {  // lbfgs
			if (iter < memory) d = lbfgs_recursion(iter, sigmas, gammas, g);
			else d = lbfgs_recursion(memory, sigmas, gammas, g);
			d = -d;
		}
		else d = -H*g; // ordinary bfgs
        	// convergence tests
		conv_fun = 0;
		conv_param = 0;
		conv_grad = 0;
		// function convergence
                p = theta+d;
		__bfgsmin_obj(obj_value, f, f_args, p, minarg);
                if (fabs(last_obj_value) > 1.0)	conv_fun=(fabs((obj_value/last_obj_value-1)))<func_tol;
		else conv_fun = fabs(obj_value - last_obj_value) < func_tol;
       		// parameter change convergence
		test = sqrt(theta.transpose() * theta);
		if (test > 1.0) conv_param = sqrt(d.transpose() * d) / test < param_tol ;
		else conv_param = sqrt(d.transpose() * d) < param_tol;		// Want intermediate results?
                // gradient convergence
		conv_grad = sqrt(g.transpose() * g) < gradient_tol;
                // Are we done?
		if (criterion == 1) {
			if (conv_fun && conv_param && conv_grad) {
				convergence = 1;
				break;
			}
		}
		else if (conv_fun) {
			convergence = 1;
			break;
		}
                // if not done, then take a step
		// stepsize: try (l)bfgs direction, then steepest descent if it fails
		f_args(minarg - 1) = theta;
                obj_value = last_obj_value;
		__newtonstep(stepsize, obj_value, f, f_args, theta, d, minarg, warnings);
		if (stepsize == 0.0)  {  // fall back to steepest descent
			if (warnings) warning("bfgsmin: BFGS direction fails, switch to steepest descent");
			d = -g; // try steepest descent
			H = identity_matrix(k,k); // accompany with Hessian reset, for good measure
			obj_value = last_obj_value;
			__newtonstep(stepsize, obj_value, f, f_args, theta, d, minarg, warnings);
			if (stepsize == 0.0) {  // if true, exit, we can't find a direction of descent
				warning("bfgsmin: failure, exiting. Try different start values?");
				f_return(0) = theta;
				f_return(1) = obj_value;
				f_return(2) = -1;
				f_return(3) = iter;
				return octave_value_list(f_return);
			}
		}
		p = stepsize*d;
                // Want intermediate results?
		if (verbosity > 1) {
			printf("------------------------------------------------\n");
			printf("bfgsmin iteration %d  convergence (f g p): %d %d %d\n", iter, conv_fun, conv_grad, conv_param);
			if (warnings) {
				if (memory > 0) printf("Using LBFGS, memory is last %d iterations\n",memory);
			}
			printf("\nfunction value: %g  stepsize: %g  \n\n", last_obj_value, stepsize);
			if (have_gradient) printf("used analytic gradient\n");
			else printf("used numeric gradient\n");
			for (j = 0; j<k; j++) printf("%15.5f %15.5f %15.5f\n",theta(j), g(j), p(j));
		}
		//--------------------------------------------------
		// // Are we done?
		// if (criterion == 1) {
		// 	if (conv_fun && conv_param && conv_grad) {
		// 		convergence = 1;
		// 		break;
		// 	}
		// }
		// else if (conv_fun) {
		// 	convergence = 1;
		// 	break;
		// }
		//-------------------------------------------------- 
		last_obj_value = obj_value;
		theta = theta + p;
		// new gradient
		gradient_ok = __bfgsmin_gradient(g_new, f, f_args, theta, minarg, try_gradient, have_gradient);
		if (memory == 0) {  //bfgs?
			// Hessian update if gradient ok
			if (gradient_ok) {
				q = g_new-g;
				g = g_new;
				denominator = q.transpose()*p;
				if ((fabs(denominator) < DBL_EPSILON)) {  // reset Hessian if necessary
					if (verbosity == 1) printf("bfgsmin: Hessian reset\n");
					H = identity_matrix(k,k);
				}
				else {
					H1 = (1.0+(q.transpose() * H * q) / denominator) / denominator \
					* (p * p.transpose());
					H2 = (p * q.transpose() * H + H*q*p.transpose());
					H2 = H2 / denominator;
					H = H + H1 - H2;
				}
			}
			else H = identity_matrix(k,k); // reset hessian if gradient fails
			// then try to start again with steepest descent
		}
		else {  // otherwise lbfgs
			// save components for Hessian if gradient ok
			if (gradient_ok) {
				sig = p; // change in parameter
				gam = g_new - g; // change in gradient
				g = g_new;
				// shift remembered vectors to the right (forget last)
				for(j = memory - 1; j > 0; j--) {
					for(i = 0; i < k; i++) 	{
						sigmas(i,j) = sigmas(i,j-1);
						gammas(i,j) = gammas(i,j-1);
					}
				}
				// insert new vectors in left-most column
				for(i = 0; i < k; i++) {
					sigmas(i, 0) = sig(i);
					gammas(i, 0) = gam(i);
				}
			}
			else { // failed gradient - loose memory and use previous theta
				sigmas.fill(0.0);
				gammas.fill(0.0);
				theta = theta - p;
			}
		}
	}
	// Want last iteration results?
	if (verbosity > 0) {
		printf("------------------------------------------------\n");
		printf("bfgsmin final results: %d iterations\n", iter);
		if (warnings) {
			if (memory > 0) printf("Used LBFGS, memory is last %d iterations\n",memory);
		}
		printf("\nfunction value: %g\n\n", obj_value);
		if (convergence == -1)                      printf("NO CONVERGENCE: max iters exceeded\n");
		if ((convergence == 1) & (criterion == 1))  printf("STRONG CONVERGENCE\n");
		if ((convergence == 1) & !(criterion == 1)) printf("WEAK CONVERGENCE\n");
		if (convergence == 2)                       printf("NO CONVERGENCE: algorithm failed\n");
		printf("Function conv %d  Param conv %d  Gradient conv %d\n\n", conv_fun, conv_param, conv_grad);
		if (have_gradient) printf("used analytic gradient\n");
		else printf("used numeric gradient\n");
		printf("          param    gradient (n)          change\n");
		for (j = 0; j<k; j++) printf("%15.5f %15.5f %15.5f\n",theta(j), g(j), d(j));
	}
	f_return(3) = iter;
	f_return(2) = convergence;
	f_return(1) = obj_value;
	f_return(0) = theta;
	return f_return;
}
