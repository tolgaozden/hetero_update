%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

if isoctave || matlab_ver_less_than('8.6')
    clear all
else
    clearvars -global
    clear_persistent_variables(fileparts(which('dynare')), false)
end
tic0 = tic;
% Save empty dates and dseries objects in memory.
dates('initialize');
dseries('initialize');
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'NKPC_REE_Estimation';
M_.dynare_version = '4.5.7';
oo_.dynare_version = '4.5.7';
options_.dynare_version = '4.5.7';
%
% Some global variables initialization
%
global_initialization;
diary off;
diary('NKPC_REE_Estimation.log');
M_.exo_names = 'eps_y';
M_.exo_names_tex = 'eps\_y';
M_.exo_names_long = 'eps_y';
M_.exo_names = char(M_.exo_names, 'eps_pi');
M_.exo_names_tex = char(M_.exo_names_tex, 'eps\_pi');
M_.exo_names_long = char(M_.exo_names_long, 'eps_pi');
M_.exo_names = char(M_.exo_names, 'eps_r');
M_.exo_names_tex = char(M_.exo_names_tex, 'eps\_r');
M_.exo_names_long = char(M_.exo_names_long, 'eps_r');
M_.endo_names = 'y';
M_.endo_names_tex = 'y';
M_.endo_names_long = 'y';
M_.endo_names = char(M_.endo_names, 'pi');
M_.endo_names_tex = char(M_.endo_names_tex, 'pi');
M_.endo_names_long = char(M_.endo_names_long, 'pi');
M_.endo_names = char(M_.endo_names, 'r');
M_.endo_names_tex = char(M_.endo_names_tex, 'r');
M_.endo_names_long = char(M_.endo_names_long, 'r');
M_.endo_names = char(M_.endo_names, 'u_y');
M_.endo_names_tex = char(M_.endo_names_tex, 'u\_y');
M_.endo_names_long = char(M_.endo_names_long, 'u_y');
M_.endo_names = char(M_.endo_names, 'u_pi');
M_.endo_names_tex = char(M_.endo_names_tex, 'u\_pi');
M_.endo_names_long = char(M_.endo_names_long, 'u_pi');
M_.endo_partitions = struct();
M_.param_names = 'y_bar';
M_.param_names_tex = 'y\_bar';
M_.param_names_long = 'y_bar';
M_.param_names = char(M_.param_names, 'pi_bar');
M_.param_names_tex = char(M_.param_names_tex, 'pi\_bar');
M_.param_names_long = char(M_.param_names_long, 'pi_bar');
M_.param_names = char(M_.param_names, 'r_bar');
M_.param_names_tex = char(M_.param_names_tex, 'r\_bar');
M_.param_names_long = char(M_.param_names_long, 'r_bar');
M_.param_names = char(M_.param_names, 'kappa');
M_.param_names_tex = char(M_.param_names_tex, 'kappa');
M_.param_names_long = char(M_.param_names_long, 'kappa');
M_.param_names = char(M_.param_names, 'tau');
M_.param_names_tex = char(M_.param_names_tex, 'tau');
M_.param_names_long = char(M_.param_names_long, 'tau');
M_.param_names = char(M_.param_names, 'phi_pi');
M_.param_names_tex = char(M_.param_names_tex, 'phi\_pi');
M_.param_names_long = char(M_.param_names_long, 'phi_pi');
M_.param_names = char(M_.param_names, 'phi_y');
M_.param_names_tex = char(M_.param_names_tex, 'phi\_y');
M_.param_names_long = char(M_.param_names_long, 'phi_y');
M_.param_names = char(M_.param_names, 'phi_dy');
M_.param_names_tex = char(M_.param_names_tex, 'phi\_dy');
M_.param_names_long = char(M_.param_names_long, 'phi_dy');
M_.param_names = char(M_.param_names, 'rho_y');
M_.param_names_tex = char(M_.param_names_tex, 'rho\_y');
M_.param_names_long = char(M_.param_names_long, 'rho_y');
M_.param_names = char(M_.param_names, 'rho_pi');
M_.param_names_tex = char(M_.param_names_tex, 'rho\_pi');
M_.param_names_long = char(M_.param_names_long, 'rho_pi');
M_.param_names = char(M_.param_names, 'rho_r');
M_.param_names_tex = char(M_.param_names_tex, 'rho\_r');
M_.param_names_long = char(M_.param_names_long, 'rho_r');
M_.param_names = char(M_.param_names, 'iota_y');
M_.param_names_tex = char(M_.param_names_tex, 'iota\_y');
M_.param_names_long = char(M_.param_names_long, 'iota_y');
M_.param_names = char(M_.param_names, 'iota_p');
M_.param_names_tex = char(M_.param_names_tex, 'iota\_p');
M_.param_names_long = char(M_.param_names_long, 'iota_p');
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 3;
M_.endo_nbr = 5;
M_.param_nbr = 13;
M_.orig_endo_nbr = 5;
M_.aux_vars = [];
M_.Sigma_e = zeros(3, 3);
M_.Correlation_matrix = eye(3, 3);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = 1;
M_.det_shocks = [];
options_.linear = 1;
options_.block=0;
options_.bytecode=0;
options_.use_dll=0;
M_.hessian_eq_zero = 1;
erase_compiled_function('NKPC_REE_Estimation_static');
erase_compiled_function('NKPC_REE_Estimation_dynamic');
M_.orig_eq_nbr = 5;
M_.eq_nbr = 5;
M_.ramsey_eq_nbr = 0;
M_.set_auxiliary_variables = exist(['./' M_.fname '_set_auxiliary_variables.m'], 'file') == 2;
M_.lead_lag_incidence = [
 1 6 11;
 2 7 12;
 3 8 0;
 4 9 0;
 5 10 0;]';
