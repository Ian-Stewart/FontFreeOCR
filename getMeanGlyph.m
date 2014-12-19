%Small function to see if matching is working
function img = getMeanGlyph(chars, matched_sets, set_idx, number_in_set)
    img = zeros(17,13);
    for i = 1:17
        for j = 1:13
            for k = 1:number_in_set
                img(i,j) = img(i,j) + chars(i,j,matched_sets(set_idx,k));
            end
        end
    end
    img = img ./ number_in_set;
end