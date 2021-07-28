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
car = REV2_car();
speeds = [10 15 20 25]; %speeds to run [m/s]
sp = {...
      %'t_mean',                {44:.5:48};...
      %'t_rear_offset',         {-1:.25:1};...
      %'wb',                    {60:.2:62};...
      %'h',                     {9:.25:12};...
      %'w',                     {[365:10:445] + 150};...
      %'camber_static(1)',      {-3:1:1};...
      %'camber_static(2)',      {-3:1:1};...
      %'toe_static(1)',         {-1:.125:1};...
      %'toe_static(2)',         {-1:.125:1};...
      %'camber_roll_gain(1)',   {0:1:3};...
      %'camber_roll_gain(2)',   {0:1:3};...
      %'camber_steer_gain',     {0:.025:.25};...
      %'N_mag',                 {.40:.05:.60};...
      'roll_grad',             {1};...
      %'pressure',              {8:1:12};...
      %'steer_linear_m',        {[.1:.2:1.9] .* .0067}
      };
nspeeds = size(speeds,2);
nparams = size(sp,1);
s = zeros(nparams,2);
ncars = 1;
for c = 1:nparams
    s(c,:) = size(sp{c,2}{1});
    ncars = ncars*s(c,1)*s(c,2);
end
disp([num2str(ncars) ' cars to run at ' num2str(nspeeds) ' speeds.'])
keyboard;
disp('---Building Parameters---');
P = zeros(nparams,ncars*nspeeds);
for ii = 1:nparams
    aa = repmat(sp{ii,2}{1},ncars/prod(s(1:ii,2)),1,nspeeds);
    bb = reshape(permute(aa,[3 1 2]),1,[]);
    P(ii,:) = repmat(bb,1,ncars/prod(s(ii:end,2)));
end
disp('--- Building cars ---');


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

mph2mps = 0.44704;

mmd = MMD_CN_Ay(car, env, betas, deltas, speeds(1), h, 0);
disp('child mmd computed');

mmds = repmat(mmd, [ncars*nspeeds, 1]);
disp('mmd storage preallocated');

ts = zeros(ncars*nspeeds,1);
for jj = 1:(ncars*nspeeds)
    tic;
    
    for ll = 1:nparams
        %car.(sp{ll,1}) = P(ll,ii);
        eval(['car.' sp{ll,1} ' = P(ll,jj);']);
    end
    
    kk = mod(jj-1, nspeeds)+1;
    mmds(jj) = MMD_CN_Ay(car, env, betas, deltas, speeds(kk), h, 0);
    ts(jj) = toc;
    
    meantime = mean(ts(1:jj,1));
    carsleft = ncars*nspeeds - jj;
    timeleft = carsleft * meantime;
    disp(['Mean MMD time: ' num2str(meantime) ' - Cars Remaining: ' num2str(carsleft) ' - Time remaining: ' num2str(timeleft)]);
end


%% Plotting
% plot_MMD(mmds, 11, 0);
%%
% plot_MMD([out1], 12, 0);
out = analyze_MMD(mmds);
out.max_untrimmed_ay = permute(reshape(out.max_untrimmed_ay, [nspeeds,ncars, size(out.max_untrimmed_ay,3)]), [2,1,3]);
out.max_trimmed_ay = permute(reshape(out.max_trimmed_ay, [nspeeds,ncars, size(out.max_untrimmed_ay,3)]), [2,1,3]);
out.trimmed_ay = permute(reshape(out.trimmed_ay, [nspeeds,ncars, size(out.trimmed_ay,3), size(out.trimmed_ay,4)]), [2,1,3,4]);


%% Sensitivity Plots
% close all;
% sc = cumsum(s(:,2));
% curridx = 1;
% for ii = 1:size(s,1)
%     figure(20+ii); hold on;
%     title(sp{ii,1});
%     plot(sp{ii,2}{1}, out.max_trimmed_ay(curridx:curridx+s(ii,2)-1,:,1), '.-');
%     curridx = curridx + s(ii,2);
% end

figure();
nmax = 2;
[~,I] = sort(out.max_untrimmed_ay(:,nspeeds,1),'descend'); %max Ay at max speed

for ii = 1:nmax 
    pos = I(ii);
    disp([ 'Max ' num2str(ii) ': ' num2str(out.max_untrimmed_ay(pos,nspeeds,1)) ' G'])
    for jj = 1:nparams
        subplot(nmax,nparams,nparams*(ii-1)+jj)
        c = 1:nparams;
        c(jj) = [];
        [~,ind1] = ismember(P(c,pos*nspeeds)',P(c,:)','rows');
        ind1 = (ind1-1)/nspeeds + 1;
        q = ceil(prod(s(jj:end,2))/s(jj,2)/nspeeds);
        ind = ((1:s(jj,2))-1)*q+ind1;
        for nn = 1:nspeeds
            plot(cell2mat(sp{jj,2}),out.max_untrimmed_ay(ind,nn,1));
            hold on
        end
        plot(P(jj,pos*nspeeds),out.max_untrimmed_ay(pos,nspeeds,1),'r.')
        title(sp{jj,1})
        grid on
    end
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


