%This is the main function of the font-free OCR program.
function text = decodeText(unsorted_words)
    %uncomment to read an image in
    input_image = imread('declaration.png');
    binary_image = translateInputImage(input_image);
    unsorted_words = splitTextImage(binary_image);
    %sorted_words = sortWords(unsorted_words);
    %[blob_locations, chars] = convertListToBlobs(sorted_words);
    [blob_locations, chars] = convertListToBlobs(unsorted_words);
    %imagesc(computeMeanGlyph(chars));
    %Create 'matched sets'. In this version, elements of the matched sets
    %do not get re-assigned after matching because there are only ever
    %perfect matches. Re-matching should be implemented once noise is added
    matched_sets = zeros(26, 1000);%For each letter, store indexes of matched characters
    number_matched = zeros(26,1);% Keep track of the number of characters in each matched set
    num_matched_sets = 0;%bookkeeping
    
    %Store the old words
    old_words = blob_locations;
    
    %General process:
    %While(there are blobs):
    %Pick a unit-length blob (glyph)
    %Compare to mean glyph for all matched sets:
    %If MI > 0.75, add to set
    %If MI < 0.75, make new matched set, shatter blobs
    %Do translation
    %For all other characters
    while(size(blob_locations,2) > 1 )%&& num_matched_sets < 26)
        glyph_blob = findGlyphs(blob_locations);
        if(glyph_blob > 0)
            glyph = blob_locations(glyph_blob,2);
            blob_locations = removeShatteredBlob(glyph_blob, blob_locations);
        else%There are no single-char wide blobs. Shatter the first blob.
            [n_blobs, new_blobs] = shatterBlobAtPos(blob_locations(1,:),blob_locations(1,2));
            blob_locations = removeShatteredBlob(1,blob_locations);
            if(size(blob_locations,2) > 1)
                blob_locations = [blob_locations;new_blobs];
            else
                blob_locations = new_blobs;
            end
        end
        found = 0;
        %Compare to mean glyph for all matched sets
        if(num_matched_sets > 1)
            for set_idx = 1:num_matched_sets
                if(mutualInformationBetweenCharacters(chars(:,:,glyph), chars(:,:,matched_sets(set_idx,1))) > 0.70)
                        %getMeanGlyph(chars, matched_sets, set_idx, number_matched(set_idx)))....% Mean of matched set
                        
                    found = set_idx;
                end% if
            end% for i = 1:num_matched_sets
        elseif(num_matched_sets == 1)% there is exactly one matched set
            if(mutualInformationBetweenCharacters(chars(:,:,glyph), chars(:,:,matched_sets(1,1))) > 0.70)
                found = 1;
            end
        else
            %found = 0
        end% if (num_matched_sets > 0)
        
        %At this point, if found = 0, the glyph must be used to create a
        %new matched set. It must also be used to shatter other blobs.
        
        %In the case where found = 1, add to matched set and go around again
                
        if(found == 0)% Glyph does not fit in any matched sets
            if(num_matched_sets < 26)%Create a new matched set
                num_matched_sets = num_matched_sets + 1;
                matched_sets(num_matched_sets,1) = glyph;%Add glyph as new matched set
                number_matched(num_matched_sets) = 1;% The matched set contains one character
                if(size(blob_locations,1)>1)
                    [new_glyphs,blob_locations] = shatterBlobs(chars, glyph, blob_locations);%huh?
                end
                for new_glyph = 1:size(new_glyphs,1)
                    if(new_glyphs(new_glyph) ~= 0)
                        number_matched(num_matched_sets) = number_matched(num_matched_sets)+1;
                        matched_sets(num_matched_sets,number_matched(num_matched_sets)) = new_glyphs(new_glyph);
                    end
                end% for 
            else%All letters have been found, match to closest letter
                max_mi = 0;
                max_mi_idx = 0;
                for i = 1:26
                    t_mi = mutualInformationBetweenCharacters(chars(:,:,matched_sets(i,1)),chars(:,:,glyph));
                    if(t_mi > max_mi)
                        max_mi = t_mi;
                        max_mi_idx = i;
                    end%if
                end%for i = 1:26
                %Add to closest set
                number_matched(max_mi_idx) = number_matched(max_mi_idx)+1;
                matched_sets(max_mi_idx, number_matched(max_mi_idx)) = glyph;
            end
        else% Glyph belongs in a matched set with index (found)
            number_matched(found) = number_matched(found) + 1;
            matched_sets(found,number_matched(found)) = glyph;
        end% if(found == 0)
        %a = num_matched_sets
        %b = size(blob_locations)
        %if(found > 0)
        %    c = number_matched(found)
        %end
    end% while(size(blob_locations,1) > 0)

    
    %Check output of matched sets
    %imagesc([chars(:,:,2360),chars(:,:,5),chars(:,:,18)]);
    %m = number_matched;
    %m = matched_sets;
    %printMatchedSets(chars,matched_sets,number_matched);
    
    %Now find the distributions
    distribution = findDistribution(matched_sets, chars);
    distribution = [transpose(1:26),distribution];
    distribution = sortrows(distribution,2);
    
    %Create the true distribution for English
