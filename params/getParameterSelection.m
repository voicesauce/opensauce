function selection = getParameterSelection(param)
% Selection struct corresponds to the parameters you would select in
% Parameter Estimation > Parameter Selection dialog. param is optional.
% 1 = on, 0 = off
    selection = {
    'F0 (Straight)' 0;
    'F0 (Snack)' 1;
    'F0 (Praat)' 0;
    'F0 (SHR)' 0;
    'F0 (Other)' 0;
    'F1, F2, F3, F4 (Snack)' 0;
    'F1, F2, F3, F4 (Praat)' 0;
    'F1, F2, F3, F4 (Other)' 0;
    'H1, H2, H4' 0;
    'A1, A2, A3' 0;
    'H1*-H2*, H2*-H4*' 0;
    'H1*-A1*, H1*-A2*, H1*-A3*' 0;
    'Energy' 0;
    'CPP' 0;
    'Harmonic to Noise Ratios - HNR' 0;
    'Subharmonic to Harmonic Ratio - SHR' 0
    };


    if (nargin == 1)
        selection = indexOf(param, selection);
        return;
    end

    
function idx = indexOf(param, sel)
for k=1:length(sel)
    thisParam = sel{k};
    if (strcmp(thisParam, param))
        idx = k;
        return
    end
end
idx = -1;

% % NOT USED -- GUI
    % assert (exist('params.mat', 'file') ~= 0);
    % selected = load('params/params.mat');
    % selected = selected.params;


    % selection = {
    %     %'F0 (Straight' 0;
    %     'F0 (Snack)' selected.F0_Snack;
    %     'F0 (Praat)' selected.F0_Praat;
    %     'F0 (SHR)' selected.F0_SHR;
    %     %'F0 (Other)' 0;
    %     'F1, F2, F3, F4 (Snack)' selected.FMT_Snack;
    %     'F1, F2, F3, F4 (Praat)' selected.FMT_Praat;
    %     %'F1, F2, F3, F4 (Other)' 0;
    %     'H1, H2, H4' selected.Hx;
    %     'A1, A2, A3' selected.Ax;
    %     'H1*-H2*, H2*-H4*' selected.H1H2_H2H4;
    %     'H1*-A1*, H1*-A2*, H1*-A3*' selected.H1A1_H1A2_H1A3;
    %     'Energy' selected.Energy;
    %     'CPP' selected.CPP;
    %     'Harmonic to Noise Ratios - HNR' selected.HNR;
    %     'Subharmonic to Harmonic Ratio - SHR' selected.SHR
    % };


% PARAMLIST
%     'F0 (Straight)'
%     'F0 (Snack)'
%     'F0 (Praat)'
%     'F0 (SHR)'
%     'F1, F2, F3, F4 (Snack)'
%     'F1, F2, F3, F4 (Praat)'
%     'A1, A2, A3'
%     'H1, H2, H4'
%     'Energy'
%     'CPP'
%     'Harmonic to Noise Ratios - HNR'
%     'Subharmonic to Harmonic Ratio - SHR'
%     'H1*-H2*, H2*-H4*'
%     'H1*-A1*, H1*-A2*, H1*-A3*'
