
[filename1, ~] = uigetfile('*.avi','File Selector');
test_vid = VideoReader(filename1);

roi_mean = zeros(test_vid.NumFrames,1);

for i = 1:test_vid.NumFrames
    active_frame = read(test_vid, i);
    roi_mean(i, 1) = mean(active_frame(roimask1), 'all'); 
end

figure()

plot(roi_mean)