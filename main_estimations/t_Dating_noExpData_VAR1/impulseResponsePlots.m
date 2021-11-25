clear;clc;%close all;
load('kf_output_workspace_4regime.mat');
load impREE_rise.mat;
%impREE_{regime_name}" #periods of IRFs x variable index x shock index 

% load imp_nkpc_rise_unitShock_march15.mat;
% load imp_nkpc_rise_march15.mat;
% period_normal=160;period_zlb=180;

 shock_names={'etaY','etaPi','etaR'};
 variable_names={'y','pi','r'};
 
  shock_names_tex={'\eta_y','\eta_{\pi}','eta_r'};
 variable_names_tex={'y_t','\pi_t','r_t'};
numPeriods=76; %period over which IRFs are computed

zlb_index = [T-44:T-16] - (T - numPeriods);

normal_index1 = [ T-numPeriods+1: T-45] - (T - numPeriods)  ;
normal_index2 = [T-15:T]- (T - numPeriods)  ;

periods=50;%length of IRFs
numExo=3;


%important: the dates are shifted by 3 quarters to get beginning of year on
%the plots, instead of end-year
% startDate=Date(end-numPeriods+1 +4);
% endDate=Date(end+4);
% 
startDate=Date(end-numPeriods+1);
endDate=Date(end);

DateTick=linspace(startDate,endDate,floor(T/20));


   alpha1(1:3) = alpha1_tt(:,T-numPeriods-1);
  beta1(1:3,1:3)=  beta1_tt(:,:,T-numPeriods-1);
  tt=T-numPeriods;
  
[gamma1_1(:,:,tt), gamma2_1(:,:,tt), gamma3_1(:,:,tt), E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,T-numPeriods-1,r_bar1,r_bar2);

%Taylor rule, MSV solution
[gamma1_2(:,:,tt), gamma2_2(:,:,tt), gamma3_2(:,:,tt), E2, F2]=NKPC_sysmat_regime2(param(:,2),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,T-numPeriods-1,r_bar1,r_bar2);

%ZLB regime, VAR-learning
[gamma1_3(:,:,tt), gamma2_3(:,:,tt), gamma3_3(:,:,tt), E3, F3]=NKPC_sysmat_regime3(param(:,3),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,T-numPeriods-1,r_bar1,r_bar2);

%ZLB regime, MSV solution 
[gamma1_4(:,:,tt), gamma2_4(:,:,tt), gamma3_4(:,:,tt), E4, F4]=NKPC_sysmat_regime4(param(:,4),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,T-numPeriods-1,r_bar1,r_bar2);


  
  
  index=0;
for tt=T-numPeriods+1:T
    index=index+1;



imp1(index,:,:,:)=impulse_response(param(:,1),gamma1_1(:,:,tt-1),gamma3_1(:,:,tt-1),periods);
imp2(index,:,:,:)=impulse_response(param(:,2),gamma1_2(:,:,tt-1),gamma3_2(:,:,tt-1),periods);
imp3(index,:,:,:)=impulse_response(param(:,3),gamma1_3(:,:,tt-1),gamma3_3(:,:,tt-1),periods);
imp4(index,:,:,:)=impulse_response(param(:,4),gamma1_4(:,:,tt-1),gamma3_4(:,:,tt-1),periods);

imp_avg(index,:,:,:) = pp_filtered(tt,1) * imp1(index,:,:,:) + ...
                            pp_filtered(tt,2) * imp2(index,:,:,:) + ...
                            pp_filtered(tt,3) * imp3(index,:,:,:) + ...
                            pp_filtered(tt,4) * imp4(index,:,:,:);


gamma1_1_old = gamma1_1(:,:,tt-1); 
gamma1_2_old = gamma1_2(:,:,tt-1); 
gamma1_3_old = gamma1_3(:,:,tt-1); 
gamma1_4_old = gamma1_4(:,:,tt-1); 

gamma2_1_old = gamma2_1(:,:,tt-1);
gamma2_2_old = gamma2_2(:,:,tt-1);
gamma2_3_old = gamma2_3(:,:,tt-1);
gamma2_4_old = gamma2_4(:,:,tt-1);

