%% Video importing

% read entire video
v  = VideoReader('videos/new dino videos/4N preload test1.wmv.mp4');
adhesion_data = csvread('data/05-28-2019 15:37- new dino fixture - 4N preload.csv');
output_file = 'output/new dino videos/4N.csv';

frame_skipping =  3;
full_intensity = zeros(length(1:frame_skipping:v.NumberOfFrames),1);
count = 1;

disp('Reading video frames')

for i=1:frame_skipping:v.NumberOfFrames
    % read frame as image and convert to grayscale
    frame = read(v,i);
    frame_bw = rgb2gray(frame);
    % measure intensity of entire image 
    full_intensity(count) = sum(sum(frame_bw));
    count = count +1;
end

disp('Finished reading video frames')
%% Find pillar guide and extract # of pillars
[~,guide_index] = max(full_intensity);
guide_index =  guide_index * frame_skipping;
guide_frame = rgb2gray(read(v,guide_index));
guide_frame = imadjust(guide_frame);
%guide_frame = imsharpen(guide_frame,'Radius',2,'Amount',1);

[centers,radii]=imfindcircles(guide_frame,[5 9],'ObjectPolarity','dark', ...
    'Sensitivity',0.96,'EdgeThreshold',0.15);

centers(find(radii>7.5),:)=[];
radii(find(radii>7.5))=[];

imshow(guide_frame)
viscircles(centers,radii*1.5,'LineWidth',1);
%% Get intensity of pillars over time

circ_int = zeros(length(radii),length(v.NumberOfFrames));
radii =  radii.*1.5;

for i=1:v.NumberOfFrames
    frame = read(v,i);
    frame_bw = rgb2gray(frame);
    
    for j=1:length(radii)
        circ_int(j,i) = find_circle_intensity(centers(j,1),centers(j,2),radii(j),frame_bw);
    end
    disp([num2str(i),'/',num2str(v.NumberOfFrames)])
end

%% Extract the region where the pillars attach/unattach in the video
disp('Extracting relevant frames')

intensity_region = find(full_intensity > 5);
intensity = full_intensity(intensity_region(1):intensity_region(end));
% normalize intensity
intensity = (intensity-min(intensity))./max(intensity-min(intensity));

%% Read force data and plot with pillar data
disp('Plotting intensity with adhesion force')
% Read adhesion force data and find relevant test region
adhesion_test_region = find(abs(adhesion_data) > 0.02);
test_length = adhesion_test_region(end)-adhesion_test_region(1)+1;

% Re-shape the pillar intensity data to same size as test to plot together
reshaper = round(linspace(1,length(intensity),test_length));
intensity_reshaped = intensity(reshaper);
intensity_reshaped = [zeros(1,adhesion_test_region(1)-1),intensity_reshaped,...
    zeros(1,length(adhesion_data)-adhesion_test_region(end))];

 x = 0 + (0:length(adhesion_data)-1)*0.3;

% Plot both with 2 different y axis 
yyaxis left
plot(x,(adhesion_data),'LineWidth',2)
ylabel('Force (N)','FontSize',15)
xlabel('Time (s)','FontSize',15)

yyaxis right
plot(x,intensity_reshaped,'LineWidth',2)
ylabel('Pillar Count','FontSize',15)

writematrix([adhesion_data intensity_reshaped'],output_file);
%% Adjust y-axis to align the zero

yyaxis left; yliml = get(gca,'Ylim');ratio = yliml(1)/yliml(2);
yyaxis right; ylimr = get(gca,'Ylim');
if ylimr(2)*ratio<ylimr(1)
    set(gca,'Ylim',[ylimr(2)*ratio ylimr(2)])
else
    set(gca,'Ylim',[ylimr(1) ylimr(1)/ratio])
end

grid on
grid minor