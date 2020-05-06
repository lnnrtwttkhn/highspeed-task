%% HIGHSPEED MRI TASK - SETTINGS FILE
% Lennart Wittkuhn, Independent Max Planck Research Group NeuroCode, 2018
% Max Planck Institute for Human Development, Berlin, Germany
% Contact: wittkuhn@mpib-berlin.mpg.de

function [Sets,Data,Basics,Parameters,Sounds] = highspeed_settings
%% DEFINE EXPERIMENTAL PARAMETERS:

% DISPLAY TASK PROGRESS
fprintf('--------------------------------------------\n') % display task progress
fprintf('Task settings\n') % display task progress
fprintf('--------------------------------------------\n') % display task progress

% GET COMPUTER DETAILS
Parameters.computerName = computer; % save information about computer
Parameters.computerMatlab = ['R' version('-release')]; % save information about operating systemversion('-release')
try
    Parameters.computerHost = char(getHostName(java.net.InetAddress.getLocalHost));
catch ME
    Parameters.computerHost = 'undefined';
    clear ME
end
    
% SET ROOT PATHS DEPENDING ON THE COMPUTER
if strcmp(Parameters.computerHost,'lip-osx-003854') % lennart's macbook
    Parameters.pathRoot = fullfile('/Users','wittkuhn','Seafile'); % set root path
elseif strcmp(Parameters.computerHost,'lip-osx-004174') % imac in neurocode office
    Parameters.pathRoot = fullfile('/Users','Shared','Seafile'); % set root path
elseif strcmp(Parameters.computerHost,'LIP-XP-165-167') % computer at the mpib mri center
    Parameters.pathRoot = fullfile('D:','Dokumente und Einstellungen', 'guest','Desktop','NeuroCode_Lennart'); % set root path
elseif strcmp(Parameters.computerHost,'NRCD-W7-472062') % windows computer in neurocode testing room 305
    Parameters.pathRoot = fullfile('D:','NeuroCode_Lennart','Seafile'); % set root path
end

% TRY TO ADD PSYCHTOOLBOX TO THE MATLAB SEARCH PATH
addpath(genpath(fullfile('..','Psychtoolbox-3','Psychtoolbox')))
Parameters.pathPsychtoolbox = fullfile(PsychtoolboxRoot); % set root path
try
    Psychtoolboxversion
catch ME
    if strcmp(ME.identifier,'MATLAB:UndefinedFunction')
        fprintf(2,'Psychtoolbox was not found in the MATLAB search path!\n');
        fprintf(1,'Trying to add Psychtoolbox to the MATLAB search path now...\n');
        addpath(genpath(Parameters.pathPsychtoolbox));
    end
    clear ME
end
Parameters.computerPTB = sscanf(PsychtoolboxVersion,'%s-'); % save psychtoolbox version
fprintf('Psychtoolbox was added to the MATLAB search path.\n'); % display task progress
fprintf('--------------------------------------------\n') % display task progress

% TRY TO ACCESS THE SCANNER PORT
try
    fprintf('Trying to read the scanner port now...\n'); % display task progress
    outportb(890,32) % sets pin for tristate in base+2 to up state. This allows to read from the scanner port.
catch
    warning('Reading from the scanner port was not successful!'); % display warning
end

% SET TASK PATHS
Parameters.studyName = 'highspeed_task';
Parameters.pathTask = fullfile(Parameters.pathRoot); % path to the task folder
Parameters.pathScripts = fullfile(Parameters.pathTask,'scripts'); % path to the task script folder
Parameters.pathPlots = fullfile(Parameters.pathTask,'plots'); % path to the task plot folder
Parameters.pathStimuli = fullfile(Parameters.pathTask,'stimuli'); % path to the task stimuli folder
Parameters.pathSounds = fullfile(Parameters.pathTask,'sounds'); % path to the task sounds folder
Parameters.pathData = fullfile(Parameters.pathTask,'data'); % path to the task data folder
cd(Parameters.pathScripts) % set the current directory to the script folder

% CHECK IF DATA DIRECTORY ALREADY EXISTS AND CREATE IF NOT
Parameters.dirTask = dir(Parameters.pathTask); % get information about task directory
Parameters.dirTask = {Parameters.dirTask.name}; % get folder names in the task directors
if ~any(strcmp(Parameters.dirTask,'data')) % check whether data directory exists
    fprintf('--------------------------------------------\n') % display task progress
    fprintf('Could not find the data directory. Will initalize a data directory now...\n') % display task progress
    mkdir(Parameters.pathTask,'data'); % create the data directory
    fprintf('Data directory was successfully initalized!\n') % display task progress
    fprintf('--------------------------------------------\n') % display task progress
else
end

% CALL KBQUEUE COMMANDS ONCE, TO AVOID CONFLICT WITH GETCHAR
KbQueueCreate; % initalize response queue
KbQueueStop; % stop queue for now

% DUMMY CALLS TO PSYCHTOOLBOX FUNCTIONS:
KbCheck(-1); % dummy call to KbCheck
WaitSecs(0.1); % dummay call to WaitSecs
GetSecs; clear ans; % dummy call to GetSecs

