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


%% Construct Cars
REV1 = REV1_car();

REV2_R25B = REV2_car();
REV2_R25B.coeffs = R25B_180_60_10_7;
REV2_R25B.name = 'REV2-R25B';

REV2_LC0 = REV2_car();
REV2_LC0.coeffs = LC0_180_60_10_7;
REV2_LC0.name = 'REV2-LC0';

REV2_noaero = REV2_car();

REV1_aero = REV1;
REV1_aero.aero = REV2_LC0.aero;
REV1_aero.name = 'REV1_{aero}';
REV1_aero.w = REV1_aero.w + 35;

%% Construct Environment
env.mu = .55;
env.rho_air = 1.162; % kg/m^3
env.g = 9.81;


%% OptimumT License and COM handle
A = exist('h', 'var');
if A == 0
    h = actxserver('OptimumT.Calculations');
end

%% Generate a MMD for this vehicle
brange = 10;
beps = 1;

drange = 20;
deps = 1;

[betas, deltas] = meshgrid(-brange:beps:brange, -drange:deps:drange);
% [betas, deltas] = meshgrid(0, 0);
% deltas = deltas + betas;

% MMD
mmds = [];
speeds = [16.667];
mph2mps = 0.44704;

tic;
for s = 1:length(speeds)
    velocity = speeds(s); % m/s
    [out1] = MMD_CN_Ay(REV1, env, betas, deltas, velocity, h, 0);
    toc;
    [out2] = MMD_CN_Ay(REV1_aero, env, betas, deltas, velocity, h, 0);
    toc;
    [out3] = MMD_CN_Ay(REV2_LC0, env, betas, deltas, velocity, h, 0);
    toc;
    [out4] = MMD_CN_Ay(REV2_R25B, env, betas, deltas, velocity, h, 0);
    toc;

    mmds = [mmds, [out1; out2; out3; out4]];
end


%% Plotting
% plot_MMD(mmds, 11, 0);
%%
% plot_MMD([out1], 12, 0);
out = analyze_MMD(mmds);
out.max_untrimmed_ay(:,:,1)
bsxfun(@rdivide, out.max_untrimmed_ay(:,:,1), out.max_untrimmed_ay(1,:,1))

out.max_trimmed_ay(:,:,1)
bsxfun(@rdivide, out.max_trimmed_ay(:,:,1), out.max_trimmed_ay(1,:,1))

%%
close all;
for ii = 1:4
    plot_MMD(mmds(:,ii), 10+ii, 0);
    axis([-2, 2, -1, 1]);
end


%%
% figure(13); clf;
% hold on; grid on; 
% plot(squeeze(out.trimmed_ay(1,1,1,:)), squeeze(out.trimmed_ay(1,1,4,:)), '.')
% xlabel('Ay [G]');
% ylabel('Body Slip Angle [deg]');
% title('Trimmed Sideslip');
% 
% figure(14); clf;
% hold on; grid on; 
% plot(squeeze(out.trimmed_ay(1,1,1,:)), squeeze(out.trimmed_ay(1,1,5,:)), '.')
% xlabel('Ay [G]');
% ylabel('Body Steer Angle [deg]');
% title('Trimmed Steer');

