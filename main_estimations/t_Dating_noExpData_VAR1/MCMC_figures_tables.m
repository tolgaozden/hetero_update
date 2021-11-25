clear;clc;close all;

load MH_results_var1_feb15;

model.endogenous_switching=0;
% model.learning_algo='rise';




names=[{'phi','sigma_c' ,'lambda' ,'xi_w' ,'sigma_l', 'xi_p' , 'iota_w','iota_p',...
    'psi' ,'phi_p','r_pi', 'rho' ,'r_y', 'r_dy' ,...
           'pi_bar' ,'beta_const' ,'l_bar', 'gamma_bar' ,'alpha'...
           'rho_a', 'rho_b' ,'rho_g' ,'rho_i' ,'rho_r', 'rho_p', 'rho_w','rho_ga',...
           'eta_a', 'eta_b' ,'eta_g' ,'eta_i' ,'eta_r1','eta_r2', 'eta_p', 'eta_w',...
           'gain','p_11','p_22','rbar_zlb','THETA_1/100','THETA_2/100','PHI_1/1000','PHI_2/1000'} ] ; %gain index=36

 names_tex=[{'$\phi$','$\sigma_c$' ,'$\lambda$' ,'$\xi_w$' ,'$\sigma_l$', '$\xi_p$' , '$\iota_w$','$\iota_p$',...
    '$\psi$' ,'$\phi_p$','$r_{\pi}$', '$\rho$' ,'$r_y$', '$r_{\Delta y}$' ,...
           '$\bar{\pi}$' ,'$\bar{\beta}$' ,'$\bar{l}$', '$\bar{\gamma}$' ,'$\alpha$'...
           '$\rho_a$', '$\rho_b$' ,'$\rho_g$' ,'$\rho_i$' ,'$\rho_r$', '$\rho_p$', '$\rho_w$','$\rho_{ga}$',...
           '$\eta_a$', '$\eta_b$' ,'$\eta_g$' ,'$\eta_i$' ,'$\eta_{r,N}$','$\eta_{r,zlb}$', '$\eta_p$', '$\eta_w$',...
           'gain','$p_{11}$','$p_{22}$','$\bar{r,zlb}$','$\frac{{\theta_1}}{100}$','$\frac{{\theta_2}}{100}$','$\frac{{\phi_1}}{1000}$','$\frac{{\phi_2}}{1000}$'} ] ; %gain index=36      
       
indices_common=[1:1:36,39];
indices_exo=[37,38]; %parameters only in exogenous switching models
indices_endo=[42,43];
indices_rise=[1:35,37:39];

if model.endogenous_switching==0;
    
   indices_final=[1:36,37,38,39];
   
elseif model.endogenous_switching==1;
    indices_final=[1:36,39,42,43];
end


if strcmp(model.learning_algo,'rise')==1; indices_final=indices_rise';end;
    
       
names_final=names_tex(indices_final);

 disp('POSTERIOR MEAN')
  mh_conf_sig=0.95;
  
  
  %fix for rise draws--get rid of corner draws
  %  xx=posteriorDist(:,4);xx(xx==0.95)=nan;posteriorDist(:,4)=xx;
%   xx=posteriorDist(:,5);xx(xx==0.25)=nan;posteriorDist(:,5)=xx;
%  xx=posteriorDist(:,24);xx(xx==0.01)=nan;posteriorDist(:,24)=xx;
%  xx=posteriorDist(:,26);xx(xx==0.01)=nan;posteriorDist(:,26)=xx;
%  
%  xx=posteriorDraws(:,4);xx(xx==0.95)=nan;posteriorDraws(:,4)=xx;
%   xx=posteriorDraws(:,5);xx(xx==0.25)=nan;posteriorDraws(:,5)=xx;
%  xx=posteriorDraws(:,24);xx(xx==0.01)=nan;posteriorDraws(:,24)=xx;
%  xx=posteriorDraws(:,26);xx(xx==0.01)=nan;posteriorDraws(:,26)=xx;
  
%for for VAR1 draws--get rid of that one point where it got stuck
%   mode_ = mode;
% clearvars mode;
% xx=mode(posteriorDraws);
% for jj=1:numVar
% temp_= posteriorDraws(:,jj);
% 
% temp_(temp_==xx(jj))=nan;
% 
% posteriorDraws(:,jj)=temp_;
% end
% mode= mode_;
% clearvars mode_; 
  
 posteriorMean=mean(posteriorDraws(Nburn+1:end,:))
