%% wait for mri scanner trigger
function [RESU t0] = fMRI_waitScannerTriggers(scannerPort, b, triggerSwitches, RESU)
% 1. The first file is the code that should be put in our scripts BEFORE using the trigger counting function.
% 2. The second file is the function that is actually counting the triggers as well as recording the trigger signal.
% 3. After the function, our task can come in the script.
%
% About the input for the function:
% scannerPort:
% It is the code identifying the port that is between the scanner and the computer.
% It  is in the script, in the code coming just before the function.
% win:
% Relates to the text "Waiting for scanner" shown by the function.
% Is a Psychtoolbox function
% textCol:
% Relates to the text "Waiting for scanner" shown by the function.
% Is a Psychtoolbox function
% b:
% The current number of block (basically the first, second, third... sequence that we run)
% To be defined in the code before the function.
% RESU:
% Apparently not very useful, can be commented out.


startState = inportb(scannerPort); % inportb() is a macro that reads a word from the input scanner port
oldValue = startState; %

triggerNum = 0; % initalize trigger number
while triggerNum < triggerSwitches
    
    val = inportb(scannerPort); % read from the scanner port
    %     RESU.LPT1{b} = [RESU.LPT1{b} val];
    
    if val ~= oldValue
        triggerNum = triggerNum + 1; % add trigger number
        triggertime(b, triggerNum) = GetSecs; % get timestamps of each trigger pulse
    end
    
    oldValue = val;
end

t0(b) = GetSecs; % start of experiment

end


