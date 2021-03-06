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
R25B_180_75_10_7 = 'GAAAAAAAAIAAAAAAEDBJAJEMCOMPNGODFOANCDBEMIIJBKHEFIDJDLPDICEEOCAMHFPDNJODNGJDJIBEMALHMIODCHFLIFOLBEHNAIOLPIEHOIAEMCBKDACELHAAFLPDPOMFCPBEMEHNBBLLJGNAJJKLHLCOGNNLABNKADMDHLABOLMDIBIKEGPLPLKJDGAMJHOOJBODHCECEFPDNLCOEJOLIGLKOPPLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';


%% Construct Cars
REV3 = REV3_car();

sp = {...
      't_mean',                {44:1:48};...
      't_rear_offset',         {-1:.5:1};...
      'wb',                    {60:.2:62};...
      'h',                     {9:.25:12};...
      'w',                     {[365:10:445] + 150};...
      'camber_static(1)',      {-3:.25:1};...
      'camber_static(2)',      {-3:.25:1};...
      'toe_static(1)',         {-1:.125:1};...
      'toe_static(2)',         {-1:.125:1};...
      'camber_roll_gain(1)',   {-2:.25:2};...
      'camber_roll_gain(2)',   {-2:.25:2};...
      'camber_steer_gain',     {0:.05:.25};...
      'N_mag',                 {.40:.01:.60};...
      'roll_grad',             {0:.125:2};...
      'pressure',              {8:.5:12};...
      'steer_linear_m',        {[.1:.2:1.9] .* .0067}
      };

s = zeros(size(sp,1),2);
for ii = 1:size(sp,1)
    s(ii,:) = size(sp{ii,2}{1});
end

disp('--- Building cars ---');
numcars = sum(s(:,2));
cars = repmat(REV3, [numcars, 1]);
ii = 1;
for jj = 1:size(s,1)
    for kk = 1:s(jj,2)
        eval(['cars(ii).' sp{jj,1} ' = sp{jj,2}{1}(kk);']);
        ii = ii + 1;
    end
end
disp([num2str(numcars) ' cars built']);


%% Construct Environment
env.mu = .6;
env.rho_air = 1.162; % kg/m^3
env.g = 9.81;


%% OptimumT License and COM handle
A = exist('h', 'var');
if A == 0
    h = actxserver('OptimumT.Calculations');
end

%% Generate a MMD for this vehicle
disp('--- Generating MMDs ---');
brange = 10;
beps = 1;

drange = 20;
deps = 1;

[betas, deltas] = meshgrid(-brange:beps:brange, -drange:deps:drange);
% deltas = deltas + betas;

% MMDs
speeds = [10 15 20 25];
mph2mps = 0.44704;

mmd = MMD_CN_Ay(cars(1), env, betas, deltas, speeds(1), h, 0);
disp('child mmd computed');
x = size(cars(:), 1);
y = size(speeds(:), 1);
mmds = repmat(mmd, [x*y, 1]);
disp('mmd storage preallocated');

ts = zeros(numcars,1);
for jj = 1:(x*y)
    tic;
    ll = ceil(jj/y);
    carsjj = cars(ll);
    kk = mod(jj-1, y)+1;
    mmds(jj) = MMD_CN_Ay(carsjj, env, betas, deltas, speeds(kk), h, 0);
    ts(jj) = toc;
    
    meantime = mean(ts(1:jj,1));
    carsleft = x*y - jj;
    timeleft = carsleft * meantime;
    disp(['Mean MMD time: ' num2str(meantime) ' - Cars Remaining: ' num2str(carsleft) ' - Time remaining: ' num2str(timeleft)]);
end

%% Plotting
% plot_MMD(mmds, 11, 0);
%%
% plot_MMD([out1], 12, 0);
out = analyze_MMD(mmds);
out.max_untrimmed_ay = permute(reshape(out.max_untrimmed_ay, [y,x, size(out.max_untrimmed_ay,3)]), [2,1,3]);
out.max_trimmed_ay = permute(reshape(out.max_trimmed_ay, [y,x, size(out.max_untrimmed_ay,3)]), [2,1,3]);
out.trimmed_ay = permute(reshape(out.trimmed_ay, [y,x, size(out.trimmed_ay,3), size(out.trimmed_ay,4)]), [2,1,3,4]);


%% Sensitivity Plots
close all;
figure(); 
sc = cumsum(s(:,2));
curridx = 1;
subrows = 4;
for ii = 1:size(s,1)
    subplot(subrows,ceil(size(s,1)/subrows),ii)
    hold on;
    title(sp{ii,1});
    plot(sp{ii,2}{1}, out.max_trimmed_ay(curridx:curridx+s(ii,2)-1,:,1), '.-');
    grid on;
    curridx = curridx + s(ii,2);
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