%     english_distribution = [...
%       8.167;1.492;2.782;4.253;12.702;...
%       2.228;2.015;6.094;6.966;0.153;...
%       0.772;4.025;2.406;6.749;7.507;...
%       1.929;0.095;5.987;6.327;9.056;...
%       2.758;0.978;2.360;0.150;1.974;0.074...
%        ];
    english_distribution = [183;35;79;98;340;63;45;147;158;5;4;92;53;182;181;50;3;146;164;275;73;30;33;1;30;1];
    letters = ['a';'b';'c';'d';'e';'f';'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v';'w';'x';'y';'z';];
    english_distribution = [transpose(1:26),english_distribution];
    english_distribution = sortrows(english_distribution,2);
    
    %Now, join the english distribution to the character distribution
    distribution_map = [distribution,english_distribution];
    
    distribution_map = sortrows(distribution_map,1);
    
    text = 'Results: ';
    
    for word = 1:size(old_words,1)
        for character = (old_words(word,1)+1):old_words(word,2)
            %For each character in a word, find the matched set it fits
            %most closely with
            max_mi = 0;
            max_mi_idx = 0;
            for set = 1:26
                t_mi = mutualInformationBetweenCharacters(chars(:,:,matched_sets(set,1)),chars(:,:,character));
                if(t_mi > max_mi)
                    max_mi = t_mi;
                    max_mi_idx = set;
                end%if
            end
            %Append the character with the highest mutual information
            text = strcat(text,letters(distribution_map(max_mi_idx,3)));

        end
        text = [text,'_'];        
    end
    %Done!
    %m = distribution_map;
end%function

% This function is called whenever a new matched set is created.
% Takes a list of characters, a glyph (as an index), and a list of blobs
% Returns a new list of blobs.
% Matched glyphs in the new set are added as blobs of length = 1
% Deletes old blobs
% 
function [new_glyphs, new_blobs] = shatterBlobs(chars, glyph, blobs)
    i = 1;
    found = 0;
    %imagesc(chars(:,:,glyph));
    new_blobs = 0;
    new_glyphs = 0;
    while (i <= size(blobs,1))
        pos = blobContainsChar(chars(:,:,glyph), blobs(i,:), chars);% Does blob contain character
        %printWord(chars,blobs(i,:));
        if(pos > 0);% If so, shatter it and append list of blobs
            if (found == 0);
                [n_blobs, new_blobs] = shatterBlobAtPos(blobs(i,:),pos);
                if(n_blobs > 0)
                    found = 1;
                else
                end
                new_glyphs = pos;
            else
                [n_blobs, t_new_blobs] =  shatterBlobAtPos(blobs(i,:),pos);% Add new blobs
                if(n_blobs > 0);
                    new_blobs  = [new_blobs;t_new_blobs];
                end%if
                new_glyphs = [new_glyphs;pos];
            end% if found == 0
            blobs = removeShatteredBlob(i, blobs);% Delete old blob
        else
            i = i + 1;
        end% if (pos > 0)
        c = 0;
        c = c+1;
    end% while i <= size(blobs)
        if(size(new_blobs,2) == 2)
            new_blobs = [new_blobs;blobs];%Append old blobs
        else
            new_blobs = blobs;
        end
end% function shatterBlobs

%Function to find the percentages for each letter
function distribution = findDistribution(matched_sets, chars)
    %total_chars = 0;
    total_chars = size(chars,3);
    chars_found = zeros(26,1);
    for i = 1:26
        for j = 1:1000
            if (matched_sets(i,j) > 0)
                chars_found(i) = j;
                %total_chars = total_chars + 1;
            end%if matched_sets > 0
        end%for j = 1:1000
    end%for i = 1:26
    chars_found = double(chars_found);
    %distribution = chars_found./total_chars;
    distribution = chars_found;
end% function findDistribution

%Pretty simple...cuts a row out of the blobs list
function updated_blobs = removeShatteredBlob(index, blobs)
    %i = index
    if (index == 1 && size(blobs,1)==1)
        updated_blobs = 0;
    else
        if (index == 1)%index is at start
            updated_blobs = blobs(2:end,:);
        else
            if (index == size(blobs,1))%index is at end
                updated_blobs = blobs(1:end-1,:);
            else%index is in middle
                updated_blobs = [blobs(1:index-1,:);blobs(index+1:end,:)];
            end
        end% (index == 1)
    end%if (index == 1 && size(blobs,1)==1)
