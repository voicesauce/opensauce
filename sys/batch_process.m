function [instance_data, err] = batch_process(indir, outdir)
    % Process a batch of wav files.
    % Indir = directory where wav files are stored
    % Outdir = directory where you want to store resulting mat & text files

    % TODO
    % - need to test how it works re: directory structures
    % - need to test on PC

    % TODO
    % separate user settings from settings that get assigned during batch
    % process

    % TODO
    % add 'check settings' method to make sure everything is valid
    % add 'check params' method to make sure everything is valid

    % - - - - - - - - - - - - - - - - - - - - - %
    % USER SETTINGS
    % corresponds to VoiceSauce Settings options (hereafter referred to as "user settings")
    % - - - - - - - - - - - - - - - - - - - - - %
    % wereChecked = checkSettings();
    % assert (wereChecked == 0, 'You should really check the settings first.');
    settings = getSettings();
    frameshift = settings.frameshift; % used to calculate data_len

    % - - - - - - - - - - - - - - - - - - - - - %
    % PARAMETER SELECTION
    % corresponds to what you would select in VoiceSauce "Parameter Selection" window
    % you can change these by opening params/getParameterSelection.m
    % - - - - - - - - - - - - - - - - - - - - - %
    selection = getParameterSelection(); % parameters selected for estimation


    % - - - - - - - - - - - - - - - - - - - - - %
    % OPTIONS
    % these correspond to the checkboxes in the main Parameter Estimation window
    % showWaveForm = settings.showWaveForm; % FIXME
    % - - - - - - - - - - - - - - - - - - - - - %
    showWaveForm = settings.showWaveForm;
    %useTextGrid = settings.useTextGrid;
    process16khz = settings.process16khz;

    % for debugging
    verbose = settings.verbose;
    err = 0;

    % - - - - - - - - - - - - - - - - - - - - - %
    % FIND AND CHECK INPUT *.WAV FILES
    % FIXME: should probably just convert all paths to absolute rather 
    % than relative here instead of later; also should check existence of
    % of wavfiles and matfiles

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
    %addpath(indir); % add input wav directory to MATLAB search path


    % check if the matfile directory actually exists; if it doesn't, 
    % create a new directory to store resulting .mat files
    if (exist(outdir, 'dir') ~= 7)
        fprintf('creating new directory [ %s ]\n', outdir);
        mkdir(outdir);
    end

    instance_data.wavdir = indir;
    instance_data.matdir = outdir;

    % % build the list of files to process
    % dirlisting = dir(fullfile(indir, '*.wav'));
    % n = length(dirlisting);
    % filelist = cell(1, n);

    % for k=1:n
    %     filelist{k} = dirlisting(k).name;
    % end

    % numwavfiles = length(filelist);

    % X = sprintf('Batch processing [%d] *.wav files in [%s]', numwavfiles, indir);
    % disp(X)

    % - - - - - - - - - - - - - - - - - - - - - %
    % - - - - - - - MAIN LOOP - - - - - - - - - %
    % - - - - - - - - - - - - - - - - - - - - - %
    fprintf('Batch processing [%d] *.wav files in [%s]', numwavfiles, indir);
    for k=1:numwavfiles
        printf('\nProcessing file [%s]: ', filelist{k});
        
        wavfile = [instance_data.wavdir '/' filelist{k}];
        mfile = [instance_data.matdir '/' filelist{k}(1:end-3) 'mat'];
        %textgridfile = [filelist{k}(1:end-3) 'Textgrid'];

        % check that wavfile actually exists
        if (exist(wavfile, 'file') == 0)
            fprintf('\n\n\t ==> Error: wavfile [ %s ] not found \n\n', wavfile);
            err = 1; instance_data = NaN;
            return;
        end
        
        % strip down the matfile and check if the directory exists
        mdir = fileparts(mfile);
        if (exist(mdir, 'dir') ~= 7)
            mkdir(mdir);
        end
        
        % check to see if we're showing the waveforms
        if (showWaveForm == 1)
            disp('plotting waveform (placeholder)');
            % TODO: plotCurrentWav(wavfile);
        end

        % if we're using TextGrids, check to see whether the textgridfile exists
        textgrid_dir = settings.textgrid_dir; % user-specified
        textgridfile = [filelist{k}(1:end-3) 'Textgrid']; % build filename based on wavfile name
        useTextGrid = settings.useTextGrid; % whether or not the user specified this

        instance_data.textgridfile = ''; % initialize field
        instance_data.textgrid_dir = textgrid_dir;
        instance_data.useTextGrid = useTextGrid;

        if (useTextGrid == 1)
            if (strcmp(textgrid_dir, '') == 1)
                if (verbose)
                    fprintf('Textgrid dir empty, default to [%s]\n', instance_data.wavdir);
                end
                textgrid_dir = instance_data.wavdir; % if no textgrid directory is empty in settings, default is wavdir
            end

            textgridfile = [textgrid_dir '/' textgridfile];
            
            if (verbose)
                fprintf('Checked for existence of Textgrid file [%s]\n', textgridfile);
            end

            if (exist(textgridfile, 'file') == 0)
                instance_data.textgridfile = '';
                instance_data.useTextGrid = 0;
            else
                instance_data.textgrid_dir = textgrid_dir;
                instance_data.textgridfile = textgridfile;
            end
        end
    

        if (verbose)
            fprintf('\n\n\t[bp line 75]\n\twavfile = %s\n\tmatfile = %s\n\ttextgridfile = %s\n', wavfile, mfile, textgridfile);
            fprintf('textgrid_dir = %s\n\n', instance_data.textgrid_dir);
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
        
        % see if we need to resample to 16 kHz (faster for Straight)
        % FIXME (need to use "signal" package from Octave Forge for resample())
        resampled = 0;
        if (process16khz == 1)
            fprintf('Resampling to 16 kHz not supported yet.')
            % if (Fs ~= 16000)
            %     fprintf('Resampling wavfile to 16 kHz ...')
            %     y = resample(y, 16000, Fs);
            %     wavfile = generateRandomFile(wavfile, settings);
            %     wavfile = [wavfile(1:end-4) '_16kHz.wav'];
            %     wavwrite(y, 16000, nbits, wavfile);
            %     resampled = 1;
            % end
            % [y, Fs] = wavread(wavfile); %reread the resampled file
        end
        
        % calculate the length of data vectors - all measures will have this
        % length - important!
        data_len = floor(length(y) / Fs * 1000 / frameshift);

        % - - - - - - - - - - - - - - - - - - - - - %
        % Store instance data in a struct so that we can pass it
        % around persisently
        instance_data.wavfile = wavfile;
        instance_data.mfile = mfile;
        instance_data.data_len = data_len;
        instance_data.Fs = Fs;
        instance_data.y = y;
        instance_data.nbits = nbits;
        instance_data.resampled = resampled;
        instance_data.verbose = verbose;
        % - - - - - - - - - - - - - - - - - - - - - %
        
        % parse the parameter list to get proper ordering
        % paramlist corresponds to parameters selected from Parameter
        % Estimation > Parameter Selection box
        % selection = getParameterSelection();
        paramlist = func_myParseParameters(selection, settings, mfile, data_len);
        n = length(paramlist);
        
        % main parameter estimation loop
        for n=1:length(paramlist)
            thisParam = char(paramlist{n});
            err = doFunction(thisParam, settings, instance_data);
        end
        
        % delete temp wavfile if it exists
        if(resampled)
            delete(wavfile);
        end

        % if (oldOpt ~= settings.useTextGrid)
        %     settings.useTextGrid = oldOpt;
        % end
    end % END MAIN LOOP

    printf('\nBatch processing complete.\n');
    assert (err == 0, 'something went wrong');
    res = 0;
end

function result = checkSettings()
    fflush(stdout);
    st = input ('Did you check the settings? [Y/n] ', 's');
    if (strcmp(st, 'Y') == 1)
        result = 0;
    else
        result = 1;
    end
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

% unused (need to fix)
function updateSettings(settings, wavfile, matfile, textgridfile, data_len, y, Fs, nbits)
settings.wavfile = wavfile;
settings.matfile = matfile;
settings.textgridfile = textgridfile;
settings.data_len = data_len;
settings.y = y;
settings.Fs = Fs;
settings.nbits = nbits;
end


% --- plots the current wavfile
function plotCurrentWav(wavfile)
% get the present file selected
disp('plotCurrentWav called!')
[y,Fs] = wavread(wavfile);
t = linspace(0, length(y)/Fs*1000, length(y));
plot(t,y);
ylabel('Amplitude');
xlabel('Time (ms)');
axis('tight');
title(wavfile);
end



