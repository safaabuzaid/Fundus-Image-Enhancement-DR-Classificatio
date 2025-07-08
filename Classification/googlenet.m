clc; 
clear all;

%%
TrainingSet = imageDatastore('TrainingSet','IncludeSubfolders',true,'LabelSource','foldernames');
TestSet = imageDatastore('TestSet','IncludeSubfolders',true,'LabelSource','foldernames');

% [trainingSet,testSet] = splitEachLabel(imds,0.8,'randomized'); 

%%
countEachLabel(TrainingSet)
countEachLabel(TestSet)

%%
net = googlenet;

%%
lgraph = layerGraph(net);
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph)

%%
net.Layers(1)

%%
inputSize = net.Layers(1).InputSize;

%%
lgraph = removeLayers(lgraph, {'loss3-classifier','prob','output'});

numClasses = numel(categories(TrainingSet.Labels));
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);

%%
lgraph = connectLayers(lgraph,'pool5-drop_7x7_s1','fc');

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

%%
[YPred,probs] = classify(net,augimdsValidation);
accuracy = mean(YPred == TestSet.Labels)