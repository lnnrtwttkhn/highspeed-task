function [Sets,Data,Basics,Parameters,Sounds] = taskSettings
%% HIGHSPEED MRI TASK
% Lennart Wittkuhn | Independent Max Planck Research Group NeuroCode
% Max Planck Institute for Human Development, Berlin, Germany
% Contact: wittkuhn@mpib-berlin.mpg.de
% 2017 - 2018

%% DEFINE EXPERIMENTAL PARAMETERS:

% DEFINE THE BASELOCATION DEPENDING ON THE PLATFORM:
if ismac
    Parameters.pathBase = '~'; % base location for Mac
elseif ispc
    Parameters.pathBase = '/'; % base location for Windows
end

% GET COMPUTER DETAILS
Parameters.computerName = computer; % save information about computer
Parameters.computerHost = char(getHostName(java.net.InetAddress.getLocalHost));
Parameters.computerOS = OSName; % save information about operating system
Parameters.computerMatlab = ['R' version('-release')]; % save information about operating systemversion('-release')

% SET ALL NECESSARY TASK PATHS AND GET SYSTEM INFORMATION
Parameters.studyName = 'highspeed_task';
Parameters.pathTask = fullfile(Parameters.pathBase,'Seafile',Parameters.studyName); % path to the task folder
Parameters.pathScripts = fullfile(Parameters.pathTask,'scripts'); % path to the task script folder
Parameters.pathPlots = fullfile(Parameters.pathTask,'plots'); % path to the task plot folder
Parameters.pathStimuli = fullfile(Parameters.pathTask,'stimuli'); % path to the task stimuli folder
Parameters.pathSounds = fullfile(Parameters.pathTask,'sounds'); % path to the task sounds folder
Parameters.pathData = fullfile(Parameters.pathTask,'data'); % path to the task data folder
cd(Parameters.pathScripts) % set the current directory to the script folder

% RUN KBQUEUE COMMANDS ONCE, TO AVOID CONFLICT WITH GETCHAR
KbQueueCreate; % initalize response queue
KbQueueStop; % stop queue

% DUMMY CALLS TO PSYCHTOOLBOX FUNCTIONS:
KbCheck(-1); % dummy call to KbCheck
WaitSecs(0.1); % dummay call to WaitSecs
GetSecs; clear ans; % dummy call to GetSecs

% INITALIZE RANDOM NUMBER GENERATOR:
rng(sum(100*clock)); % initalize random number generator

% SCREEN SETTINGS:
% Parameters.screenID = 0; % choose the lowest screen
Parameters.screenID = max(Screen('Screens')); % choose the highest screen
[Parameters.screenSize(1), Parameters.screenSize(2)] = Screen('WindowSize',Parameters.screenID); % get the screen size
Parameters.screenResolution = [Parameters.screenSize(1) Parameters.screenSize(2)]; % get screen resolution
Parameters.screenCenterX = Parameters.screenSize(1)/2; % get center of x-axis
Parameters.screenCenterY = Parameters.screenSize(2)/2; % get center of y-axis

% LOAD SOUNDS:
[Sounds.soundCoinY,Sounds.soundCoinFs] = audioread(fullfile(Parameters.pathSounds,'soundCoin.wav')); % load reward sound
[Sounds.soundErrorY,Sounds.soundErrorFs] = audioread(fullfile(Parameters.pathSounds,'soundError.wav')); % load error sound
[Sounds.soundWaitY,Sounds.soundWaitFs] = audioread(fullfile(Parameters.pathSounds,'soundWait.wav')); % load wait sound
Sounds.soundWaitPlayer = audioplayer(Sounds.soundWaitY,Sounds.soundWaitFs); % create audioplayer for wait sound
play(Sounds.soundWaitPlayer); % start player once
pause(Sounds.soundWaitPlayer); % pause player immediately again

% SET TEXT AND KEY PARAMETERS:
Parameters.textSize = 50; % text size
Parameters.textFont = 'Helvetica'; % font type
Parameters.textColorBlack = [0 0 0]; % rgb code for color black
KbName('UnifyKeyNames'); % ensure cross-platform compatibility of keynaming
Parameters.keyTargets = [KbName('LeftArrow'),KbName('RightArrow')]; % list all relevant keys here
Parameters.keyList = zeros(1,256); % initalize a key list of 256 zeros
Parameters.keyList(Parameters.keyTargets) = 1; % set keys of interest to 1
Parameters.screenPosLeft = Parameters.screenCenterX - Parameters.screenCenterX / 4; % position left of the response options
Parameters.screenPosRight = Parameters.screenCenterX + Parameters.screenCenterX / 4; % position right of the response options

% GET THE DEVICE NUMBER:
[Parameters.deviceKeyNames,Parameters.deviceNames] = GetKeyboardIndices; % get a list of all devices connected
if ismac
    Parameters.deviceString = 'Apple Internal Keyboard / Trackpad'; % name of the scanner trigger box
    Parameters.deviceID = 0;
    for k = 1:length(Parameters.deviceNames) % for each possible device
        if strcmp(Parameters.deviceNames{k},Parameters.deviceString) % compare the name to the name you want
            Parameters.deviceID = Parameters.deviceKeyNames(k); % grab the correct id, and exit loop
            break;
        end
    end
    if Parameters.deviceID == 0 %%error checking
        error('No device by that name was detected');
    end
