function [output] = dispFigureFromQueue(inputFrameStruct)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

figure(2)
frameToDisp=inputFrameStruct{1,2};
imshow(frameToDisp);

output='done';
end

