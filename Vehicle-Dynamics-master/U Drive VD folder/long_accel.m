function [outdata] = long_accel(car,env,debug)
%% Acceleration Simulation 0-75m
% assumes power limit, ideal Slip Ratio

dt = .001;
time = 3.7; %s
n = time/dt+2;

a = zeros(n,1);%in/s/s
v = zeros(n,1);%in/s
x = zeros(n,1);%in
t = zeros(n,1);%s
w = zeros(n,2);
w_ground = zeros(n,1);%
frontNorm = ones(n,1)*-car.Fz_static(3);
rearNorm = ones(n,1)*-car.Fz_static(1);
accForce = zeros(n,1);
rearTorque = zeros(n,1);
frontTorque = zeros(n,1);
frontPower = zeros(n,1);
rearPower = zeros(n,1);
totalPower = zeros(n,1);
rearFx = zeros(n,1);
frontFx = zeros(n,1);
lift = zeros(n,1);
drag = zeros(n,1);
sat = zeros(n,2);
I = zeros(n,2);
p_loss_inv = zeros(n,2);
p_loss_m = zeros(n,2);

frontNorm(1) = car.w*(1-car.wdr)/2; %lbf
rearNorm(1) = car.w*car.wdr/2; %lbf
rearFx(1) = car.tire_peakfxfz{car.tire}(rearNorm(1));
frontFx(1) = car.tire_peakfxfz{car.tire}(frontNorm(1));
g = env.g;%in/s/s
k = 2;
for i = 0:dt:time
    t(k)=i+dt;
    
    
    drag(k) = car.aero_C_d*0.5*env.rho_air*car.aero.total.area*v(k-1)^2 / g;
    lift(k) = car.aero_C_l*0.5*env.rho_air*car.aero.total.area*v(k-1)^2 / g;
    
    
    %longitudinal force - drag
    accForce(k) = rearFx(k-1)*2+frontFx(k-1)*2-drag(k);
    a(k) = g*accForce(k)/car.effective_mass;
    
    v(k) = v(k-1)+a(k)*dt;
    w_ground(k) = v(k)/(car.tire_r);
    x(k) = x(k-1)+v(k)*dt;
    
    %Weight transfer
    wt(1) = (accForce(k)/car.effective_mass*car.w*car.h+(car.aero.total.Cp_z+car.h)*drag(k)+(car.b-car.aero.total.Cp_x)*lift(k))/car.wb/2;
    wt(2) = (accForce(k)/car.effective_mass*car.w*car.h+(car.aero.total.Cp_z+car.h)*drag(k)-(car.b-car.aero.total.Cp_x)*lift(k))/-car.wb/2;
    rearNorm(k) = -car.Fz_static(1) + wt(1);
    frontNorm(k) = -car.Fz_static(3) + wt(2);
    w(k,:) = [w_ground(k)*(1 + car.tire_SR{car.tire}(rearNorm(k))), w_ground(k)*(1  + car.tire_SR{car.tire}(rearNorm(k)))];
    %Tractive forces
    rearFx(k) = car.tire_peakfxfz{car.tire}(rearNorm(k));
    frontFx(k) = car.tire_peakfxfz{car.tire}(frontNorm(k));
    rearTorque(k) = rearFx(k)*car.tire_r;
    frontTorque(k) = frontFx(k)*car.tire_r;
    frontPower(k) = frontTorque(k)*w(k,2);
    rearPower(k) = rearTorque(k)*w(k,1);
    
    %% Speed Limit
    if w(k,1)>car.max_w/car.gear_ratio_rear || w(k,2) > car.max_w/car.gear_ratio_front
        rearTorque(k) = rearTorque(k)/2;
        frontTorque(k) = frontTorque(k)/2;
    end
    %% Motor Limits
    motor_params = car.motor_params([rearTorque(k);frontTorque(k)],[w(k,1) w(k,2)]); %motor output limit, motor current, motor efficiency
    I(k,:) = motor_params(:,2)';
    sat(k,:) = motor_params(:,6)';
    p_loss_m(k,:) = motor_params(:,5)';
    p_loss_inv(k,:) = [car.powertrain_loss(I(k,1));car.powertrain_loss(I(k,2))]';
    p_draw = motor_params(:,3)'+ p_loss_inv(k,:);
    motor_torque = motor_params(:,4).*[car.gear_ratio_rear;car.gear_ratio_front];
    rearTorque(k) = motor_torque(1);
    frontTorque(k) = motor_torque(2);
    totalPower(k) = sum(p_draw)*2;
    eff = (motor_params(:,1))./(p_draw');
    %% Comp Power Limit
    if totalPower(k)-car.max_power > 0
        %disp('Comp Limit')
        delta_p = totalPower(k)-car.max_power;
        %if delta_p > 0 (above power limit) subtract torque
        rearTorque(k) = rearTorque(k)-delta_p/2/w(k,1)*(car.pdr)*eff(1);
        frontTorque(k) = frontTorque(k)-delta_p/2/w(k,2)*(1-car.pdr)*eff(2);
        
        %% Motor Limits again...
        motor_params = car.motor_params([rearTorque(k);frontTorque(k)],[w(k,1),w(k,2)]); %motor output limit, motor current, motor efficiency
        I(k,:) = motor_params(:,2)';
        sat(k,:) = motor_params(:,6)';
        p_loss_m(k,:) = motor_params(:,5)';
        p_loss_inv(k,:) = [car.powertrain_loss(I(k,1));car.powertrain_loss(I(k,2))]';
        p_draw = motor_params(:,3)'+ p_loss_inv(k,:);
        motor_torque = motor_params(:,4).*[car.gear_ratio_rear;car.gear_ratio_front];
        rearTorque(k) = motor_torque(1);
        frontTorque(k) = motor_torque(2);
        totalPower(k) = sum(p_draw)*2;
    end
    %% Evaluate 
    rearPower(k) = rearTorque(k)*w(k,1);
    frontPower(k) = frontTorque(k)*w(k,2);
    rearFx(k) = rearPower(k)/v(k);
    frontFx(k) = frontPower(k)/v(k);
    k = k+1;
end
t(k-1) = time;


if debug
    close all
    figure;
    plot(w,totalPower*4.448*.0254,'b');
    hold on
    plot(w,2*(rearPower+frontPower)*4.448*.0254,'g');
    plot(w,p_loss_inv*2*4.448*.0254)
    plot(w,p_loss_m*2*4.448*.0254)
    plot(w,sum([p_loss_inv p_loss_m],2)*2*4.448*.0254)
    legend('Total','Output','Rear Inverters','Front Inverters','Rear Motors', 'Front Motors','Total Losses','location','eastoutside')
    title('Power')
    xlabel('rad/s')
    ylabel('W')
    grid on
    
    outdata.power = [rearPower frontPower totalPower];

    outdata.a = a;
    outdata.v = v;
    outdata.x = x;
    outdata.t = t;
    outdata.w = w;
    outdata.fz = [rearNorm frontNorm];
    outdata.torque = [rearTorque frontTorque];
    outdata.fx = [rearFx frontFx accForce];
    outdata.lift = lift;
    outdata.drag = drag;
    m_pout = zeros(2,n);
    m_pdraw = zeros(2,n);
    m_ploss = zeros(2,n);
    m_t = zeros(2,n);
    m_i = zeros(2,n);
    for i = 1:n
        m = car.motor_params([500/.0254/4.448;500/.0254/4.448],[w(i,1) w(i,2)]);
        m_pout(:,i) = m(:,1);
        m_pdraw(:,i) = m(:,3);
        m_ploss(:,i) = m(:,5);
        m_t(:,i) = m(:,4);
        m_i(:,i) = m(:,2);
    end
    
    h = figure;
    set(h, 'Position', [300, 300, 1200, 720]);
    
    subplot(2,3,1)
    plot(w_ground,rearPower*4.448*.0254,'k');
    hold on;
    plot(w_ground,frontPower*4.448*.0254,'r');
    plot(w_ground,totalPower*4.448*.0254,'b');
    plot(w_ground,m_pout(1,:)*4.448*.0254,'k--');
    plot(w_ground,m_pout(2,:)*4.448*.0254,'r--');
    plot(w_ground,m_pdraw(1,:)*4.448*.0254,'k-.');
    plot(w_ground,m_pdraw(2,:)*4.448*.0254,'r-.');
    plot(w_ground,m_ploss(1,:)*4.448*.0254,'k-.');
    plot(w_ground,m_ploss(2,:)*4.448*.0254,'r-.');
    plot(w_ground,2*(rearPower+frontPower)*4.448*.0254,'g');
    %plot(car.GVK142_025L6.ws/car.gear_ratio.front,car.GVK142_025L6.ps*4.448*.0254,'r--');
    %plot(car.GVK142_050L6.ws/car.gear_ratio.rear,car.GVK142_050L6.ps*4.448*.0254,'k--');
    title('Power vs w');
    xlabel('rad/s');
    ylabel('Power (W)');
    
    
    subplot(2,3,2)
    plot(t,v*.0254,'k');
    title('Speed vs Time');
    xlabel('Time (s)');
    ylabel('Speed (m/sec)');
    
    subplot(2,3,3)
    plot(w,I,'--');
    hold on
    plot(w,m_i')%,w,sat)
    title('Current and Saturation %');
    legend('Rear I', 'Front I','Rear I peak','Front I peak','Rear Sat','Front Sat','location','eastoutside')
    xlabel('rad/s');
    ylabel('Current (Arms)');
    
    subplot(2,3,4)
    plot(t,a*.0254/9.81,'k');
    title('Acceleration vs Time');
    xlabel('Time (s)');
    ylabel('Acceleration (G)');
    
    subplot(2,3,5)
    plot(w_ground,rearTorque*4.448*.0254/car.gear_ratio_rear,'k');
    hold on;
    plot(w_ground,frontTorque*4.448*.0254/car.gear_ratio_front,'r');
    plot(w_ground,m_t(1,:)*4.448*.0254,'k--');
    plot(w_ground,m_t(2,:)*4.448*.0254,'r--');
    %plot(car.GVK142_025L6.ws/car.gear_ratio.front,car.GVK142_025L6.ps./(car.GVK142_025L6.ws/car.gear_ratio.front),'r--');
    %plot(car.GVK142_050L6.ws/car.gear_ratio.rear,car.GVK142_050L6.ps./(car.GVK142_050L6.ws/car.gear_ratio.rear),'k--');
    title('T vs w');
    xlabel('rad/s');
    ylabel('Torque (Nm)');
    
    subplot(2,3,6)
    plot(t,x*.0254,'k');
    title('Distance vs Time');
    xlabel('Time (s)');
    ylabel('Distance (m)');
else
    if x(end) > 75/.0254
        outdata = [max(a*.0254/9.81); min(t(x>75/.0254))];
    else
        outdata = [max(a*.0254/9.81); NaN];
    end
end

end