function [outputFramesAcquired, outputVidFilePath] = pCamAcquireFnContinuousDAQ(inputCam, pdir, inputFrames)
%%Acquire set number of frames from camera, output to files with timestamps
% DAQ system is triggered outside function

%create files for timestamps
filetime = datestr(datetime,'yyyymmdd-HHMMSS');
save_dir = pdir ;
addpath(genpath(save_dir)) ;
vidFilePath = [save_dir, '\', filetime, '_', imaqhwinfo(inputCam).AdaptorName, ...
    '_', imaqhwinfo(inputCam).DeviceName, '.avi'];
outputVidFilePath = vidFilePath;

%create output file
vidfile = VideoWriter(vidFilePath);
vidfile.FrameRate = 30 ;
inputCam.LoggingMode = 'disk';
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

