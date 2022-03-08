%%JJM photometry run script

%%
%initialize system with key value pair arguments

[pdir, cam, behavCam, dq] = init_system_jjm('photometryCam_name', 'pointgrey' ... 
    , 'photometryCam_devicenum', 1, 'photometryCam_imgformat', 'F7_Mono8_1920x1200_Mode0', 'DAQ', 'ni');

%%
%preview camera to get acquisition settings
DAQ_session = daq.createSession('ni');
DAQ_session.addAnalogOutputChannel('Dev2',0:1,'Voltage');
outputSingleScan(DAQ_session,[1 0])

preview(cam);
pause(20); 
src = getselectedsource(cam);
%
cam_gain = src.Gain;
cam_exposure = src.Exposure;
%
stoppreview(cam);

outputSingleScan(DAQ_session,[0 0]);
removeChannel(DAQ_session,1);
removeChannel(DAQ_session,1);

%%
%interleaved recording 
%ouputs cycle timestampts 
%
%while i<= run
frames = 500 ;
[DAQ_times, trigger_times, outputStatus] = photometryAcquisitionDAQinterleaved_disklogging_cycletime(cam, ... 
    frames, pdir, cam_gain, cam_exposure) ;
%   i=i+1; 
%%
%plotting fiber signal 
get_roi
