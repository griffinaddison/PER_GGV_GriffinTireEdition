function path = rootPath()
    filepath = mfilename('fullpath');
    path = fileparts(fileparts(filepath));
end
