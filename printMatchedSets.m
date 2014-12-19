function img = printMatchedSets(chars, matched_sets, number_matched)
    img = getMeanGlyph(chars, matched_sets, 1, number_matched(1));
    for i = 2:26
        img = [img,getMeanGlyph(chars, matched_sets, i, number_matched(i))];
    end
    imagesc(img);
end