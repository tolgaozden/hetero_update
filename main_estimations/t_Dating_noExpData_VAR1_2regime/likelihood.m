function [likelihood]= likelihood(param)


pr=NKPC_prior(param);
likl=KF_MS_VAR1(param);
likelihood=likl+pr;



if isnan(likelihood)==1
    likelihood=Inf;
end

if abs(imag(likelihood))>0
    likelihood=Inf;
end

end