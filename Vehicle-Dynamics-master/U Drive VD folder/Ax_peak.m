function [ out ] = Ax_peak(car,env,debug)
% Ax_peak simulator

tspan = [0 4];
X0 = [0 0];%x x' x''
a=0;
%a = 1.6*9.81;
[t,X] = ode45(@ax, tspan, X0);

if debug
    plot(t, X(:,1))
end
out.X = X;
out.t = t;
[~,as] = ax(0,[0 0]);
out.a = as;

    function [Xdot a_out] = ax(t,X)
        x1 = X(1);%m
        x1dot = X(2);%m/s
        persistent av
        
        drag = car.aero.total.C_d*0.5*env.rho_air*car.aero.total.area_mkgs*x1dot^2;%N
        lift = car.aero.total.C_l*0.5*env.rho_air*car.aero.total.area_mkgs*x1dot^2;%N
  %this is wrong wt(1:2) = (a*car.h_mkgs+(car.aero.total.Cp_z_mkgs+car.h_mkgs)*drag+(car.b_mkgs-car.aero.total.Cp_x_mkgs)*lift)/car.wb_mkgs;
  %this is wrong    wt(3:4) = (a*car.h_mkgs+(car.aero.total.Cp_z_mkgs+car.h_mkgs)*drag-(car.b_mkgs-car.aero.total.Cp_x_mkgs)*lift)/-car.wb_mkgs;
        fz = car.Fz_static_mkgs + wt';
        
        fx = car.tire_peakfxfz_mkgs(fz);%fx in N
        x1dotdot = (sum(fx)-drag)/car.effective_mass.mkgs;%acceleration in m/s/s
        a = x1dotdot;
        av = [av a];
        
        Xdot = [x1dot x1dotdot ]';
        if nargout >1
            a_out = av;
        end
    end


end
