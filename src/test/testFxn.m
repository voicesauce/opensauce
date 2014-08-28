function testFxn(s)
	err = 0;
	%warning off;
	%err = err + test_Energy(s);
	err = err + test_CPP(s);
	found = 0;

	matdata = load(s.matfile);
	for k=1:length(matdata.CPP)
		if (~isnan(matdata.CPP(k)))
			found = 1;
			x = sprintf('found some non-NaN value @ [%d]\n', k);
			disp(x);
			break;
		end
	end

	if (found == 0)
		x = sprintf('no non-NaN value found\n');
		disp(x);
	end

	if (err > 0)
		printf('err > 0\n');
	end
end

function err = test_CPP(settings)
	[err, CPP] = doCPP(settings);
	assert (err == 0, 'error in doCPP\n');

	% n = length(CPP);
	% nans = 0;
	% for k=1:n
	% 	if (~isnan(CPP(n)))
	% 		printf('%s ,', CPP(n));
	% 	else
	% 		nans = nans + 1;
	% 	end
	% end

	% if (nans == n)
	% 	printf('All CPP values are NaN\n');
	% 	err = err + 1;
	% end
end

function err = test_Energy(settings)
	[err, energy] = doEnergy(settings);
	assert (err == 0, 'err in energy');

	% n = length(energy);
	% nans = 0;

	% for k=1:n
	% 	if (~isnan(energy(n)))
	% 		x = sprintf(' %.4f , ', energy(n));
	% 		disp(x);
	% 	else
	% 		nans = nans + 1;
	% 	end
	% end

	% if (nans == n)
	% 	x = sprintf('All Energy values are NaN\n');
	% 	disp(x);
	% 	err = err + 1;
	% end
end









