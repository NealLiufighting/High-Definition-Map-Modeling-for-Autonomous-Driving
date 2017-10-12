%% This function is used to interpolate points.
%   Andi Zang
%   09/10
function [cp_spline] = llaPolylineInterpolation(cps, dens)
%   convert control points to ecef
cps_ecef = lla2ecef(cps);
%
cp_spline = [];
if size(cps_ecef,1)>1
    for i = 1:1:size(cps_ecef,1)-1
        dist = norm((cps_ecef(i+1,:) - cps_ecef(i,:)));
        dist
        if dist > 0
            for k = 0:dens:dist
                new_pose = k/dist*(cps_ecef(i+1,:) - cps_ecef(i,:)) + cps_ecef(i,:);
                cp_spline = cat(1, cp_spline, new_pose);
            end%endfor k
        else
        end
        i
    end
    if isempty(cp_spline)
        cp_spline = cps;
    else
        cp_spline = ecef2lla(cp_spline);
    end%endif
    
else
    cp_spline = cps;
end%endif
end%endfunction