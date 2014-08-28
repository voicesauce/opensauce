function test_PraatFormants()
disp('Testing func_PraatFormants...')

settings = getSettings();
windowsize = settings.windowsize;
frameshift = settings.frameshift;
frame_precision = settings.frame_precision;

curr_dir = pwd;
indir = 'tests/sounds';

dirlisting = dir(fullfile(indir, '*.wav'));
n = length(dirlisting);
filelist = cell(1,n);
for k=1:n
    filelist{k} = dirlisting(k).name;
end

wavfile = filelist{1};
wavfile = [curr_dir '/' indir '/' wavfile];
disp(wavfile)

[y, Fs, nbits] = wavread(wavfile);
data_len = floor(length(y) / Fs * 1000 / frameshift);


[pF1, pF2, pF3, pF4, pB1, pB2, pB3, pB4, err] = ...
    func_PraatFormants(wavfile, windowsize/1000, frameshift/1000, frame_precision, data_len);

assert(err == 0, 'something went wrong with Praat formants.');
disp('...Passed.')
