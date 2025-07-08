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
% Load pretrained network
net = nasnetlarge ();

%%
analyzeNetwork(net) 

%%
lgraph = layerGraph(net);

%%
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph)

%%
net.Layers(1)

%%
inputSize = net.Layers(1).InputSize;

%% Replace final layers
lgraph = removeLayers(lgraph, {'predictions','predictions_softmax','ClassificationLayer_predictions'});

numClasses = numel(categories(TrainingSet.Labels));
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);

%%
lgraph = connectLayers(lgraph,'global_average_pooling2d_2','fc');

figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
plot(lgraph)
ylim([0,10])

%%
layers = lgraph.Layers;
connections = lgraph.Connections;

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
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),TrainingSet, ...
    'DataAugmentation',imageAugmenter);

%%
augimdsValidation = augmentedImageDatastore(inputSize(1:2),TestSet);

%%
options = trainingOptions('sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',6, ...
    'InitialLearnRate',1e-4, ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',3, ...
    'ValidationPatience',Inf, ...
    'Verbose',false ,...
    'Plots','training-progress');

%%
net = trainNetwork(augimdsTrain,lgraph,options);

%%
