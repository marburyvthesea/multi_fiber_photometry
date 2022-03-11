
%open file, create roi, get mean, save roi mask to file to use later

[filename, folder] = uigetfile('*.avi','File Selector');

addpath(strcat(folder, '\', filename));

test_vid = VideoReader(strcat(folder, '\', filename));
frame = read(test_vid, 10);

imshow(frame);
roi = drawcircle;
disp('draw roi, press key to continue')
pause;

roimask1 = roi.createMask;

%roi_mean = zeros(test_vid.NumFrames,1);
%for i = 1:test_vid.NumFrames
%    active_frame = read(test_vid, i);
%    roi_mean(i, 1) = mean(active_frame(roimask1), 'all'); 
%end

uisave({'roimask1'}, 'C:\Users\scanimage\Documents\MATLAB\multi_fiber_photometry\params\roiDefault.mat'); 