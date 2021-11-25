endogenous y pinf r u_y u_pi gap_detrend2 pinfobs robs
observables gap_detrend2 pinfobs robs 
exogenous eps_y eps_pi eps_r 
parameters beta y_bar pi_bar kappa tau rho_y rho_pi sig_pi sig_y r_bar iota_y iota_p r_bar_zlb
parameters(coef,2) phi_pi phi_y phi_dy rho_r sig_r czlb 
parameters coef_tp_1_2, coef_tp_2_1

model


y=(1-iota_y)*y(+1)+iota_y*y(-1)-(1/tau)*(r-pinf(+1))+u_y;
pinf=beta*((1-iota_p)*pinf(+1)+ iota_p*pinf(-1))+kappa*y+u_pi;
r=rho_r*r(-1)+(1-rho_r)*(phi_pi*pinf+phi_y*y)+sig_r*eps_r-czlb*(1-rho_r)*(r_bar-r_bar_zlb) + phi_dy  * ( y - y(-1)) ; 
u_y=rho_y*u_y(-1)+sig_y*eps_y;// -czlb*(1-rho_r)*(1/tau)*(r_bar-r_bar_zlb)*(1-rho_y);
u_pi=rho_pi*u_pi(-1)+sig_pi*eps_pi;
gap_detrend2 = y_bar+y;
pinfobs=pi_bar+pinf;
robs=r_bar+r;

parameterization;
czlb(coef,1),0;
czlb(coef,2),1;
//coef_tp_1_2,0.01,0.1,0.05,beta_pdf;
//coef_tp_2_1,0.18,0.3,0.1,beta_pdf;
coef_tp_2_1,0.18,0.5,0.29,uniform_pdf;
coef_tp_1_2,0.035,0.5,0.29,uniform_pdf;
//coef_tp_2_1,0.1;
//y_bar,-0.18,0,1,uniform_pdf;
y_bar,0;
//pi_bar,0.65,0.62,0.25,gamma_pdf;
//r_bar,1.24,1,0.25,gamma_pdf;
pi_bar,0.7,0,2,uniform_pdf;
r_bar,0.82,0,2,uniform_pdf;
kappa,0.0016,0.05,0.025,beta_pdf;
tau,3.41,2,0.5,gamma_pdf;
phi_pi(coef,1),1.66,1.5,0.25,gamma_pdf;
phi_pi(coef,2),0;
phi_y(coef,1),0.13,0.25,0.1,gamma_pdf;
phi_y(coef,2),0;
phi_dy(coef,1),0.19,0.25,0.1,gamma_pdf;
phi_dy(coef,2),0;

rho_y,0.94,0.5,0.2,beta_pdf,0.01,0.99;
rho_pi,0.63,0.5,0.2,beta_pdf,0.01,0.99;
//iota_y,0;
//iota_p,0;
iota_y,0.25,0.25,0.1,beta_pdf,0.01,0.999;
iota_p,0.27,0.25,0.1,beta_pdf,0.01,0.999;
rho_r(coef,1),0.91,0.5,0.2,beta_pdf;
rho_r(coef,2),0;
sig_y,0.13,0.1,2,inv_gamma_pdf,0,99;
sig_pi,0.04,0.1,2,inv_gamma_pdf,0,99;
sig_r(coef,1),0.12,0.1,2,inv_gamma_pdf,0,99;
sig_r(coef,2),0.01,0.005,0.05,uniform_pdf,0,99;
r_bar_zlb,0.03,0.1,0.25,normal_pdf;
beta,0.99;

steady_state_model
y=0;
pinf=0;
r=-czlb*(r_bar-r_bar_zlb);;
u_y=0;
u_pi=0;
gap_detrend2=y_bar;
pinfobs=pi_bar;
robs=r_bar-czlb*(r_bar-r_bar_zlb);