% INITALIZE RANDOM NUMBER GENERATOR:
rng(sum(100*clock)); % initalize random number generator

% SCREEN SETTINGS:
if strcmp(Parameters.computerHost,'LIP-XP-165-167') % computer at the MPIB MRI center
    Parameters.screenID = 1; % choose screen 1
else
    Parameters.screenID = max(Screen('Screens')); % choose the highest screen
    % Parameters.screenID = 0; % choose the lowest screen
end
[Parameters.screenSize(1), Parameters.screenSize(2)] = Screen('WindowSize',Parameters.screenID); % get the screen size
Parameters.screenResolution = [Parameters.screenSize(1) Parameters.screenSize(2)]; % get screen resolution
Parameters.screenCenterX = Parameters.screenSize(1)/2; % get center of x-axis
Parameters.screenCenterY = Parameters.screenSize(2)/2; % get center of y-axis

% LOAD SOUNDS:
Sounds.soundWaitVolume = 2.5; % set the factor by which the volume of the wait sound should be increased
[Sounds.soundCoinY,Sounds.soundCoinFs] = audioread(fullfile(Parameters.pathSounds,'soundCoin.wav')); % load reward sound
[Sounds.soundErrorY,Sounds.soundErrorFs] = audioread(fullfile(Parameters.pathSounds,'soundError.wav')); % load error sound
[Sounds.soundWaitY,Sounds.soundWaitFs] = audioread(fullfile(Parameters.pathSounds,'soundWait.wav')); % load wait sound
Sounds.soundWaitY = Sounds.soundWaitY*Sounds.soundWaitVolume; % increase the volume of the wait sound
Sounds.soundWaitPlayer = audioplayer(Sounds.soundWaitY,Sounds.soundWaitFs); % create audioplayer for wait sound
play(Sounds.soundWaitPlayer); % start player once
pause(Sounds.soundWaitPlayer); % pause player immediately again

% SET TEXT AND KEY PARAMETERS:
if strcmp(Parameters.computerHost,'LIP-XP-165-167') % mri center computer
    Parameters.textSize = 30; % text size
else
    Parameters.textSize = 50; % text size
end
Parameters.textFont = 'Helvetica'; % font type
Parameters.textColorBlack = [0 0 0]; % rgb code for color black
KbName('UnifyKeyNames'); % ensure cross-platform compatibility of keynaming
Parameters.keyTargetsNames = {'left','right'}; % names of response options
Parameters.keyTargetsLeft = [KbName('LeftArrow'),KbName('b'),KbName('z')]; % all relevant keys for left responses
Parameters.keyTargetsRight = [KbName('RightArrow'),KbName('g'),KbName('r')]; % all relevant keys for right responses
Parameters.keyList = zeros(1,256); % initalize a key list of 256 zeros
Parameters.keyList([Parameters.keyTargetsLeft,Parameters.keyTargetsRight]) = 1; % set keys of interest to 1
Parameters.screenPosLeft = Parameters.screenCenterX - Parameters.screenCenterX / 4; % position left of the response options
Parameters.screenPosRight = Parameters.screenCenterX + Parameters.screenCenterX / 4; % position right of the response options

% GET THE DEVICE NUMBER:
[Parameters.deviceKeyNames,Parameters.deviceNames] = GetKeyboardIndices; % get a list of all devices connected
if ismac
    if strcmp(Parameters.computerHost,'lip-osx-004174') % iMac in NeuroCode office
        Parameters.deviceString = 'Magic Keyboard'; % keyboard name
    else
        Parameters.deviceString = 'Apple Internal Keyboard / Trackpad'; % keyboard name
    end
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
  Parameters.deviceID = Parameters.deviceKeyNames; 
end

Parameters = orderfields(Parameters); % orders all fields in the structure alphabetically

