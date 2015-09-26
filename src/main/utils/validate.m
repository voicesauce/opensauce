function [err, settings, docket] = validate(settingsFile, docketFile, runDir)
	printf('validating: %s\n', settingsFile);
	err = 0;
	[keys, values] = textread(settingsFile, '%s %s', 'delimiter', ',');
	settings = cell2struct(values, keys)

	windowsize = settings.windowsize;
    frameshift = settings.frameshift;
    maxF0 = settings.maxF0;
    minF0 = settings.minF0;

    printf('--> windowsize=%s, frameshift=%s, maxF0=%s, minF0=%s\n', windowsize, frameshift, maxF0, minF0);

	[keys, values] = textread(docketFile, '%s %s', 'delimiter', ',');
	docket = cell2struct(values, keys);

	f0alg = settings.F0algorithm;
	if (docket.(f0alg) == '0')
		docket.(f0alg) = '1';
	endif

	% require FMT measurement
	fmtalg = settings.FMTalgorithm;
	if (docket.('A1_A2_A3') == '1' || docket.('H1H2_H2H4_norm') == '1' || docket.('H1A1_H1A2_H1A3_norm') == '1')
		if (docket.(fmtalg) == '0')
			docket.(fmtalg) = '1';
		endif
	endif

	% require Hx
	if (docket.('H1A1_H1A2_H1A3_norm') == '1' || docket.('H1H2_H2H4_norm') == '1')
		docket.('H1_H2_H4') = '1';
	endif

	% require Ax
	if (docket.('H1A1_H1A2_H1A3_norm') == '1')
		docket.('A1_A2_A3') = '1';
	endif

	% docketPath = strcat(runDir, '/docket/docket.mat');
	% settingsPath = strcat(runDir, '/settings/settings.mat');
	
	% % save docketPath docket;
	% % save settingsPath settings;
	% save docket;
	% save settings;
end

