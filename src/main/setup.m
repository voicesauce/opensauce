% set up everything
warning('off');
root = getenv('SAUCE_ROOT');
vs_path = genpath(root);
addpath(vs_path);

TAG = 'setup.m';
err = 0;
% should be: [settings file, docket file, run dir, textgrid dir, data dir]
argList = argv();

% for k=1:length(argList)
% 	printf('%s\n', argList{k});
% endfor

if (length(argList) ~= 5)
	err = 1
	printf('%s: wrong number of arguments\n', TAG);
end

if (err == 0)
	settingsFile = argList{1};
	docketFile = argList{2};
	runDir = argList{3};
	textgridDir = argList{4};
	dataDir = argList{5};
	% check to make sure these actually exist
	err = checkFiles(settingsFile, docketFile, runDir, dataDir);
	if (err > 0)
		printf('%s: one or more errors\n', TAG);
	endif
	printf('%s: validate settings...\n', TAG);
	[err, settings, docket] = validate(settingsFile, docketFile, runDir);
	save docket.mat docket
	save settings.mat settings
end
