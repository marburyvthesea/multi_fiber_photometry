%get lag between DAQ and trigger 

total_frames = length(trigger_times);

trigger_DAQ_lag = zeros(total_frames, 1); 

for i = 1:total_frames    
    trigger_DAQ_lag(i, 1) = second(trigger_times(i, 1))-second(DAQ_times(i,1)) ;    
end
    
    