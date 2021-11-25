function[gamma1,gamma2,gamma3,EE,FF] = NKPC_sysmat_regime1(param,beta1,alpha1,phi_pinf_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2)
%8: shadow rate lagged on its past
%9 shadow rate lagged on observed nominal rate

y_bar = 0;

 pi_bar=param(1);  r_bar=param(2);  
gamma=param(3);  tau=param(4);  phi_pinf=param(5);  phi_y=param(6); phi_dy = param(7);
 rho_y=param(8);  rho_pinf=param(9);  rho_r=param(10);  
 eps_y=param(11);  eps_pinf=param(12);  eps_r=param(13); iota_y=param(14);iota_p=param(15);
 
 
alpha_1 = alpha1(1);
alpha_2 = alpha1(2);

beta11 = beta1(1,1);
beta12 = beta1(1,2);
beta13 = beta1(1,3);
beta21 = beta1(2,1);
beta22 = beta1(2,2);
beta23 = beta1(2,3);
beta31 = beta1(3,1);
beta32 = beta1(3,2);
beta33 = beta1(3,3);

    
AA1= [1,0,1/tau,-1,0,iota_y-1,-1/tau,0,0;
 -gamma,1,0,0,-1,0,0.99*(iota_p-1),0,0;
 phi_y*(rho_r-1)-phi_dy,phi_pinf*(rho_r-1),1,0,0,0,0,0,0;
 0,0,0,1,0,0,0,0,0;
 0,0,0,0,1,0,0,0,0;
 -beta11,-beta12,-beta13,0,0,1,0,0,0;
 -beta21,-beta22,-beta23,0,0,0,1,0,0
 phi_y_taylor*(rho_r_taylor-1)-phi_dy_taylor,phi_pinf_taylor*(rho_r_taylor-1),0,0,0,0,0,1,0;
 phi_y_taylor*(rho_r_taylor-1)-phi_dy_taylor,phi_pinf_taylor*(rho_r_taylor-1),0,0,0,0,0,0,1];





% if tt>zlb_threshold && tt<zlb_threshold2
%     
% BB1= [iota_y,0,0,0,0,0,0,0,0;
%  0,99/100*iota_p,0,0,0,0,0,0,0;
%  -phi_dy,0,rho_r,0,0,0,0,0,0;
%  0,0,0,rho_y,0,0,0,0,0;
%  0,0,0,0,rho_pinf,0,0,0,0;
%   0,0,0,0,0,0,0,0,0;
%  0,0,0,0,0,0,0,0,0;
%  -phi_dy_taylor,0,0,0,0,0,0,rho_r_taylor,0;
%  -phi_dy_taylor,0,0,0,0,0,0,0,rho_r_taylor];
% 
% else
    
BB1= [iota_y,0,0,0,0,0,0,0,0;
 0,99/100*iota_p,0,0,0,0,0,0,0;
 -phi_dy,0,rho_r,0,0,0,0,0,0;
 0,0,0,rho_y,0,0,0,0,0;
 0,0,0,0,rho_pinf,0,0,0,0;
  0,0,0,0,0,0,0,0,0;
 0,0,0,0,0,0,0,0,0;
 -phi_dy_taylor,0,0,0,0,0,0,rho_r_taylor,0;
 -phi_dy_taylor,0,rho_r_taylor,0,0,0,0,0,0];



% end

CC1=[0,0,0;
 0,0,0;
 0,0,1;
 1,0,0;
 0,1,0;
 0,0,0;
 0,0,0;
 0,0,0;
 0,0,0];


% if tt>zlb_threshold && tt<zlb_threshold2
% alpha_all = [0 0 0 0 0 alpha_1 alpha_2,-(1-rho_r_taylor)*(r_bar1-r_bar2),-(1-rho_r_taylor)*(r_bar1-r_bar2)]';


% else
alpha_all = [0 0 0 0 0 alpha_1 alpha_2,0,0]';

% end

% alpha_all(3) = r_bar * (1-rho_r) - (1-rho_r) * phi_pinf * pi_bar  - (1-rho_r) * phi_y * y_bar;
% alpha_all(8) = r_bar * (1-rho_r) - (1-rho_r) * phi_pinf * pi_bar  - (1-rho_r) * phi_y * y_bar;
% alpha_all(9) = r_bar * (1-rho_r) - (1-rho_r) * phi_pinf * pi_bar  - (1-rho_r) * phi_y * y_bar;

gamma1=AA1\BB1;
gamma2=AA1\alpha_all;
gamma3=AA1\CC1;


EE=[y_bar;pi_bar;r_bar];
% EE=zeros(3,1);
FF=[1,0,0,0,0,0,0,0,0;
         0,1,0,0,0,0,0,0,0;
         0,0,1,0,0,0,0,0,0];
     
     
%   gamma1=gamma1(1:7,1:7);
%   gamma2 = gamma2(1:7);
%   gamma3=  gamma3(1:7,:);
%   FF = FF(:,1:7);
end