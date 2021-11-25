function[AA BB CC DD RHO] = NKPC_sysmat_REE(param)

y_bar = 0;

 pi_bar=param(1);  r_bar=param(2);  
gamma=param(3);  tau=param(4);  phi_pinf=param(5);  phi_y=param(6); phi_dy = param(7);
 rho_y=param(8);  rho_pinf=param(9);  rho_r=param(10);  
 eps_y=param(11);  eps_pinf=param(12);  eps_r=param(13); iota_y=param(14);iota_p=param(15);
 

AA=[1,0,1/tau;
-gamma,1,0;
phi_y*(rho_r-1)-phi_dy,phi_pinf*(rho_r-1),1];



BB=[iota_y,0,0;
0,0.99*iota_p,0;
-phi_dy,0,rho_r];

CC=[1-iota_y,1/tau,0;
0,-0.99*(iota_p-1),0;
0,0,0];


DD=[1,0,0;
0,1,0;
0,0,1];


RHO=[rho_y,0,0;
0,rho_pinf,0;
0,0,0];


end