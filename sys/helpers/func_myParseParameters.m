function new_paramlist = func_myParseParameters(selection, settings, matfile, data_len)
% new_paramlist = func_myParseParameters(paramlist, matfile, data_len)
% sort through the parameter list and find dependencies, then output a new
% parameter list with the new param list
% also check data_len to ensure existing parameters have the same length

% settings carries the F0 and FMT methods
F0algorithm = settings.F0algorithm;
FMTalgorithm = settings.FMTalgorithm;

% make sure that we're still including the same parameters as before
% old = length(func_getparameterlist());
% new = length(selection);
% if (old ~= new)
%     disp('ParseParameters - something went wrong.')
%     exit
% end

% vector stores which param to enable:
% 0 = disable, 1 = calculate, 2 = conditional calculate
new_param_vec = zeros(length(selection), 1);


% TODO
% bad smell alert:
% new_param_vec(getParamSel(F0algo))) is repeated like 100x
% THERE MUST BE A BETTER WAY
for k=1:length(selection)
    
    thisParam = selection{k};
    
    if (selection{k,2} == 0) % if it's turned off, just skip it
        continue;
    end
    
    if (getParameterSelection(thisParam) < 0)
        disp('not found: ')
        disp(thisParam)
        continue;
    end
    
    new_param_vec(getParameterSelection(thisParam)) = 1;
    F0idx = getParameterSelection(F0algorithm);
    FMTidx = getParameterSelection(FMTalgorithm);
    
    % FIXME: A =+ 2 ==> A = 2 IS WRONG
    % in Octave we can do
    % A = 1; A += 1; ==> A = 2
    switch thisParam
        case {'F1, F2, F3, F4 (Snack)', 'F1, F2, F3, F4 (Praat)'}
            new_param_vec(F0idx) =+ 2; % seems like we only need this dependency to calculate "maxlen" in OutputToText

        case 'H1*-A1*, H1*-A2*, H1*-A3*'
            %new_param_vec(getParameterSelection(F0algorithm)) =+ 2;
            new_param_vec(F0idx) =+ 2;
            new_param_vec(FMTidx) =+ 2;
            new_param_vec(getParameterSelection('H1, H2, H4')) =+ 2;
            new_param_vec(getParameterSelection('A1, A2, A3')) =+ 2;
            
        case 'H1*-H2*, H2*-H4*'
            %new_param_vec(getParameterSelection(F0algorithm)) =+ 2;
            new_param_vec(F0idx) =+ 2;
            new_param_vec(FMTidx) =+ 2;
            new_param_vec(getParameterSelection('H1, H2, H4')) =+ 2;
            
        case {'Energy', 'CPP', 'Harmonic to Noise Ratios - HNR', 'H1, H2, H4'}
            %new_param_vec(getParameterSelection(F0algorithm)) =+ 2;
            new_param_vec(F0idx) =+ 2;
            
        case 'A1, A2, A3'
            new_param_vec(F0idx) =+ 2;
            new_param_vec(FMTidx) =+ 2;

        case {'Subharmonic to Harmonic Ratio - SHR'}
            new_param_vec(F0idx) =+ 2;
            %new_param_vec(getParameterSelection('F0 (SHR)')) =+ 2;

        case {'F1, F2, F3, F4 (Other)', 'F0 (Other)'}
            %disp('TODO: (Other) option not enabled.')
            
    end    
end

% check the conditional parameters to see whether they already exist in the
% matfile
% TODO: get rid of these bad smells too
if (exist(matfile, 'file'))
    matdata = load(matfile);
    
    if (mod(new_param_vec(getParameterSelection('F0 (Straight)')), 2) == 0 && isfield(matdata, 'strF0'))
        if (length(matdata.strF0) == data_len)
            new_param_vec(getParameterSelection('F0 (Straight)')) = 0;
        end
    end
    
    
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
    
    if (mod(new_param_vec(getParameterSelection('F0 (Other)')), 2) == 0 && isfield(matdata, 'oF0'))
        if (length(matdata.sF0) == data_len)
            new_param_vec(getParameterSelection('F0 (Other)')) = 0;
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
    
    if (mod(new_param_vec(getParameterSelection('F1, F2, F3, F4 (Other)')), 2) == 0 && isfield(matdata, 'oF1'))
        if (length(matdata.sF1) == data_len)
            new_param_vec(getParameterSelection('F1, F2, F3, F4 (Other)')) = 0;
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
    
end

new_param_vec(new_param_vec ~= 0) = 1;

% now build list with proper processing order of the parameters
new_paramlist = cell(sum(new_param_vec), 1);
cnt = 1;

if (new_param_vec(getParameterSelection('F0 (Straight)')) == 1)
    new_paramlist{cnt} = 'F0 (Straight)';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('F0 (Snack)')) == 1)
    new_paramlist{cnt} = 'F0 (Snack)';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('F0 (Praat)')) == 1)
    new_paramlist{cnt} = 'F0 (Praat)';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('F0 (SHR)')) == 1)
    new_paramlist{cnt} = 'F0 (SHR)';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('F0 (Other)')) == 1) %&& VSData.vars.F0OtherEnable == 1)
%     disp('TODO: (Other) not enabled')
%     new_paramlist{cnt} = 'F0 (Other)';
%     cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('F1, F2, F3, F4 (Snack)')) == 1)
    new_paramlist{cnt} = 'F1, F2, F3, F4 (Snack)';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('F1, F2, F3, F4 (Praat)')) == 1)
    new_paramlist{cnt} = 'F1, F2, F3, F4 (Praat)';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('F1, F2, F3, F4 (Other)')) == 1) %&& VSData.vars.FormantsOtherEnable == 1)
%     disp('TODO: (Other) not enabled')
%     new_paramlist{cnt} = 'F1, F2, F3, F4 (Other)';
%     cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('A1, A2, A3')) == 1)
    new_paramlist{cnt} = 'A1, A2, A3';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('H1, H2, H4')) == 1)
    new_paramlist{cnt} = 'H1, H2, H4';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('Energy')) == 1)
    new_paramlist{cnt} = 'Energy';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('CPP')) == 1)
    new_paramlist{cnt} = 'CPP';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('Harmonic to Noise Ratios - HNR')) == 1)
    new_paramlist{cnt} = 'Harmonic to Noise Ratios - HNR';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('Subharmonic to Harmonic Ratio - SHR')) == 1)
    new_paramlist{cnt} = 'Subharmonic to Harmonic Ratio - SHR';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('H1*-H2*, H2*-H4*')) == 1)
    new_paramlist{cnt} = 'H1*-H2*, H2*-H4*';
    cnt = cnt + 1;
end

if (new_param_vec(getParameterSelection('H1*-A1*, H1*-A2*, H1*-A3*')) == 1)
    new_paramlist{cnt} = 'H1*-A1*, H1*-A2*, H1*-A3*';
    cnt = cnt + 1;
end



        







        
