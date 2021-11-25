function[beta_init,rr_init,bb,dd,gamma1,gamma3,gam0_rec,gam1_rec,rho_rec,rho_shock]=REE_initialize_beliefs(param,sigma)
%beta_init: initial coefficient matrix for VAR(1) system
%rr_init: initial covar matrix for VAR(1) system
%bb: REE system matrix on lagged variables
%dd: REE system matrix on AR(1) shocks
%gamma1: recursive system matrix on lagged variables
%gamma3: recursive system matrix on iid shocks
%gam0_rec: recursive system var-covar matrix
%gam1_rec: recursive system first order autocovar matrix
%rho_rec: recursive system first order autocorrelation matrix


% solve for the REE consistent with the normal regime


[A_ree B_ree C_ree D_ree RHO_ree] = NKPC_sysmat_REE(param);

try 
         [bb,dd,gam0_eps,gamma1,gamma3,gam0_rec,gam1_rec,rho_rec]= MSV_solution(A_ree,B_ree, C_ree, D_ree, RHO_ree,sigma);
%function[bb,dd,gam0_eps,gamma1,gamma3,gam0_rec,gam1_rec,rho_rec,RHO]=REE_solve_uhlig(AA,BB,CC,DD,RHO,SIGMA)

catch
    load REE_solution_backup.mat;
end
    

fl_indices= [1 2 3]; 
bl_indices=[1 2 3];

rr_init=zeros(2,2,2);
rr_init(1,1,1)=1;
rr_init(1,1,2)=1;
rr_init(1,1,3)=1;


rr_init(2:4,2:4,1) = gam0_rec(fl_indices,bl_indices);
rr_init(2:4,2:4,2) = gam0_rec(fl_indices,bl_indices);
rr_init(2:4,2:4,3) = gam0_rec(fl_indices,bl_indices);

beta_init = (gam0_rec(1:3,1:3)')\(gam1_rec(1:3,1:3)');

rho_shock=RHO_ree;
%-------------------------------------------------------------
%REE solution consistent with the active Taylor rule model
% X_t = gam1_REE * X_{t-1} + gam3_REE * eps_t ;
% eps_t = RHO* eps_{t-1} + eta_t;

%gam1_REE and gam3_REE used for agents belief model