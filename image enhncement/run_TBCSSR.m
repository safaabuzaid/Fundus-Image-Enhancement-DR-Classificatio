%% Title: Tuned Brightness Controlled Single-Scale Retinex

%% Created by Zohair Al-Ameen.
% Department of Computer Science, 
% College of Computer Science and Mathematics,
% University of Mosul, 
% Mosul, Nineveh, Iraq

%% Please report bugs and/or send comments to Zohair Al-Ameen.
% Email: qizohair@uomosul.edu.iq

%% When you use this code or any part of it, please cite the following article:  
% Zohair Al-Ameen and Ghazali Sulong. 
% "A new algorithm for improving the low contrast of computed tomography images using tuned brightness controlled single?scale Retinex". 
% Scanning, vol. 37, no. 2, (2015): pp. 116-125. DOI: 10.1002/sca.21187

%% INPUTS
% x --> is a given low-contrast image
% beta -- > is a tuning constant whose value is larger than zero.

%% OUTPUT
% out --> a contrast-enhanced image.


%% Starting implementation %%
clear all; close all; clc
%  %%
% shadow = imread ('125_left.jpeg');
% shadow_lab = rgb2lab(shadow);
% 
% %%
% max_luminosity = 100;
% L = shadow_lab(:,:,1)/max_luminosity;
% %%
% beta=10;
% shadow_imadjust = shadow_lab;
% shadow_imadjust(:,:,1) = TBCSSR(shadow_imadjust, beta)*max_luminosity;
% shadow_imadjust = lab2rgb(shadow_imadjust);
%%

x=imread('F:\diabetic-retinopathy-detection\train.zip\Clean Data\TrainingSet\Hemorrhage\125_left.jpeg');
% x=rgb2gray(x);
figure; imshow(x)
%%
% LAB = rgb2lab(x);
%     L = LAB(:,:,1)/100;
    red = x(:,:,1);    %%
    Gr = x(:,:,2);

 blue = x(:,:,3);
   beta=10;
%    L=uint8(L *255);
tic; out1 = TBCSSR(red, beta); toc;
tic; out2 = TBCSSR(Gr, beta); toc;
tic; out3 = TBCSSR(blue, beta); toc;
%%
%     L = adapthisteq(L,'NumTiles',[8 8],'ClipLimit',0.005);
newimage = cat(3,out1,out2,out3);

figure; imshow(newimage);title('TBCSSR')
% imwrite(out,'out_TBCSSR_B6.jpg')