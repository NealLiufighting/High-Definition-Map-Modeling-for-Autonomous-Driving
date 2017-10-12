clear all
%
raw = imread('dashedline.png');
% crop raw image
raw = raw(:, 35:37,:);
raw_grey = rgb2gray(raw);

% convert to double
raw_grey = double(raw_grey)/255;
raw = double(raw)/255;
rawheat = myheatmap(raw_grey);
% my resize
width = 40;
bwidth = 0;
% initialize new figure
new_image = ones([size(raw_grey)*width,3]);
% fillup 
for i = 1:size(raw_grey,1)
    for j = 1:size(raw_grey,2)
%         new_image(width*(i-1)+1:width*i,width*(j-1)+1:width*j,:) = raw_grey(i,j);
        for k = 1:3
            new_image(width*(i-1)+1:width*i,width*(j-1)+1:width*j,k) = rawheat(i,j,k);
        end%endfor k
    end%endfor j
end%endfor i
% draw boundaries
for i = 1:size(raw_grey,1)-1
    % draw horizontal bound
    new_image(width*i-bwidth:width*i+bwidth,:,:) = 0;
end%endfor i
for j = 1:size(raw_grey,2)-1
    % draw vertical bound
    new_image(:,width*j-bwidth:width*j+bwidth,:) = 0;
end%endfor j

new_image2 = new_image;
% axis([0 14 0 1])
for i = 1:size(raw_grey,2)
    f = fit([1:size(raw_grey,1)]',raw_grey(:,i),'gauss2');
    X = [1:1/width:size(raw_grey,1)];
    Y = f(X);
    Xlist = [width/2+1:size(new_image)-width/2+1];
    Ymin = min(Y);
    Ymax = max(Y);
    for j = 1:length(X)
        y = floor((Y(j)-Ymin)/(Ymax - Ymin)*(width-10));
        new_image2(Xlist(j),y+width*(i-1)+1,:) = [0 1 0];
    end%endfor j
end%endfor ifigure

figure;
imshow(new_image2)
hold on
% print text
for i = 1:size(raw_grey,1)
    for j = 1:size(raw_grey,2)
        text(width*(j-1)+width/4,width*(i-1)+width/2,num2str(uint8(raw_grey(i,j)*255)),...
            'FontSize',11,'Color',[1 1 1]);
    end%endfor j
end%endfor i
% print peak
for i = 1:size(raw_grey,2)
    f = fit([1:size(raw_grey,1)]',raw_grey(:,i),'gauss2');
    Ymin = min(Y);
    Ymax = max(Y);
    y = floor((f(f.b1)-Ymin)/(Ymax - Ymin)*(width-10));
    x = round(f.b1*width-1/2*width+1);
    plot(y+width*(i-1)+1,x,'r*');
end%endfor i

F = getframe(gca);

imwrite(F.cdata,'test.png');