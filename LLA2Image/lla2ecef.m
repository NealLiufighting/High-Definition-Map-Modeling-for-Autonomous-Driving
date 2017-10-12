% LLA -> ECEF

function [xECEF, yECEF, zECEF] = lla2ecef(latLLA,lonLLA)

% polar and equatorial raidus of earth
a = double(6356.7523);
b = double(6378.1370);

fLLA = (a-b)/a;
eLLA = sqrt(fLLA*(2-fLLA));

nLLA = a/sqrt(1-(eLLA^2)*((sin(latLLA))^2));
xECEF = nLLA*cos(lonLLA)*cos(latLLA);
yECEF = nLLA*cos(lonLLA)*sin(latLLA);
zECEF = (1-eLLA^2)*nLLA*sin(lonLLA);