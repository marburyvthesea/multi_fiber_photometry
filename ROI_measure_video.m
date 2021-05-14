%% choose video to read
%clear all
%[result1, result2] = analyze2fiber2vid()
%%
function [roimean1,roimean2] = analyze2fiber2vid(roimat1, roimat2);
curdir = cd;
[filename1, pathname] = uigetfile('*.avi','File Selector');
cd (pathname)
[filename2, ~] = uigetfile('*.avi','File Selector');
vidin1 = VideoReader(filename1);
vidin2 = VideoReader(filename2);
%% define ROI on first frame
frame = read(vidin1, 1);
high = mean(max(max(frame)));
frame = imadjust(frame, [0 high/500],[]);
imshow(frame)

if nargin <1
    roi = drawcircle;
    roimask1 = roi.createMask;
    roi = drawcircle;
    roimask2 = roi.createMask;
    
elseif nargin == 1
    roimask1 = load(roimat1).roimask;
elseif nargin == 2 
    roimask1 = load(roimat1).roimask;
    roimask2 = load(roimat2).roimask;
end

close(gcf)

%% measure ROI in each frame
framenum = vidin1.NumFrames;
roimean1 = zeros(framenum,2);
roimean2 = zeros(framenum,2);
tic
k = 1;
while hasFrame(vidin1)
    frame = readFrame(vidin1);
    roimean1(k,1) = mean(frame(roimask1),'all');
    roimean2(k,1) = mean(frame(roimask2),'all');
    k=k+1;
end

%
k = 1;
while hasFrame(vidin2)
    frame = readFrame(vidin2);
    roimean1(k,2) = mean(frame(roimask1),'all');
    roimean2(k,2) = mean(frame(roimask2),'all');
    k=k+1;
end
toc
disp('done')
%% plot the Ca response
figure();
hold on
plot(roimean1)
plot(roimean2)
ylim([15 20])
legend()

end