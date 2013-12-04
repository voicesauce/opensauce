function [instance_data, err] = batch_process(indir, outdir, settings)
    % Process a batch of wav files.
    % Indir = directory where wav files are stored
    % Outdir = directory where you want to store resulting mat & text files

    % - - - - - - - - - - - - - - - - - - - - - %
    % USER SETTINGS
    % - - - - - - - - - - - - - - - - - - - - - %
    % settings = getSettings();

    % - - - - - - - - - - - - - - - - - - - - - %
    % PARAMETER SELECTION
    % - - - - - - - - - - - - - - - - - - - - - %
    selection = getParameterSelection(); % parameters selected for estimation
    
    % for debugging
    verbose = settings.verbose;
    err = 0;

    % - - - - - - - - - - - - - - - - - - - - - %
    % FIND AND CHECK INPUT *.WAV FILES

    % check to make sure that indir and outdir were both passed in as absolute
    % file paths (e.g. '/Users/kate/path-to-wavfiles')
    homeroot = getenv('HOME');
    l = length(homeroot);

    if (strcmp('~/', indir(1:2) == 0) && strcmp(homeroot, indir(1:l) == 0))
        fprintf('\n==> Error: Path to input wavefile directory [ %s ] must be absolute\n', indir);
        fprintf('\te.g. Change "%s" --> "%s/path-to-input-directory" or "~/path-to-input-directory"\n', indir, homeroot);
        fprintf('\tPlease fix this and try again.\n\n');
        instance_data = NaN;
        err = 1;
        return;
    end

    % if indir is passed in as "~/path-to-wavs", change it to "/Users/name/path-to-wavs"
    % b/c for some reason Snack Pitch doesn't like it the other way
    if (strcmp('~', indir(1)))
        indir = [homeroot '/' indir(3:end)];
    end

    % build the list of files to process
    wavlist = dir(fullfile(indir, '*.wav'));
    n = length(wavlist);
    filelist = cell(1, n);
    for k=1:n
        filelist{k} = wavlist(k).name;
        if (verbose)
            fprintf('file [%d] = "%s"\n', k, filelist{k});
        end
    end

    numwavfiles = length(filelist);

    wavdir = indir;
    matdir = outdir;

    % check if the matfile directory actually exists; if it doesn't, 
    % create a new directory to store resulting .mat files
    if (exist(outdir, 'dir') ~= 7)
        fprintf('creating new directory [ %s ]\n', outdir);
        mkdir(outdir);
    end

    % - - - - - - - - - - - - - - - - - - - - - %
    % - - - - - - - MAIN LOOP - - - - - - - - - %
    % - - - - - - - - - - - - - - - - - - - - - %
    fprintf('Batch processing [%d] *.wav files in [%s]', numwavfiles, indir);
    for k=1:numwavfiles
        fprintf('\nProcessing file [%s]: ', filelist{k});
        fprintf('\t [%d / %d]\n', k, numwavfiles);
        
        wavfile = [wavdir '/' filelist{k}];
        mfile = [matdir '/' filelist{k}(1:end-3) 'mat'];

        % check that wavfile actually exists
        if (exist(wavfile, 'file') == 0)
            fprintf('\n\n\t ==> Error: wavfile [ %s ] not found \n\n', wavfile);
            err = 1; instance_data = NaN;
            return;
        end
                
        % if we're using TextGrids, check to see whether the textgridfile exists
        textgrid_dir = settings.textgrid_dir; % user-specified
        textgridfile = [filelist{k}(1:end-3) 'Textgrid']; % build filename based on wavfile name
        useTextgrid = settings.useTextGrid; % whether or not the user specified this

        if (useTextgrid == 1)
            if (strcmp(textgrid_dir, '') == 1)
                if (verbose)
                    fprintf('Textgrid dir empty, default to [%s]\n', wavdir);
                end
                textgrid_dir = wavdir; % if no textgrid directory is empty in settings, default is wavdir
            end

            textgridfile = [textgrid_dir '/' textgridfile];
            
            if (verbose)
                fprintf('Checking for existence of Textgrid file [%s]\n', textgridfile);
            end

            if (exist(textgridfile, 'file') == 0)
                textgridfile = '';
                useTextgrid = 0;
            end
        end
    

        if (verbose)
            fprintf('\n\n\t[bp line 75]\n\twavfile = %s\n\tmatfile = %s\n\ttextgridfile = %s\n', wavfile, mfile, textgridfile);
            fprintf('textgrid_dir = %s\n\n', textgrid_dir);
        end
        
        % read in the wav file
        %   y = sampled data in y
        %   Fs = sample rate
        %   nbits = number of bits per sample
        [y, Fs, nbits] = wavread(wavfile);
        
        if (size(y, 2) > 1)
            disp('multichannel wav file - using first channel only: ');
            y = y(:,1);
        end
        
        % calculate the length of data vectors - all measures will have this
        % length - important!
        data_len = floor(length(y) / Fs * 1000 / settings.frameshift(1));

        % - - - - - - - - - - - - - - - - - - - - - %
        % Store instance data in a struct
        resampled = 0; %FIXME -- need to get resample to 16 kHx working
        instance_data = build_instance(wavdir, wavfile, matdir, mfile, textgrid_dir, textgridfile, useTextgrid, y, Fs, nbits, data_len, resampled, verbose, settings);
        % - - - - - - - - - - - - - - - - - - - - - %
        
        % parse the parameter list to get proper ordering
        % paramlist corresponds to parameters selected from Parameter
        % Estimation > Parameter Selection box
        paramlist = func_myParseParameters(selection, settings, mfile, data_len);
        n = length(paramlist);
        
        % main parameter estimation loop
        for n=1:length(paramlist)
            thisParam = char(paramlist{n});
            err = doFunction(thisParam, settings, instance_data);
        end
        fprintf('\n');
        
        % delete temp wavfile if it exists
        if(resampled)
            delete(wavfile);
        end

    end % END MAIN LOOP

    printf('\nBatch processing complete.\n');
    assert (err == 0, 'something went wrong');
    res = 0;
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



