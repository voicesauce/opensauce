function err = doFunction(param, settings, instance_data)

    err = 0;

    switch param
        
        case 'F0 (Straight)'
            printf('%s...', param);
            err = doStraight(settings);
            
        case 'F0 (Snack)'
            err = doSnackPitch(settings, instance_data);
                    
        case 'F0 (Praat)'
            err = doPraatPitch(settings, instance_data);
        
        case 'F0 (SHR)'
            err = doSHRP(settings, instance_data);
            
        case 'F1, F2, F3, F4 (Snack)'
            err = doSnackFormants(settings, instance_data);
            
        case 'F1, F2, F3, F4 (Praat)'
            err = doPraatFormants(settings, instance_data);
            
        case 'H1, H2, H4'
            err = doH1H2H4(settings, instance_data);

        case 'A1, A2, A3'
            err = doA1A2A3(settings, instance_data);
            
        case 'H1*-H2*, H2*-H4*'
            err = doH1H2_H2H4(settings, instance_data);

        case 'H1*-A1*, H1*-A2*, H1*-A3*'
            err = doH1A1_H1A2_H1A3(settings, instance_data);
            
        case 'Energy'
            err = doEnergy(settings, instance_data);
            
        case 'CPP'
            err = doCPP(settings, instance_data);

        case 'Harmonic to Noise Ratios - HNR'
            err = doHNR(settings, instance_data);

        case 'Subharmonic to Harmonic Ratio - SHR'
            err = doSHR(settings, instance_data);
            
    end %endswitch
    
    assert (err == 0, 'Something went wrong.');

end %endfunction