function err = checkFiles(settingsFile, docketFile, dataDir, textgridDir)
	files = {settingsFile, docketFile, dataDir, textgridDir};
	err = 0;
	for k=1:length(files)
		if (exist(files{k} == 0))
			printf('%s not found\n', files{k});
			err = err + 1;
		endif
	endfor
end