gamma3_1_old = gamma3_1(:,:,tt-1);
gamma3_2_old = gamma3_2(:,:,tt-1);
gamma3_3_old = gamma3_3(:,:,tt-1);
gamma3_4_old = gamma3_4(:,:,tt-1);

% update the system matrices
%Taylor rule, VAR-learning

   alpha1(1:3) = alpha1_tt(:,tt);
  beta1(1:3,1:3)=  beta1_tt(:,:,tt);
  
[gamma1_1(:,:,tt), gamma2_1(:,:,tt), gamma3_1(:,:,tt), E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%Taylor rule, MSV solution
[gamma1_2(:,:,tt), gamma2_2(:,:,tt), gamma3_2(:,:,tt), E2, F2]=NKPC_sysmat_regime2(param(:,2),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%ZLB regime, VAR-learning
[gamma1_3(:,:,tt), gamma2_3(:,:,tt), gamma3_3(:,:,tt), E3, F3]=NKPC_sysmat_regime3(param(:,3),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);

%ZLB regime, MSV solution 
[gamma1_4(:,:,tt), gamma2_4(:,:,tt), gamma3_4(:,:,tt), E4, F4]=NKPC_sysmat_regime4(param(:,4),bb_REE,dd_REE,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);


 

root_ALM1 = abs(eigs(gamma1_1(:,:,tt),1));
root_ALM2 = abs(eigs(gamma1_2(:,:,tt),1));
root_ALM3 = abs(eigs(gamma1_3(:,:,tt),1));
root_ALM4 = abs(eigs(gamma1_4(:,:,tt),1));

root_ALM(tt) = root_ALM1 * pp_filtered(tt,1) + root_ALM2 * pp_filtered(tt,2) + root_ALM3 * pp_filtered(tt,3) + root_ALM4 * pp_filtered(tt,4);
% 

if root_ALM(tt) > 1 
    projectionFlag(tt) = 1;
    
gamma1_1(:,:,tt) = gamma1_1_old; 
gamma1_2(:,:,tt) = gamma1_2_old; 
gamma1_3(:,:,tt) = gamma1_3_old; 
gamma1_4(:,:,tt) = gamma1_4_old; 

gamma2_1(:,:,tt) = gamma2_1_old;
gamma2_2(:,:,tt) = gamma2_2_old;
gamma2_3(:,:,tt) = gamma2_3_old;
gamma2_4(:,:,tt) = gamma2_4_old;

gamma3_1(:,:,tt) = gamma3_1_old;
gamma3_2(:,:,tt) = gamma3_2_old;
gamma3_3(:,:,tt) = gamma3_3_old;
gamma3_4(:,:,tt) = gamma3_4_old;   

end

   
end


% gamma1_1=reshape(gamma1_1,[T numVar numVar ]);
% gamma1_2=reshape(gamma1_2,[T numVar numVar ]);
% gamma1_3=reshape(gamma1_3,[T numVar numVar ]);
% gamma1_4=reshape(gamma1_4,[T numVar numVar ]);
% 
% gamma3_1 = reshape(gamma3_1,[T numVar numExo]);
% gamma3_2 = reshape(gamma3_1,[T numVar numExo]);
% gamma3_3 = reshape(gamma3_1,[T numVar numExo]);
% gamma3_4 = reshape(gamma3_1,[T numVar numExo]);

% gamma1_1avg = squeeze(mean(gamma1_1));
% gamma1_2avg = squeeze(mean(gamma1_2));
% gamma1_3avg = squeeze(mean(gamma1_3));
% gamma1_4avg = squeeze(mean(gamma1_4));
% 
% gamma3_1avg = squeeze(mean(gamma3_1));
% gamma3_2avg = squeeze(mean(gamma3_2));
% gamma3_3avg = squeeze(mean(gamma3_3));
% gamma3_4avg = squeeze(mean(gamma3_4));


% imp1_avg=impulse_response(param(:,1),gamma1_1avg,gamma3_1avg,periods);
% imp2_avg=impulse_response(param(:,2),gamma1_2avg,gamma3_2avg,periods);
% imp3_avg=impulse_response(param(:,3),gamma1_3avg,gamma3_3avg,periods);
% imp4_avg=impulse_response(param(:,4),gamma1_4avg,gamma3_4avg,periods);




refLine1=linspace(1,periods,periods);refLine1=repmat(refLine1,[numPeriods 1]);
%refLine2=linspace(1,numPeriods,numPeriods);refLine2=repmat(refLine2,[periods 1])';
refLine2=linspace(startDate,endDate,numPeriods);refLine2=repmat(refLine2,[periods 1])';


%  for ii=1:2
% %  figure('Name','Impulse Responses-VAR Model','units','normalized','outerposition',[0 0 1 0.5]);
% 
% index=0;
%     for jj=1:2
%    figure;    
%         index=index+1;
% 
% plot(imp1_avg(2:end,ii,jj)','lineWidth',0.5);
% hold on;
% plot(imp2_avg(2:end,ii,jj)','lineWidth',0.5);
% hold on;
% plot(imp3_avg(2:end,ii,jj)','lineWidth',0.5);
% hold on;
% plot(imp4_avg(2:end,ii,jj)','lineWidth',0.5);
% legend('regime 1: VAR + Taylor', 'regime 2: REE + Taylor','regime 3: VAR + ZLB', 'regime 4: REE + ZLB');
% title([shocks(jj)],'FontSize',35);
% 
%     end
% end



 for ii=1:2
%  figure('Name','Impulse Responses-VAR Model','units','normalized','outerposition',[0 0 1 0.5]);

% index=0;
    for jj=1:2
        string_= ['var1_4reg_3d_IRF_',variable_names{ii},'_',shock_names{jj}];
   figure('Name',string_);    
%         index=index+1;
%          subplot(2,1,index);
%         subplot(numVar-2,numShocks,index);
plot3(refLine1',refLine2',imp_avg(1:end,:,ii,jj)','lineWidth',0.5);
hold on;
plot3(refLine1(1,1:end)',refLine2(1,1:end)',impREE_normal(1:periods,ii,jj),'lineWidth',3,'color','black');
hold on;
plot3(refLine1(end,1:end)',refLine2(end,1:end)',impREE_zlb(1:periods,ii,jj),'lineWidth',3,'color','red');
% ylim([startDate endDate])
ylim([Date(end-numPeriods+1) Date(end)]);
  set(gca,'ytick',DateTick)
  datetick('y','yy','keepticks');
set(gca,'FontSize',14);

 % view([63 21])
 view([77 29]);
 
string2_= ['Response of ',variable_names_tex{ii},' to ',shock_names_tex{jj}];
zlabel(string2_,'FontSize',14);
xx=xlabel('Periods','FontSize',14,'rotation',-60);
xx.VerticalAlignment='cap';

% if ii~= 1 && jj~= 1
 % xx.Position(3)= xx.Position(3)*0.5;
%xx.Position = [xx_def(1)/2,xx_def(2),xx_def(3)/2];
% end
%xx.Position(3)= xx.Position(3)*0.5;
%xx.Position=1.0e+05 *[0.000300962896727   7.301732181625271  -0.000000842033601];
ylabel('Date','FontSize',14);
 
 
% set(gca, 'CameraPosition', [362,7.053250612537066e+05,3.6]);


 %plot3(refLine1',refLine2',imp11(:,:,ii,jj)','color','red','lineWidth',0.5);
 %hold on;
 %plot3(refLine1',refLine2',imp22(:,:,ii,jj)','color','black','lineWidth',0.5);
% hold on;
% plot(imp22(10,:,ii,jj),'lineWidth',3,'color','green');
%        title([vars(ii) shocks(jj)],'FontSize',35);

% title([shocks(jj)],'FontSize',35);

  generate_figures(string_,'figures');  
    end
 end

 
 %=========regime specific "average" impulse responses
 
  imp_avg_rr(:,:,:,1) = squeeze((mean(imp1([normal_index1,normal_index2],:,:,:),1)));
  imp_avg_rr(:,:,:,2) = squeeze((mean(imp2([normal_index1,normal_index2],:,:,:),1)));
  imp_avg_rr(:,:,:,3) = squeeze((mean(imp3([zlb_index],:,:,:),1)));
  imp_avg_rr(:,:,:,4) = squeeze((mean(imp4([zlb_index],:,:,:),1)));
 
 
for ii=1:2
    for jj=1:2
        string_= ['var1_4reg_averageIRF_',variable_names{ii},'_',shock_names{jj}];
   figure('Name',string_); 
    for kk=1:4

  if kk==1
    plot(imp_avg_rr(:,ii,jj,kk),'color','black');
elseif kk==2
    plot(imp_avg_rr(:,ii,jj,kk),'--','color','black');
elseif kk==3
    plot(imp_avg_rr(:,ii,jj,kk),'color','blue');
elseif kk==4
    plot(imp_avg_rr(:,ii,jj,kk),'--','color','blue');
end
    hold on;
    end
% hold on;
% plot(impREE_normal(1:periods,ii,jj));
% hold on;
% plot(impREE_zlb(1:periods,ii,jj));

% 
% hold on;
% plot(impREE_normal(1:periods,ii,jj),'color','red');
% hold on;
% plot(impREE_zlb(1:periods,ii,jj),'--','color','red');
        

if ii==1 && jj==2
%     legend('Regime 1: Taylor Rule + Learning',...
%         'Regime 2: Taylor Rule + REE',...
%         'Regime 3: ZLB + Learning',...
%         'Regime 4: ZLB + REE',...
%         'REE Normal',...
%         'REE ZLB');

  leg=  legend('Regime 1: Taylor Rule + Learning',...
        'Regime 2: Taylor Rule + REE',...
        'Regime 3: ZLB + Learning',...
        'Regime 4: ZLB + REE');
leg.Orientation='vertical';    
leg.Location='southeast';
leg.FontSize=10;


end 
set(gca,'FontSize',14);
xlabel('Periods','FontSize',14);

string2_= ['Response of ',variable_names_tex{ii},' to ',shock_names_tex{jj}];
ylabel(string2_,'FontSize',14);

  generate_figures(string_,'figures');        
        
    end
end

 
 
 
 
 
 
 
 
% legend('normal regime','zlb regime');

% fig = gcf;
% fig.PaperPositionMode = 'auto'
% fig_pos = fig.PaperPosition;
% fig.PaperSize = [fig_pos(3) fig_pos(4)];
% print(fig,'NKPC_ree_init_VAR_IR_timeVarying','-dpdf');

% figure('Name','impulse responses','units','normalized','outerposition',[0 0 1 1]);
% index=0;
% for ii=[1 2]
%         for jj=[1 2]
% impL_normal(:,ii,jj)=mean(imp33(period_normal,1:end,ii,jj));
% impL_zlb(:,ii,jj)=mean(imp33(period_zlb,1:end,ii,jj));            
%             
%     index=index+1;
% subplot(2,2,index);
% plot(impL_normal(1:end,ii,jj),'--','lineWidth',5,'color','black');
% hold on;
% plot(impL_zlb(1:end,ii,jj),'*','lineWidth',5,'color','black');
% hold on;
% plot(impREE_normal(2:periods,index),'--','lineWidth',5,'color','blue');
% hold on;
% plot(impREE_zlb(2:periods,index),'*','lineWidth',5,'color','blue');
% title(shocks(jj));
%         end
% end
% leg=legend('learning-normal','learning-zlb','ree-normal','ree-zlb');
% 
% 
% 
% figure('Name','impulse response differentials','units','normalized','outerposition',[0 0 1 1]);
% index=0;
% for ii=[1 2]
%         for jj=[1 2]        
%    index=index+1;
% diff_l=abs(impL_normal(1:end,ii,jj)-impL_zlb(1:end,ii,jj));          
% diff_ree=abs(impREE_normal(2:periods,index)-impREE_zlb(2:periods,index));            
%  
% subplot(2,2,index);
% plot(diff_l,'--','lineWidth',5,'color','black');
% hold on;
% plot(diff_ree,'--','lineWidth',5,'color','blue');
% title(shocks(jj));
%         end
% end
% leg=legend('learning-normal','ree');
