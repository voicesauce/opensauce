function err = doSHR(settings, instance)
	printf('Subharmonic to Harmonic Ratio - SHR ...\n');
	% instance data
	matfile = instance.mfile;
	y = instance.y;
	Fs = instance.Fs;
	data_len = instance.data_len;
	err = 0;
	matdata = load(matfile);
	try
		[SHR, shrF0] = func_GetSHRP(y, Fs, settings, data_len);
	catch
		err = 1;
	end
	assert (err == 0, 'TODO: SHR');
	save(matfile, 'SHR', '-append', '-v4');
end