elseif ispc
  Parameters.deviceID =  Parameters.deviceKeyNames; 
end
clear k % clear unneccessary variable

Parameters = orderfields(Parameters); % orders all fields in the structure alphabetically

%% INPUT SUBJECT INFO
while true
    
    % SELECT THE STUDY MODE:
    str = {'instructions_condition_1','instructions_condition_2','practice','behavioral','mri'}; % study mode options
    [selection,~] = listdlg('PromptString','Please choose the study mode:',...
        'SelectionMode','single','ListString',str,'Name','Study mode','ListSize',[160,70]);
    Parameters.studyMode = str{selection}; % save selection of the study mode
    
    % ENTER PARTICIPANT DETAILS:
    prompt = {'id','age','gender','session','run','cbal'}; % define the prompts
    defaultAns = {'99999','99999','m/f','1/2','1','99999'}; % define the default answers
    Parameters.subjectInfo = inputdlg(prompt,'Subject Info',1,defaultAns); % create and show dialog box
    if isempty(Parameters.subjectInfo) % if cancel was pressed
        f = msgbox('Process aborted: Please start again!','Error','error'); % show error message
        uiwait(f);
        continue
    else
        Parameters.subjectInfo = cell2struct(Parameters.subjectInfo,prompt,1); % turn into structure array
    end
    
    % CHECK INPUTS (INTERNALLY):
    if numel(Parameters.subjectInfo.id) ~= 5 % if ID has not been correctly specified
        f = msgbox('ID must contain 5 digits!','Error','error');
        uiwait(f);
    elseif ~strcmp(Parameters.subjectInfo.gender,'m') && ~strcmp(Parameters.subjectInfo.gender,'f')
        f = msgbox('Gender must be either m or f','Error','error');
        uiwait(f);
    elseif str2double(Parameters.subjectInfo.session) ~= 1 && str2double(Parameters.subjectInfo.session) ~= 2
        f = msgbox('Session must be either 1 or 2','Error','error');
        uiwait(f);
    elseif ~ismember(str2double(Parameters.subjectInfo.run),1:8)
        f = msgbox('Run number is not valid!','Error','error');
        uiwait(f);
    else
        
        % CHECK INPUTS (EXTERNALLY):
        choice = questdlg([{'Would you like to continue with this setup?'};...
            {''};...
            strcat('study mode',{': '},Parameters.studyMode);...
            strcat(transpose(prompt),{': '},struct2cell(Parameters.subjectInfo))], ...
            'Continue?', ...
            'Cancel','OK','OK');
        
        % END LOOP IF ALL DETAILS ARE CORRECT:
        if strcmp(choice,'OK')
            fprintf(1,['Selected study mode: ',Parameters.studyMode,'\n']);
            Parameters.subjectInfo.age = str2double(Parameters.subjectInfo.age); % turn into double
            Parameters.subjectInfo.session = str2double(Parameters.subjectInfo.session); % turn into double
            Parameters.subjectInfo.run = str2double(Parameters.subjectInfo.run); % turn into double
            Parameters.subjectInfo.cbal = str2double(Parameters.subjectInfo.cbal); % turn into double
            break
        else
            f = msgbox('Process aborted: Please start again!','Error','error');
            uiwait(f);
        end
    end
end

%%

