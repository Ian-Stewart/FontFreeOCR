%Function to translate image
%ti is up/down, tj is left/right.
function timg = translateImage(image,ti,tj)
    %Image shifting is done by cutting off the side that is shifted
    %out-of-frame, and then populating the opposite side with 255
    %if ti is negative, image shift up
    %if tj is negative, image shift left
    h = size(image,1);
    w = size(image,2);
    timg = circshift(image(:,:),[ti,tj]);
    if(ti < 0)
        timg((h+1+ti):h,:) = ones(-ti,w)*255;
    else
        timg(1:ti,:) = ones(ti,w)*255;
    end
    if(tj < 0)
        timg(:,((w+1+tj):w)) = ones(h,-tj)*255;
    else
        timg(:,1:tj) = ones(h,tj)*255;
    end
end% function translateImg