%% INPUT SUBJECT INFO
while true
    
    % USER INPUT: SELECT STUDY MODE:
    Parameters.studyOptions = {'instructions_condition_1','instructions_condition_2','practice','behavioral','mri'}; % study mode options
    Parameters.guiSize = [200,100]; % size of the graphical user inteface (gui)
    [i,~] = listdlg('PromptString','Please choose the study mode:',...
        'SelectionMode','single','ListString',Parameters.studyOptions,'Name','Study mode','ListSize',Parameters.guiSize); % show gui
    Parameters.studyMode = Parameters.studyOptions{i}; % save selection of the study mode
    
    % ENTER PARTICIPANT DETAILS:
    prompt = {'id','age','gender','session','run'}; % define the prompts
    defaultAns = {'99999','99999','m/f/o','1/2','1'}; % define the default answers
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
    elseif ~strcmp(Parameters.subjectInfo.gender,'m') && ~strcmp(Parameters.subjectInfo.gender,'f') && ~strcmp(Parameters.subjectInfo.gender,'o')
        f = msgbox('Gender must be either m, f or o','Error','error');
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
        
        if strcmp(choice,'OK')
            Parameters.subjectInfo.age = str2double(Parameters.subjectInfo.age); % turn into double
            Parameters.subjectInfo.session = str2double(Parameters.subjectInfo.session); % turn into double
            Parameters.subjectInfo.run = str2double(Parameters.subjectInfo.run); % turn into double
        else
            f = msgbox('Process aborted: Please start again!','Error','error');
            uiwait(f);
        end
        
        % CHECK FOR PREVIOUS DATA FILES:
        if ~strcmp(Parameters.studyMode,'mri')
            pattern = strcat(Parameters.studyName,'_', Parameters.studyMode, '_', 'sub', '_', Parameters.subjectInfo.id, '_', 'session', '_', num2str(Parameters.subjectInfo.session));
        elseif strcmp(Parameters.studyMode,'mri')
            pattern = strcat(Parameters.studyName,'_', Parameters.studyMode, '_', 'sub',{'_'}, Parameters.subjectInfo.id);
        end
        Parameters.dirDataSub = dir(fullfile(Parameters.pathData)); % get list of files in data directory
        Parameters.dirDataSub = {Parameters.dirDataSub.name}; % get cell array of files names in data directory
        Parameters.prevData = fliplr(Parameters.dirDataSub(~cellfun(@isempty,regexp(Parameters.dirDataSub,pattern))));
        if isempty(Parameters.prevData)
            if strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
                Parameters.subjectInfo.cbal = str2double(inputdlg('cbal','Enter cbal',1)); % create and show dialog box
            else
                Parameters.subjectInfo.cbal = NaN; % create and show dialog box
            end
            break
        elseif ~isempty(Parameters.prevData) && ~strcmp(Parameters.studyMode,'mri')
            f = msgbox('ID has already been used for this study setup!','Error','error');
            uiwait(f);
        elseif ~isempty(Parameters.prevData) && strcmp(Parameters.studyMode,'mri')
            while true
                if ~cellfun(@isempty,regexp(Parameters.prevData,strcat('session', '_', num2str(Parameters.subjectInfo.session)),'once'))
                    f = warndlg('Found data of the current session!','Warning!');
                    uiwait(f);
                else
                end
                [i,~] = listdlg('PromptString','Please choose the data that should be loaded:',...
                    'SelectionMode','single','ListString',Parameters.prevData,'Name','Load previous data','ListSize',[350,150]); % list of previous data
                pattern = Parameters.prevData{i}; % name of the data file that is to be loaded
                choice = questdlg([{'Do you really want to load this data file?'};{''};pattern],'Continue?','Cancel','OK','OK'); % check inputs by user
                if strcmp(choice,'OK')
                    load(fullfile(Parameters.pathData,pattern),'Data','Sets','Basics') % load the previous data file
                    fprintf('--------------------------------------------\n') % display task progress
                    fprintf('Previous data file was successfully loaded: %s\n',pattern) % display task progress
                    break
                else
                end
            end
            return % return the function
        end
    end
end  

% PRINT TASK SETTINGS TO COMMAND WINDOW:
fprintf('--------------------------------------------\n')
fprintf(1,'study mode: %s\n',Parameters.studyMode);
fprintf(1,'id: %s\n',Parameters.subjectInfo.id);
fprintf(1,'gender: %s\n',Parameters.subjectInfo.gender);
fprintf(1,'session: %d\n',Parameters.subjectInfo.session);
fprintf(1,'run: %d\n',Parameters.subjectInfo.session);
fprintf(1,'cbal: %d\n',Parameters.subjectInfo.cbal);
fprintf('--------------------------------------------\n')

%% TASK BASICS

% INDICES FOR THE DIFFERENT TASK CONDITIONS
idxFlash = 2;
idxOneTwo = 3;
idxOneTwoExtra = 4;

% DEFINE STUDY MODE SPECIFIC PARAMETERS
if ~isempty(regexp(Parameters.studyMode,'instructions','once')) || strcmp(Parameters.studyMode,'practice')
    Basics.nSession = 1; % total number of sessions
    Basics.nRun = 1; % total number of runs
elseif strcmp(Parameters.studyMode,'behavioral')
    Basics.nSession = 1; % total number of sessions
    Basics.nRun = 8; % total number of runs
elseif strcmp(Parameters.studyMode,'mri')
    Basics.nSession = 2; % total number of sessions
    Basics.nRun = 8; % total number of runs
end

% MRI-RELATED PARAMETERS
Basics.scannerPort = 888; % scanner port
Basics.triggerSwitches = 5; % number of TRs before the experiment starts

