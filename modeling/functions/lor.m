%%  This function is used to determine the position of P to line L
%   Andi Zang
%   09/03
%   -1 -> left
%   +1 -> right
function [lnr] = lor(line, p1, spheroid)
center = ecef2lla(line(1:3));
p2 = line(1:3) + 3*line(4:6);
%
[n2, e2, ~] = ecef2ned(p2(1), p2(2), p2(3),...
        center(1), center(2), center(3), spheroid);
[n1, e1, ~] = ecef2ned(p1(1), p1(2), p1(3),...
        center(1), center(2), center(3), spheroid);
%
if n1*e2 - e1*n2<0
    lnr = -1;
elseif n1*e2 - e1*n2>0
    lnr = 1;
else
    lnr = 0;
end
end%endfunction
