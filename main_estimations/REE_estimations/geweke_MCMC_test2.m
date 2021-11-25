clear;clc;close all;
load MH_results_msv_feb8;

%dynare files for later referecen: geweke_moments.m and geweke_chi2_test.m

sampleNum=2;
totalSize=Ndraws-Nburn;
sampleSize=75000;
posteriorDist=posteriorDraws(Nburn+1:end,:);
% zz=nan(sampleNum,sampleNum,numVar);

zz=nan((sampleNum-1)*sampleNum/2,numVar);

zz_joint=nan(size(zz,1),1);


   



sampleDist1=posteriorDist(75001:150000,:);
sampleDist2=posteriorDist(1:15000,:);
   
  
  

        
 sample1=sampleDist1;
 sample2=sampleDist2;
 

 
 
 [sampleMean1 sampleCovar1] =sampleMoments_calculator(sample1);
 [sampleMean2 sampleCovar2] =sampleMoments_calculator(sample2);
 
var1=diag(sampleCovar1);
var2=diag(sampleCovar2);
 
 zz=squeeze((sampleMean1-sampleMean2)'./sqrt(var1+var2));


%zz(index_,:)= (sampleCovar2+sampleCovar1)^(-0.5)*(sampleMean2-sampleMean1)';
 






   
    
% length_= size(zz,1);
% 
% figure;
% for jj=1:numVar
%     subplot(8,5,jj);
%     
%     plot(zz(:,jj),'*','lineWidth',2,'color','red');
%     
%     hold on;
%     plot(2*ones(length_,1),'color','black','lineWidth',3);
%     hold on;
%     plot(-2*ones(length_,1),'color','black','lineWidth',3);
% end




