function [x, fval, exitflag, output] = fminsearch3(fun, x0, options, params, varargin)
	% find the minimum of a function of several variables
	% default is Nelder&Mead Simplex Algorithm

  %printf('fminsearch3 called\n');
  exitflag = 0;
  output = 0;

  assert (nargin > 2, 'fminsearch usage error.');

  x = nmsmax2(fun, x0, options, params);

  if (isargout(2))
  	fval = feval(fun, x, params);
  end
end %endfunction


function [stopit, savit, dirn, trace, tol, maxiter] = parse_options(options, x)
	% tolerance for cgce test based on relative size of simplex
	stopit(1) = tol = optimget(options, 'TolX', 1e-4);

	% max no. of f-evaluations
	stopit(2) = optimget(options, 'MaxFunEvals', length(x) * 200);

	% max no. of iterations
	maxiter = optimget(options, 'MaxIter', length(x) * 200);

	% default target for f-values
	stopit(3) = Inf;

	% default initial simplex
	stopit(4) = 0;

	% default: show progress
	display = optimget(options, 'Display', 'notify');
	if (strcmp (display, 'iter'))
		stopit(5) = 1;
	else
		stopit(5) = 0;
	end
	trace = stopit(5);

	% use function to minimize, not maximize
	stopit(6) = dirn = -1;

	% file name for snapshots
	savit = [];
end %endfunction

% NMSMAX - Nelder-Mead simplex method for direct search optimization
function [x, fmax, nf] = nmsmax2(fun, x, options, params, varargin)
	%printf('nmsmax2 called\n');

	[stopit, savit, dirn, trace, tol, maxiter] = parse_options(options, x);

	if (strcmpi (optimget (options, 'FunValCheck', 'off'), 'on'))
		% replace fcn with a guarded version
		fun = @(x) guarded_eval(fun, x, params);
	end

	x0 = x(:); % work with column vector internally
	n = length(x0);

	V = [zeros(n, 1) eye(n)];
	f = zeros(n+1, 1);
	V(:, 1) = x0;
	f(1) = dirn * feval(fun, x, params, varargin{:});
	fmax_old = f(1);

	if (trace)
		fprintf('f(x0) = %9.4e\n', f(1));
	end

	k = 0; m = 0;


  % Set up initial simplex.
  scale = max (norm (x0,Inf), 1);
  if (stopit(4) == 0)
    % Regular simplex - all edges have same length.
    % Generated from construction given in reference [18, pp. 80-81] of [1].
    alpha = scale / (n*sqrt (2)) * [sqrt(n+1)-1+n, sqrt(n+1)-1];
    V(:,2:n+1) = (x0 + alpha(2)*ones (n,1)) * ones (1,n);
    for j = 2:n+1
      V(j-1,j) = x0(j-1) + alpha(1);
      x(:) = V(:,j);
      f(j) = dirn * feval (fun,x,params,varargin{:});
    end
  else
    % Right-angled simplex based on co-ordinate axes.
    alpha = scale * ones(n+1,1);
    for j=2:n+1
      V(:,j) = x0 + alpha(j)*V(:,j);
      x(:) = V(:,j);
      f(j) = dirn * feval (fun, x, params, varargin{:});
    end
  end
  nf = n+1;
  how = 'initial  ';

  [~,j] = sort (f);
  j = j(n+1:-1:1);
  f = f(j);
  V = V(:,j);

  alpha = 1;  beta = 1/2;  gamma = 2;

  while (1)   % Outer (and only) loop.
    k++;

    if (k > maxiter)
      msg = 'Exceeded maximum iterations...quitting\n';
      break;
    end

    fmax = f(1);
    if (fmax > fmax_old)
      if (! isempty (savit))
        x(:) = V(:,1);
        eval (['save ' savit ' x fmax nf']);
      end
    end
    if (trace)
      fprintf ('Iter. %2.0f,', k);
      fprintf (['  how = ' how '  ']);
      fprintf ('nf = %3.0f,  f = %9.4e  (%2.1f%%)\n', nf, fmax, ...
               100*(fmax-fmax_old)/(abs(fmax_old)+eps));
    end
    fmax_old = fmax;

    % Three stopping tests from MDSMAX.M

    % Stopping Test 1 - f reached target value?
    if (fmax >= stopit(3))
      msg = 'Exceeded target...quitting\n';
      break;
    end

    % Stopping Test 2 - too many f-evals?
    if (nf >= stopit(2))
      msg = 'Max no. of function evaluations exceeded...quitting\n';
      break;
    end

    % Stopping Test 3 - converged?   This is test (4.3) in [1].
    v1 = V(:,1);
    size_simplex = norm (V(:,2:n+1)-v1(:,ones (1,n)),1) / max (1, norm (v1,1));
    if (size_simplex <= tol)
      msg = sprintf ('Simplex size %9.4e <= %9.4e...quitting\n', ...
                      size_simplex, tol);
      break;
    end %endif

    % ##  One step of the Nelder-Mead simplex algorithm
    % ##  NJH: Altered function calls and changed CNT to NF.
    % ##       Changed each 'fr < f(1)' type test to '>' for maximization
    % ##       and re-ordered function values after sort.

    vbar = (sum (V(:,1:n)')/n)';  % Mean value
    vr = (1 + alpha)*vbar - alpha*V(:,n+1);
    x(:) = vr;
    fr = dirn * feval (fun,x,params,varargin{:});
    nf = nf + 1;
    vk = vr;  fk = fr; how = "reflect, ";
    if (fr > f(n))
      if (fr > f(1))
        ve = gamma*vr + (1-gamma)*vbar;
        x(:) = ve;
        fe = dirn * feval (fun,x,params,varargin{:});
        nf = nf + 1;
        if (fe > f(1))
          vk = ve;
          fk = fe;
          how = "expand,  ";
        end %endif
      end %endif
    else
      vt = V(:,n+1);
      ft = f(n+1);
      if (fr > ft)
        vt = vr;
        ft = fr;
      end %endif
      vc = beta*vt + (1-beta)*vbar;
      x(:) = vc;
      fc = dirn * feval (fun,x,params,varargin{:});
      nf = nf + 1;
      if (fc > f(n))
        vk = vc; fk = fc;
        how = 'contract,';
      else
        for j = 2:n
          V(:,j) = (V(:,1) + V(:,j))/2;
          x(:) = V(:,j);
          f(j) = dirn * feval (fun,x,params,varargin{:});
        end %endfor
        nf = nf + n-1;
        vk = (V(:,1) + V(:,n+1))/2;
        x(:) = vk;
        fk = dirn * feval (fun,x,params,varargin{:});
        nf = nf + 1;
        how = 'shrink,  ';
      end %endif
    end %endif
    V(:,n+1) = vk;
    f(n+1) = fk;
    [~,j] = sort(f);
    j = j(n+1:-1:1);
    f = f(j);
    V = V(:,j);

  end %endwhile   # End of outer (and only) loop.

  %## Finished.
  if (trace)
    fprintf (msg);
  endif
  x(:) = V(:,1);

end %endfunction

% A helper function that evaluates a function and checks for bad results.
function y = guarded_eval (fun, x, params)

  y = fun (x, params);

  if (! (isreal (f)))
    error ('fminsearch:notreal', 'fminsearch: non-real value encountered');
  elseif (any (isnan (f(:))))
    error ('fminsearch:isnan', 'fminsearch: NaN value encountered');
  elseif (any (isinf (f(:))))
    error ('fminsearch:isinf', 'fminsearch: Inf value encountered');
  end %endif

end %endfunction