end% function removeShatteredBlob

%Finds a glyph (a blob of length 1) in the unmatched set as an index
function blob = findGlyphs(blobs)
    blob = 0;
    for i = 1:size(blobs,1)
        if(blobs(i,2) - blobs(i,1) == 1)
            blob = i;
        end% if
    end% for i = 1:size(blobs,1)
end% findShortBlob

%Shatters a blob at a given position.
%Returns number of blobs generated and blobs generated (0, 1, 2)
%Blobs are represented by pair (end of last blob, end of blob)
function [n_blobs, new_blobs] = shatterBlobAtPos(blob,pos)
    if(pos == (blob(1)+1) && pos == blob(2))%blob is a single matched glyph
        n_blobs = 0;
        new_blobs = 0;
    else
        if(pos == (blob(1)+1))%matched character is at start of blob, create two blobs
            new_blobs = [...
                blob(1)+1,blob(2)...
                ];%Create new blob that is one character shorter
            n_blobs = 1;
        else%
            if(pos == blob(2))% matched character is at end of blob, create two blobs
                new_blobs = [...
                    blob(1), blob(2)-1;...
                    ];
                n_blobs = 1;
            else% matched character is in middle of blob, create three blobs
                new_blobs = [...
                    blob(1),pos-1;...
                    pos,blob(2)...
                    ];
                n_blobs = 2;
            end% end if pos == blob(2)
        end% end if pos == blob(1) + 1
    end% blob is single matched glypg
end% function shatterBlobAtPos

%Determines if a blob contains a certain character
%Returns 0 if no, or an integer representing the position of the match
function pos = blobContainsChar(character, blob, chars)
    pos = 0;
    for i = (blob(1)+1:blob(2))
        if( mutualInformationBetweenCharacters(chars(:,:,i), character) > 0.70)%characters match
            pos = i;
         end%if
     end% for i
 end% function blobContainsChar

    %Main matching loop
%     for char_to_match = 1:26
%         %Select a new single-width glyph
%         %note: This version does not handle glyphs of multi-width, meaning
%         %there will be issues if there is no single-width blob at the
%         %start of each loop
%         short_blob = findGlyphs(blob_locations);
%         if(short_blob == 0)
%             break
%         end
%         glyph = blob_locations(short_blob,2);
%         matched_sets(char_to_match,1) = glyph;
%         blob_locations = removeShatteredBlob(short_blob, blob_locations);
%         
%         matched_chars = 1;
%         %shatter unmatched blobs
%         i = 1;
%         while (i <= size(blob_locations,1))
%             match_position = blobContainsChar(chars(:,:,matched_sets(char_to_match,1)), blob_locations(i,:), chars);%search for the character
%             if(match_position > 0)%There is a match
%                 %If there is a match, must:
%                 %Record the matched character's location in the matched set
%                 %Update the number of matched characters
%                 %Shatter the blob
%                 %Update the number of unmatched blobs if shattering
%                 %produces new blobs
%                 
%                 matched_chars = matched_chars + 1;
%                 matched_sets(char_to_match,matched_chars) = match_position;% record the position of the matched character
%                 
%                 [n_blobs,new_blobs] = shatterBlobAtPos(blob_locations(i,:),match_position);
%                 if(n_blobs > 0)
%                     blob_locations = [blob_locations;new_blobs];
%                 end
%                 %remove current blob from unmatched blobs set, since it has
%                 %been shattered and/or matched
%                 blob_locations = removeShatteredBlob(i,blob_locations);
%             else
%                 i = i + 1;
%             end%if (match_position > 0)
%         end% for i = 1:umatched_blobs
%     end%for char_to_match = 1:26
    %Now find distribution
    %distribution = findDistribution(matched_sets, chars);
    %distribution = [transpose(1:26),distribution];
    %distribution = sortrows(distribution,2);
    %m = distribution;
    %m = matched_sets;
    %sizeOfLocs = size(blob_locations)
    
    %Create the true distribution for English
    %english_distribution = [8.167;1.492;2.782;4.253;12.702;2.228;2.015;6.094;6.966;0.153;0.772;4.025;2.406;6.749;7.507;1.929;0.095;5.987;6.327;9.056;2.758;0.978;2.360;0.150;1.974;0.074];
    %letters = ['a';'b';'c';'d';'e';'f';'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v';'w';'x';'y';'z';];
    %english_distribution = [transpose(1:26),english_distribution];
    %english_distribution = sortrows(english_distribution,2);
    
    %Now, join the english distribution to the character distribution
    %distribution_map = [distribution,english_distribution];
    %m = distribution_map;
    %m = matched_sets;
    %m = 0;