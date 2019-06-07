function [intensity] = find_circle_intensity(x,y,radius,frame)
    [frameY,frameX,~] = size(frame);
    [columnsInImage, rowsInImage] = meshgrid(1:frameX, 1:frameY);
    % Next create the circle in the image.
    circlePixels = (rowsInImage - y).^2 ...
        + (columnsInImage - x).^2 <= radius.^2;
    intensity = sum(frame(circlePixels))/100;
end

