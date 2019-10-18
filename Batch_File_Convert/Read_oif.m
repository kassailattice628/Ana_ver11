function F = Read_oif(im_path, num_ch)

im = bfopen(im_path);
%image data including in the firt cell{1}.
img = im{1};

%if the image contains sevral clolor channel;
%1st ch => img{oddnum, 1}
%2nd ch => img{evennum, 1}

img1 = img{1};

a = size(img1,1); %imgsizeX
b = size(img1,2); %imgsizeY
c = size(img,1)/num_ch; %size of the frame for 1 channel

F = zeros(a,b,c);

tic
for i = 1:c
    switch num_ch
        case 1
            F(:,:,i) = img{i, 1};
        case 2
            F(:,:,i) = img{2*i-1,1};
    end
end
toc
end
