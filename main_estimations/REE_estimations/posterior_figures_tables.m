clear;clc;close all;
load estimation_results_mode; %maximization at mode
load NKPC_REE_Estimation_mh1_blck1.mat; % MCMC results





burnFrac =0.5;
Ndraws = length(logpo2);
Nburn= round(burnFrac*Ndraws);
numVar = size(x2,2);


fh = -oo_.posterior.optimization.log_density ;
laplace_ = oo_.MarginalDensity.LaplaceApproximation;


para_names = {'pi_bar(1)','r_bar(2)','kappa(3)','tau(4)',...
    'phi_pi(5)','phi_y(6)','phi_dy(7)','rho_y(8)','rho_pi(9)','rho_r(10)',...
    'eta_y(11)','eta_{\pi}(12)','eta_r(13)','iota_y(14)','iota_p(15)'};

 para_names_latex = {'$\bar{\pi}$','$\bar{r_T}$','$\kappa$','$\tau$',...
    '$\phi_{\pi}$','$\phi_y$','$\phi_{\Delta y}$','$\rho_y$','$\rho_{\pi}$','$\rho_r$',...
    '$\eta_y$','$\eta_{\pi}$','$\eta_r$','$\iota_y$','$\iota_{\pi}$'};


dynare_param_order=[4 5 6 7 8 9 10 11 12 13 1 2 3 14 15];

posteriorMode = oo_.posterior.optimization.mode(dynare_param_order);

StdAtMode =  sqrt(diag(oo_.posterior.optimization.Variance));
StdAtMode = StdAtMode(dynare_param_order);

posteriorDraws = x2(:,dynare_param_order);
logposterior = logpo2;




%=========geweke convergence test========================================================================================
sampleFrac1 = 0.2; %fraction of the first sample size--to be taken from the beginning after burn-in
sampleFrac2 = 0.5; %fraction of the second sample size--to be taken from the end of the sample, after burn-in


index1 = [round(Ndraws * burnFrac)+1, round(Ndraws * burnFrac) + Ndraws * (1-burnFrac) * sampleFrac1];
index2 = [Ndraws - Ndraws * (1-burnFrac) * sampleFrac2 + 1 , Ndraws]; 
   
sample1 = posteriorDraws(index1(1):index1(2),:);
sample2 = posteriorDraws(index2(1):index2(2),:);
 

 
 %moments from sample 1 (first 10% after burn-in)
[results_vec, results1] = geweke_moments(sample1);
 results1= [results1.posteriormean results1.posteriorstd results1.nse_iid...
     results1.rne_iid results1.nse_taper_4 results1.rne_taper_4...
     results1.nse_taper_8 results1.rne_taper_8 results1.nse_taper_12 results1.rne_taper_12];

%moments from sample 2 (last 50% after burn-in)
[results_vec, results2] = geweke_moments(sample2);
 results2= [results2.posteriormean results2.posteriorstd results2.nse_iid...
     results2.rne_iid results2.nse_taper_4 results2.rne_taper_4...
     results2.nse_taper_8 results2.rne_taper_8 results2.nse_taper_12 results2.rne_taper_12];
 
 geweke_result = geweke_chi2_test(results1,results2);

disp('GEWEKE CHI2 TEST P-VALUES:');
disp(geweke_result.prob_chi2_test);


%============trace plots================================================================================
  mh_conf_sig=0.95;
posteriorMean=mean(posteriorDraws(Nburn+1:end,:));


posteriorDist = posteriorDraws(Nburn+1:end,:);
recursiveAverages=zeros(length(posteriorDist),numVar);
recursiveAverages(1,:) = posteriorDist(1,:);
% for j=2: length(recursiveAverages);
%     recursiveAverages(j,:) = (recursiveAverages(j-1,:)*(j-1) + posteriorDraws(j,:)) / j;
%     
%     
%     
% end


rollingAverages=zeros(length(posteriorDist),numVar);
% rollingAverages(1,:) = posteriorDist(1,:);
% for  j=2: length(recursiveAverages);
%     
%  
%     rollingAverages(j,:) = 0.99*(rollingAverages(j-1,:) + 0.01*posteriorDraws(j,:));
%  
%         
%     
%     
% end
% 
% figure;
%  for i=1:numVar;
%    subplot(5,5,i);
%    plot(recursiveAverages(2:end,i),'lineWidth',1,'color','black');
%    hold on;
%    plot(ones(length(recursiveAverages(2:end,i)),1)*posteriorMode(i),'--','lineWidth',1,'color','red');
%   
%  end
% 
% figure;
%   for i=1:numVar;
%    subplot(5,5,i);
%    plot(rollingAverages(2:end,i),'lineWidth',1,'color','black');
%     hold on;
%    plot(ones(length(recursiveAverages(2:end,i)),1)*posteriorMode(i),'--','lineWidth',1,'color','red');
%   end
  
  
% figure('units','normalized','outerposition',[0 0 1 0.35]);
% for i=1:numVar;
% subplot(8,6,i);hist(posteriorDraws(Nburn+1:end,i));hold on;plot([posteriorMode(i) posteriorMode(i)],[ylim],'r'); 
% end
 

    figure('units','normalized','outerposition',[0 0 0.25 1]);
