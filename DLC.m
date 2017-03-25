%directional local contrast
close all; clear; clc;
dir1=dir('fundusimages/*.png');%read all jpg files
for i=1:size(dir1,1)
filename=dir1(i).name
%rgbImgOrig=imread(strcat('DMED/',filename));
rgbImgOrig=imread(strcat('fundusimages/',filename));
%rgbImgOrig=imread('ddb1_fundusimages/image005.png');
%rgbImgOrig=imread('DMED/(00000162).jpg');
origSize = size(rgbImgOrig);
newSize = [400 round(400*(origSize(2)/origSize(1)))];
imgRGB = imresize(rgbImgOrig,newSize);  
imgG = imgRGB(:,:,2);
imgG8=double(imgG);
r=50;
n=24;
I3=zeros(newSize);
for x=170:300 for y=190:370
flag0=1;
for sita=1:n
    for k=1:r
        x1(k)=ceil(x+k*cos(2*sita*pi/n));
        y1(k)=ceil(y+k*sin(2*sita*pi/n));
        I(k)=imgG8(x1(k),y1(k));
    end;
    Np(sita)=sum(I)/r;
    if imgG8(x,y) >= Np(sita) flag0=0;break;end;
end;
if flag0==1
    I3(x,y)=1;
end;
end;end;
figure;imshow(I3)
L = bwlabeln(I3);
S = regionprops(L,'Area');
sarea=[S.Area];
I4 = bwareaopen(I3,max(sarea));
figure;imshow(I4)


end;