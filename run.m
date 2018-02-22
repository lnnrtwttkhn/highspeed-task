%% Run file of the Visual Object Detection Task
% Lennart Wittkuhn, Max Planck Institute for Human Development, 2017-2018
% Study short title: Highspeed MRI
% This file runs the Visual Object Detection Task

function [Sets,Data,Basics,Parameters] = run

close all; clear variables; clc;

[Sets,Data,Basics,Parameters,Sounds] = taskSettings;

[Sets,Data,Basics, Parameters] = main(Sets,Data,Basics,Parameters,Sounds);

return

end