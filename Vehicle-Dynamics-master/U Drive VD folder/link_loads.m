%Suspension member load calculator
%Foster Collins
%Fall 2015
%DS 2016-12-17 edit
%Requires a loaded look up table

function [loads] = link_loads(B, ShockDisplacement, SteeringAngle, CarLocation, sla)
%calculates forces in suspension members based on forces and moments (lbf and in-lbf) at the
%contact patch
%steering angle for current wheel **not steering wheel**
% CarLocation follows standard: [rear left, rear right, front left, front right]
%returns loads which is a column vector with the loads

%output forces in lbf
%[forward upper AA link;
% rearward upper AA link;
% steering/toe link;
% forward bottom AA link;
% rearward bottom AA link;
% pushrod];

switch CarLocation
    case 4
        %determine closest shock travel point
        [~, indexShock] = min(abs(ShockDisplacement-sla.fr_geo.shock_travel));
        [~, indexSteer] = min(abs(SteeringAngle-sla.fr_geo.steered_angle(:,indexShock)));
        %Steer = sla.fl_geo.steered_angle(indexSteer,indexShock)
        
        %construct vectors for each link
        v1 = sla.fr(1,:,indexShock, indexSteer)-sla.fr(2,:,indexShock, indexSteer); %ufibj-uobj
        v2 = sla.fr(3,:,indexShock, indexSteer)-sla.fr(2,:,indexShock, indexSteer); %uribj-uobj
        v3 = sla.fr(9,:,indexShock, indexSteer)-sla.fr(10,:,indexShock, indexSteer); %tri-tro
        v4 = sla.fr(4,:,indexShock, indexSteer)-sla.fr(5,:,indexShock, indexSteer); %lfibj-lobj
        v5 = sla.fr(6,:,indexShock, indexSteer)-sla.fr(5,:,indexShock, indexSteer); %lribj-lobj
        v6 = sla.fr(16,:,indexShock, indexSteer) - sla.fr(11,:,indexShock, indexSteer); %bc pushrod - pro 

        %vector from contact patch to where the force is applied
         p1 = sla.fr(2,:,indexShock, indexSteer)-sla.fr(8,:,indexShock, indexSteer); %uobj
         p2 = sla.fr(2,:,indexShock, indexSteer)-sla.fr(8,:,indexShock, indexSteer); %uobj
         p3 = sla.fr(10,:,indexShock, indexSteer)-sla.fr(8,:,indexShock, indexSteer); %tro
         p4 = sla.fr(5,:,indexShock, indexSteer)-sla.fr(8,:,indexShock, indexSteer); %lobj
         p5 = sla.fr(5,:,indexShock, indexSteer)-sla.fr(8,:,indexShock, indexSteer); %lobj
         p6 = sla.fr(11,:,indexShock, indexSteer)-sla.fr(8,:,indexShock, indexSteer); %pro

    case 3
        %determine closest shock travel point
        [~, indexShock] = min(abs(ShockDisplacement-sla.fl_geo.shock_travel));
        [~, indexSteer] = min(abs(SteeringAngle-sla.fl_geo.steered_angle(:,indexShock)));
        %Steer = sla.fl_geo.steered_angle(indexSteer,indexShock)
        
        %construct vectors for each link
        v1 = sla.fl(1,:,indexShock, indexSteer)-sla.fl(2,:,indexShock, indexSteer); %ufibj-uobj
        v2 = sla.fl(3,:,indexShock, indexSteer)-sla.fl(2,:,indexShock, indexSteer); %uribj-uobj
        v3 = sla.fl(9,:,indexShock, indexSteer)-sla.fl(10,:,indexShock, indexSteer); %tri-tro
        v4 = sla.fl(4,:,indexShock, indexSteer)-sla.fl(5,:,indexShock, indexSteer); %lfibj-lobj
        v5 = sla.fl(6,:,indexShock, indexSteer)-sla.fl(5,:,indexShock, indexSteer); %lribj-lobj
        v6 = sla.fl(16,:,indexShock, indexSteer) - sla.fl(11,:,indexShock, indexSteer); %bc pushrod - pro 

        %vector from contact patch to where the force is applied
        p1 = sla.fl(2,:,indexShock, indexSteer)-sla.fl(8,:,indexShock, indexSteer); %uobj
        p2 = sla.fl(2,:,indexShock, indexSteer)-sla.fl(8,:,indexShock, indexSteer); %uobj
        p3 = sla.fl(10,:,indexShock, indexSteer)-sla.fl(8,:,indexShock, indexSteer); %tro
        p4 = sla.fl(5,:,indexShock, indexSteer)-sla.fl(8,:,indexShock, indexSteer); %lobj
        p5 = sla.fl(5,:,indexShock, indexSteer)-sla.fl(8,:,indexShock, indexSteer); %lobj
        p6 = sla.fl(11,:,indexShock, indexSteer)-sla.fl(8,:,indexShock, indexSteer); %pro
        
    case 1
        %determine closest shock travel point
        [~, indexShock] = min(abs(ShockDisplacement-sla.rl_geo.shock_travel));

        %construct vectors for each link
        v1 = sla.rl(1,:,indexShock)-sla.rl(2,:,indexShock); %ufibj-uobj
        v2 = sla.rl(3,:,indexShock)-sla.rl(2,:,indexShock); %uribj-uobj
        v3 = sla.rl(9,:,indexShock)-sla.rl(10,:,indexShock); %tri-tro
        v4 = sla.rl(4,:,indexShock)-sla.rl(5,:,indexShock); %lfibj-lobj
        v5 = sla.rl(6,:,indexShock)-sla.rl(5,:,indexShock); %lribj-lobj
        v6 = sla.rl(16,:,indexShock) - sla.rl(11,:,indexShock); %bc pushrod - pro 

        %vector from contact patch to where the force is applied
        p1 = sla.rl(2,:,indexShock)-sla.rl(8,:,indexShock); %uobj
        p2 = sla.rl(2,:,indexShock)-sla.rl(8,:,indexShock); %uobj
        p3 = sla.rl(10,:,indexShock)-sla.rl(8,:,indexShock); %tro
        p4 = sla.rl(5,:,indexShock)-sla.rl(8,:,indexShock); %lobj
        p5 = sla.rl(5,:,indexShock)-sla.rl(8,:,indexShock); %lobj
        p6 = sla.rl(11,:,indexShock)-sla.rl(8,:,indexShock); %pro
        
    case 2
        %determine closest shock travel point
        [~, indexShock] = min(abs(ShockDisplacement-sla.rr_geo.shock_travel));
        
        %construct vectors for each link
        v1 = sla.rr(1,:,indexShock)-sla.rr(2,:,indexShock); %ufibj-uobj
        v2 = sla.rr(3,:,indexShock)-sla.rr(2,:,indexShock); %uribj-uobj
        v3 = sla.rr(9,:,indexShock)-sla.rr(10,:,indexShock); %tri-tro
        v4 = sla.rr(4,:,indexShock)-sla.rr(5,:,indexShock); %lfibj-lobj
        v5 = sla.rr(6,:,indexShock)-sla.rr(5,:,indexShock); %lribj-lobj
        v6 = sla.rr(16,:,indexShock) - sla.rr(11,:,indexShock); %bc pushrod - pro 

        %vector from contact patch to where the force is applied
        p1 = sla.rr(2,:,indexShock)-sla.rr(8,:,indexShock); %uobj
        p2 = sla.rr(2,:,indexShock)-sla.rr(8,:,indexShock); %uobj
        p3 = sla.rr(10,:,indexShock)-sla.rr(8,:,indexShock); %tro
        p4 = sla.rr(5,:,indexShock)-sla.rr(8,:,indexShock); %lobj
        p5 = sla.rr(5,:,indexShock)-sla.rr(8,:,indexShock); %lobj
        p6 = sla.rr(11,:,indexShock)-sla.rr(8,:,indexShock); %pro
end

%normalize vecotor
u1 = v1./norm(v1);
u2 = v2./norm(v2);
u3 = v3./norm(v3);
u4 = v4./norm(v4);
u5 = v5./norm(v5);
u6 = v6./norm(v6);

A = [u1', u2', u3', u4', u5', u6';
      cross(p1,u1)' cross(p2,u2)' cross(p3,u3)' cross(p4,u4)' cross(p5,u5)' cross(p6,u6)'];
    
% B  = [F';M'];

loads = A\B;

end

