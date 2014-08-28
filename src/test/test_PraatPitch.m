function test_PraatPitch()
settings = getSettings();
frameshift = settings.frameshift;
frame_precision = settings.frame_precision; %used for Praat f0/formant

wavdir = 'tests/sounds';
flist = dir(fullfile(wavdir, '*.wav'));
n = length(flist);
filelist = cell(1, n);
for k=1:n
    filelist{k} = flist(k).name;
end

wavfile = filelist{1};

% pass in full path to wavfile
path = '~/speech-tech/voice-sauce/VoiceSauce/tests/sounds/';
wavfile = [path wavfile];
X = ['Testing func_PraatPitch on ' wavfile '...'];
disp(X)
assert (exist(wavfile, 'file') ~= 0, 'wav file [%s] does not seem to exist', wavfile);

% need Fs from wavread to calculate correct data_len
[y, Fs, nbits] = wavread(wavfile);

data_len = floor(length(y) / Fs * 1000 / frameshift);

% get praat settings
p = settings.praat;
max = p.maxF0;
min = p.minF0;
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

err = 0;

% call praat
[pF0, err] = func_PraatPitch(wavfile, frameshift/1000, frame_precision, ...
    min, max, silthres, voicethres, octavecost, octavejumpcost, ...
    voiunvoicost, killoctavejumps, smooth, smoothbw, interpolate, ...
    method, data_len);

% did it work?
assert (err == 0, 'there was some error with func_PraatPitch');
disp('...Passed.')








    
    

