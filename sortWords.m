%Sort words by length (increasing)
function sortedWords = sortWords(words)
    %Find the number of characters in each word
    chars_per_word = sortrows(findWordLengths(words),2);
    %Insert the words into the list to return in sorted order
    sortedWords = zeros(size(words));
    for i = 1:508
        sortedWords(:,:,:,i) = words(:,:,:,chars_per_word(i,1));
    end%for i = 1:508
end% function sortWords