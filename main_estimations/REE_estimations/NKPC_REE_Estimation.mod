var y pi r u_y u_pi 
    gap_detrend2 pinfobs robs; 
varexo eps_y eps_pi eps_r;
parameters y_bar pi_bar r_bar kappa tau phi_pi phi_y phi_dy rho_y rho_pi rho_r iota_y iota_p;

y_bar=0;pi_bar=0;r_bar=0; kappa= 0.0121 ; tau=2.6414; phi_pi=1.5574; phi_y = 0.2889; rho_r =0.9073; rho_y =0.3742 ; rho_pi =0.3256; 
iota_y=0;iota_p=0;

shocks;
var eps_y ; stderr 0.7396;
var eps_pi; stderr 0.2986 ;
var eps_r ; stderr 0.2991 ;
end;

estimated_params;
//y_bar,-0.2,-2,2,UNIFORM_PDF,0,2;
pi_bar,0.7,-2,2,UNIFORM_PDF,0,2;
r_bar,0.9,-2,2,UNIFORM_PDF,0,2;
kappa,0.1,0,1,BETA_PDF,0.05,0.025;
tau,5,0,10,GAMMA_PDF,2,0.5;
phi_pi,1.5,0,10,GAMMA_PDF,1.5,0.25;
phi_y,0.5,0,10,GAMMA_PDF,0.25,0.1;
phi_dy,0.25,0,1,GAMMA_PDF,0.25,0.1;
rho_pi,0.5,0,1,BETA_PDF,0.5,0.2;
rho_y,0.5,0,1,BETA_PDF,0.5,0.2;
rho_r,0.5,0,1,BETA_PDF,0.5,0.2;
stderr eps_y,0.07,0.01,3,INV_GAMMA_PDF,0.1,2;
stderr eps_pi,1,0.01,3,INV_GAMMA_PDF,0.1,2;
stderr eps_r,0.4,0.01,3,INV_GAMMA_PDF,0.1,2;
iota_y,0.25,0,1,BETA_PDF,0.25,0.1;
iota_p,0.25,0,1,BETA_PDF,0.25,0.1;
end;
varobs gap_detrend2 pinfobs robs;



model(linear);
#beta=0.99;

y=(1-iota_y)*y(+1)+iota_y*y(-1)-(1/tau)*(r-pi(+1))+u_y;
pi=beta* ((1-iota_p)*pi(+1)+iota_p*pi(-1))+kappa*y+u_pi;
//r=phi_pi*pi+phi_y*y+eps_r;
r=rho_r*r(-1)+(1-rho_r)*(phi_pi*pi+phi_y*y)+eps_r+phi_dy*(y-y(-1));
u_y=rho_y*u_y(-1)+eps_y;
u_pi=rho_pi*u_pi(-1)+eps_pi;
gap_detrend2 = y_bar+y;
1*pinfobs=pi_bar+pi;
1*robs=r_bar+r;
end;
//resid(1);
//steady;


estimation(datafile=us_dataset_survey,
mode_file='NKPC_REE_Estimation_mode.mat',
mode_compute=5,
//dsge_var=1,
nograph,nodiagnostic,
//optim=('Algorithm','active-set'),
first_obs=4,
//first_obs=100,
presample=4,
//nobs=170,
mh_nblocks=1,
//nobs=97,
//nobs=79,
//kalman_algo=1,
mh_replic=00000,mh_jscale=0.4,mh_drop=0.2,bayesian_irf)y,pi,r;
stoch_simul(ar=10,irf=40,periods=10000);
//clean_current_folder;

//set_dynare_seed('clock') ;

