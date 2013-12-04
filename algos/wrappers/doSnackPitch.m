function err = doSnackPitch(settings, instance)
    fprintf('\n\t ==> F0 (Snack) ...');

    % get user settings into memory
    windowsize = settings.windowsize;
    frameshift = settings.frameshift;
    maxF0 = settings.maxF0;
    minF0 = settings.minF0;
    F0algorithm = settings.F0algorithm;

    % get instance data into memory
    wavfile = instance.wavfile;
    matfile = instance.mfile;
    y = instance.y;
    Fs = instance.Fs;
    nbits = instance.nbits;
    resampled = instance.resampled;
    data_len = instance.data_len;
    verbose = instance.verbose;
    
    % guard case for 32-bit precision files - some version of
    % snack on a 64-bit machine causes pitch estimation to fail
    use_alt_file = 0;
    if (nbits ~= 16)
        snackwavfile = [wavfile(1:end-4) '_16b.wav'];
        use_alt_file = 1;
        wavwrite(y, Fs, 16, snackwavfile);
    else
        snackwavfile = wavfile;
    end

    err = 0;
    try
        [sF0, sV, err] = func_SnackPitch(snackwavfile, windowsize/1000, frameshift/1000, maxF0, minF0);
    catch
        err = 1;
    end
    
    assert (err == 0, 'Something went wrong with Snack Pitch');


    % check for fatal errors
    if(strcmp(F0algorithm, 'F0 (Snack)') && err == 1)
        disp('Problem with snack - please check settings.')
        if (resampled) % delete the tmp file if it exists
            delete(wavfile);
        end
        if (use_alt_file)
            delete(snackwavfile);
        end
        err = 1;
        return;
    end
    
    sF0 = [zeros(floor(windowsize/frameshift/2),1)*NaN; sF0]; 
    sF0 = [sF0; ones(data_len-length(sF0), 1)*NaN];
    sV = [zeros(floor(windowsize/frameshift/2),1)*NaN; sV]; 
    sV = [sV; ones(data_len-length(sV), 1)* NaN];
    
    
    if (exist(matfile, 'file'))
        save(matfile, 'sF0', 'sV', 'Fs', '-append', '-v4');
    else
        save(matfile, 'sF0', 'sV', 'Fs', '-v4');
    end
    
    if (use_alt_file)
        delete(snackwavfile);
    end
    
