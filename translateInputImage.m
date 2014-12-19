%simple function to take a rgb image and turn it into black/white
%Kinda slow
function binImage = translateInputImage(img)
binImage = zeros(size(img,1),size(img,2));
    for i = 1:size(img,1)
        for j = 1:size(img,2)
            binImage(i,j) = thresholdPixel([i,j],img);
        end% for j
    end% for i
end% function translateInputImage

%simple function to threshhold to 1 or 0
function value = thresholdPixel(location, img)
    if(sum(img(location(1),location(2),:)) < 382)
        value = 1;
    else
        value = 0;
    end% if sum(img(location(1),location(2),:)) > 382
end% function thresholdPixel