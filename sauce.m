vs_path = genpath('.');
addpath(vs_path);

arg_list = argv();
usage = 'octave -qf sauce.m [full-path-to-wavdir] [full-path-to-matdir]';

if (nargin == 2)
	printf('\n ~~~ OpenSauce ~~~ \n\n');
	indir = arg_list{1};
	outdir = arg_list{2};
	unix('gui/shell_gui.sh');
	unix('python gui/get_params.py');
	printf('wav dir: [%s]; mat dir: [%s]\n\n', indir, outdir);
	VoiceSauce(indir, outdir, 1);
else
	printf('error: usage: %s', usage);
	exit(-1);
end