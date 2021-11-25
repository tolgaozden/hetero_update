 %output/input variables:                        [shadow_rate{ii,jj},Q_tv{ii,jj}(tt)]=calculate_sgadow_rate(shadow_rate{ii,jj},model,sysmat,parameters,S_upd_all{ii,jj},tt,...
 %                             THETA1,PHI1,THETA2,PHI2);


function [shadow_rate,QQ]=calculate_shadow_rate(shadow_rate,parameters,SS,vv,tt,THETA1,PHI1,THETA2,PHI2)


%retrieve normal regime (Taylor rule) parameters
r_pi=parameters(6,1); %6 
rho=parameters(10,1); % 10
r_x=parameters(7,1);%7
r_bar=parameters(3,1);
pi_bar = parameters(2,1);
x_bar = parameters(1,1);

%retrieve output gap/inflation/interest rate
xx_tt=SS(tt,1);%+x_bar;
xx_prev=SS(tt-1,1);%+x_bar;
pi_tt=SS(tt,2);%+pi_bar;
rr_prev=SS(tt-1,3);%+r_bar;
eps_r_tt = vv(tt,3);



%without MP shocks
shadow_rate(tt)=rho*shadow_rate(tt-1)+(1-rho)*(r_pi*pi_tt+r_x*xx_tt);
%with MP shocks
%shadow_rate(tt)=rho*shadow_rate(tt-1)+(1-rho)*(r_pi*pi_tt+r_x*xx_tt)+eps_r_tt;

%  q_11=THETA1/(THETA1+exp(-PHI1*(shadow_rate(tt))));
%  q_22=THETA2/(THETA2+exp(+PHI2*(shadow_rate(tt))));
q_11=THETA1/(THETA1+exp(-PHI1*(shadow_rate(tt)+r_bar)));
q_22=THETA2/(THETA2+exp(+PHI2*(shadow_rate(tt)+r_bar)));

QQ = [q_11, 1-q_11; 1-q_22 , q_22];

end