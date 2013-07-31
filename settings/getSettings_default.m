function settings = getSettings()
% The settings struct corresponds to options in "Settings" window of VoiceSauce

% -------- F0
% Used for parameter estimation:
% Options = {Straight, Snack, Praat, SHR, Other}
% settings.F0algorithm = 'F0 (Straight)';
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

% options
settings.useTextGrid = 1;
settings.process16khz = 0;
settings.showWaveForm = 0; % not implemented

    

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
settings.frameshift = 1;
settings.NotANumber = '0';
settings.Nperiods = 3; % no. periods for harmonic estimation
settings.Nperiods_EC = 5; % no. periods for energy, CPP, HNR est (?)
% TODO: checkboxes -- Recurse sub-directories, link mat directories, link wav
% directories

% -------- Textgrid
settings.TextgridIgnoreList = '"", " ", "SIL"'; % ignore these labels
settings.TextgridTierNumber = 1; % tier numbers

% -------- EGG Data
% TODO fields

% -------- Outputs
% TODO smoothing window size

% -------- Input (wav) files
% TODO search string


% -------- Misc?
settings.dirdelimiter = '/';
settings.frame_precision = 1;
settings.tbuffer = 25;

% -------- Instance variables set during batch process--do not modify
settings.wavfile = '';
settings.matfile = '';
settings.textgridfile = '';
settings.resampled = 0;
settings.data_len = -1;
settings.y = -1;
settings.Fs = -1;
settings.nbits = -1;

end