% GENERAL TASK PARAMETERS
Basics.stimNames = transpose({'Gesicht','Haus','Katze','Schuh','Stuhl'}); % list of all stimulus names
Basics.nStimCat = numel(Basics.stimNames); % number of stimulus categories
Basics.dotType = 1; % define the dot type (selected 1 for emphasis on improved performance)
Basics.dotSize = 15; % define the size of the dot, in pixels
Basics.dotColor = [105 105 105]; % define the color of the dot as rgb code
Basics.reward = 0.03; % reward in cents for each correct response
Basics.tPreFixation = 3.850; % duration of blank screen before fixation, in seconds
Basics.tFixation = 0.300; % duration of fixation, in seconds
Basics.tTargetCue = 1.0; % duration of target cue presentation, in seconds
Basics.tMaxSeqTrial = 16; % duration of one sequence trial, in seconds
Basics.tResponseLimit = 1.5; % response time limit, in seconds
Basics.tWaitEndScreen = 3; % determines how long the end screen will be shown
for i = 1:Basics.nStimCat % preload the task stimuli (pictures)
    currentStimulusName = Basics.stimNames{i}; % get the current stimulus name
    theImageLocation = fullfile(Parameters.pathStimuli,[currentStimulusName,'.jpg']);% create image path
    Basics.stimImages(i).img = imread(theImageLocation); % read the image
end

%% ODDBALL TRIALS

% STUDYMODE-SPECIFIC PARAMETERS:
if ~isempty(regexp(Parameters.studyMode,'instructions','once')) || strcmp(Parameters.studyMode,'practice')
  Sets(1).set.nSeq = 5; % number of unique category combinations / number of training trials
  Sets(1).set.sequences = datasample(perms(1:Basics.nStimCat),Sets(1).set.nSeq,'Replace',false); % randomly pick sequences of stimuli
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
  Sets(1).set.nSeq = factorial(Basics.nStimCat); % number of unique category combinations / number of training trials
  Sets(1).set.sequences = perms(1:Basics.nStimCat); % create a matrix with all possible sequences ... 
  Sets(1).set.sequences = Sets(1).set.sequences(randperm(size(Sets(1).set.sequences,1)),:); % ... and randomly shuffle the order
end

% GENERAL CONDITION PARAMETERS:
Sets(1).set.trialName = 'oddball'; % name of the trial type
Sets(1).set.nSeqStim = Basics.nStimCat; % length of a training sequence (i.e., number of elements)
Sets(1).set.nTrials = Sets(1).set.nSeq * Basics.nStimCat; % total number of stimuli presentations (to have every category in every combination)
Sets(1).set.nTrialsPerRun = Sets(1).set.nTrials/Basics.nRun; % total number of trials per run
Sets(1).set.tStim = 0.5; % duration of stimulus presentation, in seconds
Sets(1).set.tMeanITI = 1.5; % mean of the exponential distribution, in seconds
Sets(1).set.tTotalITI = 2.5; % total mean ITI duration across the entire experiment, in seconds
Sets(1).set.tTotalITIPerRun = Sets(1).set.tTotalITI * Sets(1).set.nTrials / Basics.nRun; % total ITI duration per run, in minutes
Sets(1).set.distLowerLim = 1.5; % lower limit of the ITI exponential distribution
Sets(1).set.ratioTarget = 0.2; % 20% of all trials are upside-down trials
Sets(1).set.nTargetPerCat = Sets(1).set.nSeq * Sets(1).set.ratioTarget; % number of upside down trials per category
Sets(1).set.dataIndices = transpose(reshape(1:Sets(1).set.nTrials,Sets(1).set.nSeqStim,Sets(1).set.nSeq)); % create matrix to index the response data matrix
Sets(1).set.tTrial = Basics.tPreFixation + (Basics.tFixation + Sets(1).set.tStim + Sets(1).set.tTotalITI) * Basics.nStimCat; % duration of one training trial, in seconds
Sets(1).set.tCond = Sets(1).set.tTrial * Sets(1).set.nSeq / 60; % duration of all training trials, in minutes
Sets(1).set.tCondPerRun = Sets(1).set.tCond / Basics.nRun; % average expected duration of condition per run
Sets(1).set = orderfields(Sets(1).set); % orders all fields in the structure alphabetically

% CREATE DATA TABLE
Data(1).data = dataset; % create an empty table for the data of the training trials
Data(1).data.id = repmat({Parameters.subjectInfo.id},Sets(1).set.nTrials,1); % add id
Data(1).data.trial = transpose(1:Sets(1).set.nTrials); % add a trial counter
Data(1).data.session = nan(Sets(1).set.nTrials,1); % add a session counter
Data(1).data.run = nan(Sets(1).set.nTrials,1); % add a run counter
Data(1).data.stimIndex = reshape(transpose(Sets(1).set.sequences),[Sets(1).set.nTrials,1]); % reshaped array of random sequences
Data(1).data.targetName = Basics.stimNames(Data(1).data.stimIndex); % get the stimulus name for each trial
Data(1).data.orient = zeros(Sets(1).set.nTrials,1); % initalize array for random stimulus orientation (0 (= upright presentation) as default)
for k = 1:Basics.nStimCat % determine the (random) occurences of oddballs (equal number of oddballs for each stimulus)
     Data(1).data.orient(datasample(find(Data(1).data.stimIndex == k),Sets(1).set.nTargetPerCat,'Replace',false)) = 180; % set stimulus orientation to 180 (degree)
