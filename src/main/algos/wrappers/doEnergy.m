function err = doEnergy(settings, instance)
	printf('Energy ...\n');
	% user settings
	F0algorithm = settings.F0algorithm;
	% instance data
	matfile = instance.mfile;
	Fs = instance.Fs;
	y = instance.y;
	err = 0;
	matdata = load(matfile);
	F0 = func_parseF0(matdata, F0algorithm);
	assert(length(F0)>0);
	try
		Energy = func_GetEnergy(y, F0, Fs, settings);
	catch
		err = 1;
	end
	assert (err == 0, 'Error: Energy');
	save(matfile, 'Energy', '-append', '-v4');
end