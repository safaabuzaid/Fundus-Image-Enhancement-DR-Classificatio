% clc
% close all
% clear all
function HIm = bbcce_function(I)
%directory = 'D:\Hong Seng\My PhD OAI\OAI 10 Patients - 0 month\9003406\20041118\10296205\';
%directory = 'C:\Users\User\Desktop\BBCCE\9007827\20041006\10263603\';

%cd(directory);
%pictures = dir('*.*');
% 
N = 116;
L = 256;
%pic=dicomread(pictures(N).name);
% pic1=imread('fundus.tif');
% pic=rgb2gray(pic1);
% pic = imread ('IM000102.pgm');
pic=I;
file(N).img = pic;
[r,c, ~] = size(pic);
file(N).img(:,r:c) = [];
file(N).img(r:c,:) = [];
%%
a = file(N).img;
a(a>255) = 255;
a = uint8(a);
%directory = 'C:\Users\User\Desktop\BBCCE';
%cd(directory);
xk = uint16(mean(mean(a)));
[sizex, sizey] = size(a);


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
    outputL(i)=uint8(probcL(i)*xk);
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

[~, miniL] = min(sdelL);
[~, maxiL] = max(sdelL);
[~, miniU] = min(sdelU);
[~, maxiU] = max(sdelU);


Lxpts = [0 miniL-1 maxiL-1 xk-1];
Lxpts = unique(Lxpts);
Lypts = zeros(1,length(Lxpts));
for i = 1:length(Lxpts)
    Lypts(i) = output(Lxpts(i)+1);
end
Hxpts = [xk miniU+xk-1 maxiU+xk-1 255];
Hxpts = unique(Hxpts);
Hypts = zeros(1,length(Hxpts));
for i = 1:length(Hxpts)
    Hypts(i) = output(Hxpts(i)+1);
end
[Lx, Ly] = mybezier(Lxpts,Lypts,length(0:xk-1));
[Ux, Uy] = mybezier(Hxpts,Hypts,length(xk:255));

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
dy = uint8(floor(dy));    
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
HIm2=uint8(HIm2);
%
%% uncomment if you want to see the figure
% figure;
% hold on;
% plot(1:256,output,'b');
% plot(1:256,dy,'g');
% plot(1:256,1:256,'r');
% scatter(Lxpts,Lypts,'m');
% scatter(Hxpts,Hypts,'m');
% hold off;

% figure,imshow(a);title('a');
% figure,imshow(HIm);title('HIm');

line=0:255;
line=line';
del=output-line;
% figure,plot(line,del); title('line');
% hold on;
% scatter(Lxpts,[double(Lypts)-double(Lxpts)],'r');
% scatter(Hxpts,[double(Hypts)-double(Hxpts)],'r');
% hold off;
end
