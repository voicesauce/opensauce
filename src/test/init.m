function instance = init()
    p = genpath('~/vs-octave');
    addpath(p)

    settings = getSettings();
    wavdir = '~/test-sounds';
    verbose = settings.verbose;
    %fprintf('wave directory = %s\n', wavdir);

    wavlist = dir(fullfile(wavdir, '*.wav'));
    n = length(wavlist);
    filelist = cell(1, n);
    for k=1:n
        filelist{k} = wavlist(k).name;
    endfor

    wavfile = [wavdir '/' filelist{1}];
    assert(exist(wavfile, 'file') ~= 0, 'no wavfile');
    
    matfile = [wavfile(1:end-3) 'mat'];

    textgridfile = [wavfile(1:end-3), 'Textgrid'];
    useTextgrid = 0;
    if (exist(textgridfile, 'file'))
        useTextgrid = 1;
    else
        textgridfile = '';
    endif

    [y, Fs, nbits] = wavread(wavfile);

    data_len = floor(length(y) / Fs * 1000 / settings.frameshift);

    instance.wavdir = wavdir;
    instance.wavfile = wavfile;
    instance.matdir = wavdir;
    instance.mfile = matfile;
    instance.textgridfile = textgridfile;
    instance.useTextgrid = useTextgrid;
    instance.textgrid_dir = wavdir;
    instance.data_len = data_len;
    instance.y = y;
    instance.Fs = Fs;
    instance.nbits = nbits;
    instance.resampled = 0;
    instance.verbose = verbose;

endfunction