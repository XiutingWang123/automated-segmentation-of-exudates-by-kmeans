imggray = imread('1.jpg');
figure; imshow(imggray); title('ԭʼͼ��');
imgbw = im2bw(imggray,0.5);
figure; imshow(imgbw); title( 'ʹ��Ĭ����ֵ0.5');
imgbw = im2bw(imggray,0.25);
figure; imshow(imgbw); title( 'ָ����ֵΪ0.25');
level = graythresh(imggray);
imgbw = im2bw(imggray,level);
figure; imshow(imgbw); title('ʹ�������䷽���Otsu�������ֵ');