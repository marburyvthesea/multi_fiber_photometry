frames_to_acquire=50 ;
%path to files on scanimage computer 
acquisition_file_path = 'C:\Users\scanimage\Documents\JJM\photometry_acquisition\jjm';
addpath(genpath(acquisition_file_path));

%init system with options for needed components
%default is all off 
%[pdir, cam, behavCam, dq] = init_system_jjm(options) ;
%init with photometry camera as webcam for testing 

[pdir, cam, behavCam, dq] = init_system_jjm('photometryCam_name', 'winvideo', ...
                                            'photometryCam_devicenum', 1, ...
                                            'photometryCam_imgformat', 'RGB24_744x480', ... 
                                            'behavCam_name', 'winvideo', ...
                                            'behavCam_devicenum', 2, ...  
                                            'behavCam_imgformat', 'MJPG_1024x576', ...
                                            'DAQ', 'off');
%%
%if using daq turn on here 

%parallel loop
% inputs: function_hangle, num_outputs, varible list of input args

f = parfeval(@photometryAcquisitionDAQinterleaved_disklogging, 1, cam, frames_to_acquire);
% additional function to excecute asynchronously 
f_2 = parfeval(@singleCamAcquisition_disklogging, 1, behavCam, frames_to_acquire); 
if f.State=='running'
    disp(['Cam1, photometry ', ' is running']);
end
if f_2.State=='running'
    disp(['Cam2, behav', ' is running']);    
end
%clean up 
cam = imaqfind; delete(cam); clear all; close all; 


%poolobj = gcp('nocreate');
%delete(poolobj);