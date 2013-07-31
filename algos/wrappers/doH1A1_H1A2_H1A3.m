function err = doH1A1_H1A2_H1A3(settings, instance)
	fprintf('\n\t ==> H1*-A1*, H1*-A2*, H1*-A3* ...');
	
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

	try
		[H1A1c, H1A2c, H1A3c] = func_GetH1A1_H1A2_H1A3(matdata.H1, matdata.A1, ...
	                                                matdata.A2, matdata.A3, ...
	                                                Fs, F0, F1, F2, F3);
	catch
		err = 1;
	end
	                                                                                       
	assert (err == 0, 'Something went wrong with (H1*-A1*, H1*-A2*, H1*-A3*)');
	                                            
	save(matfile, 'H1A1c', 'H1A2c', 'H1A3c', '-append', '-v4');

end