%test bbcce on fundus image
% Read Image
I = imread('F:\ACER\diabetic-retinopathy-detection\train.zip\Clean Data\TrainingSet\Hemorrhage\15114_right.jpeg');
% Resize image for easier computation
C = imresize(I, [584 565]);
%% grayscale during BBCCE
% gray=rgb2gray(B);
B = imdiffusefilt(C);

%%
red = B(:,:,1);
Green = B(:,:,2);
blue = B(:,:,3);
%% Contrast Enhancment of gray image using BBCCE
a = bbcce_function(red);
b = bbcce_function(Green);
c = bbcce_function(blue);

J= cat(3,a,b,c);

%%
D=imsharpen(J,'Radius',5,'Amount',1);
% figure('Name','Contrast Enhancement');imshow(J);

imshowpair(J,D,'montage')