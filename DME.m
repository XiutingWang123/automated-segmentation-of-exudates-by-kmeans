%糖尿病性视网膜病变图像黄斑水肿等级自动分析方法
close all; clear; clc;
filename='image005.png'
rgbImgOrig=imread(strcat('ddb1_fundusimages/',filename));
% resize
origSize = size( rgbImgOrig );
newSize = [750 round(750*(origSize(2)/origSize(1)))];
imgRGB = imresize(rgbImgOrig, newSize);  
imgG = imgRGB(:,:,2);
% change colour plane
imgHSV = rgb2hsv(imgRGB);
imgV = imgHSV(:,:,3);
imgV8 = uint8(imgV.*255);

%Remove OD region
winOnRatio = [1/15,1/15];
onY = 505;
onX = 290;
%get ON window
onY = onY * newSize(1)/origSize(1);
onX = onX * newSize(2)/origSize(2);
onX = round(onX);
onY = round(onY);
winOnSize = round(winOnRatio .* newSize);

%remove ON window from imgTh
winOnCoordY = [onY-winOnSize(1),onY+winOnSize(1)];
winOnCoordX = [onX-winOnSize(2),onX+winOnSize(2)];
if(winOnCoordY(1) < 1), winOnCoordY(1) = 1; end
if(winOnCoordX(1) < 1), winOnCoordX(1) = 1; end
if(winOnCoordY(2) > newSize(1)), winOnCoordY(2) = newSize(1); end
if(winOnCoordX(2) > newSize(2)), winOnCoordX(2) = newSize(2); end

% Create FOV mask
imgFovMask = getFovMask(imgV8,1,1);
imgFovMask(winOnCoordY(1):winOnCoordY(2), winOnCoordX(1):winOnCoordX(2)) = 0;

%fixed threshold using median Background (with reconstruction)
medBg = double(medfilt2(imgV8, [round(newSize(1)/30) round(newSize(1)/30)]  ));
%reconstruct bg
maskImg = double(imgV8);
pxLbl = maskImg < medBg;
maskImg(pxLbl) = medBg(pxLbl);
medRestored = imreconstruct( medBg, maskImg );
%subtract, remove fovMask and threshold
subImg = double(imgV8) - double(medRestored);
subImg = subImg .* double(imgFovMask);
subImg(subImg < 0) = 0;
imgThNoOD = uint8(subImg) > 0;

%--- Calculate edge strength of lesions
imgKirsch = kirschEdges( imgG );
img0 = imgG .* uint8(imgThNoOD == 0);
img0recon = imreconstruct(img0, imgG);
img0Kirsch = kirschEdges(img0recon);
imgEdgeNoMask = imgKirsch - img0Kirsch; % edge strength map

% remove mask and ON (leave vessels)
imgEdge = double(imgFovMask) .* imgEdgeNoMask;
imgEdge=uint8(imgEdge);

I2=imgEdge;
I3=I2;
K1=find(I2<5);
I3(K1)=0;
I3= logical(imresize(I3,origSize(1:2),'nearest'));
imgHEs=imfill(I3,'holes');
figure;imshow(I3)