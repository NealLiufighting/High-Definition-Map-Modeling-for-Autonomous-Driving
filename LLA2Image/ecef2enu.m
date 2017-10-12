% ECEF -> ENU

function [eENU, nENU, uENU] = ecef2enu(xECEF, yECEF, zECEF,latLLA, lonLLA)

[x0, y0, z0] = lla2ecef(0,0);

eENU = [-sin(lonLLA), cos(lonLLA), 0]*[xECEF-x0; yECEF-y0; zECEF-z0];
nENU = [-cos(lonLLA)*sin(latLLA), -sin(latLLA)*sin(lonLLA), cos(latLLA)]*[xECEF-x0; yECEF-y0; zECEF-z0];
uENU = [cos(latLLA)*cos(lonLLA), cos(latLLA)*sin(lonLLA), sin(latLLA)]*[xECEF-x0; yECEF-y0; zECEF-z0];







