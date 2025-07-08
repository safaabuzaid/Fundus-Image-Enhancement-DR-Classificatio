clear all; 
clc,

%%
imds = imageDatastore('DR','IncludeSubfolders',true,'LabelSource','foldernames');
[trainingSet,testSet] = splitEachLabel(imds,0.8,'randomized');

%%
countEachLabel(trainingSet)
countEachLabel(testSet)

%%
% Show pre-processing results
exTestImage = readimage(testSet,37);
processedImage = imbinarize(im2gray(exTestImage));

figure;

subplot(1,2,1)
imshow(exTestImage)

subplot(1,2,2)
imshow(processedImage)

%%
img = readimage(trainingSet, 100);

% Extract HOG features and HOG visualization
[hog_2x2, vis2x2] = extractHOGFeatures(adapthisteq(img),'CellSize',[2 2]);
[hog_4x4, vis4x4] = extractHOGFeatures(adapthisteq(img),'CellSize',[4 4]);
[hog_8x8, vis8x8] = extractHOGFeatures(adapthisteq(img),'CellSize',[8 8]);

% Show the original image
figure; 
subplot(2,3,1:3); imshow(img);

% Visualize the HOG features
subplot(2,3,4);  
plot(vis2x2); 
title({'CellSize = [2 2]'; ['Length = ' num2str(length(hog_2x2))]});

subplot(2,3,5);
plot(vis4x4); 
title({'CellSize = [4 4]'; ['Length = ' num2str(length(hog_4x4))]});

subplot(2,3,6);
plot(vis8x8); 
title({'CellSize = [8 8]'; ['Length = ' num2str(length(hog_8x8))]});

%%
cellSize = [4 4];
hogFeatureSize = length(hog_4x4);

%%
% Loop over the trainingSet and extract HOG features from each image. A
% similar procedure will be used to extract features from the testSet.

numImages = numel(trainingSet.Files);
trainingFeatures = zeros(numImages,hogFeatureSize,'single');

for i = 1:numImages
    img = readimage(trainingSet,i);
    
    img = im2gray(img);
    
    % Apply pre-processing steps
    img = imbinarize(img);
    
    trainingFeatures(i, :) = extractHOGFeatures(img,'CellSize',cellSize);  
end

% Get labels for each image.
trainingLabels = trainingSet.Labels;

%%
numImages = numel(testSet.Files);
testFeatures = zeros(numImages,hogFeatureSize,'single');

for i = 1:numImages
    img = readimage(testSet,i);
    
    img = im2gray(img);
    
    % Apply pre-processing steps
    img = imbinarize(img);
    
    testFeatures(i, :) = extractHOGFeatures(img,'CellSize',cellSize);  
end

% Get labels for each image.
testLabels = testSet.Labels;
%%
% fitcecoc uses SVM learners and a 'One-vs-One' encoding scheme.
classifier = fitcecoc(trainingFeatures, trainingLabels);

%%
% Extract HOG features from the test set. The procedure is similar to what
% was shown earlier and is encapsulated as a helper function for brevity.
% [testFeatures, testLabels] = helperExtractHOGFeaturesFromImageSet(testSet, hogFeatureSize, cellSize);

% Make class predictions using the test features.
predictedLabels = predict(classifier, testFeatures);

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% helperDisplayConfusionMatrix(confMat)

%%
accuracy = mean(predictedLabels == testLabels)