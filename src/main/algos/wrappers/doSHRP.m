function err = doSHRP(settings, instance)
	printf('F0 (SHR) ...\n');
	% instance data
	matfile = instance.mfile;
	y = instance.y;
	Fs = instance.Fs;
	data_len = instance.data_len;
	err = 0;
	% try
	% 	[SHR, shrF0, err] = func_GetSHRP(y, Fs, settings, data_len);
	% catch
	% 	err = 1;
	% end
	% assert (err == 0, 'Something went wrong with F0 (SHR)');
	[SHR, shrF0, err] = func_GetSHRP(y, Fs, settings, data_len);
	if (exist(matfile, 'file'))
		save(matfile, 'shrF0', 'Fs', '-append', '-v4');
	else
		save(matfile, 'shrF0', 'Fs', '-v4');
	end
end
