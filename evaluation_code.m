clc;
clear;
close all;
more off;

% ------------------------------------------------------
% PART B EVALUATION
% ------------------------------------------------------

% --- INIT
if exist('OCTAVE_VERSION', 'builtin')>0
    % If in OCTAVE load the image package
    warning off;
    pkg load image;
    warning on;
end

% ------------------------------------------------------
% COMPARE RESULTS TO GROUND TRUTH
% ------------------------------------------------------

% --- Step B1
% Load the ground truth
GT=dlmread('Troizina 1827_ground_truth.txt');
% load our results (if available)
if exist('results.txt','file')
    R=dlmread('results.txt');
else
    error('Ooooops! There is no results.txt file!');
end

% --- Step B2
% Define the threshold for the IOU matrix
T=0.5 % {0.3,0.5,0.7}

% Calculate IOU for all the results
IOU=calcIOU(R,GT);

% Apply the IOU threshold to IOU matrix
IOUFinal=IOU>=T;
fprintf('Final IOU is:\n');
disp(IOUFinal);

% Write the final IOU results to a text file
dlmwrite('IOUFinal.txt',IOUFinal,'delimiter','\t','precision',2);

% Calculate TP, FP, FN, Recall, Precision and F-Measure

TP = sum(IOUFinal(:)); % sum of the 1 in matrix IOUFinal
FP = (size(IOUFinal,1))-TP; % the number of rows in matrix IOUFinal minus TP
FN = (size(IOUFinal,2))-TP; % the number of columns in matrix IOUFinal minus TP

Recall = TP/(TP + FN); % From the Recall formula
Precision = TP/(TP + FP); % From the Precision formula
F1 = 2 * ((Recall * Precision) / (Recall + Precision)); % From the F-Measure formula


% Show the results 
fprintf('Recall %0.2f\n',Recall);
fprintf('Precision %0.2f\n',Precision);
fprintf('F-Measure %0.2f\n',F1);