end

% % SAMPLE ITIs FROM EXPONENTIAL DISTRIBUTION (MATLAB 2012 VERSION WORKAROUND)
% Data(1).data.tITI = nan(Sets(1).set.nTrials,1); % initalize
% for i = 1:Sets(1).set.nTrials
%     while isnan(Data(1).data.tITI(i)) || Data(1).data.tITI(i) < Sets(1).set.distLowerLim
%         Data(1).data.tITI(i) = exprnd(Sets(1).set.tMeanITI);
%     end
% end

% SAMPLE ITIs FROM EXPONENTIAL DISTRIBUTION (WITH FIXED RUN DURATION)
index = reshape(1:Sets(1).set.nTrials,Sets(1).set.nTrialsPerRun,Basics.nRun);
Data(1).data.tITI = nan(Sets(1).set.nTrials,1); % initalize
for run = 1:Basics.nRun
    Data(1).data.tITI(index(:,run)) = exprnd(Sets(1).set.tMeanITI,1,Sets(1).set.nTrialsPerRun) + Sets(1).set.distLowerLim; % draw from exponential distribution
    Data(1).data.tITI(index(:,run)) = Data(1).data.tITI(index(:,run))/sum(Data(1).data.tITI(index(:,run))); % normalized
    Data(1).data.tITI(index(:,run)) = Data(1).data.tITI(index(:,run)) * Sets(1).set.tTotalITIPerRun; % multiply by duration of run ITIs
end

% % % TEST THE DISTRIBUTION
% index = reshape(1:600,600/Basics.nRun,Basics.nRun);
% for run = 1:Basics.nRun
%     sumArray(run) = sum(Data(1).data.tITI(index(:,run)));
%     meanArray(run) = mean(Data(1).data.tITI(index(:,run)));
% end
% figure()
% histogram(Data(1).data.tITI)
% min(Data(1).data.tITI)
% max(Data(1).data.tITI)
% sumArray % sum duration of all itis
% meanArray % mean it of every run
% abs(min(sumArray)-max(sumArray)) % maximum time difference between runs

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

%% SEQUENCE TRIALS

% GENERAL CONDITION PARAMETERS:
Sets(2).set.trialName = 'sequence'; % name of the trial type
Sets(2).set.nSeqStim = Basics.nStimCat; % length of an object sequence (i.e., number of elements)
Sets(2).set.tStim = 0.1; % duration of stimulus presentation, in seconds
Sets(2).set.tISI = transpose(2.^(5:11)/1000); % ISI of flashes, in seconds (exponents of 2)
Sets(2).set.tISI(Sets(2).set.tISI == 0.2560)  = []; % do not use ISI of 256 ms
Sets(2).set.tISI(Sets(2).set.tISI == 1.0240)  = []; % do not use ISI of 1024 ms
if ~isempty(regexp(Parameters.studyMode,'instructions', 'once')) || strcmp(Parameters.studyMode,'practice')
    Sets(2).set.nSeq = 1; % total number of object sequences per participant
    Sets(2).set.tISI = vertcat(min(Sets(2).set.tISI),max(Sets(2).set.tISI)); % only use fastest and slowest ISI for practice and instructions
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Sets(2).set.nSeq = 15; % total number of object sequences per participant
end
Sets(2).set.nISI = numel(Sets(2).set.tISI); % number of ISIs
Sets(2).set.nTrials = Sets(2).set.nSeq * Sets(2).set.nISI; % total number of flash trials
Sets(2).set.tTrial = Basics.tTargetCue + Basics.tPreFixation + Basics.tFixation + Basics.tMaxSeqTrial + Basics.tResponseLimit; % duration of one flash trial
Sets(2).set.tCond =  Sets(2).set.tTrial * Sets(2).set.nTrials / 60; % duration of test phase, in minutes
Sets(2).set.tCondPerRun = Sets(2).set.tCond / Basics.nRun; % average expected duration of condition per run
Sets(2).set.distLowerLim = 1; % lower limit of distribution
Sets(2).set.distUpperLim = 5; % upper limit of distribution
Sets(2).set.dataIndices = repmat(transpose(1:Sets(2).set.nTrials),1,Sets(2).set.nSeqStim); % create matrix to index the response data matrix

% CREATE SEQUENCES:
if ~isempty(regexp(Parameters.studyMode,'instructions', 'once')) || strcmp(Parameters.studyMode,'practice')
    Sets(2).set.sequences = [1 2 3 4 5];
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Sets(2).set.seqPick = transpose(reshape(1:factorial(Basics.nStimCat-1),[],factorial(Basics.nStimCat)/Sets(2).set.nSeq));
    Sets(2).set.sequencesAll = fliplr(perms(1:Basics.nStimCat)); % matrix with all possible sequences
    Sets(2).set.sequences = []; % initalize final array of drawn sequences for the subject
    for k = 1:Basics.nStimCat
        indices = find(Sets(2).set.sequencesAll(:,end) == k);
        pick = Sets(2).set.seqPick(Parameters.subjectInfo.cbal,:);
        Sets(2).set.sequences = vertcat(Sets(2).set.sequences,Sets(2).set.sequencesAll(indices(pick),:));    
    end
