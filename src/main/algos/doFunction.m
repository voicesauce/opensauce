function err = doFunction(param, settings, instance_data)
    err = 0;
    printf('doFunction: param = %s\n', param);
    switch param
        case 'F0_Straight'
            printf('%s...', param);
            err = doStraight(settings);
        % case 'F0 (Snack)'
        case 'F0_Snack'
            err = doSnackPitch(settings, instance_data);
        case 'F0_Praat'
            err = doPraatPitch(settings, instance_data);
        case 'F0_SHR'
            err = doSHRP(settings, instance_data);
        case 'Formants_Snack'
            err = doSnackFormants(settings, instance_data);
        % case 'F1, F2, F3, F4 (Praat)'
        case 'Formants_Praat'
            err = doPraatFormants(settings, instance_data);
        % case 'H1, H2, H4'
        case 'H1_H2_H4'
            err = doH1H2H4(settings, instance_data);
        % case 'A1, A2, A3'
        case 'A1_A2_A3'
            err = doA1A2A3(settings, instance_data);
        % case 'H1*-H2*, H2*-H4*'
        case 'H1H2_H2H4_norm'
            err = doH1H2_H2H4(settings, instance_data);
        % case 'H1*-A1*, H1*-A2*, H1*-A3*'
        case 'H1A1_H1A2_H1A3_norm'
            err = doH1A1_H1A2_H1A3(settings, instance_data);
        case 'Energy'
            err = doEnergy(settings, instance_data);
        case 'CPP'
            err = doCPP(settings, instance_data);
        % case 'Harmonic to Noise Ratios - HNR'
        case 'HNR'
            err = doHNR(settings, instance_data);
        % case 'Subharmonic to Harmonic Ratio - SHR'
        case 'SHR'
            err = doSHR(settings, instance_data);            
    end %endswitch
    assert (err == 0, 'Something went wrong.');
end %endfunction