% Parameters.subjectFolder = strjoin({Parameters.studyName,'sub',Parameters.subjectInfo.id},'_'); % create name of subject data folder
% Parameters.dirDataSub = dir(fullfile(Parameters.pathData,Parameters.subjectFolder)); % get list of files in data directory
% Parameters.dirDataSub = {Parameters.dirDataSub.name}; % get cell array of files names in data directory
% 
% Parameters.subjectFile = strjoin({Parameters.subjectFolder,Parameters.studyMode,...
%     'session',num2str(Parameters.subjectInfo.session),...
%     'run',num2str(Parameters.subjectInfo.run)},'_');
% 
% 
% any(contains(Parameters.dirData,pattern))
% 
% 
% % CHECK IF SUBJECT FOLDER ALREADY EXISTS
% 
% % IF DATA FOLDER IS FOUND, CHECK THE DATA FILES INSIDE THE FOLDER:
% if any(contains(Parameters.dirData,Parameters.subjectFile))
%     % DATA FILES IN SUB FOLDER
%     fprintf('Loading previous subject folder: %s\n',Parameters.subjectFile);
%     Parameters.dirDataSub = dir(fullfile(Parameters.pathData,Parameters.subjectFile));
%     Parameters.dirDataSub = {Parameters.dirDataSub.name}; % get cell array of files names in data directory
%     Parameters.subjectFile = strjoin({Parameters.subjectFile,Parameters.studyMode},'_');
%     if any(contains(Parameters.dirDataSub,Parameters.subjectFile))
%         fprintf('Loading previous study mode: %s\n',Parameters.subjectFile);
%         
%     
%         
%     end
%     find(contains(Parameters.dirDataSub,Parameters.studyName))
%     
%     strjoin({Parameters.subjectFolder,Parameters.studyMode},'_')
%     
%     
%     % GET HIGHEST SESSION:
%     dataMatch = Parameters.dataFiles(idx); % list all data files of the previous session
%     maxSession = cellfun(@str2double,regexp(Parameters.dirDataSub,'(?<=sess)-*\d+','match'),'UniformOutput',false); % find the run numbers of the previous session
%     [sess,~] = max(maxSession); % get the index of the last run of the last session
%     
%     % GET HIGHEST RUN:
%     pattern = ['highspeedMRI_',Parameters.studyMode,'_sub',Parameters.subjectInfo.id,'_sess',num2str(sess)]; % check study mode and id
%     idx = startsWith(Parameters.dataFiles,pattern); % now find all the files of the subject of the previous session
%     dataMatch = Parameters.dataFiles(idx); % list all data files of the previous session
%     maxRun = cellfun(@str2double,regexp(dataMatch,'(?<=run)-*\d+','match')); % find the run numbers of the previous session
%     [run,~] = max(maxRun); % get the index of the last run of the last session
%     
%     % LOAD DATA FILE:
%     pattern = ['highspeedMRI_',Parameters.studyMode,'_sub',Parameters.subjectInfo.id,'_sess',num2str(sess),'_run',num2str(run)]; % check study mode and id
%     load(fullfile(Parameters.pathData,pattern),'Data','Sets','Basics') % load the previous data file
%     fprintf('Loading previous data: %s\n',pattern) % display task progress
%     
%     
%     
%     
%     
%     
% elseif isempty(Parameters.dataFolderIndex)
%     mkdir(Parameters.pathData,Parameters.dataFolder); % create a new data directory for the current subject
% end
% 




%% TASK BASICS

% INDICES FOR THE DIFFERENT TASK CONDITIONS
indexOddball = 1;
idxFlash = 2;
idxOneTwo = 3;
idxOneTwoExtra = 4;