end

% CREATE UNIQUE COMBINATIONS OF SEQUENCES AND INTER-STIMULUS-INTERVALS:
[p,q] = meshgrid(1:Sets(2).set.nSeq,1:Sets(2).set.nISI); % create meshgrid
if ~isempty(regexp(Parameters.studyMode,'instructions','once')) || strcmp(Parameters.studyMode,'practice')
    Sets(2).set.flashSelector = [p(:) flipud(q(:))]; % shuffle order of occurence
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Sets(2).set.flashSelector = [p(:) q(:)]; % sorted combination of sequences and ITIs
    Sets(2).set.flashSelector = Sets(2).set.flashSelector(randperm(end),:); % shuffled combination
end
Sets(2).set.sequences = Sets(2).set.sequences(Sets(2).set.flashSelector(:,1),:); % arrange the flash sequences according to the flash selector

% CREATE DATA TABLE:
Data(2).data = dataset; % initalize table
Data(2).data.id = repmat({Parameters.subjectInfo.id},Sets(2).set.nTrials,1); % add id
Data(2).data.trial = transpose(1:Sets(2).set.nTrials); % add a trial counter
Data(2).data.session = nan(Sets(2).set.nTrials,1); % add a session counter
Data(2).data.run = nan(Sets(2).set.nTrials,1); % add a run counter
Data(2).data.stimIndex = Sets(2).set.sequences; % add sequences
Data(2).data.target = nan(Sets(2).set.nTrials,1); % initalize targets
Data(2).data.orient = zeros(Sets(2).set.nTrials,1); % set stimulus orientation to upright for all stimuli
Data(2).data.tITI = Sets(2).set.tISI(Sets(2).set.flashSelector(:,2)); % define inter-stimulus intervals

% SET KEY TARGETS:
if ~isempty(regexp(Parameters.studyMode,'instructions','once')) || strcmp(Parameters.studyMode,'practice')
    Data(2).data.keyTarget = transpose(Shuffle(Parameters.keyTargetsNames)); % once left, once right response for instructions and practice
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Data(2).data.keyTarget = Shuffle(transpose(...
        [repmat(Parameters.keyTargetsNames,1,floor(Sets(2).set.nTrials/numel(Parameters.keyTargetsNames))),...
        Parameters.keyTargetsNames(randi(numel(Parameters.keyTargetsNames)))]));
end

% INITALIZE RESPONSE RELATED VARIABLES AND ADD TO THE DATA FRAME:
Data(2).data.keyIsDown = nan(Sets(2).set.nTrials,1); % initalite empty array to register key presses
Data(2).data.keyIndex = nan(Sets(2).set.nTrials,1); % initialize empty array to record key identity
Data(2).data.acc = nan(Sets(2).set.nTrials,1); % initalize empty array to record accuracy scores
Data(2).data.rt = nan(Sets(2).set.nTrials,1); % initalize empty array to record reaction times

% DRAW TARGET POSITIONS FROM POISSON DISTRIBUTION:
Sets(2).set.distLamba = 1.9; % lamda parameteter of the poisson distribution
Sets(2).set.distPoisson = poisspdf(1:Basics.nStimCat,Sets(2).set.distLamba) / sum(poisspdf(1:Basics.nStimCat,Sets(2).set.distLamba)); % create possion pdf
if ~isempty(regexp(Parameters.studyMode,'instructions','once')) || strcmp(Parameters.studyMode,'practice')
    Sets(2).set.distNumValues = round(Sets(2).set.distPoisson * Sets(2).set.nTrials); % draw absolute number of respective target positons
    Data(2).data.targetPos = transpose(Shuffle(cell2mat(arrayfun(@(x,y) repmat(x,1,y), Basics.nStimCat:-1:1,Sets(2).set.distNumValues,'uni',0)))); % define target positions
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Data(2).data.targetPos = nan(Sets(2).set.nTrials,1); % initalize
    for i = 1:Sets(2).set.nISI
        idx = Sets(2).set.flashSelector(:,2) == i; % find flash sequences
        Sets(2).set.distNumValues = round(Sets(2).set.distPoisson * Sets(2).set.nSeq); % draw absolute number of respective target positons
        Data(2).data.targetPos(idx) = transpose(Shuffle(cell2mat(arrayfun(@(x,y) repmat(x,1,y), Basics.nStimCat:-1:1,Sets(2).set.distNumValues,'uni',0)))); % define target positions
    end
end

% DEFINE TARGETS AND ALTERNATIVE RESPONSE OPTIONS:
Data(2).data.targetPosAlt = nan(Sets(2).set.nTrials,1); % initalize
for j = 1:Sets(2).set.nTrials
    Data(2).data.target(j) = Data(2).data.stimIndex(j,Data(2).data.targetPos(j)); % defines the target
    while isnan(Data(2).data.targetPosAlt(j)) || Data(2).data.targetPosAlt(j) == Data(2).data.targetPos(j)
        Data(2).data.targetPosAlt(j) = sum(rand >= cumsum([0, Sets(2).set.distPoisson]));
    end
