%function [area_micro_a microa_image] = function_MIC (I)
%Microaneurysms
%====================================
close all; clear; clc;
I=imread('ddb1_fundusimages/image001.png');
origSize = size(I);
I2=imresize(I, [576 720]); %resize image to stdize
%figure, imshow(I2), title('Fig. 1:Resized Image to 576X720');
GreenC=I2(:,:,2); %(row, column, 2-->green)
%figure, imshow(GreenC), title('Fig. 2:Green Component Image');
%====================================
Grayscale = rgb2gray (I2);%converting the fundus image (RGB) to grayscale
Grayscale_brighten = imadjust(Grayscale);
%figure, imshow(Grayscale), title('Fig. 3:Grayscale Image');
%====================================
%remove date (upper left corner)
for x=1:30 for y=1:60
Grayscale_brighten(x,y)=0; %255=white, 0=black
GreenC(x,y)=0; %255=white, 0=black
end
end
% figure, subplot(1,2,1), imshow(Grayscale_brighten), title('Fig. 3A:Brighten Grayscale wo Date');
% subplot(1,2,2), imshow(GreenC), title('Fig. 3B:Brighten Green Component wo Date');
%====================================
%====================================
Gadpt_his_X1 = adapthisteq(GreenC); % enhances the contrast of the intensity image by transforming the values
% figure, subplot(4,1,1:3), imshow(Gadpt_his_X1), title('Fig. 4:Image & Histgram after 1st adaptive histeq');
% subplot(4,1,4 ), imhist(Gadpt_his_X1)
Gadpt_his_X2 = adapthisteq(Gadpt_his_X1); % enhances the contrast of the intensity image by transforming the values
% figure, subplot(4,1,1:3), imshow(Gadpt_his_X2), title('Fig. 5:Image & Histgram after 2nd adaptive histeq');
% subplot(4,1,4 ), imhist(Gadpt_his_X2)
%====================================
%=========================================================
%Circular border =========================================
%=========================================================
outline_border=edge(Grayscale_brighten, 'canny', 0.09);
% figure, subplot(1,2,1), imshow(outline_border), title('Fig. 6:Edges of image for Cborder Detection');
%2 lines to enclose circular region, image size is 576 X 720
for x=2:5 for y=100:620 %for top bar 4x520
outline_border(x,y)=1; %1->white
end
end
for x=572:575 for y=100:620 %for bottom bar 4x520
outline_border(x,y)=1; %1->white
end
end
% subplot(1,2,2), imshow(outline_border), title('Fig. 6A:Edges with 2 more bars');
Grayscale_imfill = imfill(outline_border, 'holes');
% figure, subplot(2,2,1),imshow(Grayscale_imfill), title('Fig. 7:Imfill on the image');
se = strel('disk',6);
%cant use imopen in this case to replace imerode & then imdilate
Grayscale_imerode = imerode(Grayscale_imfill, se); %reduce size
Grayscale_imdilate= imdilate(Grayscale_imfill, se); %increase size
% subplot(2,2,2),imshow(Grayscale_imerode), title('Fig. 7A:Imerode');
% subplot(2,2,3),imshow(Grayscale_imdilate), title('Fig. 7B:Imdilate');
%Finding the circular border of the image
Grayscale_C_border = Grayscale_imdilate - Grayscale_imerode;
Grayscale_C_border_L = logical(Grayscale_C_border); %Convert numeric values to logical
% subplot(2,2,4),imshow(Grayscale_C_border_L), title('Fig.7C:Circular border');
%=========================================
%=========================================
%Area Calculation for Grayscale_C_border_L
area_Cborder = 0;
area_new_Cborder = 0;
for x = 1:576 for y = 1:720
if Grayscale_C_border_L(x,y) == 1
area_Cborder = area_Cborder+1;
end
end
end
%area_Cborder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if area_Cborder > 50000; %border detection is wrong
%close figure 6
%close figure 7
clear Grayscale_C_border_L
G_invert_G_B = imcomplement(Grayscale_brighten); %or use 255-Grayscale_brighten_9
black_filled = im2bw(G_invert_G_B, 0.94); %image to B&W using threshold, ideal 9.3-9.5
se = strel('disk',6);
black_imerode = imerode(black_filled, se); %reduce size
black_imdilate= imdilate(black_filled, se); %increase size
%determining the new circular border of the image
black_new_Cborder = black_imdilate - black_imerode;
%New Circular Border is Created
Grayscale_C_border_L = logical(black_new_Cborder);
% figure, subplot(2,3,1), imshow(Grayscale_brighten), title('Fig. 7:Brighten Image');
% subplot(2,3,2), imshow(G_invert_G_B), title('Fig. 7A:Inverted Image');
% subplot(2,3,3), imshow(black_filled), title('Fig. 7B:Filled B&W image');
% subplot(2,3,4), imshow(black_imerode), title('Fig. 7C:Imerode');
% subplot(2,3,5), imshow(black_imdilate), title('Fig. 7D:Imdilate');
% subplot(2,3,6), imshow(Grayscale_C_border_L), title('Fig. 7E:New C Border');
%Area Calculation for new Grayscale_C_border_L
area_new_Cborder = 0;
for x = 1:576 for y = 1:720
if Grayscale_C_border_L(x,y) == 1
area_new_Cborder = area_new_Cborder+1;
end
end
end
%area_new_Cborder
end
%=========================================
%=========================================
% figure, imshow(Grayscale_C_border_L),title('Fig. 8:Circular Border');
%Finding the Microaneurysms =========================================
edge_Gadpt_his_X1 = edge(Gadpt_his_X1, 'canny', 0.18); %find the outline/Edges of the features
edge_lesscborder = edge_Gadpt_his_X1 - Grayscale_C_border_L; %remove Cborder, date also removed
% figure,imshow(edge_lesscborder), title('Fig. 10:Edges without Cborder');
edge_imfill = imfill(edge_lesscborder, 'holes'); %Imfilled on the image without Cborder
image_holes = edge_imfill - edge_Gadpt_his_X1; %getting the area filled with imfill
image_largerarea = bwareaopen(image_holes,70); %Remove all obj smaller than pixels value
image_microa = image_holes - image_largerarea; %area of microaneurysms with noise
% figure, subplot(2,2,1), imshow(edge_lesscborder), title('Fig. 9:Edges w/o Cborder');
% subplot(2,2,2), imshow(edge_imfill), title('Fig. 9A:Imfilled image');
% subplot(2,2,3), imshow(image_holes), title('Fig. 9B:Imfilled area');
% subplot(2,2,4), imshow(image_microa), title('Fig. 9C:Microaneurysms with noise');
%figure, imshow(image_microa), title('Fig. 10:Area of microaneurysms with noise');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gadpt_X2_bright = im2bw(Gadpt_his_X2,0.7); %convert to binary 0 for values lesser than threshold
%figure, imshow(Gadpt_X2_bright), title('Fig. 11:Bright image after im2bw');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%removing exduates area =========================================
microa_less_ex = image_microa; %setting the size
microa_less_ex (image_microa & Gadpt_X2_bright) = 0; %AND to remove exduates, white white -> black 0
%figure, imshow(microa_less_ex), title('Fig. 12:Area of microaneurysms after removing exduates');
%=========================================
Gadpt_X2_bright_2 = ~im2bw(Gadpt_his_X2,0.3);
%figure, imshow(Gadpt_X2_bright_2), title('Fig. 13: Blood vessels and noise after im2bw');
Gadpt_X2_bright_3 = bwareaopen(Gadpt_X2_bright_2,100); %removed the small areas, consider as noise
%figure, imshow(Gadpt_X2_bright_3), title('Fig. 14:Blood vessels / noise without small area');
%removing blood vessels area =========================================
microa_less_blood = microa_less_ex;
microa_less_blood (microa_less_ex & Gadpt_X2_bright_3) = 0; %AND to remove blood vessels & noise, white white->1black->0
%figure, imshow(microa_less_blood), title('Fig. 15:Area of microaneurysms after removing blood vessels & noise');
%Finding Optical Disk =========================================
max_GB_column=max(Grayscale_brighten); %Get the largest value for each column (1-720) of image
%For matrices, max(a) is a row vector containing
%the maximum element from each column.
max_GB_single=max(max_GB_column); %Get the largest value of the columns
[row,column] = find(Grayscale_brighten==max_GB_single);
%find returns Row & Column indices of the image that match the largest value
median_row = floor(median(row)); %median(a),find 50th percentile (the middle) then
median_column = floor(median(column)); %use floor(a),round towards minus infinity
%Drawing the mask =========================================
radius = 90; %size of the mask
[x,y] = meshgrid(1:720, 1:576); %row size 576, column size 720 (576x720)
%[X,Y] = meshgrid(x,y)
%rows of o/p X are copies of vector x,
%columns of o/p Y are copies of vector y
mask = sqrt( (x - median_column).^2 + (y - median_row).^2 )<= radius;
%eqn for circle is --> R^2 = (X-h)^2 + (Y-k)^2
%where h and k is the offset, R is the radius of the circle and .^2 for array power
%figure, imshow(mask), title('Fig. 17:Mask for optical disk, Radius =90');
%Getting area of Microaneurysms =========================================
microa_less_smallarea = bwareaopen (microa_less_blood,5); %remove small area/ residue of reduction
microa_less_cborder = microa_less_smallarea - Grayscale_C_border_L; %Remove cborder
microa_image = microa_less_cborder - mask;
figure, imshow(microa_image), title('Fig. 18:Microaneurysms');
%area calcuation =========================================
area_micro_a = 0;
for x = 1:576 for y = 1:720
if microa_image(x,y) == 1
area_micro_a = area_micro_a+1;
end
end
end
% area_Cborder
% area_new_Cborder
% microa_image
% area_micro_a
%======================================================================