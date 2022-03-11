function [meanROIintensity] = dispROIbyFrameFromQueue(inputFrameStruct)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%need to use global variables for figure intensity plot

figure(2)
%hold on
%get data from input cell array
frameToDisp=inputFrameStruct{1,1};
frameTime=inputFrameStruct{1,2};
framesData=inputFrameStruct{1,3};
inputROIMask=inputFrameStruct{1,4};

vidSize = size(framesData);
%meanROIintensity=zeros(1,vidSize(1,2));  

%will need to make this faster somehow
frameMean=mean(framesData{1, frameToDisp}(inputROIMask), 'all');
meanROIintensity(frameToDisp)=frameMean;

scatter(frameToDisp,frameMean);
%hold off

end

