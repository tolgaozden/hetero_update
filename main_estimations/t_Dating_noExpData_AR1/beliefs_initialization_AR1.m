clear;clc;close all;
dynare NKPC_REE_Estimation;
dataset=oo_.endo_simul;
clearvars -except dataset;

yy_lag=dataset(1,1:end-1)';
yy=dataset(1,2:end)';
pinf_lag=dataset(2,1:end-1)';
pinf=dataset(2,2:end)';
cc=ones(length(yy_lag),1);

regr=([cc yy_lag]'*[cc yy_lag])^(-1)*([cc yy_lag]'*yy);
alpha_y=regr(1);beta_y=regr(2);
regr=([cc pinf_lag]'*[cc pinf_lag])^(-1)*([cc pinf_lag]'*pinf);
alpha_pinf=regr(1);beta_pinf=regr(2);

rr_y=([cc yy_lag]'*[cc yy_lag])/length(yy_lag);
rr_pinf=([cc pinf_lag]'*[cc pinf_lag])/length(pinf_lag);

alpha_init = [alpha_y alpha_pinf 0];
beta_init =diag( [beta_y beta_pinf 0]);
rr_init = repmat(eye(2),[1 1 2]);
rr_init(:,:,1) = rr_y; 
rr_init(:,:,2) = rr_pinf; 

save AR1_initial_beliefs.mat alpha_init beta_init rr_init;