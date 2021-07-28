%% Vehicle Model. Calculates CN vs. Cy
clearvars -except h
clc;
% car is in in. lb. sec. units. mass in slugs.
% tire model will be evaluated with correct converted units and will return
% lbf.
% use SAE coordinate system.  X forward, Y right, Z down
% if there are pairs, they correspond to [rear, front]
% if there are quads, they correspond to [rear left, rear right, front left, front right]

% Tire Models
% These were fit by Adam Farabaugh in 2015.  They are not very good.
R25B_205_70_13_6 = 'GAAAAAAAAIAAAAAAAAAAKHEMAAAAAIODAAAAADBEAAILIIHEOIHELKPDBJGNICAMMIONPFODIPFCHCBEOJDCEBODPAHJAJPDPOBPGCOLPJHPIBOLKGBLAECECLBOOHPDJNAPGIAEKCKPDCLLHOLLHAMLCPBGOCOLKJEPLCNDGEMDDPNDENLFAPODLLNOIHODMNLEDDPDBFBHKJPDFBAEAMNDPPKEFBPLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFILBCDMLDKHGDBLDAAJEEBNDBHADPMNDFBOCIEAENNHKMMNLBNMLEEPLAAAAAAAANCEHIOODOJFIDKAEAAAAAAAAAAAAAAAALKFEGACEMIJHJNOLJEKOCIPLHPGBGBODIJENPMKLMLDEFNOLNENJMOPLAAAAAAAAIHKHBANDBKFPPOMLBIMGHCAMEKACDPODHKAGOOCMEMKAEFDEKAAHPHDMEIECNOOLELBLMNAMGMBLBJPDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';
R25B_180_60_10_7 = 'GAAAAAAAAIAAAAAAAAAAKHEMGGGGGGODAAAAADBEAAILIIHEBODNDMPDCKNOHBAMGEAKOHODCIDMCGBENIJJENODMGMAHKNLCAGOPBODCFAPDDODOAOOBGCEOMPMLCAEHDCMPFBEEENJKJLLJANDONKLGPKLMKNLMNMENHNDKBCPAFLLLPLAIJPLAOFMHNODHMCGCNPDBKBGKAAEKIFEABOLNOJNOFNDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANLDPOGMLLICHAEMDJGPLLBODFIFIJLODFLNJANAEGELLCPPLOMMLKOPLAAAAAAAAAFHOKLODPDKPHOAEAAAAAAAAAAAAAAAAONKMLOBENOAKJCPDBBDIEKPLLHPAFCODMHOCJHNLLDLNNEAMNFHGMACEAAAAAAAAMLFCLCNLAEAOGLLDDGMHINPLBEPBJFNLKBNLCAAMICLIBEAMOPKPOCBMIGDFFMOLOLFMFPPDOIMPEFPDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';
LC0_180_60_10_7  = 'GAAAAAAAAIAAAAAAAAAAKHEMGGGGGGODAAAAADBEAAILIIHECKEBILODGBJFEKAMEMPEFIODJEKEHCBEAMBGAMOLFBNBAIODCMJKILOLPLKBAJNLCFNHCACECBINAKPDPLJEKBBEFHEJCKLLCACKAFLLBMEEKPNLGGGHFCNDFFAFPAMDGCPHHAPLHAOGAFNLEKIOCDPDBGCBHKPDOKFLIMNLHAHOPKNLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKJDHOGMLGKPHHOLDPKMDFMODLMAHMIMLCDFPPFAEKIIKDFNDILNLBPNDAAAAAAAAIFKFKKODEFALEFAMAAAAAAAAAAAAAAAAPAEEFNAEALDEEJNDEFLPFIPLFNMKFDODKEPFILLLMACMCLPLIIDBFDBEAAAAAAAALBGBKMLLLPFHONLLJFMJCMPLJNJAGLODGANEDPBMIDKIMBBMLMMKIKBMLHBPCJODICLLKHBMPMCEMHPDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';

REV1 = REV1_car();
REV2 = REV2_car();


