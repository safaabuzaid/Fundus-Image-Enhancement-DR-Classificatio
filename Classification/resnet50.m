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

%%
% Load pretrained network
net = resnet50();

%%
lgraph = layerGraph(net);
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph)

%%
net.Layers(1)

%%
inputSize = net.Layers(1).InputSize;

%%
lgraph = removeLayers(lgraph, {'fc1000','fc1000_softmax','ClassificationLayer_fc1000'});

numClasses = numel(categories(TrainingSet.Labels));
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);

%%
lgraph = connectLayers(lgraph,'avg_pool','fc');

figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
plot(lgraph)
ylim([0,10])

%%
layers = lgraph.Layers;
connections = lgraph.Connections;
%%
 for i = 1:numel(layers)
        if isprop(layers(i),'WeightLearnRateFactor')
            layers(i).WeightLearnRateFactor = 0;
        end
        if isprop(layers(i),'WeightL2Factor')
            layers(i).WeightL2Factor = 0;
        end
        if isprop(layers(i),'BiasLearnRateFactor')
            layers(i).BiasLearnRateFactor = 0;
        end
        if isprop(layers(i),'BiasL2Factor')
            layers(i).BiasL2Factor = 0;
        end
 end

 %%
pixelRange = [-30 30];
scaleRange = [0.9 1.1];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange, ...
    'RandXScale',scaleRange, ...
    'RandYScale',scaleRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),TrainingSet, ...
    'DataAugmentation',imageAugmenter);
%%
augimdsTrain = augmentedImageDatastore(inputSize(1:2),TrainingSet);

%%
augimdsValidation = augmentedImageDatastore(inputSize(1:2),TestSet);

%%
miniBatchSize = 10;
valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',6, ...
    'InitialLearnRate',3e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',valFrequency, ...
    'Verbose',false, ...
    'Plots','training-progress');
%%
net = trainNetwork(augimdsTrain,lgraph,options);

%% other options

options = trainingOptions('sgdm', ...
    'ExecutionEnvironment','auto', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',60, ... %60
    'MiniBatchSize',20, ... %50
    'GradientThreshold',1, ...
    'Verbose',true, ...
    'Plots','training-progress');
convnet= trainNetwork(augimdsTrain,lgraph,options);
save convnet;


%%
[YPred,probs] = classify(net,augimdsValidation);
accuracy = mean(YPred == TestSet.Labels)
disp(accuracy);

%% features train 
layer = 'fc1000' ;
featuresTrain = activations(net,augimdsTrain,layer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');
featuresTest = activations(net,augimdsValidation,layer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

 %%
whos featuresTrain
whos featuresTest

%%
YTrain = TrainingSet.Labels ;
YTest = TestSet.Labels;

%%
classifier = fitcecoc(featuresTrain, YTrain, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

%%
predictedLabels = predict(classifier, featuresTest, 'ObservationsIn', 'columns');

%%
% Get the known labels
testLabels = TestSet.Labels;

%%
% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))


%% 
m= confusionchart(YTest,predictedLabels)
%%
accuracy = mean(predictedLabels == YTest)

%% 
