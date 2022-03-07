
%% set path to photometry acquisition code package 
acquisition_file_path ='C:\Users\scanimage\Documents\MATLAB\multi_fiber_photometry';
addpath(genpath(acquisition_file_path));

%% initialize system 
%default is all off 
[pdir, cam, behavCam, dq] = init_system_jjm('photometryCam_name', 'pointgrey', ...
                                            'photometryCam_devicenum', 1, ...
                                            'photometryCam_imgformat', 'F7_Mono8_1920x1200_Mode0', ... 
                                            'behavCam_name', 'winvideo', ...
                                            'behavCam_devicenum', 1, ...  
                                            'behavCam_imgformat', 'RGB24_744x480', ...
                                            'DAQ', 'off');
                                        
%% start parallel pool 
numcores=6;
maxNumCompThreads(numcores)
p = parpool(numcores);

%% extract this into separate function to call for acqusitions
framesPerSweep=300 ;
numSweeps=2 ; 
%DAQ turns on in call to photometryAcquisitionDAQinterleaved_disklogging
%parallel loop
% inputs: function_handle, num_outputs, varible list of input args

%photometryAcquisitionInitDAQAcquirePcam(cam, numSweeps, framesPerSweep, pdir);
%%
%create data queue object 
%dataQueue = parallel.pool.DataQueue ; 
%figure for displaying video
%fig = figure ('Visible', 'on') ;
%afterEach(dataQueue, @imshow);
%%
videoPlayer = vision.VideoPlayer;




%%
f1 = parfeval(@photometryAcquisitionInitDAQAcquirePcam, 1, cam, numSweeps, framesPerSweep, pdir);

%%get output state
outputState_cam = fetchOutputs(f1);


%% then can plot results asynchronously 

%use ROI measure video here 
analyze2fiber2vid(roimat1, roimat2);

%load from videos

%% when finished at end 

%clean up

cam = imaqfind; delete(cam); clear all; close all; 

poolobj = gcp('nocreate');
delete(poolobj);