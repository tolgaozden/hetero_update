function [hpd_interval, median_]=extract_HPD_bands(data,mh_conf_sig)



data=sort(data);
data_length=length(data);

hpdDraws=round((1-mh_conf_sig)*length(data));

jj=size(data,1)-hpdDraws-2;

for ii=1:hpdDraws
    kk(ii)=data(jj)-data(ii);
    jj=jj+1;
end

[kmin,idx]=min(kk);

hpd_interval=[data(idx) data(idx)+kmin];
post_deciles=data([round(0.05*data_length)...
    round(0.2*data_length)...
    round(0.3*data_length)...
    round(0.4*data_length)...
    round(0.5*data_length)...
    round(0.6*data_length)...
    round(0.7*data_length)...
    round(0.8*data_length)...
    round(0.95*data_length)])


median_ = median(data);

end
