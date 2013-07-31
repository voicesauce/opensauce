function [x, fval, exitflag, output] = fminsearchbnd2(fun, x0, LB, UB, options, varargin)
	% fun = function to minimize
	% x0 = starting point
	% LB = lower bound vector, must be same size as x0
	% UB = upper bound vector, must be same size as X0
	% options = optimization parameters
	% Notes:
	% Variables constrained by both an upper and lower bound will
	% use a sin transformation. 

	exitflag = 0; %TODO
	output = 0; %TODO

	% check size of input
	xsize = size(x0);
	x0 = x0(:); % make a copy
	n = length(x0);
	%%printf('fmsb: size of x0: %d\n', n);

	assert (nargin > 3, 'no lower bound');
	LB = LB(:);
	assert (nargin >= 4, 'no upper bound');
	UB = UB(:);

	assert (n == length(LB), 'x0 wrong size -- doesnt match LB');
	assert (n == length(UB), 'x0 wrong size -- doesnt match UB');

	if (nargin < 5 || isempty(options))
		%%printf('fmsb: assign default options.\n');
		% values from http://ab-initio.mit.edu/octave-Faddeeva/scripts/optimization/fminsearch.m
		options = optimset("Display", "notify", ...
						"FunValCheck", "off", ...
                  		"MaxFunEvals", 400, ...
                  		"MaxIter", 400, ...
                  		"OutputFcn", [], ...
                  		"TolFun", 1e-7, ...
                  		"TolX", 1e-4);

	end

	params.args = varargin;
	params.LB = LB;
	params.UB = UB;
	params.fun = fun;
	params.n = n;
	params.OutputFcn = [];

	params.BoundClass = zeros(n, 1);
	for i = 1:n
		k = isfinite(LB(i)) + 2*isfinite(UB(i));
		%%printf('fmsb: k=%d\n', k);
		params.BoundClass(i) = k;
		if (k==3) && (LB(i) == UB(i))
			params.BoundClass(i) = 4;
	end

	%printf('fmsb: params.BoundClass = %d\n', params.BoundClass);

	% transform starting values into their unconstrained
	% surrogates. Check for infeasible starting guesses.
	x0u = x0;
	k = 1;
	for i = 1:n
		switch params.BoundClass(i)
		case 1
			%printf('LB only\n');
			k = k + 1;
		case 2
			%printf('UB only\n');
			k=k+1;
		case 3
			%printf('fmsb: lower & upper bounds\n');
			if x0(i) <= LB(i) %infeasible starting value
				x0u(k) = -pi/2;
			elseif x0(i) >= UB(i) % infeasible starting value
				x0u(k) = pi/2;
			else
				x0u(k) = 2*(x0(i) - LB(i))/(UB(i)-LB(i))-1;
				%shift by 2*pi to avoid problems at zero in fminsearch
				% otherwise the initial simplex is vanishingly small
				x0u(k) = 2 * pi + asin(max(-1, min(1, x0u(k))));
			end
			k=k+1;
		case 0
			%printf('unconstrained variable\n');
			k=k+1;
		case 4
			%printf('fixed variable');
		end
	end

	%printf('fmsb: LB=%d; UB=%d\n', LB, UB);

	% if any of the uknowns were fixed, then we need to shortend
	% x0u now

	if (k <= n)
		%printf('need to shorten x0u\n');
		x0u(k:n) = [];
	end

	% were all the variables fixed?
	if isempty(x0u)
		% this should be unreachable in this context
		%printf('fmsb: all variables were fixed, set params and return\n');
		x = xtransform(x0u, params);
		x = reshape(x, xsize);
		fval = feval(params.fun, x, params.args{:});
		exitflag = 0;
		output.iterations = 0;
		output.funcount = 1;
		output.algorithm = 'fminsearch';
		output.message = 'all variables were held fixed by the applied bounds';
		return;
	end

	% check for an outputfcn. if there is one, then substitute
	% own wrapper function
	if ~isempty(options.OutputFcn)
		% unreachable?
		%printf('TODO OutputFcn not empty, wrapping it\n');
		%params.OutputFcn = options.OutputFcn;
		%options.OutputFcn = @outfun_wrapper;
	end

	%printf('fmsb: calling fminsearch\n');

	[xu, fval] = fminsearch3(@intrafun, x0u, options, params);

	%printf('fmsb: fminsearch returned, continuing\n');

	x = xtransform(xu, params);
	x = reshape(x, xsize);


end

	function fval = intrafun(x, params)
		% transform variables, then call original function
		%printf('intrafun called\n');
		xtrans = xtransform(x, params);
		fval = feval(params.fun, xtrans, params.args{:});
	end %end subfunction

	%end %endfunction

	function xtrans = xtransform(x, params)
		%printf('xtransform called\n');
		% converts unconstrained variables into their original domains
		xtrans = zeros(1, params.n);

		%k allows some variables to be fixed, thus dropped from the
		% optimization
		k = 1;
		for i = 1:params.n
			switch params.BoundClass(i)
			case 1
				%printf('xtrans case 1');
				k=k+1;
			case 2
				%printf('xtrans case 2');
				k=k+1;
			case 3
				%printf('upper && lower bound');
				xtrans(i) = (sin(x(k))+1)/2;
				xtrans(i) = xtrans(i) * (params.UB(i) - params.LB(i)) + params.LB(i);
				% just in case of any floating point problems
				xtrans(i) = max(params.LB(i), min(params.UB(i), xtrans(i)));
				k=k+1;
			case 4
				%printf('xtrans case 4');
				k+1;
			end %endswitch
		end %endfor
	end %endfunction







end