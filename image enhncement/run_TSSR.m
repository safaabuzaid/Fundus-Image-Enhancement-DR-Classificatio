%% Title: Tuned Single-Scale Retinex Algorithm

%% Created by Zohair Al-Ameen.
% Department of Computer Science, 
% College of Computer Science and Mathematics,
% University of Mosul, 
% Mosul, Nineveh, Iraq

%% Please report bugs and/or send comments to Zohair Al-Ameen.
% Email: qizohair@uomosul.edu.iq

%% When you use this code or any part of it, please cite the following article:  
% Zohair Al-Ameen and Ghazali Sulong. 
% "Ameliorating the Dynamic Range of Magnetic Resonance Images Using a Tuned Single-Scale Retinex Algorithm." 
% International Journal of Signal Processing, Image Processing and Pattern Recognition, vol. 9, no. 7, (2016): pp. 285-292. DOI: 10.14257/ijsip.2016.9.7.25
%% INPUTS
% x --> is a given poor-contrast image
% Lambda -- > controls the amount of enhancement

%% OUTPUT
% TSSR --> contrast-enhanced image.


%% Starting implementation %%
clear all; clc; close all;

x=(imread('F:\diabetic-retinopathy-detection\train.zip\Clean Data\TrainingSet\Hemorrhage\125_left.jpeg'));
% x= rgb2gray(x);
figure; imshow(x); title('Original')
%%
I = imgaussfilt(out,4);
figure; imshow(I)

%%
Lambda = 1.5;

red = x(:,:,1);
Green = x(:,:,2);
blue = x(:,:,3);

tic; TSSR1 = TSSR(red, Lambda); toc;
tic; TSSR2 = TSSR(Green, Lambda); toc;
tic; TSSR3 = TSSR(blue, Lambda); toc;

TSSR = cat(3,TSSR1,TSSR2,TSSR3);
out = locallapfilt(TSSR, 0.4, 0.5);

figure; imshow(TSSR); title('Recovered by TSSR')
figure; imshow(out);
% imwrite(TSSR,'1_TSSR_2.25.jpg')