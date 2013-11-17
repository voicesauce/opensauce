# OpenSauce

OpenSauce is an GNU Octave-compatible (knock on wood) edition of [VoiceSauce](http://www.seas.ucla.edu/spapl/voicesauce/), software for automated voice measurements.

## Requirements
* [GNU Octave](https://www.gnu.org/software/octave/) -- make sure you have the latest version (3.6.4)
* Currently, OpenSauce only works on Mac OSX (tested on Mountain Lion)
* You may need to install [Tcl/Tk](http://www.activestate.com/activetcl)

## Installation
Download or "git clone" OpenSauce, unpack it, and change into the "opensauce" directory, i.e.

		$ git clone https://github.com/voicesauce/opensauce.git
		$ cd /path/to/opensauce

## Running OpenSauce on a batch of wav files
1. Check settings/getSettings.m. This is where you set global settings like the default F0 estimation algorithm, max/min F0 values, whether or not to use TextGrid information, etc. For example, to change the default F0 algorithm to "Snack":
* open the file settings/getSettings.m in a text editor
* change "settings.F0algorithm = 'F0 (Praat)'" to "settings.F0algorithm = 'F0 (Snack)'"

Where applicable, possible options are specified in the comments.

2. Check settings/getOutputSettings.m. This is where you specify where the data output of OpenSauce's calculations will be stored, as well as other options. For example, to set the directory where you'd like output files to be stored,
* Open the file "settings/getOutputSettings.m" in a text editor
* Change the field "os.OT_outputdir" to "path/to/your/output/directory"

3. To run OpenSauce, from the command line use the command:

		$ octave -qf sauce.m [wavdir] [matdir]

Where [wavdir] is the directory where your *.wav files are stored and [outdir] is the directory where you'd like VoiceSauce to store the resulting *.mat files. Note that even if you'd like these folders to be the same, you still have to specify both. Also note that [wavdir] and [matdir] need to be absolute paths (e.g. "/Users/johndoe/wavfiles" or "~/wavfiles" rather than a relative path like "../wavfiles"). "-qf" suppresses the Octave startup message.

The command above carries out all calculations specified in the file "params/getParameterSelection.m", runs OutputToText.m (in the "sys" folder) on the resulting *.mat files, and then stores the output in the specified directory (the field "os.OT_outputdir" in the file "settings/getOutputSettings.m").

## More Information
See the [OpenSauce wiki](https://github.com/voicesauce/opensauce/wiki)!
