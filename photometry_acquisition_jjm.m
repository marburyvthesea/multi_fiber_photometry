
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
%%set photometry camera parameters
src = getselectedsource(cam);
src.ExposureMode = 'Manual';
src.Exposure = 2.41; 
src.FrameRateMode = 'Manual';
%src.FameRate = 40; 
src.GainMode = 'Manual';
src.Gain = 29;  


%% have path to default roi mask stored here
roiMaskDefault = load('C:\Users\scanimage\Documents\MATLAB\multi_fiber_photometry\params\roiDefault.mat').roimask1;
                                   
%% start parallel pool 
numcores=4;
maxNumCompThreads(numcores);
p = parpool(numcores);

%% set acquisition parameters 
% frames per sweep, number of sweeps, DAQ setting (continuous or
% interleaved), which output (laser) to use if running continuously 
framesPerSweep= 5400;
numSweeps=2 ; 
DAQSetting='continuous';
continuousDAQParams = [0, 1.8]; 
%% set up data queue for plotting results asynchronously during acquisition
%create data queue object 
dataQueue = parallel.pool.DataQueue ;
frameDataQueue = parallel.pool.DataQueue ; 
%figure for displaying mean intensity plot
figure(1);
figure(2);
%
global meanROIintensity
meanROIintensity=zeros(1,framesPerSweep);
%inputs to display function are a structure with fields of roiMaskDefault and pathToVid
afterEach(dataQueue, @applyROIToVidPlotFromQueue);
%afterEach(frameDataQueue, @dispROIbyFrameFromQueue); 
%% maybe also want to load and play videos once acquired from data queue
%videoPlayer = vision.VideoPlayer;
%% run acquisition in parallel loops
expdir = strcat(pdir, '\', datestr(datetime,'yyyymmdd-HHMMSS'));
mkdir(expdir); 
f1 = parfeval(@photometryAcquisitionInitDAQAcquirePcamFrameQueue, 1, dataQueue, frameDataQueue, cam, numSweeps, ...
                framesPerSweep, DAQSetting, continuousDAQParams, expdir, roiMaskDefault);
%%behavior cam acquisition
% need to sort out how to align more precisely
%numBehavCamFrames = framesPerSweep*numSweeps*2;
%f2 = parfeval(@singleCamAcquisition_disklogging, 1 ,  behavCam, numBehavCamFrames, expdir);

%save params
exposure=src.Exposure ; 
gain=src.Gain ;
paramsFile = strcat(expdir, '\', 'params.mat');
save(paramsFile, 'DAQSetting', 'continuousDAQParams', 'exposure', 'gain'); 

%%get output state
%outputState_cam = fetchOutputs(f1);
%outputState_behavCam = fetchOutputs(f2);


%% when finished at end 

%clean up

cam = imaqfind; delete(cam); clear all; close all; 

poolobj = gcp('nocreate');
delete(poolobj);