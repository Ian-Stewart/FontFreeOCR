%given a list of mean glyphs, compute the mean glyph
%glyphs is a set of 17x13 images
function meanGlyph = computeMeanGlyph(glyphs)
    meanGlyph = double(zeros(17,13));
    for i = 1:17
        for j = 1:13
            meanGlyph(i,j) = mean(glyphs(i,j,:));
        end% for j = 1:13
    end% for i = 1:17
end