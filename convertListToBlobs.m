%This function turns a list of words into a list of 'blobs'
function [blob_locations, chars] = convertListToBlobs(sorted_word_list)
    word_lengths = findWordLengths(sorted_word_list);
    sums = sum(word_lengths);
    chars = zeros(17,13,sums(2));
    char_idx = 1;
    for i = 1:508
        for j = 1:word_lengths(i,2)
            chars(:,:,char_idx) = sorted_word_list(:,:,j,i);
            char_idx = char_idx + 1;
        end
    end
    blob_lengths = zeros(508,1);
    for i = 1:508
       blob_lengths(i) = word_lengths(i,2); 
    end% for i = 1:508
    %Blob locations represents the end of last blob and end of current blob
    blob_locations = zeros(508,2);
    last_end = 0;
    for i = 1:508
        blob_locations(i,1) = last_end;
        blob_locations(i,2) = blob_locations(i,1) + blob_lengths(i);
        last_end = blob_locations(i,2);
    end% for i = 1:508
    chars = double(chars);
end% function convertListToBlobs