function [da,fw]=main(filename)
% clear all;
% clc;
% close all;
% function [sol,stats] = main(filename)
% input: filename of input selected by users

% Convert information from txt into a structure param
% param = readINFILE(filename);
% param.model = 'Saetrom';
% param.method = 'KF';
% param.x_std = 20;
% param.obsstd = 1; % observation STD
% param.nt = 10; % total data assimilation step
param=get_prm(filename);
param.kernel = @(h) param.x_std.*exp(-(h./(20/3)));

% TODO: add other parameters specifed by users:
% total simulation step

%% Initialization
% Map simulation parameters to FW subclass and create an object at time 0
fw = selectFW(param);
file = load('ini.mat');
fw.xt = file.xt;
% Map inversion parameters to DA subclass and create an object at time 0
da = selectDA(param,fw);

% TODO: check if fw and da contain all the necessary properties and functions after initialization
rng(100);
% for each data asismilation step

% Plot initial condition
figure;
subplot(2,1,1)
plotstate(da,fw)
title('Initial condition at step 0');

for i = 1:param.nt
    %% Run truemodel to produce true state xt and data z, save as property of fw
    % call f and h to update state and observation
    fw.step = i; % mandatory for Saetrom case
    fw.xt = fw.f(fw.xt);
    fw.zt = fw.h(fw.xt);
    noise = fw.zt_std*randn(size(fw.zt));
    fw.zt = fw.zt + noise;
    
    %% Run data assimilation to get solution x and its uncertainty, save as property of da
    % KF forecast
    da.t_forecast = i;
    da.predict(fw);
    
    % KF predict
    da.t_assim = i;
    da.update(fw,fw.zt);
    
    % save fw and da as snapshots for analysis
end

%% plot final state
% PLOT NEEDS TO BECOME EITHER A FUNCTION OR A CLASS
subplot(2,1,2)
plotstate(da,fw)
title([param.method,' mean and STD at step 10']);


end

% clear da
% clear fw