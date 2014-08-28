function cleanup(outdir)
	dirlist = dir(fullfile(outdir, '*.mat'));
    n = length(dirlist);
    filelist = cell(1, n);
    for k=1:n
        filelist{k} = dirlist(k).name;
    endfor

    for k=1:length(filelist)
    	f = [outdir '/' filelist{k}];
    	fprintf('\n deleting [ %s ]\n', f);
    	delete(f);
    endfor
    
endfunction