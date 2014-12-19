function W = splitWord(word)
    %words are at most 15 characters long
    %each character is 17x13
    W = zeros(17,13,15);
    for i = 0:14
        W(:,:,i+1) = word(1:17,((i*14)+5):((i*14)+17));
    end%for j = 1:15
end%function