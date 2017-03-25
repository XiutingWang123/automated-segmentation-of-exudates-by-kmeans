%I2 is rgb image 
imgR=double(I2(:,:,1));
imgG=double(I2(:,:,2));
imgB=double(I2(:,:,3));
%exudates is the region
%exudates = bwareaopen(exudates,10);
L = bwlabeln(exudates);
%area of exudates
S = regionprops(L, 'Area');
%mean of exudates
Sp = regionprops(L, 'PixelList');
for i=1:length(Sp)
    Pxy=Sp(i).PixelList;
    sizeP=size(Pxy);
    sumRm=0;
    sumGm=0;
    sumBm=0;
    for j=1:sizeP(1)
        sumRm=sumRm+imgR(Pxy(j,1),Pxy(j,2));
        sumGm=sumGm+imgG(Pxy(j,1),Pxy(j,2));
        sumBm=sumBm+imgB(Pxy(j,1),Pxy(j,2));
    end;
    imgRmean(i)=sumRm/S(i).Area;%mean
    imgGmean(i)=sumGm/S(i).Area;
    imgBmean(i)=sumBm/S(i).Area;
    %std of exudates
    sumRs=0;
    sumGs=0;
    sumBs=0;
    for j=1:sizeP(1)
       sumRs=sumRs+(imgR(Pxy(j,1),Pxy(j,2))-imgRmean(i))^2;
       sumGs=sumGs+(imgG(Pxy(j,1),Pxy(j,2))-imgGmean(i))^2;
       sumBs=sumBs+(imgB(Pxy(j,1),Pxy(j,2))-imgBmean(i))^2;
    end;
    imgRstd(i)=sqrt(sumRs)/S(i).Area;%std
    imgGstd(i)=sqrt(sumGs)/S(i).Area;
    imgBstd(i)=sqrt(sumBs)/S(i).Area;
end;
%Centroid
Sc = regionprops(L, 'Centroid');
for i=1:length(Sc)
    Pxy1=round(Sc(i).Centroid);
    imgRc(i)=imgR(Pxy1(1,1),Pxy1(1,2));
    imgGc(i)=imgG(Pxy1(1,1),Pxy1(1,2));
    imgBc(i)=imgB(Pxy1(1,1),Pxy1(1,2));
end;
Sbox = regionprops(L, 'BoundingBox');
%area of neighbourhood
for i=1:length(Sbox)
    Sn(i)=(Sbox(i).BoundingBox(3)+10)*(Sbox(i).BoundingBox(4)+10)-S(i).Area;
end;
%mean of neighbourhood
%calculate the sum of rectangle,then subtract the region 
for i=1:length(Sbox)
    %rectangle('Position',Sbox(i).BoundingBox,'edgecolor','r')
    Pxy2=round(Sbox(i).BoundingBox(1:2))-5;
    width=Sbox(i).BoundingBox(3:4)+10;%5 pixels width
    sumRN=imgR(Pxy2(1):Pxy2(1)+width(1),Pxy2(2):Pxy2(2)+width(2));
    sumRNm=sum(sumRN(:))-imgRmean(i)*S(i).Area;
    imgRNmean(i)=sumRNm/Sn(i);%mean
    sumGN=imgG(Pxy2(1):Pxy2(1)+width(1),Pxy2(2):Pxy2(2)+width(2));
    sumGNm=sum(sumGN(:))-imgGmean(i)*S(i).Area;
    imgGNmean(i)=sumGNm/Sn(i);%mean
    sumBN=imgB(Pxy2(1):Pxy2(1)+width(1),Pxy2(2):Pxy2(2)+width(2));
    sumBNm=sum(sumBN(:))-imgBmean(i)*S(i).Area;
    imgBNmean(i)=sumBNm/Sn(i);%mean
    %std of neighbourhood
    %std of rectangle
    sumRNs1=(sumRN-imgRNmean(i)).^2;
    sumGNs1=(sumGN-imgGNmean(i)).^2;
    sumBNs1=(sumBN-imgBNmean(i)).^2;
    %std of region
    Pxy=Sp(i).PixelList;
    sizeP=size(Pxy);
    sumRNs2=0;
    sumGNs2=0;
    sumBNs2=0;
    for j=1:sizeP(1)
        sumRNs2=sumRNs2+(imgR(Pxy(j,1),Pxy(j,2))-imgRNmean(i))^2;
        sumGNs2=sumGNs2+(imgG(Pxy(j,1),Pxy(j,2))-imgGNmean(i))^2;
        sumBNs2=sumBNs2+(imgB(Pxy(j,1),Pxy(j,2))-imgBNmean(i))^2;
    end;
    imgRNstd(i)=sqrt(sum(sumRNs1(:))-sumRNs2)/Sn(i);%std
    imgGNstd(i)=sqrt(sum(sumGNs1(:))-sumGNs2)/Sn(i);
    imgBNstd(i)=sqrt(sum(sumBNs1(:))-sumBNs2)/Sn(i);
end
%Ratio of the mean RGB values
CR=imgRmean./imgRNmean;
CG=imgGmean./imgGNmean;
CB=imgBmean./imgBNmean;
%Region edge strength(Prewitt operator)
bound=bwboundaries(exudates,'noholes');
Spm = regionprops(L, 'Perimeter');
imgGp=edge(imgG,'prewitt');
for i=1:length(bound)
    sizeb=size(bound{i});
    sumGp=0;
    for j=1:sizeb(1)
        sumGp=sumGp+imgGp(bound{i}(j,2),bound{i}(j,1));%bound{i}(j,2)->x,bound{i}(j,1)->y
    end;
    ES(i)=sumGp/Spm(i).Perimeter;
end;
%Homogeneity of the region
for i=1:length(Sp)
    grayL=256;              %gray levels
    hR=0;
    nR=zeros(grayL,1);
    hG=0;
    nG=zeros(grayL,1);
    hB=0;
    nB=zeros(grayL,1);
    Pxy=Sp(i).PixelList;
    sizeP=size(Pxy);
    for j=1:sizeP(1)
        ImgR_level=imgR(Pxy(j,1),Pxy(j,2))+1;%get gray levels           
        nR(ImgR_level)=nR(ImgR_level)+1;     %the number of pixels with intensity equal to Img_level
        ImgG_level=imgG(Pxy(j,1),Pxy(j,2))+1;
        nG(ImgG_level)=nG(ImgG_level)+1; 
        ImgB_level=imgB(Pxy(j,1),Pxy(j,2))+1;
        nB(ImgB_level)=nB(ImgB_level)+1; 
    end;
    for k=1:grayL
        Psr(k)=nR(k)/S(i).Area;                 
        if Psr(k)~=0;                           %delete pixels of probability 0
            hR=-Psr(k)*log2(Psr(k))+hR;   %calculate entropy
        end;
        Psg(k)=nG(k)/S(i).Area;
        if Psg(k)~=0;
            hG=-Psg(k)*log2(Psg(k))+hG;       
        end;
        Psb(k)=nB(k)/S(i).Area;                 
        if Psb(k)~=0;
            hB=-Psb(k)*log2(Psb(k))+hB;
        end;
    end;
    hRm(i)=hR;
    hGm(i)=hG;
    hBm(i)=hB;
end;