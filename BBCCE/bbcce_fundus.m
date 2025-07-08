%test bbcce on fundus image
% Read Image
I = imread('IMG0001 (4).pgm');
% Resize image for easier computation
B = imresize(I, [584 565]);
%% grayscale during BBCCE
% gray=rgb2gray(B);
%% Contrast Enhancment of gray image using BBCCE
J = bbcce_function(B);
figure('Name','Contrast Enhancement');imshow(J);