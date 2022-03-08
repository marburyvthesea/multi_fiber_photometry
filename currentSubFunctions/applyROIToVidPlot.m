function [roiMean] = applyROIToVidPlotFromQueue(inputStruct)
%
inputROIMask = inputStruct{1,1};
inputVidPath = inputStruct{1,2};

loadedVideo = VideoReader(inputVidPath);
roiMean = zeros(loadedVideo.NumFrames, 1);

for i = 1:loadedVideo.NumFrames
    activeFrame = read(loadedVideo, i);
    roiMean(i, 1) = mean(activeFrame(inputROIMask), 'all');
end
plot(roiMean);
end

