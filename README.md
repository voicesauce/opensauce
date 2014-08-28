# OPENSAUCE

OPENSAUCE is an GNU Octave-compatible version of [VOICESAUCE](http://www.seas.ucla.edu/spapl/voicesauce/), software for automated voice measurements.

## Dependencies
* [GNU Octave](https://www.gnu.org/software/octave/)
* [Tcl/Tk](http://www.activestate.com/activetcl)
* python 2.7+ as well as [SciPy](http://www.scipy.org/install.html)
* A working knowledge of the shell/command line tools

Currently, OPENSAUCE has only been tested on Mac OSX (Mavericks). Other *nix environments  
may require some tweaking. If you're on Windows, for now your best bet is to install [VirtualBox](https://www.virtualbox.org/) and something like [Ubuntu](http://www.ubuntu.com/).

## Installation
Clone the OPENSAUCE repository, "cd" into the directory:

		$ git clone https://github.com/voicesauce/opensauce.git
		$ cd /path/to/opensauce

If you're on a Mac, here's a one-line for adding the SAUCE_ROOT environment variable to your .bash_profile:

		$ echo export SAUCE_ROOT=$PWD >> ~/.bash_profile

Then, don't forget to

		$ source ~/.bash_profile

or open a new Terminal session.

If you're not on a Mac, add "export SAUCE_ROOT=/path/to/opensauce/directory" to your .profile manually.

## Hello World

Coming soon...