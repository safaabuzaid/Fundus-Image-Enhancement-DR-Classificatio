clear all; close all; 
clc; 
 
PicOri=imread('IMG0026 (8).pgm'); 


if isgray(PicOri)==0		
	PicGray=rgb2gray(PicOri); 
else 
 	PicGray=PicOri; 
end 
figure(1),imshow(PicGray),title('ori Image'); 
 
h=imhist(PicGray); 
figure(2),plot(h),title('Ori hist'); 
 
[m,n]=size(PicGray); 
 
halfarea=floor(m*n/2); 
 
SUM(1)=h(1); 
for i=2:256 
	SUM(i)=h(i)+SUM(i-1); 
end 
 
index=find(SUM>=halfarea); 
Xm=index(1); 
 
max=double(max(PicGray(:)));		
min=double(min(PicGray(:)));		
 
[rowl,coll]=find(PicGray<=Xm); 
pixl=size(coll,1); 
 
PZL=zeros(1,Xm+1); 
for i=1:Xm+1 
	PZL(i)=h(i)/pixl;				
end 
 
SL=zeros(1,Xm+1); 
SL(1)=PZL(1); 
for i=2:Xm+1 
	SL(i)=PZL(i)+SL(i-1);		
end 
 
FuncHEL=min+(Xm-min)*SL;			 
 
PicHE1=zeros(m,n); 
 
for k=1:pixl 
	PicHE1(rowl(k),coll(k))=floor(FuncHEL(PicGray(rowl(k),coll(k))+1)); 
end 
 
[rowu,colu]=find(PicGray>Xm); 
pixu=size(colu,1); 
 
PZU=zeros(1,max-Xm-1); 
for i=Xm+2:max 
	PZU(i-Xm-1)=h(i)/pixu;				
end 
 
%SU=zeros(1,max-Xm-1); 
SU=zeros(1,max); 
SU(Xm+2)=PZU(1); 
for i=Xm+3:max 
	SU(i)=PZU(i-Xm-1)+SU(i-1);		
end 
 
FuncHEU=Xm+(max-Xm)*SU;			
 
for k=1:pixu 
	PicHE1(rowu(k),colu(k))=floor(FuncHEU(PicGray(rowu(k),colu(k)))); 
end 

 
PicHE=uint8(PicHE1); 
h1=imhist(PicHE); 

figure(3),plot(h1),title('Enhanced Hist'); 
figure(4),imshow(PicHE),title('Enhanced Image'); 
 
PSNR = psnr(PicHE,PicOri);
[ssimval m] = ssim(PicHE,PicOri)