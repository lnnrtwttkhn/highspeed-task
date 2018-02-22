%% MAIN OF THE VISUAL OBJECT SEQUENCE TASK
function [Sets,Data,Basics,Parameters] = main(Sets,Data,Basics,Parameters,Sounds)

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
HideCursor(); % hides the cursor
ListenChar(2); % suppress echo to the command line for keypresses
KbName('UnifyKeyNames'); % used for cross-platform compatibility of keynaming
RestrictKeysForKbCheck([KbName('LeftArrow'),KbName('RightArrow')]); % restrict keys for KbCheck
Parameters.flipInterval = Screen('GetFlipInterval', Parameters.window); % get the monitor flip interval

% START SCREEN: WELCOME PARTICIPANTS TO THE EXPERIMENT
DrawFormattedText(Parameters.window,'Willkommen zur Aufgabe "Visuelle Objekte Erkennen"!','center','center',Parameters.textColorBlack);
DrawFormattedText(Parameters.window, 'Start mit beliebiger Pfeiltaste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
Screen('Flip',Parameters.window); % flip to the screen
VBLTime = KbPressWait(Parameters.deviceID); % save key press time
Basics.tExperimentStart = VBLTime; % save start time of the task
waitSecs = 0; % define stimulus duration

% START THE RESPONSE QUEUE
KbQueueCreate(Parameters.deviceID,Parameters.keyList); % creates queue, restricted to the relevant key targets
KbQueueStart(Parameters.deviceID); % starts queue

% MAIN TASK LOOP
for run = Parameters.subjectInfo.run:Basics.nRunSession
    
    fprintf('Starting run %d of %d (in the current session)\n',run,Basics.nRunSession) % display task progress
    Basics.tRunStart = VBLTime; % save time of run start
    
    trialStart = Basics.breakTrials(run,Parameters.subjectInfo.session);
    trialStop = trialStart + Basics.nTrialsRun - 1;
    
    for trial = trialStart:trialStop
        
        % DEFINE THE CURRENT TASK CONDITION:
        cond = Basics.trialStructure(trial); % get the current condition (i.e., oddball, sequence or repetition trial)
        
        % DISPLAY THE TASK PROGRESS IN THE COMMAND WINDOW:
        fprintf('Starting trial %d of %d (total trials).\n',trial,length(Basics.trialStructure)) % display task progress
        fprintf('Starting trial %d of %d (current session).\n',trial,Basics.nTrialsSession) % display task progress
        fprintf('Starting trial %d of %d (current run).\n',trial,trialStop) % display task progress
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
            DrawFormattedText(Parameters.window,'+','center','center',Parameters.textColorBlack); % draw fixation cross to screen
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
                DrawFormattedText(Parameters.window,'+','center','center',Parameters.textColorBlack); % draw fixation cross to screen
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
                VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
                Data(cond).data.tFlipITI(dataIndex,stim) = VBLTime; % save flip time
                waitSecs = Data(cond).data.tITI(dataIndex); % define wait time
            end
        end
        
        % FURTHER PROCEDURE FOR SEQUENCE AND REPETITION TRIALS AFTER STIMULUS LOOP:
        if ismember(cond,[idxFlash idxOneTwo idxOneTwoExtra]) % only for sequence and repetition trials
            
            % WAITING PERIOD AFTER LAST STIMULUS (WAIT UNTIL 16s HAVE ELAPSED)
            DrawFormattedText(Parameters.window,'+','center','center',Parameters.textColorBlack); % draw fixation cross to screen
            Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
            VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
            Data(cond).data.tFlipDelay(dataIndex,stim) = VBLTime; % save flip time
            waitSecs = Basics.tMaxSeqTrial; % define wait time
            resume(Sounds.soundWaitPlayer); % start to play sound during the delay period
            
            % SHOW RESPONSE OPTIONS
            DrawFormattedText(Parameters.window,Data(cond).data.targetName{dataIndex},'center','center',Parameters.textColorBlack); % draw text to screen
            if Data(cond).data.keyTarget(dataIndex) == KbName('LeftArrow') % target is left
                DrawFormattedText(Parameters.window,num2str(Data(cond).data.targetPos(dataIndex)),Parameters.screenPosLeft, Parameters.screenCenterY + Parameters.textSize * 5,Parameters.textColorBlack); % show target on the left side
                DrawFormattedText(Parameters.window,num2str(Data(cond).data.targetPosAlt(dataIndex)),Parameters.screenPosRight, Parameters.screenCenterY + Parameters.textSize * 5,Parameters.textColorBlack); % show non-target on the right side
            elseif Data(cond).data.keyTarget(dataIndex) == KbName('RightArrow') % target is right
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
            if Data(cond).data.keyIsDown(dataIndex) == 1 && Data(cond).data.keyIndex(dataIndex) == Data(cond).data.keyTarget(dataIndex) % correct response
                sound(Sounds.soundCoinY,Sounds.soundCoinFs); % play coin sound
                Data(cond).data.acc(dataIndex) = 1; % accuracy for this trial is 1
                fprintf('Correct: +%.2f Euro\n',Basics.reward);
            elseif Data(cond).data.keyIsDown(dataIndex) == 1 && Data(cond).data.keyIndex(dataIndex) ~= Data(cond).data.keyTarget(dataIndex) % wrong response
                sound(Sounds.soundErrorY,Sounds.soundErrorFs); % play error sound
                Data(cond).data.acc(Sets(cond).set.count) = 0; % accuracy for this trial is 0
                disp('Wrong: 0.00 Euro');
            elseif Data(cond).data.keyIsDown(dataIndex) == 0 % no reaction
                sound(Sounds.soundErrorY,Sounds.soundErrorFs); % play error sound
                Data(cond).data.acc(dataIndex) = 0; % accuracy for this trial is 0
                disp('Too slow: 0.00 Euro');
            end
        end
        
        % UPDATE TOTAL CURRENT REWARD:
        totalWinTrain = sum(Data(idxTrain).data.orient == 180 & Data(idxTrain).data.acc == 1) * Basics.reward; % current total reward from all training trials
        totalLossTrain = sum(Data(idxTrain).data.orient == 0 & Data(idxTrain).data.keyIsDown == 1) * - Basics.reward; % current total loss from all training trials
        totalWinSequences = nansum(vertcat(Data(idxFlash).data.acc,Data(idxOneTwo).data.acc,Data(idxOneTwoExtra).data.acc)) * Basics.reward; % current total reward from all sequence trials
        Basics.totalWinAll = totalWinTrain + totalLossTrain + totalWinSequences; % sum all rewards and losses
        
    end
    
    % END OF RUN: TIME FOR A BREAK
    if strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
        DrawFormattedText(Parameters.window,'Pause','center',Parameters.textSize * 2,Parameters.textColorBlack);
        DrawFormattedText(Parameters.window,sprintf('Sie haben Durchgang %d von %d geschafft.',run,Basics.nRunSession),'center',Parameters.textSize * 3,Parameters.textColorBlack);
        str = sprintf('Sie haben bisher %.2f Euro verdient!',Basics.totalWinAll);
        DrawFormattedText(Parameters.window,str,'center','center',Parameters.textColorBlack);
        DrawFormattedText(Parameters.window, 'Weiter mit beliebiger Pfeiltaste','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
        Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
        VBLTime = Screen('Flip',Parameters.window,VBLTime + waitSecs - 0.5 * Parameters.flipInterval); % flip to the screen
        fprintf('End run %d of %d.\n',run,Basics.nRunSession) % display task progress
        fprintf('Break. Saving data...\n'); % display current task status
    end
    
    % SAVE THE DATA OF THE CURRENT RUN
    fileName = [strjoin({...
        Parameters.studyName,Parameters.studyMode,...
        'sub',num2str(Parameters.subjectInfo.id),...
        'session',num2str(Parameters.subjectInfo.session),...
        'run',num2str(Parameters.subjectInfo.run)},'_'),'.mat']; % define file name
    save(fullfile(Parameters.pathData,fileName),'Sets','Data','Basics','Parameters'); % save data
    
    % SAVE DURATION OF RUN:
    Basics.tRunStop = VBLTime; % save run stop time
    Basics.tRunTotal = Basics.tRunStop - Basics.tRunStart; % calculate total run time
    fprintf('Total run duration: %d minutes and %f seconds\n',floor(Basics.tRunTotal/60),rem(Basics.tRunTotal,60));
    Basics.tRuns(run,Parameters.subjectInfo.session) = Basics.tRunTotal; % save duration of run
    
    % CONTINUE WITH NEXT RUN
    if strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
        fprintf('Data saved.\n'); % display current task status
        VBLTime = KbPressWait(Parameters.deviceID); % save key press time
        waitSecs = 0; % define wait time
    end
    
end

% STOP SOUND AND RESPONSE QUEUE:
stop(Sounds.soundWaitPlayer); % stop to play sound
KbQueueStop(Parameters.deviceID); % stop the response queue

% GET TOTAL TIME:
Basics.tExperimentStop = VBLTime; % save experiment stop time
Basics.tExperimentTotal = Basics.tExperimentStop - Basics.tExperimentStart; % calculate total experiment time
fprintf('Total experiment duration: %d minutes and %f seconds\n',floor(Basics.tExperimentTotal/60),rem(Basics.tExperimentTotal,60));

% END OF THE TASK:
DrawFormattedText(Parameters.window,'Ende der Aufgabe','center',Parameters.textSize * 2,Parameters.textColorBlack);
if strcmp(Parameters.studyMode,'behavioral') || strcmp(Parameters.studyMode,'mri')
    str = sprintf('Sie haben insgesamt %.2f Euro verdient!',Basics.totalWinAll);
elseif strcmp(Parameters.studyMode,'instructions') || strcmp(Parameters.studyMode,'practice')
    str = sprintf('Sie haetten insgesamt %.2f Euro verdient!',Basics.totalWinAll);
end
DrawFormattedText(Parameters.window,str,'center','center',Parameters.textColorBlack);
DrawFormattedText(Parameters.window, 'Bitte wenden Sie sich an die Versuchsleitung.','center',Parameters.screenSize(2)-Parameters.textSize,Parameters.textColorBlack);
Screen('DrawingFinished', Parameters.window); % tell PTB that stimulus drawing for this frame is finished
Screen('Flip',Parameters.window); % flip to the screen
KbPressWait; % save key press time
fprintf('End of the experiment\n'); % display current task status
fprintf('Total reward: %.2f Euro\n',Basics.totalWinAll); % display current task status

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
