function settings = getSettings(fname)
% function settings = getSettings()
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
	settings.Nperiods = 3; % no. periods for harmonic estimation (DEFAULT = 3)
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

% function settings = getSettings(fname)
% 	s = load(fname);
	
% 	% function settings = getSettings()
% 	% The settings struct corresponds to options in "Settings" window of VoiceSauce
% 	settings.verbose = str2num(s.verbose);
% 	settings.sid = s.sid;

% 	% TEXTGRID FILE DIRECTORY
% 	% (if nothing specified, defaults to same directory as wav files)
% 	settings.textgrid_dir = s.textgrid_dir;

% 	% checkbox options
% 	settings.useTextGrid = str2num(s.useTextGrid);
% 	settings.process16khz = s.process16khz; % FIXME
% 	settings.showWaveForm = s.showWaveForm; % not implemented

% 	% -------- F0 -------- %
% 	% Default F0 Algorithm
% 	% Options = 'F0 (Snack)', 'F0 (Praat)', 'F0 (SHR)'
% 	settings.F0algorithm = s.F0algorithm;

% 	% Straight
% 	% settings.maxstrF0 = 500;
% 	% settings.minstrF0 = 40;
% 	% settings.maxstrdur = 10;

% 	% Snack
% 	settings.maxF0 = str2double(s.maxF0);
% 	settings.minF0 = str2double(s.minF0);

% 	% SHR
% 	settings.SHRmax = str2double(s.SHRmax);
% 	settings.SHRmin = str2double(s.SHRmin);
% 	settings.SHRThreshold = str2double(s.SHRThreshold);

% 	% Praat
% 	settings.praat.minF0 = str2double(s.praat_minF0);
% 	settings.praat.maxF0 = str2double(s.praat_maxF0);
% 	settings.praat.silthres = str2double(s.praat_silthres);
% 	settings.praat.voicethres = str2double(s.praat_voicethres);
% 	settings.praat.voiunvoicost = str2double(s.praat_voiunvoicost);
% 	settings.praat.octavecost = str2double(s.praat_octavecost);
% 	settings.praat.octavejumpcost = str2double(s.praat_octavejumpcost);
% 	settings.praat.smooth = str2num(s.praat_smooth);
% 	settings.praat.smoothing_bandwidth = str2double(s.praat_smoothing_bandwidth);
% 	settings.praat.kill_octave_jumps = str2num(s.praat_kill_octave_jumps);
% 	settings.praat.interpolate = str2num(s.praat_interpolate);
% 	settings.praat.method = s.praat_method; % or 'cc'

% 	% Other
% 	% TODO: enable, command, offset


% 	% -------- Formants
% 	% Options = {Snack, Praat, Other}
% 	settings.FMTalgorithm = s.FMTalgorithm;

% 	% Snack
% 	settings.preemphasis = str2double(s.preemphasis);

% 	% Other
% 	% TODO: enable, command, offset

% 	% -------- Common
% 	settings.windowsize = str2num(s.windowsize);
% 	settings.frameshift = str2num(s.frameshift); % def 1
% 	settings.NotANumber = s.NotANumber;
% 	settings.Nperiods = str2num(s.Nperiods); % no. periods for harmonic estimation (DEFAULT = 3)
% 	settings.Nperiods_EC = str2num(s.Nperiods_EC); % no. periods for energy, CPP, HNR est (?)
% 	% TODO: checkboxes -- Recurse sub-directories, link mat directories, link wav
% 	% directories

% 	% -------- Textgrid
% 	settings.TextgridIgnoreList = s.TextgridIgnoreList; % ignore these labels
% 	settings.TextgridTierNumber = s.TextgridTierNumber; % tier numbers

% 	% -------- EGG Data
% 	settings.EGGheaders = s.EGGheaders;
% 	settings.EGGtimelabel = s.EGGtimelabel;

% 	% -------- Outputs
% 	% TODO smoothing window size

% 	% -------- Input (wav) files
% 	% TODO search string


% 	% -------- Misc?
% 	settings.dirdelimiter = s.dirdelimiter;
% 	settings.frame_precision = str2num(s.frame_precision);
% 	settings.tbuffer = str2num(s.tbuffer);
% end
