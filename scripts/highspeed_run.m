%% Run file of the Visual Object Detection Task
% Lennart Wittkuhn, Max Planck Institute for Human Development, 2017-2018
% Study short title: Highspeed MRI
% This file runs the Visual Object Detection Task

close all; clear variables; clc;

[Sets,Data,Basics,Parameters,Sounds] = highspeed_settings;

[Sets,Data,Basics,Parameters] = highspeed_main(Sets,Data,Basics,Parameters,Sounds);
