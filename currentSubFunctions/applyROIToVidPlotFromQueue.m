function [roiMean] = applyROIToVidPlotFromQueue(inputStruct)
%
inputROIMask = inputStruct{1,1};
inputVidPath = inputStruct{1,2};

loadedVideo = VideoReader(inputVidPath);
roiMean = zeros(loadedVideo.NumFrames-10, 1);

%discard first 10 frames for camera warm up

for i = 1:loadedVideo.NumFrames-10
    activeFrame = read(loadedVideo, i+10);
    roiMean(i, 1) = mean(activeFrame(inputROIMask), 'all');
end
figure(1)
ylim([90, 100]);
plot(roiMean);

end

