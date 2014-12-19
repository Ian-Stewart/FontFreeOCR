function split = splitTextImage(im)
    %image is 12195x225
    %characters are 17x13
    %508 words
    %return 508 words with a max of 15 characters
    split = (zeros(17,13,15,508));
    for i = 0:507;
        split(:,:,:,i+1) = splitWord(im(((i*24)+7):((i*24)+23),:));
    end%for i = 1:508
end%function splitTextImage