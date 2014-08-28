function err = doSnackFormants(settings, instance)
    printf('F1, F2, F3, F4 (Snack) ...\n');
    % user settings
    windowsize = double(settings.windowsize);
    frameshift = double(settings.frameshift);
    preemphasis = settings.preemphasis;
    % instance data
    resampled = instance.resampled;
    wavfile = instance.wavfile;
    matfile = instance.mfile;
    nbits = instance.nbits;
    Fs = instance.Fs;
    y = instance.y;
    data_len = instance.data_len;
    err = 0;
    % guard case for 32-bit precision files (see above)
    use_alt_file = 0;
    if (nbits ~= 16)
        snackwavfile = [wavfile(1:end-4) '_16b.wav'];
        wavwrite(y, Fs, 16, snackwavfile);
        use_alt_file = 1;
    else
        snackwavfile = wavfile;
    end
    try
        [sF1, sF2, sF3, sF4, sB1, sB2, sB3, sB4, err] = func_SnackFormants(snackwavfile, windowsize/1000, frameshift/1000, preemphasis);
    catch
        err = 1;
    end
    if (strcmp(settings.FMTalgorithm, "'Formants_Snack'") && err == 1)
        printf('Error in Snack Formats, unable to proceed')
        if (resampled)
            delete(wavfile)
        end
        if (use_alt_file)
            delete(snackwavfile);
        end
        err = 1;
        return;
    end
    sF1 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF1]; sF1 = [sF1; ones(data_len-length(sF1), 1)*NaN];
    sF2 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF2]; sF2 = [sF2; ones(data_len-length(sF2), 1)*NaN];
    sF3 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF3]; sF3 = [sF3; ones(data_len-length(sF3), 1)*NaN];
    sF4 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sF4]; sF4 = [sF4; ones(data_len-length(sF4), 1)*NaN];
    sB1 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB1]; sB1 = [sB1; ones(data_len-length(sB1), 1)*NaN];
    sB2 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB2]; sB2 = [sB2; ones(data_len-length(sB2), 1)*NaN];
    sB3 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB3]; sB3 = [sB3; ones(data_len-length(sB3), 1)*NaN];
    sB4 = [zeros(floor(windowsize/frameshift/2),1) * NaN; sB4]; sB4 = [sB4; ones(data_len-length(sB4), 1)*NaN];
    if (exist(matfile, 'file'))
        save(matfile, 'sF1', 'sF2', 'sF3', 'sF4', 'sB1', 'sB2', 'sB3', 'sB4', '-append', '-v4');
        save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append', '-v4');
    else
        save(matfile, 'sF1', 'sF2', 'sF3', 'sF4', 'sB1', 'sB2', 'sB3', 'sB4', '-v4');
        save(matfile, 'windowsize', 'frameshift', 'preemphasis', '-append', '-v4');
    end
    if (use_alt_file)
        delete(snackwavfile);
    end
end
