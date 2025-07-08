% 8 bit PROICE
% clear all; close all; clc

function [ori HIm] = proice_mod8bit(i)
% i= 2;
%loc = 'D:\posgrad\Coding test\Data Collection\sample pic\Knee\'
%image = [loc num2str(i) 'IM000102.pgm'];
% image = '70.tif';
a = imread('IM000102.pgm');
%a(:,:,4) = [];
%a = rgb2gray(a); %for knee only, change four into 3, for knee only
a1 = a;
ori = a;
[sizex sizey] = size(a);

%% Add smoothing filter and noise remover
% a = imgaussfilt(a,0.8);
% a = medfilt2(a,[2 2]);

% patch = imcrop(a,[0 0 50 50]);
% patchVar = std2(patch);
% DoS = 2*patchVar;
% a = imbilatfilt(a,DoS,3);
% figure, imshow(patch),title('patch');

% a= imdiffusefilt(a,'NumberOfIterations',1);
%% GMM
a = uint8(256 * mat2gray(a)); 

% data = double(a(:));
% 
% %Fit a gaussian mixture model
% obj = fitgmdist(data,2);%'SharedCovariance' ,true
% idx = cluster(obj,data);
% cluster1 = data(idx == 1,:);
% cluster2 = data(idx == 2,:);
% 
% % Display Histogram
% %  figure;%histogram(a); hold on;
% %         histogram(cluster1);hold on;
% %         histogram(cluster2)
%         
%         x_values = 0:1:255;
% gcluster1 = fitdist(cluster1,'Normal');
% gcluster2 = fitdist(cluster2,'Normal');
% 
% %plot separate gaussian distribution
% y1 = pdf(gcluster1,x_values);
% y2 = pdf(gcluster2,x_values);
% MAX = max(y1)+ max(y2);
% y1 = y1/MAX *256;
% y2 = y2/MAX *256;
% 
% %obtain the original mean and std
% stdY2 = std(gcluster2);
% meanY2 = mean(gcluster2);
% stdY1 = std(gcluster1);
% meanY1 = mean(gcluster1);
% xk = floor(meanY2);
% xk(meanY1>meanY2) = floor(meanY1); %knee

% figure;
% plot(y1,'b'); hold on;
% plot(y2,'r')

% 
%  %get back the complete gaussian distribution
% plot(x_values,y1+y2,'g');

%use breakpoint as histogram separation point: ROI and background separated
%BRSHE
% yt= y1 + y2;
% xk = floor(find(islocalmin(yt)==1));

% a = uint8(256 * mat2gray(filtered));
%% PROICE

L = 256;
xk = floor(mean(mean(a)));


%===========================lower==========================================
t = cputime;
nOccurL=zeros(L,1);
probcL=zeros(L,1);
cumL=zeros(L,1);
outputL=zeros(L,1);
%=========================process_of_lower_bi-histogram====================
pixel_value=zeros(L,1);
for i=1:sizex
    for j=1:sizey
        if a(i,j)<=xk
            pixel_value=a(i,j);
            nOccurL(pixel_value+1)=nOccurL(pixel_value+1)+1;
        end
    end
end

nL=sum(nOccurL(:));
sum1=0;

for i=1:xk
    sum1=nOccurL(i)+sum1;
    cumL(i)=sum1;
    probcL(i)=(cumL(i)-cumL(1))/(nL-cumL(1));
    outputL(i)=uint16(probcL(i)*xk);
end


%=============================end_of_process_lower_histogram===============
%===========================upper==========================================
nOccurU=zeros(L,1);%
cumU=zeros(L,1);
outputU=zeros(L,1);
probcU = zeros(L-xk-1,1);
%==============================process_of_upper_bi-Histogram===============
for i=1:sizex
    for j=1:sizey
        if a(i,j)>xk  
            pixel_value=a(i,j);
            nOccurU(pixel_value+1)=nOccurU(pixel_value+1)+1;
        end
    end
end

sum1=0;
nU=sum(nOccurU);

 for k=(xk+1):256
    sum1=nOccurU(k)+sum1;
    cumU(k)=sum1;
    probcU(k)=(cumU(k)-cumU(1))/(nU-cumU(1));
    outputU(k)=floor(probcU(k)*(L-1-xk)+xk);
 end

outputL((xk+1):L) = [];
outputU(1:xk) = [];
output = [outputL; outputU];
%===========================end of_process_upper_histogram=================
%============================bezier bi-histogram===================

lineL = double(0:xk-1)';
lineU = double(xk:255)';

sdelL = outputL - lineL;
sdelU = outputU - lineU;

[minvL miniL] = min(sdelL);
[maxvL maxiL] = max(sdelL);
[minvU miniU] = min(sdelU);
[maxvU maxiU] = max(sdelU);


Lxpts = [0 miniL-1 maxiL-1 xk-1];
Lxpts = unique(Lxpts);
Lypts = zeros(1,length(Lxpts));
for i = 1:length(Lxpts);
    Lypts(i) = output(Lxpts(i)+1);
end
Hxpts = [xk miniU+xk-1 maxiU+xk-1 255];
Hxpts = unique(Hxpts);
Hypts = zeros(1,length(Hxpts));
for i = 1:length(Hxpts);
    Hypts(i) = output(Hxpts(i)+1);
end
[Lx Ly] = mybezier(Lxpts,Lypts,length(0:xk-1));
[Ux Uy] = mybezier(Hxpts,Hypts,length(xk:255));

resY = [Ly Uy];
resX = [Lx Ux];

dy = zeros(1,256);
counter = 1;
for x = 1 : 256
    while resX(counter) < x && counter < 256
        counter = counter + 1;
    end
    dy(x) = resY(counter-1)+(resY(counter)-resY(counter-1))*(x-resX(counter-1))/...
        (resX(counter)-resX(counter-1));
end

for x = 1 : 256
    if (dy(x) - floor(dy(x))) > 0.5
        dy(x) = dy(x) + 0.5;
    end
end
dy = uint16(floor(dy));    
HIm = uint8(zeros(sizex,sizey));
HIm2 = HIm;
for i=1:sizex
    for j=1:sizey
      HIm(i,j)=dy(a(i,j)+1);
    end
end
t = cputime - t;
disp(t); 
for i=1:sizex
    for j=1:sizey
      HIm2(i,j)=output(a(i,j)+1);
    end
end
HIm2=uint16(HIm2);

% figure;
% hold on;
% plot(1:256,output,'b');
% % plot(1:256,dy,'g');
% plot(1:256,1:256,'r');
% scatter(Lxpts,Lypts,'m');
% scatter(Hxpts,Hypts,'m');
% hold off;
% figure,imshow(a);
% figure,imshow(HIm);
% 
% line=0:255;
% line=line';
% del=output-line;
% figure,plot(line,del);
% hold on;
% scatter(Lxpts,[double(Lypts)-double(Lxpts)],'r');
% scatter(Hxpts,[double(Hypts)-double(Hxpts)],'r');
% hold off;


% en = im2double(filtered); oriI = im2double(a);
% [ssimval, ssimmap] = ssim(en,oriI);
% PSNR = psnr(en,oriI);
% AMBE = abs(mean(mean(en)) - mean(mean(oriI)))*255;
% 
% disp(PSNR);
% disp(ssimval);
% disp(AMBE);
%display histogram
close all;
end
         