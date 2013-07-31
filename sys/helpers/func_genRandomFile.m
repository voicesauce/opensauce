function filename = func_genRandomFile(fname, variables)
% function to generate random file names

N = 8; % this many random digits/characters
[pathstr, name, ext] = fileparts(fname);
randstr = '00000000';

isok = 0;

while(isok == 0)
    for k=1:N
        randstr(k) = floor(rand() * 25) + 65;
    end
    filename = [pathstr '/' variables.dirdelimiter name randstr ext];
    
    if (exist(filename, 'file') == 0)
        isok = 1;
    end
end
end