M_.nstatic = 0;
M_.nfwrd   = 0;
M_.npred   = 3;
M_.nboth   = 2;
M_.nsfwrd   = 2;
M_.nspred   = 5;
M_.ndynamic   = 5;
M_.equations_tags = {
};
M_.static_and_dynamic_models_differ = 0;
M_.exo_names_orig_ord = [1:3];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(5, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(3, 1);
M_.params = NaN(13, 1);
M_.NNZDerivatives = [23; 0; -1];
M_.params( 1 ) = 0;
y_bar = M_.params( 1 );
M_.params( 2 ) = 0.4;
pi_bar = M_.params( 2 );
M_.params( 3 ) = 0.7;
r_bar = M_.params( 3 );
M_.params( 4 ) = 0.00588303564312093;
kappa = M_.params( 4 );
M_.params( 5 ) = 2.6376376636598;
tau = M_.params( 5 );
M_.params( 6 ) = 1.47216909623833;
phi_pi = M_.params( 6 );
M_.params( 7 ) = 0.0866513128636564;
phi_y = M_.params( 7 );
M_.params( 8 ) = 0.121768044002484;
phi_dy = M_.params( 8 );
M_.params( 11 ) = 0.939996619054617;
rho_r = M_.params( 11 );
M_.params( 9 ) = 0.633820220735662;
rho_y = M_.params( 9 );
M_.params( 10 ) = 0.0525487901175443;
rho_pi = M_.params( 10 );
M_.params( 12 ) = 0.534636246394045;
iota_y = M_.params( 12 );
M_.params( 13 ) = 0.193584431292423;
iota_p = M_.params( 13 );
%
% SHOCKS instructions
%
M_.exo_det_length = 0;
M_.Sigma_e(1, 1) = (0.312975868173658)^2;
M_.Sigma_e(2, 2) = (0.0799885597155151)^2;
M_.Sigma_e(3, 3) = (0.114062909833523)^2;
options_.ar = 10;
options_.irf = 40;
options_.nograph = 1;
var_list_ = char();
info = stoch_simul(var_list_);
save('NKPC_REE_Estimation_results.mat', 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save('NKPC_REE_Estimation_results.mat', 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save('NKPC_REE_Estimation_results.mat', 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save('NKPC_REE_Estimation_results.mat', 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save('NKPC_REE_Estimation_results.mat', 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save('NKPC_REE_Estimation_results.mat', 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save('NKPC_REE_Estimation_results.mat', 'oo_recursive_', '-append');
end


disp(['Total computing time : ' dynsec2hms(toc(tic0)) ]);
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
diary off
