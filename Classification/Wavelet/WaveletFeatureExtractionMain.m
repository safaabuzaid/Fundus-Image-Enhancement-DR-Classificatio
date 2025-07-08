clc; 
clear all;

%%
imds = imageDatastore('DR','IncludeSubfolders',true,'LabelSource','foldernames');
[trainingSet,testSet] = splitEachLabel(imds,0.8,'randomized'); 

%% 
%Wavelet Image Scattering Feature Extraction

sf = waveletScattering2('ImageSize',[28 28],'InvarianceScale',28, ...
    'NumRotations',[8 8]);

%%
if isempty(gcp)
    parpool;
end

%% Split Data

rng(10);
Imds = shuffle(imds);
[trainImds,testImds] = splitEachLabel(imds,0.8);
Ttrain = tall(trainImds);
Ttest = tall(testImds);
trainfeatures = cellfun(@(x)helperScatImages(sf,x),Ttrain,'UniformOutput',false);
testfeatures = cellfun(@(x)helperScatImages(sf,x),Ttest,'UniformOutput',false);

%%
Trainf = gather(trainfeatures);

%%
trainfeatures = cat(2,Trainf{:});
Testf = gather(testfeatures);

%%
