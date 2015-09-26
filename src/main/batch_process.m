function [instance_data, err] = batch_process(indir, outdir, settings_mat, docket_mat, textgrid_dir)
    TAG = 'batch_process.m: ';
    printf('settings_mat=%s\n', settings_mat);

    % s = load(settings_mat);
    % settings = s.settings;
    load(settings_mat);

    windowsize = settings.windowsize;
    frameshift = settings.frameshift;
    maxF0 = settings.maxF0;
    minF0 = settings.minF0;

    printf('windowsize=%s, frameshift=%s, maxF0=%s, minF0=%s\n', windowsize, frameshift, maxF0, minF0);

    % build praat settings struct
    % FIXME: s.praat = praat_settings(settings);
    selection = getSelection(docket_mat);
    verbose = settings.verbose;
    err = 0;
    homeroot = getenv('HOME');
    l = length(homeroot);
    if (strcmp('~/', indir(1:2) == 0) && strcmp(homeroot, indir(1:l) == 0))
        fprintf('\nbatch_process.m : error : invalid input directory %s', indir);
        instance_data = NaN;
        err = 1;
        return;
    end
    if (strcmp('~', indir(1)))
        indir = [homeroot '/' indir(3:end)];
    end
    filelist = getFiles(indir);
    numwavfiles = length(filelist);
    wavdir = indir;
    matdir = outdir;
    if (exist(outdir, 'dir') ~= 7)
        fprintf('creating new directory [ %s ]\n', outdir);
        mkdir(outdir);
    end
    fprintf('%s Batch processing %d *.wav files in %s\n', TAG, numwavfiles, indir);
    for k=1:numwavfiles
        fprintf('%s Processing file %s\n', TAG, filelist{k});
        wavfile = [wavdir '/' filelist{k}];
        mfile = [matdir '/' filelist{k}(1:end-3) 'mat'];
        if (exist(wavfile, 'file') == 0)
            fprintf('%s Error: wavfile [ %s ] not found \n', TAG, wavfile);
            err = 1; instance_data = NaN;
            return;
        end
        textgridfile = '';
        if (settings.useTextGrid == 1)
            textgridfile = [filelist{k}(1:end-3) 'Textgrid']; % build filename based on wavfile name
            % if (strcmp(textgrid_dir, '') == 1)
            %     if (verbose)
            %         fprintf('Textgrid dir empty, default to [%s]\n', wavdir);
            %     end
            %     textgrid_dir = wavdir; % if no textgrid directory is empty in settings, default is wavdir
            % end
            textgridfile = [textgrid_dir '/' textgridfile];
            if (verbose)
                fprintf('%s Checking for existence of Textgrid file [%s]\n', TAG, textgridfile);
            end
            if (exist(textgridfile, 'file') == 0)
                textgridfile = '';
                useTextgrid = 0;
            end
        end
        % read in the wav file: y = sampled data in y, Fs = sample rate, nbits = number of bits per sample
        [y, Fs, nbits] = wavread(wavfile);
        if (size(y, 2) > 1)
            disp('multichannel wav file - using first channel only: ');
            y = y(:,1);
        end
        % calculate the length of data vectors - all measures will have this
        % length - important!
        data_len = floor(length(y) / Fs * 1000 / settings.frameshift(1));
        resampled = 0; %FIXME -- need to get resample to 16 kHx working
        instance_data = build_instance(wavdir, wavfile, matdir, mfile, textgrid_dir, textgridfile, settings.useTextGrid, y, Fs, nbits, data_len, resampled, verbose, settings);
        % parse the parameter list to get proper ordering
        paramList = fieldnames(selection);
        m = length(paramList);
        ordered = cell(m,2);
        for i=1:m
            ordered{i,1} = paramList(i){1};
            ordered{i,2} = int2str(orderOf(paramList(i){1}));
        endfor
        ordered = sortrows (ordered, 2);
        % run stuff
        for i=1:m
            err = doFunction(ordered{i,1}, settings, instance_data);
        endfor
        % delete temp wavfile if it exists
        if(resampled)
            delete(wavfile);
        end
    end % END MAIN LOOP
    printf('%s Batch processing complete.\n', TAG);
    assert (err == 0, 'something went wrong');
    res = 0;
end

function selection = getSelection(docket_mat)
    s = load(docket_mat);
    s = s.docket;
    fnames = fieldnames(s);
    selection.foo = 'bar';
    for i=1:nfields(s)
        field = fnames{i};
        if (s.(field) == '1')
            field
            selection.(field) = 1;
        endif
    endfor
    selection = rmfield(selection, 'foo');
end

function filelist = getFiles(indir)
    % build the list of files to process
    wavlist = dir(fullfile(indir, '*.wav'));
    n = length(wavlist);
    filelist = cell(1, n);
    for k=1:n
        filelist{k} = wavlist(k).name;
        % if (verbose)
        %     fprintf('file [%d] = "%s"\n', k, filelist{k});
        % end
    end
end

function idx = orderOf(param)
    params = {
    'F0_Straight',1;
    'F0_Snack',1;
    'F0_Praat',1;
    'F0_SHR',1;
    'F0_Other',1;
    'Formants_Snack',2;
    'Formants_Praat',2;
    'Formants_Other',2;
    'H1_H2_H4',3;
    'A1_A2_A3',3;
    'H1H2_H2H4_norm',4;
    'H1A1_H1A2_H1A3_norm',4;
    'Energy',2;
    'CPP',2;
    'HNR',3;
    'SHR',2
    };
    idx = -1;
    for i=1:length(params)
        if (strcmp(params{i}, param))
            idx = params{i,2};
            break;
        endif
    endfor
end

function praat = praat_settings(settings)
    fnames = fieldnames(settings);
    for i=1:length(fnames)
        parts = strsplit(fnames{i,1}, '_');
        if (length(parts) == 2 && strcmp(parts{1,1}, 'praat'))
            praat.(parts{1,2}) = settings.(fnames{i,1});
        endif
    endfor
end


function instance = build_instance(wavdir, wavfile, matdir, matfile, textgrid_dir, textgridfile, useTextgrid, y, Fs, nbits, data_len, resampled, verbose, settings)
    instance.wavdir = wavdir;
    instance.wavfile = wavfile;
    instance.matdir = matdir;
    instance.mfile = matfile;
    instance.textgrid_dir = textgrid_dir;
    instance.textgridfile = textgridfile;
    instance.useTextgrid = useTextgrid;
    instance.y = y;
    instance.Fs = Fs;
    instance.nbits = nbits;
    instance.data_len = data_len;
    instance.resampled = resampled;
    instance.verbose = verbose;
    instance.settings = settings;
end

% Function to generate random file names
function filename = generateRandomFile(fname, settings)
    %VSData = guidata(handles.VSHandle);
    N = 8;  % this many random digits/characters    
    [pathstr, name, ext] = fileparts(fname);
    randstr = '00000000';

    isok = 0;

    while(isok == 0)
        for k=1:N
            randstr(k) = floor(rand() * 25) + 65;
        end
        filename = [pathstr settings.dirdelimiter 'tmp_' name randstr ext];
        
        if (exist(filename, 'file') == 0)
            isok = 1;
        end
    end
end %endfunction



