function [outputStatus] = photometryAcquisitionInitDAQAcquirePcamFrameQueue(inputDataQueue, inputFrameDataQueue, inputCam, numSweeps, frames, inputDAQSetting, continuousDAQParams, pdir, inputROIMask)

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

%switch for DAQ on continously or interleaved
if strcmp(inputDAQSetting, 'continuous')
    outputSingleScan(DAQ_session, continuousDAQParams);
    %wait 10seconds for warmup
    java.lang.Thread.sleep(10000);
end

%% call function to acquire frames
i=1;
while i <= numSweeps
    %init camera properties
    %select function to use here based on DAQ trigger parameters
    if strcmp(inputDAQSetting, 'continuous')
        [acquiredFrames, outputVidFilePath] = pCamAcquireFnContinuousDAQFrameQueue(inputFrameDataQueue, inputCam, pdir, frames, inputROIMask); 
    else
        [acquiredFrames, outputVidFilePath] = pCamAcquireFnTriggerDAQ(inputCam, pdir, frames, DAQ_session); 
    end
    disp(acquiredFrames); 
    outputStruct = {inputROIMask, outputVidFilePath};
    send(inputDataQueue, outputStruct); 
    i=i+1; 
end
%% turn off laser if continuous 
if strcmp(inputDAQSetting, 'continuous')
    outputSingleScan(DAQ_session, [0, 0]);
end

%% close DAQ session

removeChannel(DAQ_session,1);
removeChannel(DAQ_session,1);

outputStatus='done' ;
release(DAQ_session) ;
clear DAQ_session ; 

%disp(['finished'+outputStatus]);
end



