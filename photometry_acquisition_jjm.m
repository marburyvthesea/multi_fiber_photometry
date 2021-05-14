
%path to files on scanimage computer 
acquisition_file_path = 'C:\Users\scanimage\Documents\JJM\photometry_acquisition\jjm';
addpath(genpath(acquisition_file_path));

%init system with options for needed components
%default is all off 
%[pdir, cam, behavCam, dq] = init_system_jjm(options) ;
%init with photometry camera as webcam for testing 

[pdir, cam, behavCam, dq] = init_system_jjm('photometryCam_name', 'pointgrey', ...
                                            'photometryCam_devicenum', 1, ...
                                            'photometryCam_imgformat', 'F7_Mono8_480x300_Mode5', ... 
                                            'behavCam_name', 'winvideo', ...
                                            'behavCam_devicenum', 1, ...  
                                            'behavCam_imgformat', 'MJPG_640x360', ...
                                            'DAQ', 'off');
%% extract this into separate function to call for acqusitions
frames_to_acquire=50 ;
%DAQ turns on in call to photometryAcquisitionDAQinterleaved_disklogging
%parallel loop
% inputs: function_hangle, num_outputs, varible list of input args

if ischar(cam)==0 && isobject(cam) 
    f = parfeval(@photometryAcquisitionDAQinterleaved_disklogging_memmeasure, 2, cam, frames_to_acquire, pdir);
else disp('photometry camera not initialized');
end 
% additional function to excecute asynchronously 
if ischar(behavCam)==1 && isobject(behavCam)   
    f_2 = parfeval(@singleCamAcquisition_disklogging, 1, behavCam, frames_to_acquire, pdir); 
else disp('behavior camera not initialized');
end 
  
if exist('f') && strcmp(f.State, 'running') 
    disp(['Cam1, photometry ', ' is running']);
    memory
end
if exist('f_2') && strcmp(f_2.State, 'running')
    disp(['Cam2, behav', ' is running']);
    memory
end
%% then can plot results asynchronously 

%load from videos

%% when finished at end 

%clean up

cam = imaqfind; delete(cam); clear all; close all; 

poolobj = gcp('nocreate');
delete(poolobj);