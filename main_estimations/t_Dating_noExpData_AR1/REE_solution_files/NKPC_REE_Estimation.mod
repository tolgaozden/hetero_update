var y pi r u_y u_pi;
varexo eps_y eps_pi eps_r;
parameters y_bar pi_bar r_bar kappa tau phi_pi phi_y phi_dy rho_y rho_pi rho_r iota_y iota_p;

y_bar=0;
pi_bar=0.4;
r_bar=0.7;
 kappa= 0.00588303564312093; 
tau= 2.6376376636598;
 phi_pi= 1.47216909623833; 
phi_y = 0.0866513128636564; 
phi_dy = 0.121768044002484;
rho_r =0.939996619054617; 
rho_y =0.633820220735662; 
rho_pi =0.0525487901175443; 
iota_y= 0.534636246394045;
iota_p=0.193584431292423;

shocks;
var eps_y ; stderr  0.312975868173658;
var eps_pi; stderr 0.0799885597155151;
var eps_r ; stderr  0.114062909833523;
end;




model(linear);
#beta=0.99;

y=(1-iota_y)*y(+1)+iota_y*y(-1)-(1/tau)*(r-pi(+1))+u_y;
pi=beta* ((1-iota_p)*pi(+1)+iota_p*pi(-1))+kappa*y+u_pi;
//r=phi_pi*pi+phi_y*y+eps_r;
r=rho_r*r(-1)+(1-rho_r)*(phi_pi*pi+phi_y*y)+eps_r+phi_dy*(y-y(-1));
u_y=rho_y*u_y(-1)+eps_y;
u_pi=rho_pi*u_pi(-1)+eps_pi;
end;
//resid(1);
//steady;


/*
estimation(datafile=us_dataset_survey,
mode_file='NKPC_REE_Estimation_mode.mat',
mode_compute=7,
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
mh_replic=00000,mh_jscale=0.28,mh_drop=0.2,bayesian_irf)y,pi,r;*/


stoch_simul(ar=10,irf=40,nograph);

