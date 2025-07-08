clc;
close all;
clear all;
F = imread('IM000102.pgm');
%F = rgb2gray(path);


[rows, cols]=size(F);
G=F;
%% Histogram array
myhist=zeros(256,1);
for k=0 : 255
myhist(k+1)=numel(find(F==k)); %number of elements where F has gray level equal to 'k'     
end
%End of Histogram array


%% Calculate cdf
cdf=zeros(256,1);
cdf(1)=myhist(1);
for k=2 : 256
cdf(k)=cdf(k-1)+myhist(k);
end
%End of Calculate cdf

%% Find Equalized histogram array
cumprob=cdf/(rows.*cols);
equalizedhist=floor((cumprob).*255);

for i=1 : cols
        for j=1 : rows
            for m = 0 : 255
                if(F(i,j)==m)
                G(i,j)=equalizedhist(m+1);
                end
            end
        end
end

%% Equalized Histogram array
myeqhist=zeros(256,1);
for k=0 : 255
myeqhist(k+1)=numel(find(G==k));  
end  
%End of Equalized Histogram array

%% plots and figures
figure(1);
subplot(2,1,1);
imshow(F);
title('Original Image');
subplot(2,1,2);
bar(myhist);
title('Histogram of Original Image');

figure(2);
subplot(2,1,1);
imshow(G);
title('Histogram Equalized Image');
subplot(2,1,2);
bar(myeqhist);
title('Equalized Histogram of Image');
%end plots and figures