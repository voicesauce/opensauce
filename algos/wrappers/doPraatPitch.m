function err = doPraatPitch(settings, instance)
	fprintf('\n\t ==> F0 (Praat) ...');

	% user settings
	frameshift = settings.frameshift;
	frame_precision = settings.frame_precision;

	% get praat settings
	p = settings.praat;
	maxF0 = p.maxF0;
	minF0 = p.minF0;
	silthres = p.silthres;
	voicethres = p.voicethres;
	octavecost = p.octavecost;
	octavejumpcost = p.octavejumpcost;
	voiunvoicost = p.voiunvoicost;
	killoctavejumps = p.kill_octave_jumps;
	smooth = p.smooth;
	smoothbw = p.smoothing_bandwidth;
	interpolate = p.interpolate;
	method = p.method;

	% instance data
	wavfile = instance.wavfile;
	matfile = instance.mfile;
	data_len = instance.data_len;
	Fs = instance.Fs;

	try
		% fprintf('KOJ: %d\n\n', killoctavejumps);
	    [pF0, err] = func_PraatPitch(wavfile, frameshift/1000, frame_precision, ...
	        minF0, maxF0, silthres, voicethres, octavecost, octavejumpcost, ...
	        voiunvoicost, killoctavejumps, smooth, smoothbw, interpolate, ...
	        method, data_len);
	catch
	    err = 1;
	end

	assert (err == 0, 'Something went wrong with Praat Pitch');



	if (exist(matfile, 'file'))
	    save(matfile, 'pF0', 'Fs', '-append', '-v4');
	else
	    save(matfile, 'pF0', 'Fs', '-v4');
	end
end