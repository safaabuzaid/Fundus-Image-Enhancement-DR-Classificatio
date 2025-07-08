clc; 
clear all;

%%
TrainingSet = imageDatastore('TrainingSet','IncludeSubfolders',true,'LabelSource','foldernames');
TestSet = imageDatastore('TestSet','IncludeSubfolders',true,'LabelSource','foldernames');

% [trainingSet,testSet] = splitEachLabel(imds,0.8,'randomized'); 

%%
countEachLabel(TrainingSet)
countEachLabel(TestSet)

%% show some training images
numTrainImages = numel(TrainingSet.Labels);
idx = randperm(numTrainImages,12);
figure
for i = 1:12
    subplot(4,3,i)
    I = readimage(TrainingSet,idx(i));
    imshow(I)
end

 %% process to whole images 
 
imgFiles = dir('*.JPEG');   % get all png files in the folder 
numfiles = length(imgFiles);  % total number of files 
for k = 1:numfiles   % loop for each file 
    img = imgFiles(k).name    % present image file 
    %%do what you want %%
    img = imresize(img, [224 224]);
end
%%
% Load pretrained network
net = resnet50();

%%
imageSize = net.Layers(1).InputSize;
augmentedTrainingSet = augmentedImageDatastore(imageSize, TrainingSet, 'ColorPreprocessing', 'gray2rgb');
augmentedTestSet = augmentedImageDatastore(imageSize, TestSet, 'ColorPreprocessing', 'gray2rgb');

%%
% Get the network weights for the second convolutional layer
w1 = net.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5); 

% Display a montage of network weights. There are 96 individual sets of
% weights in the first layer.
figure
montage(w1)
title('First convolutional layer weights')

%%
featureLayer = 'fc1000';
trainingFeatures = activations(net, augmentedTrainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

%%
% Get training labels from the trainingSet
trainingLabels = TrainingSet.Labels;

% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

%%
% Extract test features using the CNN
testFeatures = activations(net, augmentedTestSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures, 'ObservationsIn', 'columns');

% Get the known labels
testLabels = TestSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))

%%
% Display the mean accuracy
mean(diag(confMat))

%%
