%I3=f_images{2};
I=imread(strcat('hardexudates/',filename));
mask=logical(zeros(size(I)));%groundtruth
pix1=I==max(I(:));
mask(pix1)=1;
figure,imshow(mask),title('groundtruth')

%SE=strel('disk',40);
%I3=imdilate(I3,SE);
%figure,imshow(I3)

sumI3=sum(I3(:));

mask1=mask & I3;
figure,imshow(mask1),title('TP')

%#####################################
imsub=imsubtract(mask,mask1);
pix2=imsub==1;
[pixlabel num] = bwlabeln(mask);
sum1 = cell(1,num);
for k=1:num
    pix3=pixlabel==k;
    imsub(pix2 & pix3)=k;
    sum1{k}=sum(pix3(:));
end

piximage=logical(zeros(size(I)));
for k=1:num
    pix4=imsub==k;
    if(sum(pix4(:))==sum1{k})
        piximage=piximage+pix4;
    end
end
figure,imshow(piximage),title('FN')
%####################################    
TP=sum(mask1(:));
FP=sumI3-TP;
mask2=~I3 & ~mask;
TN=sum(mask2(:));

%FN=sum(mask(:))-TP;
FN=sum(piximage(:));

SE=TP/(TP+FN);
SP=TN/(TN+FP);
PPV=TP/(TP+FP);
AC=(TP+TN)/(TP+TN+FP+FN);


