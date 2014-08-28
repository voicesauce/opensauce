function test_Hx()
	fprintf('\n test_Hx \n');
	% set up the test
	instance = init();
	settings = getSettings();

	verbose = instance.verbose;
	if (verbose)
		fprintf('wavfile = %s\n', instance.wavfile);
	endif

	err = 0;

	err = doSnackPitch(settings, instance);

	assert(err == 0, 'Error in Snack Pitch');

	% Hx functions
	F0algorithm = settings.F0algorithm;
	matfile = instance.mfile;
	matdata = load(matfile);
	textgridfile = instance.textgridfile;
	useTextgrid = instance.useTextgrid;
	y = instance.y;
	Fs = instance.Fs;

	F0 = func_parseF0(matdata, F0algorithm); % length(F0) == 2092

	if (useTextgrid)
		fprintf('Using Textgrid\n');
		[H1, H2, H4, err] = func_GetH1_H2_H4(y, Fs, F0, settings, textgridfile);
	else
		fprintf('No Textgrid\n');
		%[H1, H2, H4, err] = func_GetH1_H2_H4(y, Fs, F0, settings);
		[H1, H2, H4, err] = func_GetH1_H2_H4(y, Fs, F0, settings);
	endif

	err = doA1A2A3(settings, instance);
	err = doH1H2_H2H4(settings, instance);
	err = doH1A1_H1A2_H1A3(settings, instance);

	OutputToText(instance);

	cleanup(instance.wavdir);






	%cleanup(instance.wavdir);

endfunction


