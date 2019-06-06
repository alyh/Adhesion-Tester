%% Video importing

% read entire video
v  = VideoReader('videos/new dino videos/4N preload test1.wmv.mp4');
adhesion_data = csvread('data/05-28-2019 15:37- new dino fixture - 4N preload.csv');
output_file = 'output/new dino videos/4N.csv';

full_intensity = [];
count = 1;

all_bw = [];

disp('Reading video frames')
previousCenters = [];
lost=[];
ncount=1;
numDetached=[];
detachedList=[0.0 0.0 0.0];

for i=580:648
    % read frame as image and convert to grayscale
    frame = read(v,i);
    frame_bw = rgb2gray(frame);
    % measure intensity of entire image (analogue to # of pillars for now)
    [full_intensity(count),centers,radii] = pillar_counter(frame_bw);
   % all_bw(:,:,count) = final_bw;

    centers(find(radii>6),:)=[];
    radii(find(radii>6))=[];
    
    if isempty(previousCenters)
        previousCenters =  centers;
    end
    
    detached = 0;
    for j=1:length(radii)
        d=pdist2(centers(j,:),previousCenters);
        if length(find(d<6,1)) >= 1    
            continue
        end
        
        d2 = pdist2(centers(j,:),detachedList(:,1:2));
        if length(find(d2<6,1)) >= 1
            disp(['replaced ',num2str(detachedList(find(d2<6,1),3)),' with ',num2str(length(find(d<20)))])
            detachedList(find(d2<6,1),:) = [centers(j,:),length(find(d<20))];
           
        else        
            detachedList(ncount,:) = [centers(j,:),length(find(d<20))];
            ncount = ncount+1;
        end
        
    end
    numDetached(count) = detached;
    count = count +1;
    previousCenters =  centers;
end



%% Extract the region where the pillars attach/unattach in the video
disp('Extracting relevant frames')
%full_intensity(25:35)=0
intensity_region = find(full_intensity > 5);
intensity = full_intensity(intensity_region(1):intensity_region(end));
% normalize intensity
%intensity = (intensity-min(intensity))./max(intensity-min(intensity));

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