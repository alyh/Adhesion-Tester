v  = VideoReader('videos/thesis analysis/preload dependance/8n preload detachment.mp4');

count = 1;
%%
disp('Reading video frames...')
sum_frame=zeros(960,1280);

for i=1:v.NumberOfFrames
    % read frame as image and convert to grayscale
    frame = read(v,i);
    frame_bw = rgb2gray(frame)>60;
    frame_bw = imerode(frame_bw,strel('square',1));
    frame_bw = bwareaopen(frame_bw,50);
    sum_frame = frame_bw + sum_frame;
end
%%
disp('Finding circles...')
guide_frame = rgb2gray(read(v,2));
guide_frame = imadjust(guide_frame);
%guide_frame = imsharpen(guide_frame,'Radius',2,'Amount',1);

[centers,radii]=imfindcircles(guide_frame,[5 9],'ObjectPolarity','dark', ...
    'Sensitivity',0.955,'EdgeThreshold',0.1);

centers(radii>6.4,:)=[]; %7.5 for 4N test2 sample
radii(radii>6.4)=[];

imshow(guide_frame)
viscircles(centers,radii*1.48,'LineWidth',1);

%%
disp('Finding intensity in each circle...')
circ_ints = zeros(length(centers),3);
for i=1:length(centers)
    circ_int = find_circle_intensity(centers(i,1),centers(i,2),radii(i)*1.48,sum_frame);
    circ_ints(i,:)=[centers(i,:) circ_int]; 
end

disp('Plotting...')
%circ_ints(circ_ints(:,3)>1.1e4,3)=1.1e4;
circ_ints(:,3) = circ_ints(:,3) - min(min(circ_ints(:,3)))+40;
%circ_ints(circ_ints(:,3)<=50,:)=[];

scatter3(circ_ints(:,1),circ_ints(:,2),circ_ints(:,3),200,circ_ints(:,3).^3,'.')
colormap hot
%ylim([-10 525])
%xlim([-10 525])
view(0,90)
set(gca,'Color','k')
set(gcf,'Position',[200 200 260 250])
