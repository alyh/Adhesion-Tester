function [count,centers,radii] = pillar_counter(frame)
%     I = 1-(frame>40);
%     I=logical(I);
%     I = I & (~guide);
% 
%     J = imdilate(I,strel('disk',1));
%     J = imerode(I,strel('square',3));
%     J = bwareafilt(J,[8,500]);
%     J = imdilate(J,strel('disk',2));
%     J = bwpropfilt(J,'eccentricity',[0,0.8]);
%     J = bwareafilt(J,[0,140]);
%     
%     [~,count] = bwlabel(J);
% %     final_bw = J;
% [centers,radii]=imfindcircles(frame,[5 9],'ObjectPolarity','bright', ...
%     'Sensitivity',0.95,'EdgeThreshold',0.13);
[centers,radii]=imfindcircles(frame,[5 9],'ObjectPolarity','dark', ...
    'Sensitivity',0.96,'EdgeThreshold',0.15);
count = length(centers);
end