end

% DEFINE TARGET NAMES:
Data(2).data.targetName = Basics.stimNames(Data(2).data.target); % get target names

% INITIALIZE EMPTY ARRAYS TO RECORD RESPONSES AND STIMULUS TIMINGS:
Data(2).data.tSequence = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipCue = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipBlank = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipFix = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipStim = nan(Sets(2).set.nTrials,Sets(2).set.nSeqStim); % initalize empty array to record flip time
Data(2).data.tFlipITI = nan(Sets(2).set.nTrials,Sets(2).set.nSeqStim); % initalize empty array to record flip time
Data(2).data.tFlipDelay = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tFlipResp = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Data(2).data.tResponse = nan(Sets(2).set.nTrials,1); % initalize empty array to record flip time
Sets(2).set = orderfields(Sets(2).set); % orders all fields in the structure alphabetically

%% REPETITION TRIALS (SHORT) 

% GENERAL CONDITION PARAMETERS:
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
Sets(3).set.tTrial = Basics.tTargetCue + Basics.tPreFixation + Basics.tFixation + Basics.tMaxSeqTrial + Basics.tResponseLimit;
Sets(3).set.tCond = Sets(3).set.tTrial * Sets(3).set.nTrials / 60; % duration of one two phase, in minutes
Sets(3).set.tCondPerRun = Sets(3).set.tCond / Basics.nRun; % average expected duration of condition per run

% CREATE SEQUENCES:
Sets(3).set.sequences = []; % initalize empty matrix
for x = 1:Sets(3).set.nRep
    a = transpose(randperm(Basics.nStimCat)); % generate a random sequence of all object categories
    a(a == x) = []; % delete the current first category (x)
    oneTwoSequence = repmat(vertcat(a,flipud(a)),1,Sets(3).set.nSeqStim);
    oneTwoSequence = fliplr(tril(oneTwoSequence,0));
    oneTwoSequence(oneTwoSequence == 0) = x;
    Sets(3).set.sequences = vertcat(Sets(3).set.sequences,oneTwoSequence);
end
Sets(3).set.sequences = Sets(3).set.sequences(randperm(end),:); % randomly shuffle all sequences
Sets(3).set = orderfields(Sets(3).set); % orders all fields in the structure alphabetically

% CREATE DATA FRAME:
Data(3).data = dataset; % initalize empty table
Data(3).data.id = repmat({Parameters.subjectInfo.id},Sets(3).set.nTrials,1); % add id
Data(3).data.trial = transpose(1:Sets(3).set.nTrials); % set trial counter
Data(3).data.session = nan(Sets(3).set.nTrials,1); % add a session counter
Data(3).data.run = nan(Sets(3).set.nTrials,1); % add a run counter
Data(3).data.stimIndex = Sets(3).set.sequences; % set sequences
Data(3).data.orient = zeros(Sets(3).set.nTrials,1); % set orientation of all stimuli to upright
Data(3).data.keyTarget = Shuffle(transpose(repmat(Parameters.keyTargetsNames,1,Sets(3).set.nTrials/numel(Parameters.keyTargetsNames))));
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

% CREATE ALTERNATIVE TARGET POSITIONS
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
Data(3).data.tFlipDelay = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time
Data(3).data.tFlipResp = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time
Data(3).data.tResponse = nan(Sets(3).set.nTrials,1); % initalize empty array to record flip time

%% REPETITION TRIALS (LONG)

% GENERAL CONDITION PARAMETERS:
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
Sets(4).set.tCondPerRun = Sets(4).set.tCond / Basics.nRun; % average expected duration of condition per run

% CREATE SEQUENCES:
Sets(4).set.sequences = repmat(transpose(1:Basics.nStimCat),Sets(4).set.nRep,Sets(4).set.nSeqStim); % create sequences of extra oneTwo Trials
while any(Sets(4).set.sequences(:,end) == Sets(4).set.sequences(:,end-1)) % while the last and second-to-last element of any row are the same ...
    Sets(4).set.sequences(:,end) = transpose(randperm(Basics.nStimCat)); % ... change the last elements of rows randomly
end
Sets(4).set.sequences = Sets(4).set.sequences(randperm(end),:); % randomly shuffle all sequences
Sets(4).set = orderfields(Sets(4).set); % orders all fields in the structure alphabetically

