function err = doH1H2H4(settings, instance)
    % FIXME: this is extremely slow
    % need to clean up fminsearchbnd2 and fminsearch3 (in optim)
    % need to figure out what the bottleneck is
    
    fprintf('\n\t ==> H1, H2, H4 ...');

    % user settings
    useTextGrid = settings.useTextGrid;
    F0algorithm = settings.F0algorithm;

    % instance data
    resampled = instance.resampled;
    matfile = instance.mfile;
    textgridfile = instance.textgridfile;
    y = instance.y;
    Fs = instance.Fs;

    err = 0;

    matdata = load(matfile);

    F0 = func_parseF0(matdata, F0algorithm);

    if (useTextGrid == 1)
        if (instance.verbose)
            fprintf(' Using Textgrid ');
        end
        try
            [H1, H2, H4, isComplete] = func_GetH1_H2_H4(y, Fs, F0, settings, textgridfile);
        catch
            err = 1;
        end
    else
        try
            [H1, H2, H4, isComplete] = func_GetH1_H2_H4(y, Fs, F0, settings);
        catch
            err = 1;
        end
    end

    HF0algorithm = F0algorithm; % ??

    % check if process was completed
    if (isComplete == 0)
        fprintf('did not complete');
        err = 1;
        if (resampled)
            delete(wavfile);
        end
        return;
    end

    assert (err == 0, 'Error: Something went wrong with (H1, H2, H4)');

    if (exist(matfile, 'file'))
        save(matfile, 'H1', 'H2', 'H4', 'HF0algorithm', '-append', '-v4');
    else
        save(matfile, 'H1', 'H2', 'H4', 'HF0algorithm', '-v4');
    end
end