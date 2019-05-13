%% Video importing

% read entire video
v  = VideoReader('videos/3.5mm sample/8 preload - 2.wmv.mp4')

full_intensity = [];
count = 1;

% extract every 3rd frame 
for i=1:3:v.NumberOfFrames
    % read frame as image and convert to grayscale
    frame = read(v,i);
    frame_bw = rgb2gray(frame);
    
    % measure intensity of entire image (analogue to # of pillars for now)
    full_intensity(count) = sum(sum(frame_bw));
    count = count+1;
end

%% Extract the region where the pillars attach/unattach in the video

intensity_region = find(full_intensity > 500);
intensity = full_intensity(intensity_region(1):intensity_region(end));
% normalize intensity
intensity = (intensity-min(intensity))./max(intensity-min(intensity));

%% Read force data and plot with pillar data

% Read adhesion force data and find relevant test region
adhesion_data = csvread('data/may 10 - automated test 1/3.5mm sample - 8N preload.csv');
adhesion_test_region = find(abs(adhesion_data) > 0.02);
test_length = adhesion_test_region(end)-adhesion_test_region(1)+1;

% Re-shape the pillar intensity data to same size as test to plot together
reshaper = round(linspace(1,length(intensity),test_length));
intensity_reshaped = intensity(reshaper);
intensity_reshaped = [zeros(1,adhesion_test_region(1)-1),intensity_reshaped,...
    zeros(1,length(adhesion_data)-adhesion_test_region(end))];

% Plot both with 2 different y axis 
yyaxis left
plot((adhesion_data))
yyaxis right
plot(intensity_reshaped)

%% Adjust y-axis to align the zero

yyaxis left; yliml = get(gca,'Ylim');ratio = yliml(1)/yliml(2);
yyaxis right; ylimr = get(gca,'Ylim');
if ylimr(2)*ratio<ylimr(1)
    set(gca,'Ylim',[ylimr(2)*ratio ylimr(2)])
else
    set(gca,'Ylim',[ylimr(1) ylimr(1)/ratio])
end