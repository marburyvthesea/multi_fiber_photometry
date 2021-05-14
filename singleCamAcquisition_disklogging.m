function [outputStatus] = singleCamAcquisition_disklogging(inputCam, frames, pdir)
 
%%init
triggerconfig(inputCam, 'manual');
inputCam.FramesPerTrigger = 1;
inputCam.TriggerRepeat = Inf;
freq = 20 ;

%
filetime = datestr(datetime,'yyyymmdd-HHMM');
save_dir = pdir ;
addpath(genpath(save_dir)) ;
vidfile = [save_dir, '\', filetime, '_', imaqhwinfo(inputCam).AdaptorName, ...
    '_', imaqhwinfo(inputCam).DeviceName];

%
vidfile = VideoWriter(vidfile);
vidfile.FrameRate = freq ;
inputCam.LoggingMode = 'disk';
inputCam.DiskLogger = vidfile;

times = datetime(zeros(frames,1), 0, 0, 'format', 'HH:mm:ss.SSS');

open(vidfile);
start(inputCam);

i=1;
while i <=frames
%for i = 1:frames

    if islogging(inputCam)== 0
        trigger(inputCam) ;
        times(i,1)= datetime('now', 'format', 'HH:mm:ss.SSS');
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
    %i=i+1;  
end
%wait for final frame 
if inputCam.DiskLoggerFrameCount~=inputCam.FramesAcquired
    pause(0.1);
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
dlmwrite(expname,char(times),'delimiter','');

outputStatus='done';
%disp(['finished'+outputStatus]);
end



