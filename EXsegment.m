%基于SVM的眼底图像硬性渗出检测
close all; clear; clc;
%dir1=dir('ddb1_fundusimages/*.png');%read all jpg files
%for i=1:size(dir1,1)
%filename=dir1(i).name;
%I=imread(strcat('ddb1_fundusimages/',filename));
filename='image005.png'
I=imread(strcat('ddb1_fundusimages/',filename));
origSize=size(I);
gray=rgb2gray(I); %%converting the fundus image (RGB) to grayscale
imgGray=double(gray);
%figure;imshow(gray,[])
background=imopen(imgGray,strel('disk',13)); %background
%figure;imshow(background,[])
I2=imsubtract(imgGray,background);
%figure;imshow(I2,[])

%thresh
I3=I2;
th=21;
K1=find(I2<th);
I3(K1)=0;
K2=find(I2>th);
I3(K2)=1;
I3=logical(I3);
%figure;imshow(I3)

%Grayscale_brighten = imadjust(gray);
Grayscale_brighten = adapthisteq(gray);
%figure;imshow(Grayscale_brighten)
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
radius = 135; %size of the mask
[x,y]=meshgrid(1:origSize(2),1:origSize(1)); %row size origSize(1), column size origSize(2)
%[X,Y] = meshgrid(x,y)
%rows of o/p X are copies of vector x,
%columns of o/p Y are copies of vector y
mask = sqrt( (x - median_column).^2 + (y - median_row).^2 )<= radius;
%figure;imshow(mask)

%Removing optical disk
I3=I3.*~mask;
figure,imshow(I3)
imwrite(I3,'1.jpg')

%uiwait;
%end;