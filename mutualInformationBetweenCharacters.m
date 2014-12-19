%Computes the mutual information between two characters.
% I(a,b) = H(a) + H(b) - H(a,b)
function I = mutualInformationBetweenCharacters(char_a, char_b)
    %First find the joint distribution
    %The joint table represents the values
    %     |a(1)|a(0)
    % b(1)|____|____
    % b(0)|____|____
    table = zeros(2,2);
    %unroll the characters
    char_a = char_a(:);
    char_b = char_b(:);
    char_a = char_a + 1;
    char_b = char_b + 1;
    for i = 1:(17*13)
        table(char_a(i),char_b(i)) = table(char_a(i),char_b(i))+1;
    end% for i = 1:(17*13)
    table = arrayfun(@(x) x/(13*17),table);
    %table is the joint distribution
    % Find mutual information I(X,Y) = H(X) + H(Y) - H(X,Y)
    I = mutInfo(table);
end% function mutualInformationBetweenCharacters