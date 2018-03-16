%% HIGHSPEED MRI TASK - MAIN FILE
% Lennart Wittkuhn, Independent Max Planck Research Group NeuroCode, 2018
% Max Planck Institute for Human Development, Berlin, Germany
% Contact: wittkuhn@mpib-berlin.mpg.de

function [Sets,Data,Basics,Parameters] = highspeed_main(Sets,Data,Basics,Parameters,Sounds)

% DEFINE CONDITION INDICES
idxTrain = 1;
idxFlash = 2;
idxOneTwo = 3;
idxOneTwoExtra = 4;

% PSYCHTOOLBOX SETTINGS
Screen('Preference','SkipSyncTests',1); % for maximum accuracy and reliability
Screen('Preference','VisualDebugLevel',3);
Screen('Preference','SuppressAllWarnings',1);
Screen('Preference','Verbosity',2);
set(0,'DefaultFigureWindowStyle','normal');
Screen('Preference','TextEncodingLocale','UTF-8'); % set text encoding preference to UTF-8
Screen('Preference', 'TextRenderer', 0);

% OPEN WINDOW
Parameters.window = Screen('OpenWindow', Parameters.screenID); % open screen
Priority(MaxPriority(Parameters.window)); % raise Matlab to realtime-priority mode to get the highest suitable priority
Screen('TextFont', Parameters.window, Parameters.textFont); % select specific text font
Screen('TextSize', Parameters.window, Parameters.textSize); % select specific text size
Screen('BlendFunction',Parameters.window, 'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); % set the blend function
HideCursor(); % hide the cursor
ListenChar(2); % suppress echo to the command line for keypresses
KbName('UnifyKeyNames'); % used for cross-platform compatibility of keynaming
RestrictKeysForKbCheck([KbName('LeftArrow'),KbName('RightArrow')]); % restrict keys for KbCheck
Parameters.flipInterval = Screen('GetFlipInterval', Parameters.window); % get the monitor flip interval

% START SCREEN: WELCOME PARTICIPANTS TO THE EXPERIMENT
DrawFormattedText(Parameters.window,'Willkommen zur Aufgabe "Visuelle Objekte Erkennen"!','center','center',Parameters.textColorBlack);
if strcmp(Parameters.studyMode,'mri')
    DrawFormattedText(Parameters.window, 'Bitte warten Sie auf die Versuchsleitung.','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
else
    DrawFormattedText(Parameters.window, 'Start mit beliebiger Pfeiltaste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
end
Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
Screen('Flip',Parameters.window); % flip to the screen
VBLTime = KbPressWait(Parameters.deviceID); % save key press time
waitSecs = 0; % define stimulus duration

% PRINT TASK PROGRESS TO COMMAND WINDOW:
fprintf('--------------------------------------------\n')
fprintf('Start task\n')

% START THE RESPONSE QUEUE
KbQueueCreate(Parameters.deviceID,Parameters.keyList); % creates queue, restricted to the relevant key targets
KbQueueStart(Parameters.deviceID); % starts queue

% MAIN TASK LOOP
for run = Parameters.subjectInfo.run:Basics.nRunSession
    
    % START THE NEXT RUN OF THE EXPERIMENT:
    fprintf('--------------------------------------------\n'); % display task progress
    fprintf('Starting run %d of %d (current session)\n',run,Basics.nRunSession); % display task progress
    trialStart = Basics.breakTrials(run,Parameters.subjectInfo.session); % first trial index of the current run
    trialStop = trialStart + Basics.nTrialsRun - 1; % last trial index of the current run
    fprintf('--------------------------------------------\n'); % display task progress
    
    % MRI STUDY MODE: WAIT FOR MRI TRIGGER TO START THE NEXT RUN:
    if strcmp(Parameters.studyMode,'mri')
        DrawFormattedText(Parameters.window,'Bereit? Das Experiment startet gleich nach dem Countdown!','center','center',Parameters.textColorBlack);
        Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
        VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
        fprintf('Waiting for MRI scanner triggers...\n'); % display task progress
        try
            Basics.startState = inportb(Basics.scannerPort); % read from the scanner port
            oldState = Basics.startState; % save old trigger state in a separate variable
            triggerCounter = 0; % initalize the trigger counter
            while triggerCounter < Basics.triggerSwitches
                newState = inportb(Basics.scannerPort); % read from the scanner port
                if newState ~= oldState
                    triggerCounter = triggerCounter + 1; % update the trigger counter
                    Basics.runInfo.tTrigger(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run,triggerCounter) = GetSecs;
                    DrawFormattedText(Parameters.window,num2str(Basics.triggerSwitches-triggerCounter),'center','center',Parameters.textColorBlack);
                    Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
                    VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
                end
                oldState = newState; % update the old state
            end
            fprintf('MRI triggers were successfully recorded!\n'); % display task progress
        catch
            warning('MRI triggers are not working properly!') % display warning
        end
    end
    
    Basics.runInfo.tRunStart(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run) = GetSecs; % start run start time
    
    for trial = trialStart:trialStop
        
        % DEFINE THE CURRENT TASK CONDITION:
        cond = Basics.trialStructure(trial); % get the current condition (i.e., oddball, sequence or repetition trial)
        
        % DISPLAY THE TASK PROGRESS IN THE COMMAND WINDOW:
        fprintf('--------------------------------------------\n') % display task progress
        fprintf('Starting trial %d of %d (total trials)\n',trial,length(Basics.trialStructure)) % display task progress
        fprintf('Starting trial %d of %d (current session)\n',trial,Basics.nTrialsSession*Parameters.subjectInfo.session) % display task progress
        fprintf('Starting trial %d of %d (current run)\n',trial,trialStop) % display task progress
        fprintf('Trial type: %s\n',Sets(cond).set.trialName) % display current trial type
        
        % UPDATE THE TRIAL COUNTER OF THE CURRENT TASK CONDITION:
        Sets(cond).set.count = sum(ismember(Basics.trialStructure(1:trial),cond));
        
        % SHOW TARGET CUE (SEQUENCE TRIALS ONLY)
        if ismember(cond,[idxFlash idxOneTwo idxOneTwoExtra]) % check if the current trial is a sequence trial
            DrawFormattedText(Parameters.window,Data(cond).data.targetName{Sets(cond).set.count},'center','center',Parameters.textColorBlack); % draw the target name to the screen
            Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
            VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
            Data(cond).data.tFlipCue(Sets(cond).set.count) = VBLTime; % save flip time
            waitSecs = Basics.tTargetCue; % wait for duration of fixation
        end
        
        % FLIP BLANK SCREEN (I.E., PRE FIXATION DELAY)
        VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
        Data(cond).data.tFlipBlank(Sets(cond).set.dataIndices(Sets(cond).set.count,1)) = VBLTime; % save flip time
        waitSecs = Basics.tPreFixation; % wait for duration of pre fixation delay
        
        % SHOW FIXATION CROSS (BEFORE STIMULI LOOP; SEQUENCE TRIALS ONLY)
        if ismember(cond,[idxFlash idxOneTwo idxOneTwoExtra])
%             DrawFormattedText(Parameters.window,'+','center','center',Parameters.textColorBlack); % draw fixation cross to screen
            Screen('DrawDots',Parameters.window,[Parameters.screenCenterX,Parameters.screenCenterY],Basics.dotSize,Basics.dotColor,[],Basics.dotType); % draw dot
            Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
            VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
            Data(cond).data.tFlipFix(Sets(cond).set.count) = VBLTime; % save flip time
            waitSecs = Basics.tFixation; % wait for duration of pre fixation delay
        end
        
        % STIMULI LOOP
        for stim = 1:Sets(cond).set.nSeqStim % loop depending on the number of stimuli within the sequence
            
            dataIndex = Sets(cond).set.dataIndices(Sets(cond).set.count,stim); % define the current response index for training trials
            Data(cond).data.session(dataIndex) = Parameters.subjectInfo.session; % write session information into data file
            Data(cond).data.run(dataIndex) = run; % write session information into data file
            
            % SHOW FIXATION CROSS (WITHIN STIMULI LOOP; TRAINING TRIALS ONLY)
            if ismember(cond,idxTrain)
%                 DrawFormattedText(Parameters.window,'+','center','center',Parameters.textColorBlack); % draw fixation cross to screen
                Screen('DrawDots',Parameters.window,[Parameters.screenCenterX,Parameters.screenCenterY],Basics.dotSize,Basics.dotColor,[],Basics.dotType); % draw dot
                Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished#
                VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
                Data(cond).data.tFlipFix(dataIndex) = VBLTime; % save flip time
                waitSecs = Basics.tFixation; % define wait time
            end
            
            % SHOW STIMULUS
            currentStimulus = Sets(cond).set.sequences(Sets(cond).set.count,stim); % get the current stimulus number
            theImage = Basics.stimImages(currentStimulus).img; % read the image
            imageTexture = Screen('MakeTexture', Parameters.window, theImage); % make the image into a texture
            Screen('DrawTexture', Parameters.window, imageTexture,[],[],Data(cond).data.orient(dataIndex)); % draw the image to the screen with corresponding stimulus orientation
            Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
            VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
            waitSecs = Sets(cond).set.tStim; % define wait time
            clear theImage % clear the image to save working power
            
            % CREATE AUDITORY FEEDBACK ANY TIME (TRAINING TRIALS ONLY)
            if ismember(cond,idxTrain) % check if current trial is an oddball trial
                
                Data(cond).data.tFlipStim(dataIndex) = VBLTime; % save flip time
                KbQueueFlush(Parameters.deviceID,1); % clear the response queue (only relevant for training trials)
                
                % COLLECT RESPONSES FROM STIMULUS ONSET TO END OF ISI (NO BREAK)
                while isnan(Data(cond).data.tFlipITI(dataIndex)) || isnan(Data(cond).data.acc(dataIndex))
                    
                    % START TO SHOW ISI (BLANK SCREEN) IF STIMULUS PRESENTATION TIME HAS ELAPSED:
                    % Check if the time of stimulus duration has elapsed since stimulus onset and if the ITI (blank screen) has not been flipped yet
                    if GetSecs >= Data(cond).data.tFlipStim(dataIndex) + Sets(cond).set.tStim - 0.5 * Parameters.flipInterval && isnan(Data(cond).data.tFlipITI(dataIndex))
%                         Screen('DrawDots',Parameters.window,[Parameters.screenCenterX,Parameters.screenCenterY],Basics.dotSize,Basics.dotColor,[],Basics.dotType); % draw dot
                        VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
                        Data(cond).data.tFlipITI(dataIndex) = VBLTime; % save flip time
                        waitSecs = Data(cond).data.tITI(dataIndex); % define wait time
                    end
                    
                    % ONLY CHECK RESPONSES DURING THE RESPONSE INTERVAL
                    if GetSecs - Data(cond).data.tFlipStim(dataIndex) < Basics.tResponseLimit
                        % AS LONG AS NO RESPONSE HAS BEEN MADE, CHECK KEYBOARD
                        if isnan(Data(cond).data.keyIsDown(dataIndex)) || Data(cond).data.keyIsDown(dataIndex) == 0
                            [Data(cond).data.keyIsDown(dataIndex), firstKeyPressTimes] = KbQueueCheck(Parameters.deviceID); %  check if any key was pressed during the previous time period (i.e., since keyboard was flushed)
                            % IF THE PARTICIPANT PRESSED A KEY
                            if Data(cond).data.keyIsDown(dataIndex) == 1 % participant responded
                                % CHECK WHICH KEY WAS PRESSED AND GET RT
                                firstKeyPressTimes(firstKeyPressTimes==0) = NaN; % little trick to get rid of 0s
                                [tResponse,Data(cond).data.keyIndex(dataIndex)] = min(firstKeyPressTimes); % gets the RT of the first key-press and its id
                                Data(cond).data.rt(dataIndex) = tResponse - Data(cond).data.tFlipStim(dataIndex); % calculate and save reaction time
                                Data(cond).data.tResponse(dataIndex) = tResponse; % record the time of the response
                                % CHECK THE CORRECTNESS OF THE RESPONSE AND PLAY CORRESPONDING FEEDBACK SOUND
                                if Data(cond).data.keyIsDown(dataIndex) == 1 && Data(cond).data.orient(dataIndex) == 180 % hit
                                    sound(Sounds.soundCoinY,Sounds.soundCoinFs); % play coin sound
                                    Data(cond).data.acc(dataIndex) = 1; % accuracy for this trial is 1
                                    fprintf('Hit: +%.2f Euro\n',Basics.reward);
                                elseif Data(cond).data.keyIsDown(dataIndex) == 1 && Data(cond).data.orient(dataIndex) == 0 % false alarm
                                    sound(Sounds.soundErrorY,Sounds.soundErrorFs); % play error sound
                                    Data(cond).data.acc(dataIndex) = 0; % accuracy for this trial is 0
                                    fprintf('False alarm: -%.2f Euro\n',Basics.reward);
                                end
                            end
                        end
                    elseif GetSecs - Data(cond).data.tFlipStim(dataIndex) > Basics.tResponseLimit
                        if isnan(Data(cond).data.acc(dataIndex)) % IF NO ACCURACY SCORE HAS BEEN RECORDED YET
                            % IF NO RESPONSE HAS BEEN MADE, CHECK CORRECTNESS AND GIVE FEEDBACK
                            if Data(cond).data.keyIsDown(dataIndex) == 0 && Data(cond).data.orient(dataIndex) == 180 % miss
                                sound(Sounds.soundErrorY,Sounds.soundErrorFs); % play error sound
                                Data(cond).data.acc(dataIndex) = 0; % accuracy for this trial is 0
                                disp('Miss: 0.00 Euro');
                            elseif Data(cond).data.keyIsDown(dataIndex) == 0 && Data(cond).data.orient(dataIndex) == 0 % correct rejection
                                % do not play any sound on trials with correct rejection
                                Data(cond).data.acc(dataIndex) = 1; % accuracy for this trial is 1
                                disp('Correct rejection: 0.00 Euro');
                            end
                        end
                    end
                end
                
            % PROCEDURE FOR SEQUENCE TRIALS AFTER STIMULUS HAS BEEN SHOWN: SHOW ISI (I.E., FLIP BLANK SCREEN)
            elseif ismember(cond,[idxFlash,idxOneTwo,idxOneTwoExtra]) % only on sequence trials
                Data(cond).data.tFlipStim(dataIndex,stim) = VBLTime; % save flip time
                Screen('DrawDots',Parameters.window,[Parameters.screenCenterX,Parameters.screenCenterY],Basics.dotSize,Basics.dotColor,[],Basics.dotType); % draw dot
                VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
                Data(cond).data.tFlipITI(dataIndex,stim) = VBLTime; % save flip time
                waitSecs = Data(cond).data.tITI(dataIndex); % define wait time
            end
        end
        
        % FURTHER PROCEDURE FOR SEQUENCE AND REPETITION TRIALS AFTER STIMULUS LOOP:
        if ismember(cond,[idxFlash idxOneTwo idxOneTwoExtra]) % only for sequence and repetition trials
            
            % WAITING PERIOD AFTER LAST STIMULUS (WAIT UNTIL 16s HAVE ELAPSED)
%             DrawFormattedText(Parameters.window,'+','center','center',Parameters.textColorBlack); % draw fixation cross to screen
            Screen('DrawDots',Parameters.window,[Parameters.screenCenterX,Parameters.screenCenterY],Basics.dotSize,Basics.dotColor,[],Basics.dotType); % draw dot
            Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
            VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
            Data(cond).data.tFlipDelay(dataIndex) = VBLTime; % save flip time
            waitSecs = Basics.tMaxSeqTrial; % define wait time
            resume(Sounds.soundWaitPlayer); % start to play sound during the delay period
            
            % SHOW RESPONSE OPTIONS
            DrawFormattedText(Parameters.window,Data(cond).data.targetName{dataIndex},'center','center',Parameters.textColorBlack); % draw text to screen
            if strcmp(Data(cond).data.keyTarget(dataIndex),'left') % target is left
                DrawFormattedText(Parameters.window,num2str(Data(cond).data.targetPos(dataIndex)),Parameters.screenPosLeft, Parameters.screenCenterY + Parameters.textSize * 5,Parameters.textColorBlack); % show target on the left side
                DrawFormattedText(Parameters.window,num2str(Data(cond).data.targetPosAlt(dataIndex)),Parameters.screenPosRight, Parameters.screenCenterY + Parameters.textSize * 5,Parameters.textColorBlack); % show non-target on the right side
            elseif strcmp(Data(cond).data.keyTarget(dataIndex),'right') % target is right
                DrawFormattedText(Parameters.window,num2str(Data(cond).data.targetPos(dataIndex)),Parameters.screenPosRight, Parameters.screenCenterY + Parameters.textSize * 5,Parameters.textColorBlack); % show target on the right side
                DrawFormattedText(Parameters.window,num2str(Data(cond).data.targetPosAlt(dataIndex)),Parameters.screenPosLeft, Parameters.screenCenterY + Parameters.textSize * 5,Parameters.textColorBlack); % show target on the left side
            end
            Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
            % Only start to show response options after the waiting period has elapsed (i.e., after 16 seconds since the first stimulus):
            VBLTime = Screen('Flip',Parameters.window,Data(cond).data.tFlipStim(dataIndex,1) + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
            pause(Sounds.soundWaitPlayer); % pause sounds during waiting period
            Data(cond).data.tSequence(dataIndex) = VBLTime - Data(cond).data.tFlipStim(dataIndex,1); % calculate and save total duration of sequence
            Data(cond).data.tFlipResp(dataIndex) = VBLTime; % save flip time
            waitSecs = Basics.tResponseLimit; % define wait time
            
            % COLLECT RESPONSE AND BREAK IF RESPONSE WAS MADE
            KbQueueFlush(Parameters.deviceID,1); % clear the response queue
            while GetSecs < (VBLTime + Basics.tResponseLimit) && (isnan(Data(cond).data.keyIsDown(dataIndex))) || Data(cond).data.keyIsDown(dataIndex) == 0
                [Data(cond).data.keyIsDown(dataIndex), firstKeyPressTimes] = KbQueueCheck(Parameters.deviceID); %  check if any key was pressed during the previous time period
                if Data(cond).data.keyIsDown(dataIndex) == 1 || GetSecs > (VBLTime + Basics.tResponseLimit) % participant responded or response time has elapsed
                    break
                end
            end
            
            % CHECK WHICH KEY WAS PRESSED AND GET RT
            firstKeyPressTimes(firstKeyPressTimes==0) = NaN; % little trick to get rid of 0s
            [tResponse,Data(cond).data.keyIndex(dataIndex)] = min(firstKeyPressTimes); % gets the RT of the first key-press and its id
            Data(cond).data.rt(dataIndex) = tResponse - VBLTime; % calculate and save reaction time
            Data(cond).data.tResponse(dataIndex) = tResponse; % record the time of the response
            
            % PLAY FEEDBACK SOUND AND SAVE ACCURACY SCORE:
            if Data(cond).data.keyIsDown(dataIndex) == 1 && ...
                    ((ismember(Data(cond).data.keyIndex(dataIndex),Parameters.keyTargetsLeft) && strcmp(Data(cond).data.keyTarget(dataIndex),'left')) || ...
                    (ismember(Data(cond).data.keyIndex(dataIndex),Parameters.keyTargetsRight) && strcmp(Data(cond).data.keyTarget(dataIndex),'right'))) % correct response
                sound(Sounds.soundCoinY,Sounds.soundCoinFs); % play coin sound
                Data(cond).data.acc(dataIndex) = 1; % accuracy for this trial is 1
                fprintf('Correct: +%.2f Euro\n',Basics.reward);
            elseif Data(cond).data.keyIsDown(dataIndex) == 1 && ...
                    ~(ismember(Data(cond).data.keyIndex(dataIndex),Parameters.keyTargetsLeft) && strcmp(Data(cond).data.keyTarget(dataIndex),'left') || ...
                    ismember(Data(cond).data.keyIndex(dataIndex),Parameters.keyTargetsRight) && strcmp(Data(cond).data.keyTarget(dataIndex),'right')) % correct response
                sound(Sounds.soundErrorY,Sounds.soundErrorFs); % play error sound
                Data(cond).data.acc(Sets(cond).set.count) = 0; % accuracy for this trial is 0
                disp('Incorrect: 0.00 Euro');
            elseif Data(cond).data.keyIsDown(dataIndex) == 0 % no reaction
                sound(Sounds.soundErrorY,Sounds.soundErrorFs); % play error sound
                Data(cond).data.acc(dataIndex) = 0; % accuracy for this trial is 0
                disp('Too slow: 0.00 Euro');
            end
        end
        
        % UPDATE TOTAL CURRENT REWARD:
        Basics.totalWinTrain = sum(Data(idxTrain).data.orient == 180 & Data(idxTrain).data.acc == 1) * Basics.reward; % current total reward from all training trials
        Basics.totalLossTrain = sum(Data(idxTrain).data.orient == 0 & Data(idxTrain).data.keyIsDown == 1) * - Basics.reward; % current total loss from all training trials
        Basics.totalWinSequences = nansum(vertcat(Data(idxFlash).data.acc,Data(idxOneTwo).data.acc,Data(idxOneTwoExtra).data.acc)) * Basics.reward; % current total reward from all sequence trials
        Basics.totalWinAll = Basics.totalWinTrain + Basics.totalLossTrain + Basics.totalWinSequences; % sum all rewards and losses
        
    end
    
    % SAVE DURATION OF THE CURRENT RUN
    Basics.runInfo.tRunStop(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run) = GetSecs; % save run stop time
    Basics.runInfo.tRunTotal(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run) = ...
        Basics.runInfo.tRunStop(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run) - ...
    Basics.runInfo.tRunStart(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run); % save duration of run
    
    % END OF RUN: TIME FOR A BREAK
    if strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
        DrawFormattedText(Parameters.window,'Pause','center',Parameters.textSize * 2,Parameters.textColorBlack);
        DrawFormattedText(Parameters.window,sprintf('Sie haben Durchgang %d von %d geschafft.',run,Basics.nRunSession),'center',Parameters.textSize * 3,Parameters.textColorBlack);
        str = sprintf('Sie haben bisher %.2f Euro verdient!',Basics.totalWinAll);
        DrawFormattedText(Parameters.window,str,'center','center',Parameters.textColorBlack);
        if strcmp(Parameters.studyMode,'mri')
            DrawFormattedText(Parameters.window, 'Sie koennen sich jetzt ausruhen.','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
        else
            DrawFormattedText(Parameters.window, 'Weiter mit beliebiger Pfeiltaste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
        end
        Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
        VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
        fprintf('--------------------------------------------\n') % display task progress
        fprintf('End run %d of %d (current session)\n',run,Basics.nRunSession) % display task progress
        fprintf('Total run duration: %d minutes and %.f seconds\n',...
            floor(Basics.runInfo.tRunTotal(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run)/60),...
            rem(Basics.runInfo.tRunTotal(Basics.runInfo.session == Parameters.subjectInfo.session & Basics.runInfo.run == run),60)); % display run duration
        fprintf('Break. Saving data...\n'); % display current task status
    end
    
    % SAVE THE DATA OF THE CURRENT RUN
    fileName = [strcat(...
        Parameters.studyName,'_',Parameters.studyMode, '_',...
        'sub','_',num2str(Parameters.subjectInfo.id),'_',...
        'session','_',num2str(Parameters.subjectInfo.session),'_',...
        'run','_',num2str(run)),'.mat']; % define file name
    save(fullfile(Parameters.pathData,fileName),'Sets','Data','Basics','Parameters'); % save data
    
    % CONTINUE WITH NEXT RUN
    if strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
        fprintf('Data saved successfully.\n'); % display current task status
        VBLTime = KbPressWait(Parameters.deviceID); % save key press time
        waitSecs = 0; % define wait time
    end
    
end

% STOP SOUND AND RESPONSE QUEUE:
stop(Sounds.soundWaitPlayer); % stop to play sound
KbQueueStop(Parameters.deviceID); % stop the response queue

% END OF THE TASK:
DrawFormattedText(Parameters.window,'Ende der Aufgabe','center',Parameters.textSize * 2,Parameters.textColorBlack);
if strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    str = sprintf('Sie haben insgesamt %.2f Euro verdient!',Basics.totalWinAll);
elseif contains(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
    str = sprintf('Sie haetten insgesamt %.2f Euro verdient!',Basics.totalWinAll);
end
DrawFormattedText(Parameters.window,str,'center','center',Parameters.textColorBlack);
DrawFormattedText(Parameters.window, 'Bitte wenden Sie sich an die Versuchsleitung.','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
Screen('Flip',Parameters.window); % flip to the screen
Basics.tExperimentTotal = nansum(Basics.runInfo.tRunTotal(Basics.runInfo.session == Parameters.subjectInfo.session)); % calculate total experiment time
WaitSecs(Basics.tWaitEndScreen); % wait for task to end
fprintf('--------------------------------------------\n') % display task progress
fprintf('End of the experiment:\n'); % display current task status
fprintf('Total experiment duration: %d minutes and %.f seconds\n',floor(Basics.tExperimentTotal/60),rem(Basics.tExperimentTotal,60));
fprintf('Total reward: %.2f Euro\n',Basics.totalWinAll); % display current task status
fprintf('--------------------------------------------\n') % display task progress

% END OF THE EXPERIMENT:
ShowCursor(); % show the cursor
ListenChar(1); % re-enable echo to the command line for key presses
Screen('CloseAll'); % close screen
KbQueueRelease(Parameters.deviceID) % release the keyboard queue
RestrictKeysForKbCheck; % reset the keyboard input checking for all keys
Priority(0); % disable realtime mode
Screen('Preference','SkipSyncTests',0);
Screen('Preference','Verbosity',3);

end