for i=1:numVar;
    
    for jj=1:2
        if jj==1
subplot(15,2,2*(i-1)+1);histogram(posteriorDraws(Nburn+1:end,i),'Normalization','Probability');
hold on;
plot([posteriorMode(i) posteriorMode(i)],[ylim],'color','red','lineWidth',2); 
        ylabel(para_names_latex(i),'interpreter','Latex','FontSize',12) ;
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
        elseif jj==2
 subplot(15,2,2*(i-1)+2);
 plot(posteriorDraws(Nburn+1:end,i));
 hold on;
 plot(ones(length(posteriorDraws(Nburn+1:end,i)),1)*posteriorMean(i),'color','red','lineWidth',2);  
 set(gca,'YTickLabel',[]);
 set(gca,'XTickLabel',[]);
 xlim([1 Ndraws-Nburn+1]);
        end
    end

end
 generate_figures('posteriorDist_ree','figures'); 
    %=========================HPD %intervals===================================================================




posteriorDist=sort(posteriorDist);
hpdDraws=round((1-mh_conf_sig)*length(posteriorDist));
kk=zeros(hpdDraws,13);
  
 
for paraInd=1:length(posteriorMode)
    jj=size(posteriorDist,1)-hpdDraws-2;

for ii=1:hpdDraws
    kk(ii,paraInd)=posteriorDist(jj,paraInd)-posteriorDist(ii,paraInd);
    jj=jj+1;
end
[kmin,idx]=min(kk(:,paraInd));
hpd_interval(paraInd,:)=[posteriorDist(idx,paraInd) posteriorDist(idx,paraInd)+kmin];
post_deciles(paraInd,:)=posteriorDist([round(0.05*length(posteriorDist(:,paraInd)))...
    round(0.2*length(posteriorDist(:,paraInd)))...
    round(0.3*length(posteriorDist(:,paraInd)))...
    round(0.4*length(posteriorDist(:,paraInd)))...
    round(0.5*length(posteriorDist(:,paraInd)))...
    round(0.6*length(posteriorDist(:,paraInd)))...
    round(0.7*length(posteriorDist(:,paraInd)))...
    round(0.8*length(posteriorDist(:,paraInd)))...
    round(0.95*length(posteriorDist(:,paraInd)))],paraInd);
end 
  

MHM_density= MHM_calculator(numVar,Ndraws,Nburn,posteriorDraws,posteriorMean,logposterior,fh);
MHM_density = -MHM_density(9,2);


para_names = para_names';
posteriorMean = posteriorMean';




table(para_names,posteriorMode,StdAtMode, posteriorMean, hpd_interval)

disp('Laplace Approximation:');
disp(laplace_); 

disp('MHM Estimator');
disp(MHM_density);

disp('likelihood');
disp(fh);

%==================================================================
%=============================estimated shocks=====================




%==========================================write table to excel

% st_dev=round(sqrt(diag(H)),3);
posteriorMode=round(posteriorMode,3);
posteriorMean = round(posteriorMean,3);
hpd_interval= round(hpd_interval,3);
StdAtMode = round(StdAtMode,3);

 output_file='Estimation_Results.csv';
 output_sheet='Estimation_Results';
 
 column_names = {'Para.', 'Post. Mode', 'St. Dev at Mode',' Post. Mean', '90 % HPD', 'Interval', 'Laplace', 'MHM','Post. Mode'};
 
%  para_names_latex = {'\bar{\pi}','r\bar{r}','\kappa','\tau',...
%     '\phi_{\pi}','\phi_y','\phi_{\Delta y}','\rho_y','\rho_{\pi}','\rho_r',...
%     '\eta_y','\eta_pi','\eta_r','\iota_y','\iota_p'}';
 
  xlswrite(output_file,column_names(1),output_sheet,'a1');
 xlswrite(output_file,para_names_latex,output_sheet,'a2');
 
 xlswrite(output_file,column_names(2),output_sheet,'b1');
 xlswrite(output_file,posteriorMode,output_sheet,'b2');
 
 xlswrite(output_file,column_names(3),output_sheet,'c1');
 xlswrite(output_file,StdAtMode,output_sheet,'c2');
 
 xlswrite(output_file,column_names(4),output_sheet,'d1');
 xlswrite(output_file,posteriorMean,output_sheet,'d2');
 
  xlswrite(output_file,column_names(5),output_sheet,'e1');
xlswrite(output_file,column_names(6),output_sheet,'f1');
xlswrite(output_file,hpd_interval,output_sheet,'e2');
 
xlswrite(output_file,column_names(7),output_sheet,'a25');
xlswrite(output_file,laplace_,output_sheet,'b25');

xlswrite(output_file,column_names(8),output_sheet,'a26');
xlswrite(output_file,MHM_density,output_sheet,'b26');

xlswrite(output_file,column_names(9),output_sheet,'a27');
xlswrite(output_file,fh,output_sheet,'b27');
