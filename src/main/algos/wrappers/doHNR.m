function err = doHNR(settings, instance)
	printf('Harmonic to Noise Ratios - HNR ...\n');
	F0algorithm = settings.F0algorithm;
	matfile = instance.mfile;
	y = instance.y;
	Fs = instance.Fs;
	err = 0;
	matdata = load(matfile);
	F0 = func_parseF0(matdata, F0algorithm);
	assert(length(F0)>0);
	try
		[HNR05, HNR15, HNR25, HNR35] = func_GetHNR(y, Fs, F0, settings);
	catch
		err = 1;
	end
	assert (err == 0, 'doHNR : error : something went wrong with HNR');
	save(matfile, 'HNR05', 'HNR15', 'HNR25', 'HNR35', '-append', '-v4');
end