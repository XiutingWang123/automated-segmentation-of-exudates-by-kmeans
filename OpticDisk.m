close all; clear; clc;
dir1=dir('ddb1_fundusimages/*.png');%read all jpg files
for i=1:size(dir1,1)
filename=dir1(i).name
rgb_he=imread(strcat('ddb1_fundusimages/',filename));
%filename='image088.png'
%rgb_he=imread(strcat('ddb1_fundusimages/',filename));
origSize=size(rgb_he);
gray=rgb2gray(rgb_he);
Grayscale_brighten = adapthisteq(gray);
figure,imshow(Grayscale_brighten)
%Finding Optical Disk =========================================
max_GB_column=max(Grayscale_brighten); %Get the largest value for each column (1-720) of image
max_GB_single=max(max_GB_column); %Get the largest value of the columns
[row,column] = find(Grayscale_brighten==max_GB_single);
%find returns Row & Column indices of the image that match the largest value
median_row = floor(median(row)); %median(a),find 50th percentile (the middle) then
median_column = floor(median(column)); %use floor(a),round towards minus infinity
%Drawing the mask =========================================
radius = 135; %size of the mask
[x,y]=meshgrid(1:origSize(2),1:origSize(1)); %row size 576, column size 720 (576x720)
mask = sqrt( (x - median_column).^2 + (y - median_row).^2 )<= radius;
figure, imshow(Grayscale_brighten.*uint8(~mask))
pause;
end;