posteriorDist=posteriorDraws(Nburn+1:end,:);
posteriorDist=sort(posteriorDist);





hpdDraws=round((1-mh_conf_sig)*length(posteriorDist));
kk=zeros(hpdDraws,13);


for paraInd=1:length(mode)
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


figure('Name','ZLB Exit Probability','units','normalized','outerposition',[0 0 0.4 0.8]);
i=numVar-1;
histogram(posteriorDraws(Nburn+1:end,i),'Normalization','Probability','FaceColor','blue');
xlim([0 0.45]);
    hold on;
    plot([mode(i) mode(i)],[ylim],'r','lineWidth',3); 
    title('ZLB Exit Probability','interpreter', 'latex');
    set(gca,'FontSize',10)
fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
string_ = ['zlb_exit_prob_' model.learning_algo];
  print(fig,string_,'-dpdf');  
    
 mode_zlb_exit_msv = mode(i);
 dist_zlb_exit_msv =  posteriorDraws(Nburn+1:end,i);
 save dist_zlb_exit_msv.mat  mode_zlb_exit_msv dist_zlb_exit_msv;
  

figure('units','normalized','outerposition',[0 0 1 1]);
for i=1:numVar;
subplot(8,5,i);histogram(posteriorDraws(Nburn+1:end,i),'Normalization','Probability');
    hold on;
    plot([mode(i) mode(i)],[ylim],'r'); 
    title(names_final(i),'interpreter', 'latex');
    set(gca,'FontSize',10)
end


% fig = gcf;
% fig.PaperPositionMode = 'auto'
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% 
% if model.endogenous_switching==0
% string=[model.learning_algo,'_MH_distributions'];
% else
% string=[model.learning_algo,'_endo_MH_distributions']; 
% end
% 
% print(fig,string,'-dpdf');


% figure;
% title('Recursive Averages');
%      disp('calculating recursive averages for cusum plots...');
% %      disp(i)
% for j=1:Ndraws
%     disp(j)
%     recursiveAverages(j,:)=mean(posteriorDraws(1:j,:));
%     
% end
%  for i=1:numVar;
%    subplot(8,6,i);
%    plot(recursiveAverages(100:end,i),'lineWidth',2);
%   
%  end


MHM_= MHM_calculator(numVar,Ndraws,Nburn,posteriorDraws,posteriorMean,logposterior,fh);


% results_=table(names_final', mode', st_dev ,posteriorMean', hpd_interval);
%  results_.Properties.VariableNames={'parameter','mode','stdevMode','postMean','HPD'};
%  disp(results_);
% 
% names_final=names_final';
% posteriorMode=round(mode,4);
% posteriorStdev=round(st_dev,4);
% posteriorMean=round(posteriorMean',4);
% hpd_interval=round(hpd_interval,4);
% laplace1=round(laplace1,4);
% mhm=round(MHM_(1,2),4);
% 
% output_file='SW_Estimation_Results.xlsx';
% 
% if model.endogenous_switching==0
% output_sheet=model.learning_algo;
% else
% output_sheet=[model.learning_algo,'_endo'];
% end
% % 
% 
%  xlswrite(output_file,{'Parameter'},output_sheet,'a2');
%   xlswrite(output_file,{'Posterior'},output_sheet,'b1');
%     xlswrite(output_file,{'Mode'},output_sheet,'b2');
%       xlswrite(output_file,{'St. Dev'},output_sheet,'c2');
%        xlswrite(output_file,{'Mean'},output_sheet,'d2');
%            xlswrite(output_file,{'HPD 5 %'},output_sheet,'e2');
%  xlswrite(output_file,{'HPD 95 %'},output_sheet,'e2');
%  
%   xlswrite(output_file,names_final,output_sheet,'a3');
%   xlswrite(output_file,posteriorMode',output_sheet,'b3');
%   xlswrite(output_file,posteriorStdev,output_sheet,'c3');
%    xlswrite(output_file,posteriorMean,output_sheet,'d3');  
%  xlswrite(output_file,hpd_interval,output_sheet,'e3'); 
%  
%   xlswrite(output_file,{'Laplace'},output_sheet,'a43'); 
%   xlswrite(output_file,laplace1,output_sheet,'b43'); 
%   
%   xlswrite(output_file,{'MHM'},output_sheet,'a44'); 
% xlswrite(output_file,mhm,output_sheet,'b44'); 