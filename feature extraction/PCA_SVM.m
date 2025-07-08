clc; 
clear all;
%%
% I = double(imread('peppers.png'));
% X = reshape(I,size(I,1)*size(I,2),3);
% coeff = pca(X);
%%
imds = imageDatastore('DR','IncludeSubfolders',true,'LabelSource','foldernames');
[trainingSet,testSet] = splitEachLabel(imds,0.8,'randomized'); 

%%
img = readimage(trainingSet, 240);

%%
img = double (img);
% img = reshape(img,size(img,1)*size(img,2),3);
[pca_4x4] = pca(img);

%%
 cellSize = [4 4];
pcaFeatureSize = length(pca_4x4);

%%
numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages,pcaFeatureSize,'single');

for i = 1:numImages
    img = readimage(trainingSet,i);
    
%     img = im2gray(img);
%     img = adapthisteq(img);
    % Apply pre-processing steps
%     img = imbinarize(img);
    img = double(img);
%     m = size(img,1)*size(img,2);
%     n = 3;
    img = reshape(img,size(img,1)*size(img,2),3,[]);
    trainingFeatures(i, :) = pca(img);  
end
%%

% Get labels for each image.
trainingLabels = trainingSet.Labels;

%%
numImages = numel(testSet.Files);
testFeatures = zeros(numImages,pcaFeatureSize,'single');

for i = 1:numImages
    img = readimage(testSet,i);
    
%     img = im2gray(img);
    
    % Apply pre-processing steps
%     img = imbinarize(img);
    img = double(img);
%     m = size(img,1)*size(img,2);
%     n = 3;
    img = reshape(img,size(img,1)*size(img,2),3,[]);
    testFeatures(i, :) = pca(img);  
end

%%
testLabels = testSet.Labels;

%%
classifier = fitcecoc(trainingFeatures, trainingLabels);

%%
predictedLabels = predict(classifier, testFeatures);

%%
confMat = confusionmat(testLabels, predictedLabels);

%%
accuracy = mean(predictedLabels == testLabels)