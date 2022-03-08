function [output] = dispROIbyFrameFromQueue(inputFrameStruct)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%need to use global variables for figure intensity plot

figure(2)
hold on
frameToDisp=inputFrameStruct{1,2};
frameNum=inputFrameStruct{1,1};
frameIndex(frameNum)=frameNum;
inputROIMask=inputFrameStruct{1,3};
meanROIintensity(frameNum)=mean(frameToDisp(inputROIMask), 'all');

plot(meanROIintensity);
hold off

output='done';
end

