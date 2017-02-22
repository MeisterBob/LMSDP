function [a,b,c]=inverseKin(machine, x0, y0, z0)
     a = 0; b = 0; c = 0;
     [status, a] = calcAngleYZ(machine, x0, y0, z0);
     sin120 = sqrt(3)/2;
     cos120 = -0.5;
     if (status == 0)
         [status, b] = calcAngleYZ(machine,  x0*cos120+y0*sin120,  y0*cos120-x0*sin120, z0); % rotate coords to +120 deg
     end 
     if (status == 0)
         [status, c] = calcAngleYZ(machine, x0*cos120-y0*sin120, y0*cos120+x0*sin120, z0); % rotate coords to -120 deg
     end
     if (status ~= 0)
         disp('da kann ich nicht hin');
         a = 0; b = 0; c = 0;
     end
end
