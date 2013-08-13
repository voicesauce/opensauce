# OpenSauce

OpenSauce is an GNU Octave-compatible (knock on wood) edition of [VoiceSauce](http://www.seas.ucla.edu/spapl/voicesauce/), software for automated voice measurements.

## Requirements
* [GNU Octave](https://www.gnu.org/software/octave/) -- make sure you have the latest version (3.6.4)
* Currently, OpenSauce only works on Mac OSX (tested on Mountain Lion)
* You may need to install [Tcl/Tk](http://www.activestate.com/activetcl)

In order to use the GUI, you'll also need:
* Python (tested on v2.7)
* [dialog](http://linux.die.net/man/1/dialog)

If you have [homebrew](http://brew.sh/), you can use "check.sh" to make sure that your system has the required dependencies, i.e.

		$ ./check.sh

Note that you only really need Python and dialog for the GUI functionality.

## Running OpenSauce on a batch of *.wav files
0. Download or "git clone" OpenSauce, unpack it, and change into the "opensauce" directory. For example:

		$ git clone https://github.com/voicesauce/opensauce.git
		$ cd /path/to/opensauce

1. Check settings/getSettings.m. This is where you set global settings like the default F0 estimation algorithm, max/min F0 values, whether or not to use TextGrid information, etc. For example, to change the default F0 algorithm to "Snack":

		$ emacs settings/getSettings.m

		change [ settings.F0algorithm = 'F0 (Praat)' ] ==> [ settings.F0algorithm = 'F0 (Snack)' ]

Where applicable, possible options are specified in the comments.

2. Check settings/getOutputSettings.m. This is where you specify where the text output of OpenSauce's calculations will be stored, as well as other options. For example, to set the directory where you'd like output files to be stored:

		$ emacs settings/getOutputSettings.m

		os.OT_outputdir = 'path/to/output/directory'

3. To run OpenSauce, use the command:

		$ octave -qf sauce.m [wavdir] [matdir]

Where [wavdir] is the directory where your *.wav files are stored and [outdir] is the directory where you'd like VoiceSauce to store the resulting *.mat files. "-qf" suppresses the Octave startup message.

PLEASE NOTE that [wavdir] and [matdir] need to be absolute paths (e.g. "/Users/johndoe/wavfiles" or "~/wavfiles" rather than a relative path like "../wavfiles").

The command above carries out all calculations specified in the "Parameter Selection" dialog, runs OutputToText.m (in sys/) on the resulting *.mat files, and then stores the output in the specified directory (the field "os.OT_outputdir" in settings/getOutputSettings.m).

## More Information
See the [OpenSauce wiki](https://github.com/voicesauce/opensauce/wiki)!
