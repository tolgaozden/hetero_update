clear;clc;%close all;
load counterfactual_initials;
% rng(1);

para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
    'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
    'eta_y(11)','eta_pi(12)','eta_r(13)','iota_y(14)','iota_p(15)',...
    'r_bar_zlb(16)','eta_r_zlb(17)','1-p_11(18)','1-p_22(19)','gain_y(20)','memory(21)','intensity(22)'};

% load estimation_results_march15.mat;
pi_bar = parameters(1);
r_bar1 = parameters(2);
r_bar2 =parameters(16);
%simul_type: 
%1= reproduce the benchmark scenario, both gain and n1 stay at estimated
%values
%2=n1 endogenously determined (estimated case), gain is set by user
%3= n1 set by the user, gain is fixed at the estimated value
%4= both n1 and gain are set by the user

simul_LB = [-100 -100 -100 -100 ] ;
simul_UB = [ 100 100 100 100];

n1 = 0;
gain = parameters(20);
CF_start=3;
plot_start=1;
CF_length=1000;
numSimul=10;
mh_conf = 0.9;

simul_type=1;
iid_indicator=0;
T = length(S_filtered);
CF_period = [CF_start, CF_length+CF_start-1];

 seed_grid = round(5000*rand(numSimul,1))
counter_ = 0;

deflationary_index=[];
normal_index=[];

for jj=1:numSimul
      disp(jj)
seed_ = seed_grid(jj);
% gain = parameters(20);
gain = 0.01;
n1 = 0.1;
T = length(S_filtered);




[explosive_indicator,SS,PP,shadow_rate, n1,alpha1_tt,beta1_tt,pr_flag,eta_all] =...
    MC_function_rnd(simul_LB,simul_UB,n1,gain,CF_start,simul_type,CF_length,seed_,iid_indicator);

exp_ind(jj) = explosive_indicator;




if explosive_indicator ~=1
    
    
    counter_ = counter_ + 1;
    
    
P_normal_est(:,counter_) = (PP(1,:) + PP(2,:))';
P_zlb_est(:,counter_)   = (PP(3,:) + PP(4,:))';
pr_flag_est(:,counter_) = pr_flag;
SS_all_est(:,:,counter_) = SS;
n1_est(:,counter_) = n1;
shadow_rate_est(:,counter_) = shadow_rate;
eta_all_est(:,:,:,counter_) = eta_all;


  if explosive_indicator==0
       normal_index =[normal_index,counter_];
  elseif explosive_indicator==2
      deflationary_index=[deflationary_index,counter_];
  end

end


end

disp('Non-explosive Simulations Fraction in %');
disp(100*counter_/numSimul);

disp('Fraction of explosive/deflationary/discarded simulations:');
disp(length(deflationary_index)/counter_);

disp('Fraction of simulations that are kept:');
disp(length(normal_index)/counter_);


P_normal_def = P_normal_est(:,deflationary_index);
P_zlb_def = P_zlb_est(:,deflationary_index);
pr_flag_def = pr_flag_est(:,deflationary_index);
SS_def= SS_all_est(:,:,deflationary_index);
n1_def = n1_est(:,deflationary_index);
shadow_rate_def = shadow_rate_est(:,deflationary_index);

P_normal_nor = P_normal_est(:,normal_index);
P_zlb_nor = P_zlb_est(:,normal_index);
pr_flag_nor = pr_flag_est(:,normal_index);
SS_nor= SS_all_est(:,:,normal_index);
n1_nor = n1_est(:,normal_index);
shadow_rate_nor = shadow_rate_est(:,normal_index);
