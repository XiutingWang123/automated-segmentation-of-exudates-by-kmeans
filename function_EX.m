%function [area_exudates exudates] = function_EX (I)
%Exudates
%====================================
close all; clear; clc;
%dir1=dir('ddb1_fundusimages/*.png');%read all jpg files
%for i=1:size(dir1,1)
%filename=dir1(i).name
%I=imread(strcat('ddb1_fundusimages/',filename));
I=imread('ddb1_fundusimages/image005.png');
origSize = size(I);
I2=imresize(I, [576 720]); %resize image to stdize
%figure, imshow(I2), title('Fig. 1:Resized Image to 576X720');
Grayscale = rgb2gray (I2);%converting the fundus image (RGB) to grayscale
Grayscale_brighten = imadjust(Grayscale);
%figure, %subplot(1,2,1), imshow(Grayscale), title('Fig. 2:Grayscale Image');
% %subplot(1,2,2), imshow(Grayscale_brighten), title('Fig. 2A:Brighten Grayscale Image');
%====================================
%remove date (upper left corner)
for x=1:30 for y=1:60
Grayscale_brighten(x,y)=0; %255=white, 0=black
end
end
%figure, imshow(Grayscale_brighten), impixelinfo, title('Fig. 3:With Date Patched');
%====================================
%Rectangle border ==========================
for x=1:5 for y=1:720 %for top bar
box_5pix(x,y)=1; %1->white
end
end
for x=572:576 for y=1:720 %for bottom bar
box_5pix(x,y)=1; %1->white
end
end
for x=1:576 for y=1:5 %for left bar
box_5pix(x,y)=1; %1->white
end
end
for x=1:576 for y=715:720 %for right bar
box_5pix(x,y)=1; %1->white
end
end
box_5pixel = logical(box_5pix);
%=========================================
%Circular border =========================================
outline_border=edge(Grayscale_brighten, 'canny', 0.09);
%figure, subplot(1,2,1), imshow(outline_border), title('Fig. 4:Edges of the image');
%2 lines to enclose circular region, image size is 576 X 720
for x=2:5 for y=100:620 %for top bar 4x520
outline_border(x,y)=1; %1->white
end
end
for x=572:575 for y=100:620 %for bottom bar 4x520
outline_border(x,y)=1; %1->white
end
end
% subplot(1,2,2), imshow(outline_border), title('Fig. 4A:Image with 2bars');
Grayscale_imfill = imfill(outline_border, 'holes');
%figure, subplot(2,2,1),imshow(Grayscale_imfill), title('Fig. 5:Imfill on the image');
se = strel('disk',6);
%cant use imopen in this case to replace imerode & then imdilate
Grayscale_imerode = imerode(Grayscale_imfill, se); %reduce size
Grayscale_imdilate= imdilate(Grayscale_imfill, se); %increase size
% subplot(2,2,2),imshow(Grayscale_imerode), title('Fig. 5A:Imerode');
% subplot(2,2,3),imshow(Grayscale_imdilate), title('Fig. 5B:Imdilate');
%Finding the circular border of the image
Grayscale_C_border = Grayscale_imdilate - Grayscale_imerode;
Grayscale_C_border_L = logical(Grayscale_C_border); %Convert numeric values to logical
% subplot(2,2,4),imshow(Grayscale_C_border_L), title('Fig. 5C:Circular border');
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
%close figure 5
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
% figure, subplot(2,3,1), imshow(Grayscale_brighten), title('Fig. 5:Brighten Image');
% subplot(2,3,2), imshow(G_invert_G_B), title('Fig. 5A:Inverted Image');
% subplot(2,3,3), imshow(black_filled), title('Fig. 5B:Filled B&W image');
% subplot(2,3,4), imshow(black_imerode), title('Fig. 5C:Imerode');
% subplot(2,3,5), imshow(black_imdilate), title('Fig. 5D:Imdilate');
% subplot(2,3,6), imshow(Grayscale_C_border_L), title('Fig. 5E:New C Border');
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
%figure, imshow(Grayscale_C_border_L),title('Fig. 6:Circular Border');
%Removing the blood vessels =========================================
%morphological gradient (blurry image depending on value)
%SE = strel('ball',R,H,N) %nonflat, radius, height, N line-shaped element,default8
%imdilate - increase the size of exudates
%imerode - remove others
%=========================================
se2 = strel('ball',10,10); %values use ard 8-12
G_imclose = imclose(Grayscale_brighten, se2); %imdilate(expand exudates) then imerode
%figure,imshow(G_imclose), title('Fig. 7:Imclosed, blood vessels removed');
%Detecting the Exudates =======================================
%==============================================================
%Use of Column filter =========================================
filter_db_G_imclose = double(G_imclose); %need type double for colfilt
filter_colfilt = colfilt(filter_db_G_imclose,[6 6],'sliding',@var); %6-8
filter_uint8_colfilt = uint8(filter_colfilt); %convert back to uint8 0-255
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%colfilt processes distinct or sliding blocks as columns.
%colfilt can perform operations similar to blkproc and nlfilter,
%but often executes much faster.
%B = colfilt(A,[m n],block_type,fun) processes image A by rearranging each
%m-by-n block of A into a column of a temp. matrix, then applying the
%function fun to this matrix. fun must be a function handle.
%colfilt zero-pads A, if necessary.
%colfilt use im2col to create temp. matrix before using fun
%colfilt use col2im to rearrange back into m-by-n blocks after using fun
%V = var(X) returns the variance of X for vectors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure, subplot(2,2,1), imshow(G_imclose), title('Fig. 7:Imclosed, blood vessels removed');
% subplot(2,2,2), imshow(filter_db_G_imclose), title('Fig. 8:Image type Double');
% subplot(2,2,3), imshow(filter_colfilt), title('Fig. 8A:Image with Colfilt');
% subplot(2,2,4), imshow(filter_uint8_colfilt), title('Fig. 8B:Image type uint8');
%figure, imshow(filter_uint8_colfilt), title('Fig. 9:Image type uint8');
%Image Segmentation =========================================
%============================================================
filter_image_seg = im2bw(filter_uint8_colfilt, 0.45); %0.35 to 0.7
%figure, imshow(filter_image_seg), title('Fig. 10:Image after image seg, using 0.45');
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
[x,y]=meshgrid(1:720, 1:576); %row size 576, column size 720 (576x720)
%[X,Y] = meshgrid(x,y)
%rows of o/p X are copies of vector x,
%columns of o/p Y are copies of vector y
mask = sqrt( (x - median_column).^2 + (y - median_row).^2 )<= radius;
%eqn for circle is --> R^2 = (X-h)^2 + (Y-k)^2
%where h and k is the offset, R is the radius of the circle and .^2 for array power
%figure, imshow(mask), title('Fig. 11:Mask for optical disk, Radius =90');
%Removing optical disk portion =========================================
image_optical_removed = filter_image_seg - mask;
%figure, imshow(image_optical_removed), title('Fig. 12:Image with optical disk removed');
% figure, subplot(2,2,1), imshow(Grayscale_brighten), title('Fig. 13:Grayscale image');
% subplot(2,2,2), imshow(filter_image_seg), title('Fig. 13A:After image seg');
% subplot(2,2,3), imshow(mask), title('Fig. 13B:Mask for optical disk, Radius =90');
% subplot(2,2,4), imshow(image_optical_removed), title('Fig. 13C:Image with optical disk removed');
%Removing Circular and Rectangle border =========================================
image_od_Cborder_removed = image_optical_removed - Grayscale_C_border_L;
image_ex = image_od_Cborder_removed - box_5pixel;
%figure, imshow(image_ex), title('Fig. 14:Region with exudates');
%Expansing the region =========================================
image_ex_imclose = imclose (image_ex, se); %imdilate then imerode to increase the area
%Non-exudates region =========================================
Gadpt_his = adapthisteq(Grayscale_brighten); %enhances the contrast
dark_region = im2bw(Gadpt_his,0.85);
dark_features = ~dark_region; %inv, logical so can use ~ instead of 1-IM or imcomplement(IM)
%exudates area =========================================
exudates = image_ex_imclose;
exudates (image_ex_imclose & dark_features) = 0; %AND to get exudates regions, white white -> black0
% figure, subplot(2,2,1), imshow(image_ex), title('Fig. 15:Region with exudates');
% subplot(2,2,2), imshow(image_ex_imclose), title('Fig. 15A:Expanded Region');
% subplot(2,2,3), imshow(dark_features), title('Fig. 15B:Dark Features');
% subplot(2,2,4), imshow(exudates), title('Fig. 15C:Exudates after AND function');
%figure, imshow(dark_features), title('Fig. 16:Dark Features');
%exudates= imresize(exudates,origSize(1:2),'nearest' );
figure, imshow(exudates), title('Fig. 17:Exudates');
%area caluation =========================================
area_exudates = 0;
for x = 1:576 for y = 1:720
if exudates(x,y) == 1
area_exudates = area_exudates+1;
end
end
end

%uiwait;
%end;
%area_exudates
%======================================================================