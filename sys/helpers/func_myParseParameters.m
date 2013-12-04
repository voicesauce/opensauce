function new_paramlist = func_myParseParameters(selection, settings, matfile, data_len)
% % new_paramlist = func_myParseParameters(paramlist, matfile, data_len)
% % sort through the parameter list and find dependencies, then output a new
% % parameter list with the new param list
% % also check data_len to ensure existing parameters have the same length

    F0algorithm = settings.F0algorithm;
    FMTalgorithm = settings.FMTalgorithm;
    % fprintf('f0: %s fmt: %s \n', F0algorithm, FMTalgorithm);

    new_param_vec = zeros(length(selection), 1);

    F0idx = getParameterSelection(F0algorithm);
    FMTidx = getParameterSelection(FMTalgorithm);
    % fprintf('%d %d \n\n', F0idx, FMTidx);

    L = length(selection);
    for k=1:L
        thisParam = selection{k};
        if (selection{k, 2} == 0)
            continue;
        end

        if (getParameterSelection(thisParam) < 0)
            fprintf('%s not found.\n', thisParam);
            continue;
        end

        new_param_vec(getParameterSelection(thisParam)) = 1;

        switch thisParam
            case {'F1, F2, F3, F4 (Snack)', 'F1, F2, F3, F4 (Praat)', ...
                'Energy', 'CPP', 'Harmonic to Noise Ratios - HNR', ...
                'H1, H2, H4', 'Subharmonic to Harmonic Ratio - SHR'}
                new_param_vec(F0idx) += 2; % seems like we only need this dependency to calculate "maxlen" in OutputToText

            case 'H1*-A1*, H1*-A2*, H1*-A3*'
                new_param_vec(F0idx) += 2;
                new_param_vec(FMTidx) += 2;
                new_param_vec(getParameterSelection('H1, H2, H4')) += 2;
                new_param_vec(getParameterSelection('A1, A2, A3')) += 2;
                
            case 'H1*-H2*, H2*-H4*'
                new_param_vec(F0idx) += 2;
                new_param_vec(FMTidx) += 2;
                new_param_vec(getParameterSelection('H1, H2, H4')) += 2;
                
            case 'A1, A2, A3'
                new_param_vec(F0idx) += 2;
                new_param_vec(FMTidx) += 2;
        end %endswitch
    end %endfor

    if (exist(matfile, 'file'))
        matdata = load(matfile);
        
        if (mod(new_param_vec(getParameterSelection('F0 (Snack)')), 2) == 0 && isfield(matdata, 'sF0'))
            if (length(matdata.sF0) == data_len)
                new_param_vec(getParameterSelection('F0 (Snack)')) = 0;
            end
        end
        
        if (mod(new_param_vec(getParameterSelection('F0 (Praat)')), 2) == 0 && isfield(matdata, 'pF0'))
            if (length(matdata.pF0) == data_len)
                new_param_vec(getParameterSelection('F0 (Praat)')) = 0;
            end
        end

        if (mod(new_param_vec(getParameterSelection('F0 (SHR)')), 2) == 0 && isfield(matdata, 'shrF0'))
            if (length(matdata.shrF0) == data_len)
                new_param_vec(getParameterSelection('F0 (SHR)')) = 0;
            end
        end   
            
        if (mod(new_param_vec(getParameterSelection('F1, F2, F3, F4 (Snack)')), 2) == 0 && isfield(matdata, 'sF1'))
            if (length(matdata.sF1) == data_len)
                new_param_vec(getParameterSelection('F1, F2, F3, F4 (Snack)')) = 0;
            end
        end

        if (mod(new_param_vec(getParameterSelection('F1, F2, F3, F4 (Praat)')), 2) == 0 && isfield(matdata, 'pF1'))
            if (length(matdata.sF1) == data_len)
                new_param_vec(getParameterSelection('F1, F2, F3, F4 (Praat)')) = 0;
            end
        end    
                
        if (mod(new_param_vec(getParameterSelection('A1, A2, A3')), 2) == 0 && isfield(matdata, 'A1'))
            if (length(matdata.A1) == data_len)
                new_param_vec(getParameterSelection('A1, A2, A3')) = 0;
            end
        end
        
        if (mod(new_param_vec(getParameterSelection('H1, H2, H4')), 2) == 0 && isfield(matdata, 'H1'))
            if (length(matdata.H1) == data_len)
                new_param_vec(getParameterSelection('H1, H2, H4')) = 0;
            end
        end
    end %endif

    new_param_vec(new_param_vec ~= 0) = 1; % change everything back to 1's

    % build list with proper ordering
    new_paramlist = cell(sum(new_param_vec), 1);
    cnt = 1;
    for k=1:length(selection)
        param = selection{k,1};
        val = selection{k,2};
        if (new_param_vec(getParameterSelection(param)) == 1)
            new_paramlist{cnt} = param;
            cnt += 1;
        end 
    end

end %endfunction