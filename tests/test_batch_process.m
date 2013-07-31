function test_batch_process()

disp('Testing batch_process.m ...')

wavdir = 'tests/sounds';
outdir = 'tests/sounds/out';
[err] = batch_process(wavdir, outdir);

assert (err == 0, 'something went wrong.');
disp('...Passed.')

% clean up
matlist = dir(fullfile(outdir, '*.mat'));
n = length(matlist);

X = sprintf('Cleaning up %d *.mat files in %s ...', n, outdir);
disp(X)

for k=1:n
    mfile = [outdir '/' matlist(k).name];
    %disp(mfile)
    if (exist(mfile, 'file'))
        delete(mfile);
    end
end
disp('...Done.')



    