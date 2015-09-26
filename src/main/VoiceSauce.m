function VoiceSauce(indir, outdir, settings_mat, docket_mat)
% simply runs batch_process and then OutputToText
% indir - the directory where wave files are stored
% outdir - the directory where *.mat files should be stored
% OutputToText parameters are specified in "settings/getOutputSettings.m"

% settings = getSettings(settingsfile);
% settings = load(settings_mat);
% docket = load(docket_mat);

[instance_data, err] = batch_process(indir, outdir, settings_mat, docket_mat);
assert (err == 0, 'Error: Something went wrong in batch_process');

err = OutputToText(ott_settings_mat, instance_data);
assert (err == 0, 'Error: Something went wrong in OutputToText');