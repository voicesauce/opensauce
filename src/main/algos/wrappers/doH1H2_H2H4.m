function err = doH1H2_H2H4(settings, instance)
	printf('H1*-H2*, H2*-H4* ...\n');
	% user settings
	F0algorithm = settings.F0algorithm;
	FMTalgorithm = settings.FMTalgorithm;
	% instance data
	matfile = instance.mfile;
	Fs = instance.Fs;
	err = 0;
	matdata = load(matfile);
	F0 = func_parseF0(matdata, F0algorithm);
	[F1, F2, F3] = func_parseFMT(matdata, FMTalgorithm);
	assert(length(F0)>0);
	assert(length(F1)>0 && length(F2)>0 && length(F3)>0);
	try
		[H1H2c, H2H4c] = func_GetH1H2_H2H4(matdata.H1, matdata.H2, matdata.H4, Fs, F0, F1, F2);
	catch
		err = 1;
	end

	assert (err == 0, 'Error: Something went wrong with (H1*-H2*, H2*-H4*)');

	save(matfile, 'H1H2c', 'H2H4c', '-append', '-v4');

end