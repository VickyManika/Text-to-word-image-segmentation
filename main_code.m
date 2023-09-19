clc;
clear;
close all;
more off;

% ------------------------------------------------------
% PART A MAIN 
% ------------------------------------------------------

% --- INIT
if exist('OCTAVE_VERSION', 'builtin')>0
    % If in OCTAVE load the image package
    warning off;
    pkg load image;
    warning on;
end

% ------------------------------------------------------
% LOAD AND SHOW THE IMAGE + CONVERT TO BLACK-AND-WHITE
% ------------------------------------------------------

% --- Step A1
% Read the original RGB image 
Filename='Troizina 1827.jpg';
I=imread(Filename);

% show it (Eikona 1)
figure;
image(I);
axis image off;
colormap(gray(256));

% --- Step A2
% Convert the image to grayscale
A=any_image_to_grayscale_func('Troizina 1827.jpg');

% Apply gamma correction (a value of 1.0 doesn't change the image)
GammaValue=1.0; % {0.6,0.8,1.0,1.2,1.4}
A=imadjust(A,[],[],GammaValue); 

% Show the grayscale image (Eikona 2)
figure;
image(A);
colormap(gray(256));
axis image off;
title('Grayscale image');

% --- Step A3
% Convert the grayscale image to black-and-white using Otsu's method
Threshold= graythresh(A); 
BW = ~im2bw(A,Threshold);

% Show the black-and-white image (Eikona 3)
figure;
image(~BW);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('Binary image');

% ------------------------------------------------------
% CLEAN THE IMAGE
% ------------------------------------------------------
% --- Step A4

% Morphological operations to reduse the noise from image
% First: Dilation with SE = rectangle (25x3)
SE_0=strel("rectangle",[25 3]);
BW0=imdilate(BW,SE_0);
%Show the dilated image (Eikona 4)
figure;
image(~BW0);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('BW0')

%Second: Clean the borders of the dilated image
BW0_CB=imclearborder(BW0,4);

%Show the clear border image (Eikona 5)
figure;
image(~BW0_CB);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('CLEAR BORDERS | BW0')

%Third: Use of logical operation "AND" between the original binary image and the generated image  
BW_NEW=and(BW,BW0_CB);

%Show the new BW image (Eikona 6)
figure;
image(~BW_NEW);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('B&W "AND" ')

% The connected components of the new BW image
CC = bwconncomp(BW_NEW);
% Statistical information of the new BW image
stats = regionprops(CC,BW_NEW,'all');

% The area of all the connected components
area = [stats.Area];

%Threshold for pixels by using the staistical information
% Use the staistical information: std=standard deviation and mean of the area
Pix_thresh = (2*std(area))-mean(area); 

% Αρχικοποίηση είκόνας 
Clean_Image = zeros(size(BW_NEW));

% For each connected component
for i = 1:CC.NumObjects
    % If the area of the current component is graeter than the threshold
    if area(i) > Pix_thresh 
        % Set the pixels in the current component to 1 in the cleaned image
        Clean_Image(CC.PixelIdxList{i}) = 1;
    else 
         % Set the pixels in the current component to 0 in the cleaned image
        Clean_Image(CC.PixelIdxList{i}) = 0;

    end
end

%Show the final cleaned image (Eikona 7)
figure;
image(~Clean_Image);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('FINAL CLEAN IMAGE')

% ------------------------------------------------------
% WORD SEGMENTATION
% ------------------------------------------------------
% --- Step A5

% Make morphological operations for word segmentation 
% Union the letters to make the words of the text by dilating with SE = line
% with 18 lenght and 2 angle
SE_1=strel("line",18,2);
BW_WordSeg=imdilate(Clean_Image,SE_1);

% Show the original binary image (Eikona 8)
figure('color','w');
image(~BW); % NOTICE! the image is shown inverted
axis image;
set(gca,'xtick',[],'ytick',[]);
colormap(gray(2));
title('Original image');

% Find the connected components and their overall number
% The second parameter defines the connectivity: 4 or 8
[L,Count] = bwlabel(BW_WordSeg,4);

% Show each connected component with a different color (Eikona 9)
RGB = label2rgb(L,'lines');
figure('color','w');
image(RGB);
axis image;
set(gca,'xtick',[],'ytick',[]);
title(sprintf('There are %g connected components',Count));

% Store all the bounding boxes in an array R
R=[];
for i=1:Count
    [r,c]=find(L==i);
    XY=[c r];
    x1=min(XY(:,1));
    y1=min(XY(:,2));
    x2=max(XY(:,1));
    y2=max(XY(:,2));
    R=[R;x1 y1 x2 y2]; % append to R the bounding box as [x1 y1 x2 y2]
end

%Draw the original image with the bounding boxes around the connected
%component (Eikona 10)
ColorMap=lines;
figure('color','w');
A=(~I)*255;
image(A); % NOTICE! the image is shown inverted
colormap(gray(256));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('Bounding boxes');

for i=1:size(R,1)
    x1=R(i,1);
    y1=R(i,2);
    x2=R(i,3);
    y2=R(i,4);
    line([x1-0.5 x2+0.5 x2+0.5 x1-0.5 x1-0.5],[y1-0.5 y1-0.5 y2+0.5 y2+0.5 y1-0.5],'color',ColorMap(mod(i-1,7)+1,:),'linewidth',2);
end

% Show in Command Window the connected Componennts array L
L;
s=regionprops(L,'BoundingBox');
AllBoxes=cat(1,s.BoundingBox);

if exist('R','var')
    dlmwrite('results.txt',R,'\t');
else
    error('Ooooops! There is no R variable!');
end