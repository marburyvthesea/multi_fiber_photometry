function [outputStatus] = photometryAcquisitionInitDAQAcquirePcam(inputCam, numSweeps, frames, pdir)

%% must initialize DAQ session inside parallel function

%analog output - laser trigger
DAQ_session = daq.createSession('ni');
DAQ_session.addAnalogOutputChannel('Dev2',0:1,'Voltage');
outputSingleScan(DAQ_session,[0 0])
%digital output - camera trigger
%DAQ_digital_session = daq.createSession('ni');
%DAQ_digital_session.addDigitalChannel('Dev1','Port0/Line0','OutputOnly')
%outputSingleScan(DAQ_digital_session,[0])

%%init camera properties
triggerconfig(inputCam, 'manual');
inputCam.FramesPerTrigger = 1;
inputCam.TriggerRepeat = Inf;

%% call function to acquire frames
i=1;
while i <= numSweeps
    %%init camera properties
    acquiredFrames = pCamAcquireFnTriggerDAQ(inputCam, pdir, frames, DAQ_session); 
    disp(acquiredFrames); 
    i=i+1; 
end 
    
%% close DAQ session 

removeChannel(DAQ_session,1);
removeChannel(DAQ_session,1);

outputStatus='done' ;
release(DAQ_session) ;
clear DAQ_session ; 

%disp(['finished'+outputStatus]);
end



