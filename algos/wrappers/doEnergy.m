function err = doEnergy(settings, instance)
	fprintf('\n\t ==> Energy ...');

	% user settings
	F0algorithm = settings.F0algorithm;

	% instance data
	matfile = instance.mfile;
	Fs = instance.Fs;
	y = instance.y;

	err = 0;

	matdata = load(matfile);
	F0 = func_parseF0(matdata, F0algorithm);

	try
		Energy = func_GetEnergy(y, F0, Fs, settings);
	catch
		err = 1;
	end

	assert (err == 0, 'Error: Energy');

	save(matfile, 'Energy', '-append', '-v4');

end