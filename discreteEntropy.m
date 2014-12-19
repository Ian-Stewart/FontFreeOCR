%Calculates the entropy of a discrete probability distribution
%Input is a 1D vector containing n values for P(x1)...P(xn)
%Value returned is in bits
%Note: This can all be accomplished with the matlab function entropy(), but
%that's no fun.
function entropy = discreteEntropy(distribution)
    distribution = arrayfun(@findProbabilityLog,distribution);
    distribution = arrayfun(@nanRemove,distribution);
    entropy = -sum(distribution);
end% function discreteEntropy

%small function to find P(x)log(P(x))
function findProbLog = findProbabilityLog(probability)
    findProbLog = probability * log2(probability);
end%function findProbabilityLog

%Small function that returns 0 if input is NaN
function nanRemove = nanRemove(element)
    nanRemove = element;
    if(isnan(element))
        nanRemove = 0;
    end%if (element == NaN)
end% function infToZero