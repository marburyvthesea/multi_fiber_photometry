function [outputState] = playPhotometryVideo(pathToVid,inputVideoPlayer)
% Play video

vid = VideoReader(pathToVid);

while hasFrame(inputVideoReader)
    vidFrame = readFrame(inputVideoReader); 
    step(inputVideoPlayer, vidFrame);  
end

outputState = 'done'; 
end

