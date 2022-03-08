function [roiMean] = applyROIToVid(inputROIMask,inputVidPath)
%

loadedVideo = VideoReader(inputVidPath);
roiMean = zeros(loadedVideo.NumFrames, 1);

for i = 1:loadedVideo.NumFrames
    activeFrame = read(loadedVideo, i);
    roiMean(i, 1) = mean(activeFrame(inputROIMask), 'all');
end    
end