% DEFINE TOTAL NUMBER OF RUNS AND SESSIONS
if contains(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
    Basics.nSession = 1; % total number of sessions
    Basics.nRun = 1; % total number of runs
elseif strcmp(Parameters.studyMode,'behavioral')
    Basics.nSession = 1; % total number of sessions
    Basics.nRun = 8; % total number of runs
elseif strcmp(Parameters.studyMode,'mri')
    Basics.nSession = 2; % total number of sessions
    Basics.nRun = 8; % total number of runs
end

% DEFINE TRIAL STRUCTURE
if strcmp(Parameters.studyMode,'instructions_condition_1')
    Basics.trialStructure = ones(5,1);
elseif strcmp(Parameters.studyMode,'instructions_condition_2')
    Basics.trialStructure = transpose([2 2 3 3 4]);
elseif strcmp(Parameters.studyMode,'practice')
    Basics.trialStructure = reshape(transpose(horzcat(ones(5,1),Shuffle(vertcat(repmat(2,2,1),repmat(3,2,1),repmat(4,1,1))))),10,1);
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    % CREATE A SHUFFLED ORDER OF ALL SEQUENCE TRIALS
    Basics.allSeqTrials = [repmat(idxFlash,Sets(2).set.nTrials,1);repmat(idxOneTwo,Sets(3).set.nTrials,1);repmat(idxOneTwoExtra,Sets(4).set.nTrials,1)]; % create array with all sequence trials
    Basics.allSeqTrials = Shuffle(Basics.allSeqTrials); % shuffle all sequence trials
    % CREATE THE TRIAL SEQUENCE, WITH ODDBALL, SEQUENCE AND REPETITION TRIALS INTERLEAVED
    Basics.trialStructure = [ones(length(Basics.allSeqTrials),1),Basics.allSeqTrials]; % create trial structure as matrix
    Basics.trialStructure = reshape(transpose(Basics.trialStructure),[numel(Basics.trialStructure),1]);
end

% DEFINE TRIAL BASICS
Basics.nTrials = length(Basics.trialStructure); % number of trials in total
Basics.nTrialsRun = Basics.nTrials/Basics.nRun; % number of trials per run
Basics.nTrialsSession = Basics.nTrials/Basics.nSession; % number of trials per session
Basics.nRunSession = Basics.nRun/Basics.nSession; % number of runs per session
Basics.breakTrials = reshape(1:Basics.nTrialsRun:Basics.nTrials,Basics.nRunSession,Basics.nSession); % define break trials

% GENERAL TASK PARAMETERS
Basics.stimNames = transpose({'Gesicht','Haus','Katze','Schuh','Stuhl'}); % list of all stimulus names
Basics.nStimCat = numel(Basics.stimNames); % number of stimulus categories
Basics.reward = 0.03; % reward in cents for each correct response
Basics.tFixation = 0.150; % duration of fixation, in seconds
Basics.tPreFixation = 4; % duration of blank screen before fixation, in seconds
Basics.tTargetCue = 0.5; % duration of target cue presentation, in seconds
Basics.tMaxSeqTrial = 16; % duration of one sequence trial, in seconds
Basics.tResponseLimit = 1.5; % response time limit, in seconds
for i = 1:Basics.nStimCat % preload the task stimuli (pictures)
    currentStimulusName = Basics.stimNames{i}; % get the current stimulus name
    theImageLocation = fullfile(Parameters.pathStimuli,[currentStimulusName,'.jpg']);% create image path
    Basics.stimImages(i).img = imread(theImageLocation); % read the image
end
Basics = orderfields(Basics); % orders all fields in the structure alphabetically

%% ODDBALL CONDITION

% STUDYMODE-SPECIFIC PARAMETERS:
if contains(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
  Sets(1).set.nSeq = 5; % number of unique category combinations / number of training trials
  Sets(1).set.sequences = datasample(perms(1:Basics.nStimCat),Sets(1).set.nSeq,'Replace',false);
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
  Sets(1).set.nSeq = factorial(Basics.nStimCat); % number of unique category combinations / number of training trials
  Sets(1).set.sequences = Shuffle(perms(1:Basics.nStimCat),2); % create a matrix with all possible sequences sand randomly shuffle the order
end

% GENERAL CONDITION PARAMETERS:
Sets(1).set.trialName = 'oddball'; % name of the trial type
Sets(1).set.nSeqStim = Basics.nStimCat; % length of a training sequence (i.e., number of elements)
Sets(1).set.nTrials = Sets(1).set.nSeq * Basics.nStimCat; % total number of stimuli presentations (to have every category in every combination)
Sets(1).set.tStim = 0.5; % duration of stimulus presentation, in seconds
Sets(1).set.tMeanITI = 1.5; % mean inter-trial interval (ITI), in seconds
Sets(1).set.distLowerLim = 1; % lower limit of the ITI exponential distribution
Sets(1).set.distUpperLim = inf; % lower limit of the ITI exponential distribution
Sets(1).set.distTruncExp = makedist('Exponential','mu',Sets(1).set.tMeanITI); % create exponential distribution with mean = meanITI
Sets(1).set.distTruncExp = truncate(Sets(1).set.distTruncExp,Sets(1).set.distLowerLim,Sets(1).set.distUpperLim); % truncate at 1 sec (lower limit), upper limit is inf
Sets(1).set.ratioTarget = 0.2; % 20% of all trials are upside-down trials
Sets(1).set.nTargetPerCat = Sets(1).set.nSeq * Sets(1).set.ratioTarget; % number of upside down trials per category
Sets(1).set.dataIndices = transpose(reshape(1:Sets(1).set.nTrials,Sets(1).set.nSeqStim,Sets(1).set.nSeq)); % create matrix to index the response data matrix
Sets(1).set.tTrial = Basics.tPreFixation + (Basics.tFixation + Sets(1).set.tStim + Sets(1).set.tMeanITI) * Basics.nStimCat; % duration of one training trial, in seconds
Sets(1).set.tCond = Sets(1).set.tTrial * Sets(1).set.nSeq / 60; % duration of all training trials, in minutes
Sets(1).set = orderfields(Sets(1).set); % orders all fields in the structure alphabetically

% CREATE INDIVIDUALIZED DATA TABLE
Data(1).data = table; % create an empty table for the data of the training trials
Data(1).data.id = repmat({Parameters.subjectInfo.id},Sets(1).set.nTrials,1); % add id
Data(1).data.trial = transpose(1:Sets(1).set.nTrials); % add a trial counter
Data(1).data.session = nan(Sets(1).set.nTrials,1); % add a session counter
Data(1).data.run = nan(Sets(1).set.nTrials,1); % add a run counter
Data(1).data.stimIndex = reshape(transpose(Sets(1).set.sequences),[Sets(1).set.nTrials,1]); % reshaped array of random sequences
Data(1).data.targetName = Basics.stimNames(Data(1).data.stimIndex); % get the stimulus name for each trial
Data(1).data.orient = zeros(Sets(1).set.nTrials,1); % initalize array for random stimulus orientation (0 (= upright presentation) as default)
Data(1).data.tITI = random(Sets(1).set.distTruncExp,Sets(1).set.nTrials,1); % generate random ITIs for every trial drawn from the truncated exponential distribution
for k = 1:Basics.nStimCat % determine the (random) occurences of oddballs (equal number of oddballs for each stimulus)
    Data(1).data.orient(datasample(find(Data(1).data.stimIndex == k),Sets(1).set.nTargetPerCat,'Replace',false)) = 180; % set stimulus orientation to 180 (degree)
end

% INITIALIZE EMPTY ARRAYS TO RECORD RESPONSES AND STIMULUS TIMINGS:
Data(1).data.keyIsDown = nan(Sets(1).set.nTrials,1); % initalize empty array to save whether key was down or not for every trial
Data(1).data.keyIndex = nan(Sets(1).set.nTrials,1); % initalize empty array to save the key indices of the keys pressed by the subject during the task
Data(1).data.acc = nan(Sets(1).set.nTrials,1); % initalize empty array for accuracy data
Data(1).data.rt = nan(Sets(1).set.nTrials,1); % initalize empty array for reaction time data
Data(1).data.tFlipBlank = nan(Sets(1).set.nTrials,1); % initalize empty array to record flip time of blank screen at the start of the trial
Data(1).data.tFlipFix = nan(Sets(1).set.nTrials,1); % initalize empty array to record flip time of the fixation cross
Data(1).data.tFlipStim = nan(Sets(1).set.nTrials,1); % initalize empty array to record flip time of the stimulus onset
Data(1).data.tFlipITI = nan(Sets(1).set.nTrials,1); % initalize empty array to record flip time of ITI onset
Data(1).data.tResponse = nan(Sets(1).set.nTrials,1); % initalize empty array to record the time of response

%% SEQUENCE TASK CONDITON

% GENERAL CONDITION PARAMETERS:
Sets(2).set.trialName = 'sequence'; % name of the trial type
Sets(2).set.nSeqStim = Basics.nStimCat; % length of an object sequence (i.e., number of elements)
Sets(2).set.tStim = 0.1; % duration of stimulus presentation, in seconds
Sets(2).set.tISI = transpose(2.^(5:11)/1000); % ISI of flashes, in seconds (exponents of 2)
Sets(2).set.tISI(Sets(2).set.tISI == 0.2560)  = []; % do not use ISI of 256 ms
Sets(2).set.tISI(Sets(2).set.tISI == 1.0240)  = []; % do not use ISI of 1024 ms
if contains(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
    Sets(2).set.nSeq = 1; % total number of object sequences per participant
    Sets(2).set.tISI = vertcat(min(Sets(2).set.tISI),max(Sets(2).set.tISI)); % only use fastest and slowest ISI for practice and instructions
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Sets(2).set.nSeq = 15; % total number of object sequences per participant
end
Sets(2).set.nISI = numel(Sets(2).set.tISI); % number of ISIs
Sets(2).set.nTrials = Sets(2).set.nSeq * Sets(2).set.nISI; % total number of flash trials
Sets(2).set.tTrial = Basics.tTargetCue + Basics.tPreFixation + Basics.tFixation + Basics.tMaxSeqTrial + Basics.tResponseLimit; % duration of one flash trial
Sets(2).set.tCond =  Sets(2).set.tTrial * Sets(2).set.nTrials / 60; % duration of test phase, in minutes
Sets(2).set.distLowerLim = 1; % lower limit of distribution
Sets(2).set.distUpperLim = 5; % upper limit of distribution
Sets(2).set.dataIndices = repmat(transpose(1:Sets(2).set.nTrials),1,Sets(2).set.nSeqStim); % create matrix to index the response data matrix


Sets(2).set.seqPick = transpose(reshape(1:factorial(Basics.nStimCat-1),3,8));

% CREATE OBJECT SEQUENCES:
if contains(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
    Sets(2).set.sequences = [1 2 3 4 5];
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Sets(2).set.sequencesAll = fliplr(perms(1:Basics.nStimCat)); % matrix with all possible sequences
    Sets(2).set.sequences = []; % initalize final array of drawn sequences for the subject
    for k= 1:Basics.nStimCat
        indices = find(Sets(2).set.sequencesAll(:,end) == k);
        pick = Sets(2).set.seqPick(Parameters.subjectInfo.cbal,:);
        Sets(2).set.sequences = vertcat(Sets(2).set.sequences,Sets(2).set.sequencesAll(indices(pick),:));    
    end
end

% CREATE FLASH SEQUENCES FOR THE SUBJECT
% if strcmp(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
%     Sets(2).set.sequences = [1 2 3 4 5];
% elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
%     Sets(2).set.sequencesAll = fliplr(perms(1:Basics.nStimCat)); % matrix with all possible sequences
%     indices = 1:length(Sets(2).set.sequencesAll); % list of all indices to index the all sequences matrix
%     Parameters.dirTask = dir(Parameters.pathScripts); % check task directory
%     Parameters.dirTaskFiles = {Parameters.dirTask.name}; % get directory files names
%     if ~any(contains(Parameters.dirTaskFiles,'usedIndices.mat')) % if previous indices do not exist (e.g., first subject)
%         warning('No previous flash sequence indices saved! This may be the case if you are running the first subject.') % warn
%         usedIndices = []; % define used indices as empty
%     else % if a file with previous indices exists
%         load('usedIndices.mat'); % load indices that we already used for previous subjects
%         if length(usedIndices) == length(Sets(2).set.sequencesAll) % if all indices have been used, reset the list
%             usedIndices = [];
%             warning('A new indices list has been created.') % show warning that a new list will be created
%         else
%         end
%     end
%     done = 0;
%     while done == 0
%         Sets(2).set.sequences = []; % initalize final array of drawn sequences for the subject
%         unusedSequenceIndices = true(1,length(Sets(2).set.sequencesAll)); % initalize array for unused indices
%         unusedSequenceIndices(usedIndices) = false; % set all previously used indices to zero
%         count = 0; % start while loop counter (set to 0)
%         while length(Sets(2).set.sequences) ~= Sets(2).set.nSeq % fill up the sequence matrix for the subject
% %             currentIndices = indices(unusedSequenceIndices); % get all unused indices
%             idx = datasample(indices(unusedSequenceIndices),1); % sample random index from the list of indices
%             currentSequence = Sets(2).set.sequencesAll(idx,:); % draw the corresponding sequence from the all sequence matrix
%             Sets(2).set.sequences = vertcat(Sets(2).set.sequences,currentSequence); % add drawn sequence to the final sequence matrix
%             [nLastElements,~] = hist(Sets(2).set.sequences(:,end),unique(Sets(2).set.sequences(:,end))); % check the number of last elements per category in sequence matrix
%             [nFirstElements,~] = hist(Sets(2).set.sequences(:,1),unique(Sets(2).set.sequences(:,1))); % check the number of first elements per category in sequence matrix
%             if any(nLastElements > Sets(2).set.nSeq/Basics.nStimCat) || any(nFirstElements > Sets(2).set.nSeq/Basics.nStimCat) % if the number of unique elements in the fist and last column of the matrix get bigger than 3
%                 Sets(2).set.sequences(end,:) = []; % delete the previously added sequence again
%             else
%                 unusedSequenceIndices(idx) = false; % mark the sequence index as used
%             end
%             if count > 10000 % if the loop takes too long, break and restart
%                 break
%             end
%             count = count + 1; % count up
%         end
%         if length(Sets(2).set.sequences) == Sets(2).set.nSeq % if all sequences are drawn break out of the loop
%             break
%         end
%     end
%     usedIndices = indices(~unusedSequenceIndices); % save the used indices
%     save usedIndices.mat usedIndices; % save variable to directory
% end

% Create shuffled unique combinations of sequences and flashISIs
[p,q] = meshgrid(1:Sets(2).set.nSeq,1:Sets(2).set.nISI); % create meshgrid
if strcmp(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
    Sets(2).set.flashSelector = [p(:) flipud(q(:))]; % shuffle order of occurence
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Sets(2).set.flashSelector = Shuffle([p(:) q(:)],2); % shuffle order of occurence
end
Sets(2).set.sequences = Sets(2).set.sequences(Sets(2).set.flashSelector(:,1),:); % arrange the flash sequences according to the flash selctor

% CREATE DATA TABLE:
Data(2).data = table; % initalize table
Data(2).data.id = repmat({Parameters.subjectInfo.id},Sets(2).set.nTrials,1); % add id
Data(2).data.trial = transpose(1:Sets(2).set.nTrials); % add a trial counter
Data(2).data.session = nan(Sets(2).set.nTrials,1); % add a session counter
Data(2).data.run = nan(Sets(2).set.nTrials,1); % add a run counter
Data(2).data.stimIndex = Sets(2).set.sequences; % add sequences
Data(2).data.target = nan(Sets(2).set.nTrials,1); % 
Data(2).data.orient = zeros(Sets(2).set.nTrials,1);
Data(2).data.tITI = Sets(2).set.tISI(Sets(2).set.flashSelector(:,2));

if strcmp(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
    Data(2).data.keyTarget = transpose(Shuffle(Parameters.keyTargets));
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Data(2).data.keyTarget = Shuffle(transpose([repmat(Parameters.keyTargets,1,floor(Sets(2).set.nTrials/numel(Parameters.keyTargets))),Parameters.keyTargets(randi(numel(Parameters.keyTargets)))]));
end

Data(2).data.keyIsDown = nan(Sets(2).set.nTrials,1);
Data(2).data.keyIndex = nan(Sets(2).set.nTrials,1);
Data(2).data.acc = nan(Sets(2).set.nTrials,1);
Data(2).data.rt = nan(Sets(2).set.nTrials,1);

% DRAW TARGET POSITIONS FROM POISSON DISTRIBUTION:
Sets(2).set.distLamba = 1.7; % lamda parameteter of the poisson distribution
Sets(2).set.distPoisson = poisspdf(1:Basics.nStimCat,Sets(2).set.distLamba) / sum(poisspdf(1:Basics.nStimCat,Sets(2).set.distLamba));
Sets(2).set.distNumValues = round(Sets(2).set.distPoisson * Sets(2).set.nTrials);
Data(2).data.targetPos = Shuffle(transpose(repelem(5:-1:1,Sets(2).set.distNumValues))); % define target positions
for j = 1:Sets(2).set.nTrials % define the targets
    Data(2).data.target(j) = Data(2).data.stimIndex(j,Data(2).data.targetPos(j)); % defines the target
end
Data(2).data.targetName = Basics.stimNames(Data(2).data.target); % get target names

% DEFINE ALTERNATIVE RESPONSE OPTIONS:
Data(2).data.targetPosAlt = nan(Sets(2).set.nTrials,1); % initalize
for j = 1:Sets(2).set.nTrials
    while isnan(Data(2).data.targetPosAlt(j)) || Data(2).data.targetPosAlt(j) == Data(2).data.targetPos(j)
        Data(2).data.targetPosAlt(j) = sum(rand >= cumsum([0, Sets(2).set.distPoisson]));
    end
end

% INITIALIZE EMPTY ARRAYS TO RECORD RESPONSES AND STIMULUS TIMINGS:
Data(2).data.tSequence = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipCue = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipBlank = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipFix = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipStim = nan(Sets(2).set.nTrials,Sets(2).set.nSeqStim); % initalize empty array to record flip time
Data(2).data.tFlipITI = nan(Sets(2).set.nTrials,Sets(2).set.nSeqStim); % initalize empty array to record flip time
Data(2).data.tFlipDelay = nan(Sets(2).set.nTrials,Sets(2).set.nSeqStim); % initalize empty array to record flip time
Data(2).data.tFlipResp = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tResponse = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Sets(2).set = orderfields(Sets(2).set); % orders all fields in the structure alphabetically

%% REPETITION TRIALS (SHORT) - SETTINGS
% SET CONDITION PARAMETERS:
Sets(3).set.trialName = 'repetition (short)'; % name of the trial type
Sets(3).set.nSeq = 8; % total number of sequences
Sets(3).set.nRep = 5; % number of sequence repetitions
Sets(3).set.nSeqStim = 9; % length of a repetition sequence (i.e., number of elements per sequence)
Sets(3).set.nTrials = Sets(3).set.nSeq * Sets(3).set.nRep; % total of repetition sequence trials
Sets(3).set.tStim = Sets(2).set.tStim; % time of stimulus presentation, in seconds (same as during the sequence condition)
Sets(3).set.tISI = min(Sets(2).set.tISI); % ISI of one-two sequences, in seconds (= minimal flash sequence)
Sets(3).set.distLowerLimit = 1; % lower limit of distribution for response targets 
Sets(3).set.distUpperLimit = Sets(3).set.nSeqStim; % upper limit of distribution for response targets
Sets(3).set.respDiff = 3;
Sets(3).set.dataIndices = repmat(transpose(1:Sets(3).set.nTrials),1,Sets(3).set.nSeqStim); % matrix with indices to write in data file
Sets(3).set.tOneTwoTrial = Basics.tTargetCue + Basics.tPreFixation + Basics.tFixation + Basics.tMaxSeqTrial + Basics.tResponseLimit;
Sets(3).set.tCond = Sets(3).set.tOneTwoTrial * Sets(3).set.nTrials / 60; % duration of one two phase, in minutes

Sets(3).set.sequences = []; % initalize empty matrix
for x = 1:Sets(3).set.nRep
    oneTwoSequence = ones(Sets(3).set.nSeq,Sets(3).set.nSeqStim); % create 8 x 8 matrix with ones
    oneTwoSequence = tril(oneTwoSequence,0); % create matrix diagonal with 1s and 0s
    oneTwoSequence = fliplr(oneTwoSequence); % flip matrix from left to right
    a = transpose(randperm(Basics.nStimCat)); % generate a random sequence of all object categories
    a(a == x) = []; % delete the current first category (x)
    oneTwoSequence = oneTwoSequence .* vertcat(a,flipud(a));
    oneTwoSequence(oneTwoSequence == 0) = x;
    Sets(3).set.sequences = vertcat(Sets(3).set.sequences,oneTwoSequence);
end
Sets(3).set.sequences = Shuffle(Sets(3).set.sequences,2); % randomly shuffle all sequences
Sets(3).set = orderfields(Sets(3).set); % orders all fields in the structure alphabetically

% CREATE DATA FRAME
Data(3).data = table; % initalize empty table
Data(3).data.id = repmat({Parameters.subjectInfo.id},Sets(3).set.nTrials,1); % add id
Data(3).data.trial = transpose(1:Sets(3).set.nTrials); % set trial counter
Data(3).data.session = nan(Sets(3).set.nTrials,1); % add a session counter
Data(3).data.run = nan(Sets(3).set.nTrials,1); % add a run counter
Data(3).data.stimIndex = Sets(3).set.sequences; % set sequences
Data(3).data.orient = zeros(Sets(3).set.nTrials,1); % set stimulus orientation (all stimuli should be upright)
Data(3).data.keyTarget = Shuffle(transpose(repmat(Parameters.keyTargets,1,Sets(3).set.nTrials/numel(Parameters.keyTargets))));
Data(3).data.keyIsDown = nan(Sets(3).set.nTrials,1); % initilaze empty array to collect key presses
Data(3).data.keyIndex = nan(Sets(3).set.nTrials,1);
Data(3).data.acc = nan(Sets(3).set.nTrials,1);
Data(3).data.rt = nan(Sets(3).set.nTrials,1);
Data(3).data.targetPosAlt = nan(Sets(3).set.nTrials,1);
[Data(3).data.targetPos,~] = find(transpose(diff(Sets(3).set.sequences,1,2)));
Data(3).data.targetPos = Data(3).data.targetPos + 1; % add one because of the diff function properties
Data(3).data.target = Sets(3).set.sequences(:,end); % the target categories
Data(3).data.targetName = Basics.stimNames(Data(3).data.target); % get target names
Data(3).data.tITI = repmat(Sets(3).set.tISI,Sets(3).set.nTrials,1); % set ISIs for all trials

% determine alternative target options
for i = 1:Sets(3).set.nTrials
    x = Data(3).data.targetPos(i) + Sets(3).set.respDiff; % find lower center
    y = Data(3).data.targetPos(i) - Sets(3).set.respDiff; % find upper center
    ba = horzcat(x-1:x+1,y-1:y+1); % array of possible alternative targets
    while isnan(Data(3).data.targetPosAlt(i)) || ~ismember(Data(3).data.targetPosAlt(i),1:Sets(3).set.nSeqStim)
        Data(3).data.targetPosAlt(i) = datasample(ba,1,'Replace',true); % draw the alternative response option from array of possible alternative targets
    end
end

% INITALIZE EMPTY ARRAYS TO SAVE THE TASK TIMINGS (STIMULUS DISPLAY, ETC.)
Data(3).data.tSequence = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time
Data(3).data.tFlipCue = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time
Data(3).data.tFlipBlank = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time
Data(3).data.tFlipFix = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time
Data(3).data.tFlipStim = nan(Sets(3).set.nTrials,Sets(3).set.nSeqStim); % initalize empty array to record flip time
Data(3).data.tFlipITI = nan(Sets(3).set.nTrials,Sets(3).set.nSeqStim); % initalize empty array to record flip time
Data(3).data.tFlipResp = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time
Data(3).data.tResponse = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time


%% REPETITION TRIALS (LONG) - SETTINGS

Sets(4).set.trialName = 'repetition (long)'; % name of the trial type
Sets(4).set.nSeq = 5; % total number of object sequences
Sets(4).set.nSeqStim  = 16; % length of extra one-two trial
Sets(4).set.nRep = 1; % number of times the same sequence is repeated
Sets(4).set.nTrials = Sets(4).set.nSeq * Sets(4).set.nRep; % total number of extra one-two trials
Sets(4).set.tStim = Sets(3).set.tStim; % time of stimulus presentation, in seconds (same as during flash sequence)
Sets(4).set.tISI = min(Sets(2).set.tISI); % ISI of one-two sequences, in seconds (= minimal flash sequence)
Sets(4).set.dataIndices = repmat(transpose(1:Sets(4).set.nSeq),1,Sets(4).set.nSeqStim);
Sets(4).set.tTrial = Basics.tTargetCue + Basics.tPreFixation + Basics.tFixation + Basics.tMaxSeqTrial + Basics.tResponseLimit; % duration of one flash trial
Sets(4).set.tCond = Sets(4).set.tTrial * Sets(4).set.nTrials / 60; % duration of one two phase, in minutes

% determine the sequences of the one two extra trials:
Sets(4).set.sequences = repmat(transpose(1:Basics.nStimCat),Sets(4).set.nRep,Sets(4).set.nSeqStim); % create sequences of extra oneTwo Trials
while any(Sets(4).set.sequences(:,end) == Sets(4).set.sequences(:,end-1)) % while the last and second-to-last element of any row are the same ...
    Sets(4).set.sequences(:,end) = transpose(randperm(Basics.nStimCat)); % ... change the last elements of rows randomly
end
Sets(4).set.sequences = Shuffle(Sets(4).set.sequences,2); % randomly shuffle all sequences
Sets(4).set = orderfields(Sets(4).set); % orders all fields in the structure alphabetically

% CREATE DATA TABLE
Data(4).data = table; % initalize data table
dataOneTwo.id = repmat({Parameters.subjectInfo.id},Sets(4).set.nTrials,1); % add id
Data(4).data.trial = transpose(1:Sets(4).set.nTrials); % add a trial counter
Data(4).data.session = nan(Sets(4).set.nTrials,1); % add a session counter
Data(4).data.run = nan(Sets(4).set.nTrials,1); % add a run counter
Data(4).data.stimIndex = Sets(4).set.sequences;
Data(4).data.orient = zeros(Sets(4).set.nTrials,1);
Data(4).data.keyTarget = Shuffle(transpose([repmat(Parameters.keyTargets,1,2),Parameters.keyTargets(randi(numel(Parameters.keyTargets)))]));
Data(4).data.keyIsDown = nan(Sets(4).set.nTrials,1);
Data(4).data.keyIndex = nan(Sets(4).set.nTrials,1);
Data(4).data.acc = nan(Sets(4).set.nTrials,1);
Data(4).data.rt = nan(Sets(4).set.nTrials,1);
Data(4).data.target = Data(4).data.stimIndex(:,end);
Data(4).data.targetPos = repmat(Sets(4).set.nSeqStim,Sets(4).set.nTrials,1);
Data(4).data.targetPosAlt = Data(4).data.targetPos-transpose(randsample(Sets(3).set.respDiff-1:Sets(3).set.respDiff + 1,5,true));
Data(4).data.targetName = Basics.stimNames(Data(4).data.target); % get target names
Data(4).data.tITI = repmat(Sets(4).set.tISI,Sets(4).set.nTrials,1); % set ISIs for all trials
Data(4).data.tSequence = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipCue = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipBlank = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipFix = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipStim = nan(Sets(4).set.nTrials,Sets(4).set.nSeqStim); % initalize empty array to record flip time
Data(4).data.tFlipITI = nan(Sets(4).set.nTrials,Sets(4).set.nSeqStim); % initalize empty array to record flip time
Data(4).data.tFlipResp = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tResponse = nan(Sets(4).set.nTrials,1); % initalize empty array to record the time of response

end
