function VoiceSauce(indir, outdir)
% simply runs batch_process and then OutputToText
% indir - the directory where wave files are stored
% outdir - the directory where *.mat files should be stored
% OutputToText parameters are specified in "settings/getOutputSettings.m"

[instance_data, err] = batch_process(indir, outdir);
assert (err == 0, 'Error: Something went wrong in batch_process');

err = OutputToText(instance_data);
assert (err == 0, 'Error: Something went wrong in OutputToText');