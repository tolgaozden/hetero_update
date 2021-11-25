function [prior]=NKPC_prior(param)
% para_names = {'y_bar(1)','pi_bar(2)','r_bar(3)','kappa(4)','tau(5)',...
%     'phi_pi(6)','phi_y(7)','phi_dy(8)','rho_y(9)','rho_pi(10)','rho_r(11)',...
%     'eta_y(12)','eta_pi(13)','eta_r(14)','iota_y(15)','iota_p(16)',...
%     'r_bar_zlb(17)','eta_r_zlb(18)','1-p_11(19)','1-p_22(20)','gain(21)'};


% y_bar=normpdf(param(1),0,0.25);
% y_bar = unifpdf(param(1),-2,2);
% mu=0.62;sigma2=0.25^2;b  = sigma2/mu;a  = mu/b;
% pi_bar=gampdf(param(2),a,b);
pi_bar = unifpdf(param(1),-2,2);
% mu=1;sigma2=0.25^2;b  = sigma2/mu;a  = mu/b;
% r_bar=gampdf(param(3),a,b);
r_bar = unifpdf(param(2),-2,2);

mu=0.05;sigma2=0.025^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
kappa= betapdf(param(3),a,b);
mu=2;sigma2=0.5^2;b  = sigma2/mu;a  = mu/b;
tau=gampdf(param(4),a,b);
mu=1.5;sigma2=0.25^2;b  = sigma2/mu;a  = mu/b;
phi_pi=gampdf(param(5),a,b);

mu=0.25;sigma2=0.1^2;b  = sigma2/mu;a  = mu/b;
phi_y=gampdf(param(6),a,b);

mu=0.25;sigma2=0.1^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
phi_dy=gampdf(param(7),a,b);


mu=0.5;sigma2=0.2^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
rho_y= betapdf(param(8),a,b);
mu=0.5;sigma2=0.2^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
rho_pi= betapdf(param(9),a,b);
mu=0.75;sigma2=0.1^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
rho_r= betapdf(param(10),a,b);
[s,nu] = inverse_gamma_specification(0.1,4, 0,1, false, 'name');
eta_y= exp(lpdfig1(param(11),s,nu));
eta_pi= exp(lpdfig1(param(12),s,nu));
eta_r= exp(lpdfig1(param(13),s,nu));


mu=0.25;sigma2=0.1^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
iota_y= betapdf(param(14),a,b);
mu=0.25;sigma2=0.1^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
iota_p= betapdf(param(15),a,b);

r_bar_zlb=normpdf(param(16),0.1,0.25);
% 
% mu=0.03;sigma2=0.005^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
% prior15=  betapdf(param(15),a,b);
eta_r_zlb=unifpdf(param(17),0.005,0.05);
% mu=0.02;sigma2=0.01^2;b  = sigma2/mu;a  = mu/b;
% prior15=gampdf(param(15),a,b);

 
%  mu=0.1;sigma2=0.05^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
%  prior18=betapdf(param(18),a,b);

% minus_p11=unifpdf(param(19),0,1);

%    mu=0.3;sigma2=0.1^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
%  prior19=betapdf(param(19),a,b);

% minus_p22=unifpdf(param(20),0,1);
 
mu=0.2;sigma2=0.1^2;b  = sigma2/mu;a  = mu/b;
PHI1=gampdf(param(18),a,b);

mu=0.2;sigma2=0.1^2;b  = sigma2/mu;a  = mu/b;
PHI2=gampdf(param(19),a,b);
 
 mu=0.035;sigma2=0.015^2;b  = sigma2/mu;a  = mu/b;
gain_y=gampdf(param(20),a,b);
% 
%  mu=0.035;sigma2=0.015^2;b  = sigma2/mu;a  = mu/b;
% gain_pinf=gampdf(param(21),a,b);

%  mu=0.035;sigma2=0.015^2;b  = sigma2/mu;a  = mu/b;
%gain_r=gampdf(param(25),a,b);
% prior18=unifpdf(param(18),0.0001,0.1);
%    mu=0.05;sigma2=0.01^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
%   prior18=betapdf(param(18),a,b);
%  prior19=betapdf(param(19),a,b);
%prior18=unifpdf(param(18),0,0.05);


% mu=0.5;sigma2=0.2^2;a = (1-mu)*mu*mu/sigma2-mu;b = a*(1/mu-1);
% memory= betapdf(param(22),a,b);
% 
% 
% mu=5;sigma2=2^2;b  = sigma2/mu;a  = mu/b;
% intensity=gampdf(param(23),a,b);


prior=pi_bar*r_bar*kappa*tau*phi_pi*phi_y*phi_dy*rho_y*rho_pi*...
    rho_r*eta_y*eta_pi*eta_r*iota_y*iota_p*r_bar_zlb*eta_r_zlb*gain_y*PHI1*PHI2;%*memory*intensity*gain_pinf;
prior=-log(prior);
%not included: 
%y_bar**gain_r

%minus_p11*minus_p22*


% para_names = {'y_bar(1)','pi_bar(2)','r_bar(3)','kappa(4)','tau(5)',...
%     'phi_pi(6)','phi_y(7)','phi_dy(8)','rho_y(9)','rho_pi(10)','rho_r(11)',...
%     'eta_y(12)','eta_pi(13)','eta_r(14)','iota_y(15)','iota_p(16)',...
%     'r_bar_zlb(17)','eta_r_zlb(18)','1-p_11(19)','1-p_22(20)','gain(21)'};
end