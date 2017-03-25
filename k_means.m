close all; clear; clc;
filename='image019.png'
he=imread(strcat('ddb1_fundusimages/',filename));
hsi_he = rgb2hsi(he);
hsi_I = hsi_he(:,:,3);
hsi_I_med = medfilt2(hsi_I);
hsi_I_his = adapthisteq(hsi_I_med);
hsi_c = cat(3,hsi_he(:,:,1),hsi_he(:,:,2),hsi_I_his);
rgb_he = hsi2rgb(hsi_c);
figure,imshow(rgb_he)

cform = makecform('srgb2lab'); % 色彩空间转换
lab_he = applycform(rgb_he,cform);
ab = double(lab_he(:,:,2:3)); % 数据类型转换

origSize = size(ab);
newSize = [400 round(400*(origSize(2)/origSize(1)))];
ab = imresize(ab,newSize);
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2); % 矩阵形状变换

nColors = 6;
% 重复聚类3次，以避免局部最小值
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','start','uniform','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols); % 矩阵形状改变
%figure,imshow(pixel_labels,[]);title('image labeled by cluster index');

segmented_images = cell(1,nColors);
for k = 1:nColors
color = pixel_labels;
color(pixel_labels ~= k) = 0;
segmented_images{k} = color;
end

gray=rgb2gray(rgb_he);
Grayscale_brighten = adapthisteq(gray);
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
%figure, imshow(mask)

for k = 1:nColors
    segmented_images{k}= imresize(segmented_images{k},origSize(1:2),'nearest' );
    f_images{k}=logical(segmented_images{k}.*~mask);
    %f_images{k}=logical(segmented_images{k});
    %figure,imshow(f_images{k})
    area{k}=sum(f_images{k}(:));
end
minarea=min([area{:}]);
for k = 1:nColors
    if(area{k}==minarea)
        break;
    end
end
I3=f_images{k};
figure,imshow(I3)