vs_path = genpath('.');
addpath(vs_path);

arg_list = argv();
indir = '';
outdir = '';
usage = './oct-sauce [wavdir] [matdir]';

if (nargin == 1)
	if (arg_list{1} == '-t')
		printf('\n ~~~ TEST MODE ~~~ \n\n');
		wavdir = 'sounds';
		matdir = 'sounds';
		VoiceSauce(wavdir, matdir);
	elseif (arg_list{1} == '-o')
		OutputToText();
	end

elseif (nargin == 2)
	printf('\n ~~~ VOICESAUCE ~~~ \n\n');
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