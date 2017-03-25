close all;clear;clc;
he = imread('ddb1_fundusimages/image005.png');
hsi_he = rgb2hsi(he);
hsi_I = hsi_he(:,:,3);
hsi_I_med = medfilt2(hsi_I);
hsi_I_his = adapthisteq(hsi_I_med);
hsi_c = cat(3,hsi_he(:,:,1),hsi_he(:,:,2),hsi_I_his);
rgb_he = hsi2rgb(hsi_c);
figure,imshow(rgb_he)

cform = makecform('srgb2lab'); % 色彩空间转换
lab_he = applycform(rgb_he,cform);
ab = double(lab_he(:,:,1:3)); % 数据类型转换

origSize = size(ab);
newSize = [200 round(200*(origSize(2)/origSize(1)))];
ab = imresize(ab,newSize);
[m,n,k] = size(ab);
data = reshape(ab,m*n,k); % 矩阵形状变换

options = [2 50 1e-5 1];
cluster_n = 10;
%[center, U, obj_fcn] = fcm(data, cluster_n, options);
[center, U, obj_fcn] = KFCM(data, cluster_n, 150, options);
cluster = cell(1,cluster_n);
cluster_pic = cell(1,cluster_n);
pic = cell(1,cluster_n);

for i = 1:cluster_n
    cluster{i} = find(U(i,:)==max(U));
    cluster{i} = cluster{i}';
    cluster_pic{i} = zeros(size(data));
    temp = zeros(size(data));
    temp(cluster{i}) = 1;
    cluster_pic{i} = temp;
    pic{i} = reshape(cluster_pic{i},m,n,k);
    image=pic{i};
    figure,imshow(image)
end