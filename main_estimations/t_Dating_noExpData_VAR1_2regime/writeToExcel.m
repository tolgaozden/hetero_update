clear;clc;close all;
load mcmc_results_final.mat;


para_names = {'pi_bar','r_bar','kappa','tau',...
    'phi_pi','phi_y','phi_dy','rho_y','rho_pi','rho_r',...
    'eta_y','eta_pi','eta_r','iota_y','iota_p',...
    'r_bar_zlb','eta_r_zlb','1-p_11','1-p_22','gain_y'};

st_dev = sqrt(diag(H));
Nburn= round(0.4*Ndraws);

MHM_density= MHM_calculator(numVar,Ndraws,Nburn,posteriorDraws,posteriorMean,logposterior,fh);
MHM_density = -MHM_density(9,2);

posteriorMean = posteriorMean';
para_names = para_names';
MHM_density = round(MHM_density,3);
laplace_ = round(laplace_,3);
table(para_names,mode,st_dev, posteriorMean, hpd_interval)

disp('Laplace Approximation:');
disp(laplace_); 

disp('MHM Estimator');
disp(MHM_density);


%write table to excel

st_dev=round(sqrt(diag(H)),3);
mode=round(mode,3);
posteriorMean = round(posteriorMean,3);
hpd_interval= round(hpd_interval,3);


 output_file='Estimation_Results.csv';
 output_sheet='Estimation_Results';
 
 column_names = {'Para.', 'Post. Mode', 'St. Dev at Mode',' Post. Mean', '90 % HPD', 'Interval', 'Laplace', 'MHM'};
 
  xlswrite(output_file,column_names(1),output_sheet,'a1');
 xlswrite(output_file,para_names,output_sheet,'a2');
 
 xlswrite(output_file,column_names(2),output_sheet,'b1');
 xlswrite(output_file,mode,output_sheet,'b2');
 
 xlswrite(output_file,column_names(3),output_sheet,'c1');
 xlswrite(output_file,st_dev,output_sheet,'c2');
 
 xlswrite(output_file,column_names(4),output_sheet,'d1');
 xlswrite(output_file,posteriorMean,output_sheet,'d2');
 
  xlswrite(output_file,column_names(5),output_sheet,'e1');
xlswrite(output_file,column_names(6),output_sheet,'f1');
xlswrite(output_file,hpd_interval,output_sheet,'e2');
 
xlswrite(output_file,column_names(7),output_sheet,'a25');
xlswrite(output_file,laplace_,output_sheet,'b25');

xlswrite(output_file,column_names(8),output_sheet,'a26');
xlswrite(output_file,MHM_density,output_sheet,'b26');