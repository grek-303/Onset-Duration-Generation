%% Onset Duration Files for FSL
% Created by R.R. Nicolai, 11-01-2024


%% General 
% set the folder of interest, for me that was the current working directory
DIR = pwd; 

% search for '.csv' files in folder of interest (this is a function I
% created myself)
files = searchfiles(DIR, '*.csv', 'no');

%% loop over participants
for j = 1:length(files)
    
    % read csv file
    file = readtable(files{j}); 
    
    % get the subject number and print it
    splitfile = strsplit(files{j}, '.');
    splitfile = strsplit(splitfile{1}, '\');
    subj_n = splitfile{end}; 
    fprintf('Processing subject %s\n', subj_n);
    
    
    % by accident for the last block the memorable condition was stored in a
    % different variable called memorable_1, so we need to change this
    % structure
    file.Memorable(132:end) = str2double(file.Memorable_1(132:end));
    
    % check if trial number in block is same as before, if so, this is the
    % baseline period tracker (we should omit these trials, as they fuck up the log)
    logic_baseline = [true; diff(file.live_row) ~= 0]; 
    file = file(logic_baseline, :);
    
    % memorable and repetition condition logical
    logic_memorable_repeat = file.Memorable == 1 & file.Repetition == 1;
    
    % memorable and no repetition condition logical
    logic_memorable_non_repeat = file.Memorable == 1 & file.Repetition == 0; 

    % not memorable and repetition condition logical
    logic_non_memorable_repeat = file.Memorable == 0 & file.Repetition == 1;
    
    % not memorable and no repetition condition logical
    logic_non_memorable_non_repeat = file.Memorable == 0 & file.Repetition == 0;
    
    % manually calculate the ONSET of the response (thus end of trial)
    response_onset = (file.time_response_sketchpad + file.response_time);
    
    % calculate trial duration
    duration_array = response_onset- file.time_fixation_sketchpad;
    
    % just a check whether there are significant differences between using
    % logger or the addition of sketchpad onset + response time
    just_a_check = file.time_new_logger - (file.time_response_sketchpad + file.response_time);
    just_a_check2 = file.time_new_logger - file.time_response_sketchpad;
    
    % create cell arrays
    columns = {'onset', 'duration', 'parametric modulation'};
    memorable_repeat = columns;
    memorable_non_repeat = columns;
    non_memorable_repeat = columns;
    non_memorable_non_repeat = columns;
    baseline = columns;
    
    % create variable that indicates trigger onset (we can just use the
    % value from the first row)
    trigger = file.response_time_trigger_scanner_keyboard_response(1) + ...
        file.time_trigger_scanner_keyboard_response(1);

    % get information from trial and put it in right condition cell array
    for i = 1:size(file,1)
    
        onset = (file.time_fixation_sketchpad(i) - trigger)/1000;
    
        duration = duration_array(i)/1000;
    
        par_mod = 1;
        
        trial_info = {onset, duration, par_mod};
    
        if logic_memorable_repeat(i) 
            memorable_repeat = cat(1,memorable_repeat, trial_info);    
        elseif logic_memorable_non_repeat(i) 
            memorable_non_repeat = cat(1,memorable_non_repeat, trial_info);  
        elseif logic_non_memorable_repeat(i) 
           non_memorable_repeat = cat(1,non_memorable_repeat, trial_info);
        else
           non_memorable_non_repeat = cat(1,non_memorable_non_repeat, trial_info);
        end
        
    
        if i>1 & i ~= size(file,1) & (onset - file.time_fixation_sketchpad(i-1)) > 15000
            
                onset = file.time_baseline_block_sketchpad(i);
    
                duration = file.time_fixation_sketchpad(i+1) - onset;
    
                par_mod = 1;
                   
                trial_info = {onset, duration, par_mod};
    
                baseline = cat(1,baseline,trial_info);
        end
    end
    
    memorable_repeat = memorable_repeat(2:end,1:3);
    memorable_non_repeat = memorable_non_repeat(2:end,1:3);
    non_memorable_repeat = non_memorable_repeat(2:end,1:3);
    non_memorable_non_repeat = non_memorable_non_repeat(2:end,1:3);
    baseline = baseline(2:end,1:3);

    % write cell arrays to txt files, can't be arsed to turn this into
    % another loop
    
    filename = [subj_n,'_memorable_repeat.txt'];
    writecell(memorable_repeat,filename,'Delimiter','tab')
    
    filename = [subj_n,'_memorable_non_repeat.txt'];
    writecell(memorable_non_repeat,filename,'Delimiter','tab')
    
    filename = [subj_n,'_non_memorable_repeat.txt'];
    writecell(non_memorable_repeat,filename,'Delimiter','tab')
    
    filename = [subj_n,'_non_memorable_non_repeat.txt'];
    writecell(non_memorable_non_repeat,filename,'Delimiter','tab')
    
    filename = [subj_n,'_baseline.txt'];
    writecell(baseline,filename,'Delimiter','tab')

end
