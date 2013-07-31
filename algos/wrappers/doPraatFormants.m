function err = doPraatFormants(settings, instance)
	fprintf('\n\t ==> F1, F2, F3, F4 (Praat) ...');

	% user settings
	windowsize = settings.windowsize;
	frameshift = settings.frameshift;
	frame_precision = settings.frame_precision;
	preemphasis = settings.preemphasis;

	% instance data
	wavfile = instance.wavfile;
	matfile = instance.mfile;
	data_len = instance.data_len;

	err = 0;

	try
		[pF1, pF2, pF3, pF4, pB1, pB2, pB3, pB4, err] = func_PraatFormants(wavfile, windowsize/1000, frameshift/1000, frame_precision, data_len);
	catch
		err = 1;
	end

	assert (err == 0, 'Error: Something went wrong with Praat Formants');

	if (exist(matfile, 'file'))
	    save(matfile, 'pF1', 'pF2', 'pF3', 'pF4', 'pB1', 'pB2', 'pB3', 'pB4', '-append', '-v4');
	    save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append', '-v4');
	else
	    save(matfile, 'pF1', 'pF2', 'pF3', 'pF4', 'pB1', 'pB2', 'pB3', 'pB4', '-v4');
	    save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append', '-v4');
	end
end