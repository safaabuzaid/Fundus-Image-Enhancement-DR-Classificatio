clc 
clear all 
close all

%gf=rgb2gray(imread('sagital.jpg')); 
S= imread('F:\diabetic-retinopathy-detection\train.zip\Clean Data\TrainingSet\Hemorrhage\125_left.jpeg');


  gf = S(:,:,2);




figure,imhist(gf) 
title('original histogram'); 
 
 
%???????????? 
[s,t]=size(gf); 
 
%??????????N??ÿ?????????????? 
N=s*t; 
h=imhist(gf); 
 
 
%??????????Xt 
SMBE=zeros(1,256); 
ASMBE=zeros(1,256); 
 
 
gmean=mean(gf(:)); 
 
SMBE(1)=(N-h(1))*256-gmean*2*N; 
ASMBE(1)=abs(SMBE(1)); 
r=ASMBE(1); 
 
 
 
 
for k=1:255 
     
    SMBE(k+1)=SMBE(k)+(N-h(k+1)*256); 
    
    ASMBE(k+1)=abs(SMBE(k+1)); 
     
     
    if  ASMBE(k+1)<r 
        r=ASMBE(k+1); 
        m=k+1; 
    else 
        continue; 
    end 
     
end 
 
AMBE=min(ASMBE(:))/(2*N) 
Xt=m-1 
 
 
g=histeq(gf,256); 
AMBE_HE=abs(mean(g(:))-gmean) 
AMBE_BBHE=ASMBE(135)/(2*N) 
AMBE_DSIHE=ASMBE(141)/(2*N) 
 
 
 
%????nl,nu 
nl=sum(h(1:Xt+1)); 
nu=sum(h(Xt+2:256)); 
 
% ????MMBEBHE??????????????Y(i,j) 
for i=1:s 
    for j=1:t 
        x=gf(i,j); 
        if x<=Xt 
            cl=sum(h(1:x+1))/nl; 
            y(i,j)=0+(Xt-0)*cl; 
        else 
            cu=sum(h(Xt+2:x+1))/nu; 
            y(i,j)=(Xt+1)+(255-(Xt+1))*cu; 
        end   
    end 
end 
 
 %%
 red = S(:,:,1);
 blue = S(:,:,3);
%  LAB(:,:,1) = y*100;
%     newimage = lab2rgb(LAB);
%  y = uint8(255 * y);
% y=mat2gray(y); 
%???MMBEBHE????????????????

newimage = cat(3,red,y,blue);
figure,imshow(newimage) 
title('MMBEBHE enhanced'); 
figure,imhist(newimage) 
title('MMBEBHE histogram'); 
