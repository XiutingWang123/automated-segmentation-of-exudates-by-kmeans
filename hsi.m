close all; clear; clc;
he = imread('ddb1_fundusimages/image005.png');
hsi_he = rgb2hsi(he);
hsi_I = hsi_he(:,:,3);
%figure,imshow(hsi_I)
hsi_I_med = medfilt2(hsi_I,[3 3]);
%figure,imshow(hsi_I_med)
hsi_I_his = adapthisteq(hsi_I_med);
%figure,imshow(hsi_I_his)
hsi_c = cat(3,hsi_he(:,:,1),hsi_he(:,:,2),hsi_I_his);
rgb_he = hsi2rgb(hsi_c);
figure,imshow(rgb_he)