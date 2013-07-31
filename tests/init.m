function settings = init()
    wavfile = 'sounds/hmong_f4_40_a.wav';
    assert (exist(wavfile, 'file') ~= 0, 'no such wavfile %s', wavfile);
    [y, Fs, nbits] = wavread(wavfile);
    matfile = 'sounds/hmong_f4_40_a.mat';

    settings = getSettings();

    data_len = floor(length(y) / Fs * 1000 / settings.frameshift);

    settings.wavfile = wavfile;
    settings.matfile = matfile;
    settings.y = y;
    settings.Fs = Fs;
    settings.nbits = nbits;
    settings.data_len = data_len;

    err = doSnackPitch(settings);
    assert (err == 0, 'err in snack pitch');
end