% CREATE DATA TABLE:
Data(4).data = dataset; % initalize data table
Data(4).data.id = repmat({Parameters.subjectInfo.id},Sets(4).set.nTrials,1); % add id
Data(4).data.trial = transpose(1:Sets(4).set.nTrials); % add a trial counter
Data(4).data.session = nan(Sets(4).set.nTrials,1); % add a session counter
Data(4).data.run = nan(Sets(4).set.nTrials,1); % add a run counter
Data(4).data.stimIndex = Sets(4).set.sequences; % add sequences
Data(4).data.orient = zeros(Sets(4).set.nTrials,1); % set orientation of all stimuli to upright
Data(4).data.keyTarget = Shuffle(transpose([repmat(Parameters.keyTargetsNames,1,2),Parameters.keyTargetsNames(randi(numel(Parameters.keyTargetsNames)))])); % key targets
Data(4).data.keyIsDown = nan(Sets(4).set.nTrials,1); % initalite empty array to register key presses
Data(4).data.keyIndex = nan(Sets(4).set.nTrials,1); % initialize empty array to record key identity
Data(4).data.acc = nan(Sets(4).set.nTrials,1); % initalize empty array to record accuracy scores
Data(4).data.rt = nan(Sets(4).set.nTrials,1); % initalize empty array to record reaction times
Data(4).data.target = Data(4).data.stimIndex(:,end); % define targets
Data(4).data.targetPos = repmat(Sets(4).set.nSeqStim,Sets(4).set.nTrials,1); % define target positions
Data(4).data.targetPosAlt = Data(4).data.targetPos-transpose(randsample(Sets(3).set.respDiff-1:Sets(3).set.respDiff + 1,5,true)); % set alternative target options
Data(4).data.targetName = Basics.stimNames(Data(4).data.target); % get target names
Data(4).data.tITI = repmat(Sets(4).set.tISI,Sets(4).set.nTrials,1); % set ISIs for all trials
Data(4).data.tSequence = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipCue = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipBlank = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipFix = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipStim = nan(Sets(4).set.nTrials,Sets(4).set.nSeqStim); % initalize empty array to record flip time
Data(4).data.tFlipITI = nan(Sets(4).set.nTrials,Sets(4).set.nSeqStim); % initalize empty array to record flip time
Data(4).data.tFlipDelay = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tFlipResp = nan(Sets(4).set.nTrials,1); % initalize empty array to record flip time
Data(4).data.tResponse = nan(Sets(4).set.nTrials,1); % initalize empty array to record the time of response

%% TRIAL STRUCTURE

% DEFINE TRIAL STRUCTURE DEPENDING ON THE TASK CONDITION
if strcmp(Parameters.studyMode,'instructions_condition_1')
    Basics.trialStructure = ones(5,1);
elseif strcmp(Parameters.studyMode,'instructions_condition_2')
    Basics.trialStructure = transpose([2 2 3 3 4]);
elseif strcmp(Parameters.studyMode,'practice')
    Basics.trialStructure = reshape(transpose(horzcat(ones(5,1),Shuffle(vertcat(repmat(2,2,1),repmat(3,2,1),repmat(4,1,1))))),10,1);
elseif strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    Basics.allSeqTrials = [repmat(idxFlash,Sets(2).set.nTrials,1);repmat(idxOneTwo,Sets(3).set.nTrials,1);repmat(idxOneTwoExtra,Sets(4).set.nTrials,1)]; % create array with all sequence trials
    Basics.allSeqTrials = Shuffle(Basics.allSeqTrials); % shuffle all sequence trials
    % CREATE THE TRIAL SEQUENCE, WITH ODDBALL, SEQUENCE AND REPETITION TRIALS INTERLEAVED
    Basics.trialStructure = [ones(length(Basics.allSeqTrials),1),Basics.allSeqTrials]; % create trial structure as matrix
    Basics.trialStructure = reshape(transpose(Basics.trialStructure),[numel(Basics.trialStructure),1]); % reshape as vector
end

% DEFINE SOME FINAL TRIAL BASICS
Basics.nTrials = length(Basics.trialStructure); % number of trials in total
Basics.nTrialsRun = Basics.nTrials/Basics.nRun; % number of trials per run
Basics.nTrialsSession = Basics.nTrials/Basics.nSession; % number of trials per session
Basics.nRunSession = Basics.nRun/Basics.nSession; % number of runs per session
Basics.breakTrials = reshape(1:Basics.nTrialsRun:Basics.nTrials,Basics.nRunSession,Basics.nSession); % define break trials

% CREATE A TABLE WITH RUN INFO:
Basics.runInfo = dataset;
Basics.runInfo.id = repmat({Parameters.subjectInfo.id},Basics.nRun,1); % add id
Basics.runInfo.session = reshape(repmat(1:Basics.nSession,Basics.nRunSession,1),Basics.nRun,1);
Basics.runInfo.run = reshape(repmat(1:Basics.nRunSession,1,Basics.nSession),Basics.nRun,1);
Basics.runInfo.tTrigger = nan(Basics.nRun,Basics.triggerSwitches); % initalize empty array to record run time
Basics.runInfo.tRunStart = nan(Basics.nRun,1); % initalize empty array to record run time
Basics.runInfo.tRunStop = nan(Basics.nRun,1); % initalize empty array to record run time
Basics.runInfo.tRunTotal = nan(Basics.nRun,1); % initalize empty array to record run time

Basics = orderfields(Basics); % orders all fields in the structure alphabetically

end
