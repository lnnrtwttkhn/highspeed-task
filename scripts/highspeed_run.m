%% HIGHSPEED MRI TASK - RUN FILE
% Lennart Wittkuhn, Independent Max Planck Research Group NeuroCode, 2018
% Max Planck Institute for Human Development, Berlin, Germany
% Contact: wittkuhn@mpib-berlin.mpg.de
close all; clear variables; clc; clearvars -global; % clear all variables from the workspace and close all windows
[Sets,Data,Basics,Parameters,Sounds] = highspeed_settings; % get the highspeed task settings
[Sets,Data,Basics,Parameters] = highspeed_main(Sets,Data,Basics,Parameters,Sounds); % run the highspeed task main file
