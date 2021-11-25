function[AA BB CC DD RHO] = NKPC_sysmat_REE(param)

y_bar=param(1); pi_bar=param(2);  r_bar=param(3);  
gamma=param(4);  tau=param(5);  phi_pinf=param(6);  phi_y=param(7); phi_dy = param(8);
 rho_y=param(9);  rho_pinf=param(10);  rho_r=param(11);  
 eps_y=param(12);  eps_pinf=param(13);  eps_r=param(14); iota_y=param(15);iota_p=param(16);
 
 

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