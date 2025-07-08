%% Testing Part 

clc;
 close all;
 clear all
 warning off
 load convnet;

 %read image
filename = ['C:\Users\GL62 6QF\Desktop\New folder\CNN brain tumour classification\validation data\glioma_tumor\image(1).jpg']
im = imread(filename);
label=classify(convnet,im);
disp(label);

