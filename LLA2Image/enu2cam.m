%ENU -> Camera

function [xCam, yCam, zCam] = enu2cam(eENU, nENU, uENU)

qs = -0.696910;
qx = -0.675713;
qy = 0.172945;
qz = 0.166786;

xCam = [qs^2+qx^2-qy^2-qz^2, 2*qx*qy-2*qs*qz, 2*qx*qz+2*qs*qy]*[nENU; eENU; -uENU];
yCam = [2*qx*qy+2*qs*qz, qs^2-qx^2+qy^2-qz^2, 2*qy*qz-2*qs*qx]*[nENU; eENU; -uENU];
zCam = [2*qx*qz-2*qs*qy, 2*qy*qz+2*qs*qx, qs^2-qx^2-qy^2+qz^2]*[nENU; eENU; -uENU];