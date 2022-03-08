
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
addpath(genpath(pdir));                                        
%% have path to default roi mask stored here
roiMaskDefault = load('C:\Users\scanimage\Documents\MATLAB\multi_fiber_photometry\params\roiDefault.mat').roimask1;
                                   
%% start parallel pool 
numcores=6;
maxNumCompThreads(numcores)
p = parpool(numcores);

%% set acquisition parameters 
framesPerSweep=300 ;
numSweeps=2 ; 
%photometryAcquisitionInitDAQAcquirePcam(cam, numSweeps, framesPerSweep, pdir);
%%
%create data queue object 
dataQueue = parallel.pool.DataQueue ; 
%figure for displaying mean intensity plot
%fig = figure ('Visible', 'on') ;
%inputs to display function are a structure with fields of roiMaskDefault and pathToVid
afterEach(dataQueue, @applyROIToVidPlotFromQueue);
%% want to load and play videos once acquired from data streat
%videoPlayer = vision.VideoPlayer;


%% run acquisition in parallel loops
%f1 = parfeval(@photometryAcquisitionInitDAQAcquirePcam, 1, cam, numSweeps, framesPerSweep, pdir);
f1 = parfeval(@photometryAcquisitionInitDAQAcquirePcamDataStream, 1, dataQueue, cam, numSweeps, framesPerSweep, pdir, roiMaskDefault);

%%get output state
outputState_cam = fetchOutputs(f1);


%% then can plot results asynchronously
roiMeanOut = applyROIToVid(roiMaskDefault, pathToVid);
plot(roiMeanOut)
%% when finished at end 

%clean up

cam = imaqfind; delete(cam); clear all; close all; 

poolobj = gcp('nocreate');
delete(poolobj);