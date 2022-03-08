
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
numcores=4;
maxNumCompThreads(numcores);
p = parpool(numcores);

%% set acquisition parameters 
% frames per sweep, number of sweeps, DAQ setting (continuous or
% interleaved), which output (laser) to use if running continuously 
framesPerSweep=100 ;
numSweeps=2 ; 
DAQSetting='continuous';
continuousDAQParams = [1, 0]; 
%% set up data queue for plotting results asynchronously during acquisition
%create data queue object 
dataQueue = parallel.pool.DataQueue ;
frameDataQueue = parallel.pool.DataQueue ; 
%figure for displaying mean intensity plot
figure(1);
figure(2);
%need to use global variables for iteratively plotting intensity after each
%frame 
global frameIndex ;
frameIndex = zeros(framesPerSweep);
global meanROIintensity ;
meanROIintensity = zeros(framesPerSweep);
%inputs to display function are a structure with fields of roiMaskDefault and pathToVid
afterEach(dataQueue, @applyROIToVidPlotFromQueue);
afterEach(frameDataQueue, @dispROIbyFrameFromQueue); 
%% maybe also want to load and play videos once acquired from data queue
%videoPlayer = vision.VideoPlayer;

%% run acquisition in parallel loops
f1 = parfeval(@photometryAcquisitionInitDAQAcquirePcamFrameQueue, 1, dataQueue, frameDataQueue, cam, numSweeps, ...
                framesPerSweep, DAQSetting, continuousDAQParams, pdir, roiMaskDefault);
%%behavior cam acquisition
% need to sort out how to align more precisely
%numBehavCamFrames = framesPerSweep*numSweeps;
%f2 = parfeval(@singleCamAcquisition_disklogging, 1 ,  behavCam, numBehavCamFrames, pdir);
            
%%get output state
outputState_cam = fetchOutputs(f1);
%outputState_behavCam = fetchOutputs(f2);


%% then can plot results asynchronously
roiMeanOut = applyROIToVid(roiMaskDefault, pathToVid);
plot(roiMeanOut)
%% when finished at end 

%clean up

cam = imaqfind; delete(cam); clear all; close all; 

poolobj = gcp('nocreate');
delete(poolobj);