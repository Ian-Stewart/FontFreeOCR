%This function takes an image and splits it into thirds vertically.
%I assume the image to be 999px high with 25px of white border at top
%and bottom. Ideally this would use a nicer method of splitting involving
%edge detection, but this seems good enough. Splits incorrectly on 00194v and 01167v, but not too badly. 
function image = splitImage(img)
    image(:,:,1) = img(13:345,1:size(img,2));
    image(:,:,2) = img(346:678,1:size(img,2));
    image(:,:,3) = img(679:1011,1:size(img,2));
end% function splitImage