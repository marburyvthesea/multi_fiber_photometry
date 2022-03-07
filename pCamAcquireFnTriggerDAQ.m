function [outputFramesAcquired] = pCamAcquireFnTriggerDAQ(inputCam, pdir, inputFrames, inputDAQ_session)
%%Acquire set number of frames from camera, output to files with timestamps
% DAQ system is triggered outside function

%create files for timestamps
filetime = datestr(datetime,'yyyymmdd-HHMMSS');
save_dir = pdir ;
addpath(genpath(save_dir)) ;
vidfile = [save_dir, '\', filetime, '_', imaqhwinfo(inputCam).AdaptorName, ...
    '_', imaqhwinfo(inputCam).DeviceName];

%create output file
vidfile = VideoWriter(vidfile);
vidfile.FrameRate = 20 ;
inputCam.LoggingMode = 'disk';
inputCam.DiskLogger = vidfile;

%create files to store DAQ triggers
trigger_times = datetime(zeros(inputFrames,1), 0, 0, 'format', 'HH:mm:ss.SSS');
DAQ_times = datetime(zeros(inputFrames,1), 0, 0, 'format', 'HH:mm:ss.SSS');
%mem_usage = double.empty(frames, 0);

%create video files
open(vidfile);
start(inputCam);

i=1;
while i <=inputFrames
%for i = 1:frames
    if islogging(inputCam)== 0
        % trigger DAQ
        outputSingleScan(inputDAQ_session,[0 1])
        DAQ_times(i,1)= datetime('now', 'format', 'HH:mm:ss.SSS');
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
    
    outputSingleScan(inputDAQ_session,[0 0])
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

expname_DAQ = [save_dir, '\', filetime, '_DAQ', ...
    '_', 'trigger', '_time','.txt'];

dlmwrite(expname_DAQ,char(DAQ_times),'delimiter','');

outputFramesAcquired = i ;

end

