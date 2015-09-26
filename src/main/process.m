warning('off');
root = getenv("SAUCE_ROOT");
vs_path = genpath(root);
addpath(vs_path);
arg_list = argv();
if (nargin == 8)
	indir = arg_list{1};
	outdir = [arg_list{2}, '/mat'];
	settings_mat = arg_list{3};
	docket_mat = arg_list{4};
	ott_settings_mat = arg_list{5};
	ott_outputdir = arg_list{6};
	matdir = arg_list{7};
	tgdir = arg_list{8};

	% VoiceSauce(indir, outdir, settings_mat, docket_mat);
	[instance_data, err] = batch_process(indir, outdir, settings_mat, docket_mat, tgdir);
	
	% if (err == 0)
	% 	OutputToText(ott_settings_mat, settings_mat, ott_outputdir, matdir);
	% end
else
	printf('error: usage: %s', usage);
	exit(-1);
end

