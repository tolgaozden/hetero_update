clear classes;
clc;
close all;
load('us_dataset_survey.mat'); 
rng(1);
dataset=[gap_detrend2,pinfobs,robs];
dataset=dataset(4:end,:);
 data_start='1982q2';
dataset=ts(data_start,dataset,{'gap_detrend2','pinfobs','robs'});
enddate=obs2date(data_start,size(dataset,1));
vnames=dataset.varnames;

% clear classes;
% clc;
% close all;
% load('full_dataset.mat'); 
% rng(1);
% dataset=[gap_cbo,pinfobs,robs];
% dataset=dataset(44:end,:);
% data_start='1966q2';
% dataset=ts(data_start,dataset,{'gap_cbo','pinfobs','robs'});
% enddate=obs2date(data_start,size(dataset,1));
% vnames=dataset.varnames;

% clear classes;
% clc;
% close all;
% load('final_dataset.mat'); 
% rng(1);
% dataset=[gap_detrend2_us,pinfobs_us,robs_us];
% dataset=dataset(64:end,:);
% data_start='1966q2';
% dataset=ts(data_start,dataset,{'gap_cbo','pinfobs','robs'});
% enddate=obs2date(data_start,size(dataset,1));
% vnames=dataset.varnames;

options=optimset('TolFun',10e-4,'TolX',10e-4,'Display','iter','UseParallel',true,'MaxIter',9999999,'MaxFunEvals',9999);

mm=rise('nkpc_estimation_ms_lagged.rs','data',dataset,...
 'estim_start_date',obs2date(data_start,1),...
 'kf_presample',3,'kf_init_variance',10,...
  'steady_state_imposed',true,'steady_state_unique',false,'optimset',options,...
  'kf_filtering_level',0,'solve_check_stability',true);
%mm=solve(mm);
%mm.print_solution;
 mm=estimate(mm);
[objective,lb,ub,x0,SIG]=pull_objective(mm);
 draws_mcmc = 250000;
 ndraws_burnin = floor(0.2*draws_mcmc);
 mcmc_options=struct('burnin',ndraws_burnin,'N',draws_mcmc,'thin',1); %/,'thin',1
zResults=mh_sampler(objective,lb,ub,mcmc_options,x0,SIG);
%mm=set(mm,'data',dataset,'estim_end_date',enddate);


%mm=estimate(mm);


%plot_priors(mm)
% plot_posteriors(m,Results.pop)
% plot_priors_and_posteriors(m,Results.pop)



 save('nkpc_estimation_results_march15.mat');