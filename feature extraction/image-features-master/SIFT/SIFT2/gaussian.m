function [ out_img ] = gaussian( input_img, sigma )
% 高斯平滑函数
k = 3;
hsize = round(2*k*sigma+1);
if mod(hsize,2) == 0
    hsize = hsize+1;
end
g = fspecial('gaussian',hsize,sigma);
out_img = conv2(input_img,g,'same');
end
