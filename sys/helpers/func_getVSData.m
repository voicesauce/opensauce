function vsvars = func_getVSData()
% The vsvars struct corresponds to options in "Settings" window of VoiceSauce

vsvars.windowsize = 25;
vsvars.frameshift = 1;
vsvars.preemphasis = 0.9600;
vsvars.F0algorithm = 'F0 (Straight)';
vsvars.FMTalgorithm = 'F1, F2, F3, F4 (Snack)';
vsvars.maxF0 = 500;
vsvars.minF0 = 40;
vsvars.frame_precision = 1;
vsvars.maxstrF0 = 500;
vsvars.minstrF0 = 40;
vsvars.maxstrdur = 10;

end

