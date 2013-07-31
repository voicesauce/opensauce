function err = test_SnackPitch()
	fprintf('Testing Snack Pitch...\n');
	settings = getSettings();

	wavdir = '~/sounds';
	flist = dir(fullfile(wavdir, '*.wav'));
	n = length(flist);
	filelist = cell(1, n);
	for k=1:n
	    filelist{k} = flist(k).name;
	end

	wavfile = [wavdir '/' filelist{1}];

	fprintf('Using wavfile [ %s ]\n', wavfile);

	assert (exist(wavfile, 'file') ~= 0, 'wavfile DNE');

	instance.wavfile = wavfile;

	mfile = '~/sounds/a.mat';
	instance.mfile = mfile;

	[y, Fs, nbits] = wavread(wavfile);
	instance.y = y;
	instance.Fs = Fs;
	instance.nbits = nbits;
	instance.resampled = 0;
	instance.verbose = 1;


	data_len = floor(length(y) / Fs * 1000 / settings.frameshift);
	instance.data_len = data_len;

	err = doSnackPitch(settings, instance);
	fprintf('err = %d\n', err);

endfunction