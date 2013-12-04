% TODO: add check for software dependencies here (i.e. is python installed?)

vs_path = genpath('.');
addpath(vs_path);

arg_list = argv();
usage = 'octave -qf sauce.m [full-path-to-wavdir] [full-path-to-matdir] [path-to-settings]';

if (nargin == 3)
	printf('\n ~~~ OpenSauce ~~~ \n\n');
	indir = arg_list{1};
	outdir = arg_list{2};
	settingsdir = arg_list{3};
	%-- GUI stuff --%
	% unix('gui/shell_gui.sh');
	% unix('python gui/get_params.py');
	% -- -- -- %
	printf('wav dir: [%s]; mat dir: [%s]; settings dir: [%s]\n\n', indir, outdir, settingsdir);
	VoiceSauce(indir, outdir, settingsdir);
else
	printf('error: usage: %s', usage);
	exit(-1);
end