function [marginal] =MHM_calculator(numVar,Ndraws,Nburn,posteriorDraws,posteriorMean,logposterior,fh)


posterior_covar=zeros(numVar,numVar);
posterior_length=Ndraws-Nburn+1;




for ii=Nburn+1:Ndraws
    
XX=(posteriorDraws(ii,:)-posteriorMean)';    
    
 posterior_covar= posterior_covar + XX * XX';
    
end
    
posterior_covar=posterior_covar/posterior_length;   
detCovar=det(posterior_covar);
invCovar=inv(posterior_covar);
marginal=[];
deviation=zeros(posterior_length,1);

for pp=0.1:0.1:0.9
    index=0;
     critval = qchisq(pp,numVar);
     tmp=0;
     
     
    for ii=Nburn+1:Ndraws
     index=index+1;
     XX=(posteriorDraws(ii,:)-posteriorMean);   
     deviation(index)=XX*invCovar*XX';
        if deviation(index) <=critval
         lftheta= -log(pp)-(numVar*log(2*pi)+log(detCovar)+deviation(index))/2;
         tmp=tmp+exp(lftheta-logposterior(ii)-fh);
        end
    end

    
    
    marginal=cat(1,marginal,[pp,-fh-log(tmp/posterior_length)]);
    
end
format long;
% disp(marginal(:,2));

















end