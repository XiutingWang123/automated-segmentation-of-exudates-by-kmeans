H=imread('3.jpg'); 
b1=rgb2gray(H); 
figure;imshow(b1);
h=fspecial('gaussia',5,0.8);
b=imfilter(b1,h); 
bw1=edge(b,'sobel');
bw2=edge(b,'prewitt');
bw3=edge(b,'roberts');
bw4=edge(b,'log');
bw5=edge(b,'canny');
figure;imshow(bw1);
figure;imshow(bw2);
figure;imshow(bw3);
figure;imshow(bw4);
figure;imshow(bw5);