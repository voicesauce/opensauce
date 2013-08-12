# OpenSauce

OpenSauce is an GNU Octave-compatible (knock on wood) edition of [VoiceSauce](http://www.seas.ucla.edu/spapl/voicesauce/), software for automated voice measurements.

## Requirements
* [GNU Octave](https://www.gnu.org/software/octave/) -- make sure you have the latest version (3.6.4)
* Currently, OpenSauce only works on Mac OSX (tested on Mountain Lion)
* You may need to install [Tcl/Tk](http://www.activestate.com/activetcl)

## Running OpenSauce on a batch of *.wav files
0. Download or "git clone" OpenSauce, unpack it, and change into the "opensauce" directory. For example:

	$ git clone https://github.com/voicesauce/opensauce.git
	$ cd /path/to/opensauce

1. Check settings/getSettings.m. This is where you set global settings like the default F0 estimation algorithm, max/min F0 values, whether or not to use TextGrid information, etc. For example, to change the default F0 algorithm to "Snack":

	$ emacs settings/getSettings.m
	change [ settings.F0algorithm = 'F0 (Praat)' ] ==> [ settings.F0algorithm = 'F0 (Snack)' ]

Where applicable, possible options are specified in the comments.

2. Check params/getParameterSelection.m. This is where you choose which voice source parameter measurements you'd like OpenSauce to calculate. For example, to select 'CPP':

	$ emacs params/getParameterSelection.m
	change [ 'CPP' 0; ] ==> [ 'CPP' 1; ]


3. Check settings/getOutputSettings.m. This is where you specify where the text output of OpenSauce's calculations will be stored, as well as other options. For example, to set the directory where you'd like output files to be stored:

	$ emacs sys/getOutputSettings.m
	os.OT_outputdir = 'path/to/output/directory'

4. To run OpenSauce, use the command:

	$ octave -qf sauce.m [wavdir] [matdir]

Where [wavdir] is the directory where your *.wav files are stored and [outdir] is the directory where you'd like VoiceSauce to store the resulting *.mat files. "-qf" suppresses the Octave startup message.


PLEASE NOTE that [wavdir] and [matdir] need to be absolute paths (e.g. "/Users/johndoe/wavfiles" or "~/wavfiles" rather than "../wavfiles").

The command above carries out all calculations specified in getParameterSelection.m, runs OutputToText.m (in sys/) on the resulting *.mat files, and stores the output in the specified directory.
