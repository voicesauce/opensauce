function settings = getSettings()
	% The settings struct corresponds to options in "Settings" window of VoiceSauce
	settings.verbose = 0;

	% TEXTGRID FILE DIRECTORY
	% (if nothing specified, defaults to same directory as wav files)
	settings.textgrid_dir = ''; 

	% checkbox options
	settings.useTextGrid = 1;
	settings.process16khz = 0; % FIXME
	settings.showWaveForm = 0; % not implemented

	% -------- F0 -------- %
	% Default F0 Algorithm
	% Options = 'F0 (Snack)', 'F0 (Praat)', 'F0 (SHR)'
	settings.F0algorithm = 'F0 (Snack)';

	% Straight
	settings.maxstrF0 = 500;
	settings.minstrF0 = 40;
	settings.maxstrdur = 10;

	% Snack
	settings.maxF0 = 500;
	settings.minF0 = 40;

	% SHR
	settings.SHRmax = 500;
	settings.SHRmin = 40;
	settings.SHRThreshold = 0.4000;

	% Praat
	settings.praat.minF0 = 40;
	settings.praat.maxF0 = 500;
	settings.praat.silthres = 0.03;
	settings.praat.voicethres = 0.45;
	settings.praat.voiunvoicost = 0.14;
	settings.praat.octavecost = 0.01;
	settings.praat.octavejumpcost = 0.35;
	settings.praat.smooth = 0;
	settings.praat.smoothing_bandwidth = 5;
	settings.praat.kill_octave_jumps = 0;
	settings.praat.interpolate = 0;
	settings.praat.method = 'ac'; % or 'cc'



	    

	% Other
	% TODO: enable, command, offset


	% -------- Formants
	% Used for parameter estimation:
	% Options = {Snack, Praat, Other}
	settings.FMTalgorithm = 'F1, F2, F3, F4 (Snack)';

	% Snack
	settings.preemphasis = 0.9600;

	% Other
	% TODO: enable, command, offset

	% -------- Common
	settings.windowsize = 25;
	settings.frameshift = 1; % def 1
	settings.NotANumber = 'NA';
	settings.Nperiods = 3; % no. periods for harmonic estimation
	settings.Nperiods_EC = 5; % no. periods for energy, CPP, HNR est (?)
	% TODO: checkboxes -- Recurse sub-directories, link mat directories, link wav
	% directories

	% -------- Textgrid
	settings.TextgridIgnoreList = '"", " ", "SIL"'; % ignore these labels
	settings.TextgridTierNumber = 1; % tier numbers

	% -------- EGG Data
	settings.EGGheaders = 'CQ, CQ_H, CQ_PM, CQ_HT, peak_Vel, peak_Vel_Time, min_Vel, min_Vel_Time, SQ2-SQ1, SQ4-SQ3, ratio';
	settings.EGGtimelabel = 'Frame';

	% -------- Outputs
	% TODO smoothing window size

	% -------- Input (wav) files
	% TODO search string


	% -------- Misc?
	settings.dirdelimiter = '/';
	settings.frame_precision = 1;
	settings.tbuffer = 25;


end
