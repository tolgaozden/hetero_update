% load nkpc_estimation_results_march15.mat;
load nkpc_estimation_results_march15.mat;

%rewrite parameter order in line with the AL estimation results
param_order=[3 4 5 7 8 9 10 11 12 15 16 17 18 13 14 6 19 1 2];

x=mm.estimation.posterior_maximization.mode;
x=x(param_order);
x=round(x,2);

st_dev=mm.estimation.posterior_maximization.mode_stdev;
st_dev=st_dev(param_order);
st_dev=round(st_dev,3);

laplace_=mm.estimation.posterior_maximization.log_marginal_data_density_laplace;

output=round(x,2);
  output_file='Estimation_Results.csv';
 output_sheet='Estimation_Results';
%  xlswrite(output_file,priorMean,output_sheet,'c15');
%  xlswrite(output_file,priorStd,output_sheet,'d15');
 xlswrite(output_file,output,output_sheet,'e3');
 xlswrite(output_file,st_dev,output_sheet,'f3');
 xlswrite(output_file,laplace_,output_sheet,'f24');