%% OptimumT License and COM handle
A = exist('h', 'var');
if A == 0
    h = actxserver('OptimumT.Calculations');
end

%% Generate a MMD for this vehicle
brange = 10;
beps = 1;

drange = 10;
deps = 1;

[betas, deltas] = meshgrid(-brange:beps:brange, -drange:deps:drange);
% deltas = deltas + betas;
% betas = betas + 6;
% deltas = deltas + 8;

% Skidpad MMD
radius = 10 / .0254;
[hist] = MMD_CN_Cy(REV2, betas, deltas, radius, h, 0);



%% Plotting
figure(11); clf;
suptitle(['Output, Radius = ' num2str(radius)]);


nsr = 6;
nsc = 4;

% Tire Info
subplot(nsr,nsc,1); hdi = plot(hist(:,3:6), '.-');    ylabel('Delta_i'); legend('RL', 'RR', 'FL', 'FR');
subplot(nsr,nsc,2); hbi = plot(hist(:,7:10), '.-');   ylabel('Beta_i'); 
subplot(nsr,nsc,3); hai = plot(hist(:,11:14), '.-');  ylabel('alpha_i');
subplot(nsr,nsc,4); hnci = plot(hist(:,19:22), '.-'); ylabel('no_contact_i');

% Tire forces and moments
subplot(nsr,nsc,5); hfzi = plot(hist(:,15:18), '.-'); ylabel('Fz_i');
subplot(nsr,nsc,6); hfxi = plot(hist(:,27:30), '.-'); ylabel('Fx_i');
subplot(nsr,nsc,7); hfyi = plot(hist(:,23:26), '.-'); ylabel('Fy_i');
subplot(nsr,nsc,8); hmzi = plot(hist(:,31:34), '.-'); ylabel('Mz_i');

% Body forces and moments
% subplot(nsr,nsc,9); hfxb = plot(hist(:,35), '.-'); ylabel('Fx_b');
% subplot(nsr,nsc,10); hfyb = plot(hist(:,36), '.-'); ylabel('Fy_b');
% subplot(nsr,nsc,11); hmzb = plot(hist(:,37), '.-'); ylabel('Mz_b');

% Velocity Frame Outputs
subplot(nsr,nsc,9); haxv = plot(hist(:,38), '.-'); ylabel('Ax_v');
subplot(nsr,nsc,10); hayv = plot(hist(:,39), '.-'); ylabel('Ay_v');
subplot(nsr,nsc,11); hcnv = plot(hist(:,40), '.-'); ylabel('CN_v');

% Residual
subplot(nsr,nsc,12); hres = semilogy(abs(hist(:,42)), '.-'); ylabel('Conv Crit');

set(findobj('type','axes'),'xgrid','on','ygrid','on');
drawnow();

CN = reshape(hist(:,40), size(betas));
CY = reshape(hist(:,39), size(betas));
CX = reshape(hist(:,38), size(betas));
betas_actual = reshape(hist(:,1), size(betas));
deltas_actual = reshape(hist(:,2), size(betas));

% Plot Traditional MMD
subplot(nsr,nsc,13:(nsr*nsc));
hold on;
% Lines of constant steer are in rows, i.e. CY(11,:)
hsteer = plot3(CY(1,:), CN(1,:), CX(1,:), '--b', 'LineWidth',1);
plot3(CY(2:end,:)', CN(2:end,:)', CX(2:end,:)', '--b', 'LineWidth',1);
% Lines of constant vehicle slip are in columns, i.e. CY(:,11)
hslip = plot3(CY(:,1), CN(:,1), CX(:,1), '-r', 'LineWidth',1);
plot3(CY(:,2:end), CN(:,2:end), CX(:,2:end), '-r', 'LineWidth',1);

grid on;
legend([hslip, hsteer], 'Constant Vehicle Slip', 'Constant Steer');
xlabel('Normalized Lateral Force (CY)');
ylabel('Yaw Moment Coefficient (CN)');
zlabel('Normalized Longitudinal Force (CX)');

