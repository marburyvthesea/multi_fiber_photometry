function [outputStatus] = photometryAcquisitionDAQinterleaved_disklogging(inputCam, frames, pdir)

%% must initialize DAQ session inside parallel function
%analog output - laser trigger
DAQ_session = daq.createSession('ni');
DAQ_session.addAnalogOutputChannel('Dev1',0:1,'Voltage');
outputSingleScan(DAQ_session,[0 0])
%digital output - camera trigger
DAQ_digital_session = daq.createSession('ni');
DAQ_digital_session.addDigitalChannel('Dev1','Port0/Line0','OutputOnly')
outputSingleScan(DAQ_digital_session,[0]);

%%init camera properties
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

trigger_times = datetime(zeros(frames,1), 0, 0, 'format', 'HH:mm:ss.SSS');
DAQ_times = datetime(zeros(frames,1), 0, 0, 'format', 'HH:mm:ss.SSS');


open(vidfile);
start(inputCam);

i=1;
while i <=frames
%for i = 1:frames
    if islogging(inputCam)== 0
        % trigger DAQ
        outputSingleScan(DAQ_session,[0 1])
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
    
    outputSingleScan(DAQ_session,[0 0])
    
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
dlmwrite(expname,char(trigger_times),'delimiter','');

expname_DAQ = [save_dir, '\', filetime, '_DAQ', ...
    '_', 'trigger', '_time','.txt'];

dlmwrite(expname_DAQ,char(DAQ_times),'delimiter','');

removeChannel(DAQ_session,1);
removeChannel(DAQ_session,1);

outputStatus='done';
%disp(['finished'+outputStatus]);
end



