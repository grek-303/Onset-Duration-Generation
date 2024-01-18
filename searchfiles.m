function filelist = searchfiles(directory, expression, seperate)

%% Description:

% function to search files that start or end with a certain expression in specified
% directory. Start or end expression with '*' (wildcard) to search for a file or 
% all files with a certain expression. Seperate path and filename in two
% seperate collums by setting seperate to 'yes' 



% Check if directory is provided, otherwise set to pwd
if nargin < 1 || isempty(directory)
    warning('Argument 1 was not provided, directory was set to pwd');
    directory = pwd;
end

% Check if expression is provided and is a string starting with '*'
if  nargin <2 || isempty(expression) || ~ischar(expression) || ~contains(expression, '*')
    warning('If you want to locate all files that start or end with a certain pattern, start or end with ''*''');
    return
end

% Check if separate is provided and is 'yes' or 'no'
if nargin <3 || isempty(seperate) || ~ischar(seperate) || ~strcmp(seperate,'yes')
    seperate = 'no';
end


filelist = {};

% Use the dir function to get information about files in the directory
files = dir(fullfile(directory, expression));

if strcmp(seperate,'no')   
    for i = 1:length(files)
        filelist{i} = fullfile(files(i).folder,files(i).name);
    end
    filelist = filelist';
    if length(files) == 1
        filelist = filelist{1};
    end

elseif strcmp(seperate, 'yes')
    for i = 1:length(files)
        filelist{i,1} = files(i).folder;
        filelist{i,2} = files(i).name;
    end

elseif isempty(files)
    warning('No files found in the specified directory.');
    filelist = {};  % or any other appropriate action
end

end