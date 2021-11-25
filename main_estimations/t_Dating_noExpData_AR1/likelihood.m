function [likelihood]= likelihood(param,param_bounds)

param=vec(param);

pr=NKPC_prior(param);
likl=KF_MS_VAR1(param);
likelihood=likl+pr;


if norm(double((param < param_bounds(:,1))))>0

    likelihood = Inf;
    
end;

    
if norm(double((param > param_bounds(:,2))))>0

   likelihood = Inf;
end;

if isnan(likelihood)==1
    likelihood=Inf;
end

if abs(imag(likelihood))>0
    likelihood=Inf;
end

end