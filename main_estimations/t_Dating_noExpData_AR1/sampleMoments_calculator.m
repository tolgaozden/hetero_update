function [sampleMean sampleCovar] =sampleMoments_calculator(draws_)

sampleMean=mean(draws_);


length_=size(draws_,1);
numVar=size(draws_,2);

posterior_covar=zeros(numVar,numVar);


for ii=1:length_
    
XX=(draws_(ii,:)-sampleMean)';    
    
 posterior_covar= posterior_covar + XX * XX';
    
end
    
sampleCovar=posterior_covar/length_;   


    

    
end





