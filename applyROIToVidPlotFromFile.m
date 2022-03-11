function [roiMean] = applyROIToVidPlotFromFile(inputROIMask)
%
[filename, folder] = uigetfile('*.avi','File Selector');

addpath(strcat(folder, '\', filename));

inputVidPath = strcat(folder, '\', filename);

loadedVideo = VideoReader(inputVidPath);
roiMean = zeros(loadedVideo.NumFrames, 1);

for i = 1:loadedVideo.NumFrames
    activeFrame = read(loadedVideo, i);
    roiMean(i, 1) = mean(activeFrame(inputROIMask), 'all');
end
plot(roiMean);
end

