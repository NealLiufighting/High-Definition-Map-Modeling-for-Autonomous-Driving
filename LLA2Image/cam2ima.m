% Camera -> Image

function [xIma, yIma] = cam2ima(xCam, yCam, zCam, Res)

% Front Cube
xIma = (yCam/zCam)*((Res-1)/2) + (Res+1)/2;
yIma = (xCam/zCam)*((Res-1)/2) + (Res+1)/2;
