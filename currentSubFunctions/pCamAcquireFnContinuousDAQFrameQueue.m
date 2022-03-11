function [outputFramesAcquired, outputVidFilePath] = pCamAcquireFnContinuousDAQFrameQueue(inputFrameDataQueue, inputCam, pdir, inputFrames, inputROIMask)
%%Acquire set number of frames from camera, output to files with timestamps
% DAQ system is triggered outside function

%create arrays for storing and updating real time data here
%skip 1st 10 frames
%frameIndex = zeros(inputFrames-10);
%imgDataArray = zeros(1200, 1920, 3); 
%imgDataArray = cell(1,inputFrames-10);  

%create files for timestamps
filetime = datestr(datetime,'yyyymmdd-HHMMSS');
save_dir = pdir ;
addpath(genpath(save_dir)) ;
vidFilePath = [save_dir, '\', filetime, '_', imaqhwinfo(inputCam).AdaptorName, ...
    '_', imaqhwinfo(inputCam).DeviceName, '.avi'];
outputVidFilePath = vidFilePath;
%trigger_times = zeros(inputFrames); 

%create output file
vidfile = VideoWriter(vidFilePath);
vidfile.FrameRate = 30 ;
inputCam.LoggingMode = 'disk&memory';
inputCam.DiskLogger = vidfile;

%create video files
open(vidfile);
start(inputCam);

i=1;
while i <=inputFrames
%for i = 1:frames
    if islogging(inputCam)== 0
        % wait 10msec
        java.lang.Thread.sleep(10);
        % get image from camera
        trigger(inputCam) ;
        trigger_times(i,1)= datetime('now', 'format', 'HH:mm:ss.SSS');
        imgData = getdata(inputCam);
        %if i>=10
        %    imgDataArray{1, i-9} = imgData; 
        %    send(inputFrameDataQueue, {i-10, trigger_times(i, 1), imgDataArray, inputROIMask});
        %end 
        i=i+1;       
    else 
        disp('waiting for disk writing'); 
        while islogging(inputCam)== 1 
            java.lang.Thread.sleep(1); 
        end 
    end
    disp('frames acquired from stream');
    disp(inputCam.FramesAcquired); 
    disp('frames logged to disk');
    disp(inputCam.DiskLoggerFrameCount); 
    
end
%wait for final frame 
if inputCam.DiskLoggerFrameCount~=inputCam.FramesAcquired
    pause(10);
end
disp('frames acquired from stream');
disp(inputCam.FramesAcquired); 
disp('frames logged to disk');
disp(inputCam.DiskLoggerFrameCount); 
close(vidfile) ;
stop(inputCam) ; 
delete(vidfile) ;
clear vidfile ; 
%end 
disp('Done') ;

expname = [save_dir, '\', filetime,imaqhwinfo(inputCam).AdaptorName, ...
    '_', imaqhwinfo(inputCam).DeviceName, '_time','.txt'];
dlmwrite(expname,char(trigger_times),'delimiter','');


outputFramesAcquired = i ;

end

