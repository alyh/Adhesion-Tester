%% Video importing

% read entire video
v  = VideoReader('videos/new dino videos/10N preload test1.wmv.mp4');
adhesion_data = csvread('data/05-28-2019 15:43- new dino fixture - 10N preload.csv');
output_file = 'output/new dino videos/10N';

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

centers(find(radii>6.3),:)=[]; %7.5 for 4N test2 sample
radii(find(radii>6.3))=[];

imshow(guide_frame)
viscircles(centers,radii*1.48,'LineWidth',1);
%% Get intensity of pillars over time

circ_int = zeros(length(radii),length(v.NumberOfFrames));
radii =  radii.*1.48;

for i=1:v.NumberOfFrames
    frame = read(v,i);
    frame_bw = rgb2gray(frame);
    
    for j=1:length(radii)
        circ_int(j,i) = find_circle_intensity(centers(j,1),centers(j,2),radii(j),frame_bw);
    end
    disp([num2str(i),'/',num2str(v.NumberOfFrames)])
end

writematrix(circ_int,[output_file,' - pillar intensity.csv']);

%% OR import existing pillar intensity matrix
% circ_int = csvread('output/new dino videos/10N - pillar intensity.csv');

%%

circle_int_d1 = diff(circ_int');
count=0;
bad_pillars = [];
cutoff=[];
time=[];
for i=1:length(radii)
    a_mean = mean(circle_int_d1(guide_index-50:guide_index+20,i));
    a_stddev = std(circle_int_d1(guide_index-100:guide_index+20,i));
    cutoff(i)=(abs(a_mean)+abs(a_stddev))*2.5;
    
    a = find(circle_int_d1(850:end,i)<-cutoff(i),1);
    time(i)=a;
    time(i) = find(circ_int(i,800:end)<50,1);
    if isempty(a)
        count = count+1;
        bad_pillars(count) = i;
    end
end
count
pillar_info = horzcat(centers,horzcat(radii,(time+guide_index)'));

%% Find # of neighbours when it detaches

% remove pillars that detached abnormally early (probably cut in half)
pillar_info(pillar_info(:,4)<400,:)=[];

pillar_info(:,5) = zeros( length(pillar_info),1);
for i=1:length(pillar_info)
    d = pdist2(pillar_info(i,1:2),pillar_info([1:(i-1),(i+1):end],1:2));
    
    pillar_info(i,5) = sum(pillar_info(find(d<22),4)>pillar_info(i,4));
end

scatter3(pillar_info(:,1),pillar_info(:,2),pillar_info(:,5),40,pillar_info(:,5),'MarkerFaceColor','flat')
xlim([0 800])
ylim([0 800])
colormap(copper)
figure
scatter3(pillar_info(:,1),pillar_info(:,2),pillar_info(:,5),40,pillar_info(:,5),'MarkerFaceColor','flat')
xlim([0 800])
ylim([0 800])
colormap(copper)

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