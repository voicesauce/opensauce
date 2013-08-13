#!/bin/bash

echo "checking opensauce dependencies..."

check=$(brew list | grep "octave" | wc -l)
if [ $check -eq 0 ]; then
echo "octave not installed... brew-installing it..."
brew tap homebrew/science
brew update && brew upgrade
brew install gfortran
brew install octave
else
echo "octave installed"
fi

check=$(brew list | grep "dialog" | wc -l)
if [ $check -eq 0 ]; then
echo "dialog not installed... brew-installing it..."
brew install dialog
else
echo "dialog installed."
fi

check=$(brew list | grep "python" | wc -l)
if [ $check -eq 0 ]; then
	echo "python not installed... brew-installing it..."
	brew install python
else
	echo "python installed."
fi



echo "done."