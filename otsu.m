imggray = imread('1.jpg');
figure; imshow(imggray); title('原始图像');
imgbw = im2bw(imggray,0.5);
figure; imshow(imgbw); title( '使用默认阈值0.5');
imgbw = im2bw(imggray,0.25);
figure; imshow(imgbw); title( '指定阈值为0.25');
level = graythresh(imggray);
imgbw = im2bw(imggray,level);
figure; imshow(imgbw); title('使用最大类间方差法（Otsu）获得阈值');