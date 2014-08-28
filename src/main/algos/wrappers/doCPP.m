function err = doCPP(settings, instance)
	printf('CPP ...\n');

	% user settings
	F0algorithm = settings.F0algorithm;

	% instance data
	matfile = instance.mfile;
	Fs = instance.Fs;
	y = instance.y;

	assert (exist(matfile, 'file') ~= 0, 'no matfile found');
	assert (Fs > 0, 'bad Fs');
	assert (length(y) > 0, 'bad y vector');

	err = 0;

	matdata = load(matfile);
	F0 = func_parseF0(matdata, F0algorithm);

	assert(length(F0)>0);

	try
		CPP = func_GetCPP(y, Fs, F0, settings);
	catch
		err = 1;
	end

	assert (err == 0, 'Error: CPP');

	save(matfile, 'CPP', '-append', '-v4');

end %endfunction