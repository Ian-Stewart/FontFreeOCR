%Finds the mutual information of two random variables given a joint
%discrete distribution of the random variables
%This uses the property I(X,Y) = H(X)+ H(Y) - H(X,Y)
%Note on notation: The joint table is assumed to be P(x,y). In other words,
%row indicates the value of x, col indicates value of y.
function mutInfo = mutInfo(joint)
    HX = discreteEntropy(sum(joint,2));%Entropy of the marginal P(X)
    HY = discreteEntropy(sum(joint,1));%Entropy of the marginal P(Y)
    HXY = discreteEntropy(joint(:));%Entropy of joint distribution
    mutInfo = HX + HY - HXY;
end% function mutInfo