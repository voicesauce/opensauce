settings = getSettings();

wavdir = 'tests/sounds';
flist = dir(fullfile(wavdir, '*.wav'));
n = length(flist);
filelist = cell(1, n);
for k=1:n
    filelist{k} = flist(k).name;
end

wavfile = filelist{1};
settings.wavfile = wavfile;

[y, Fs, nbits] = wavread(wavfile);
settings.y = y;
settings.Fs = Fs;
settings.nbits = nbits;

data_len = floor(length(y) / Fs * 1000 / settings.frameshift);
settings.data_len = data_len;

err = doSnackPitch(settings);