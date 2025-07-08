%% Training & testing CNN 

clc
clear all
close all
warning off
allImages=imageDatastore('database','IncludeSubfolders',true, 'LabelSource','foldernames');
imdsValidation = imageDatastore('validation data','IncludeSubfolders',true, 'LabelSource','foldernames');
net = googlenet; % Change net here

%% Identification of final layers to be replaced

if isa(net,'SeriesNetwork') 
  lgraph = layerGraph(net.Layers); 
else
  lgraph = layerGraph(net);
end 
[learnableLayer,classLayer] = findLayersToReplace(lgraph);

%% Replace final layers

lgraph = layerGraph(net);
newFCLayer = fullyConnectedLayer(4,'Name','new_fc','WeightLearnRateFactor',10, 'BiasLearnRateFactor',10);
lgraph = replaceLayer(lgraph,'loss3-classifier',newFCLayer);%resnet-fc1000
newClassLayer = classificationLayer('Name','new_classouput');
lgraph = replaceLayer(lgraph,'output',newClassLayer);%resnet -ClassificationLayer_predictions

%%
options = trainingOptions('sgdm', ...
    'ExecutionEnvironment','auto', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',60, ... %60
    'MiniBatchSize',20, ... %50
    'GradientThreshold',1, ...
    'Verbose',true, ...
    'Plots','training-progress');
convnet=trainNetwork(allImages,lgraph,options);
save convnet;

%% Classify Validation Images
[YPred,probs] = classify(convnet,imdsValidation);
accuracy = mean(YPred == imdsValidation.Labels);
disp(accuracy);