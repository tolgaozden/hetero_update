clear;clc;%close all;
load('kf_output_workspace.mat');
% load imp_nkpc_rise_unitShock_march15.mat;
% load imp_nkpc_rise_march15.mat;
% period_normal=160;period_zlb=180;

shocks={'\eta_y','\eta_{pi}','\eta_r'};
numPeriods=50; %period over which IRFs are computed
periods=20;%length of IRFs
numExo=3;


   alpha1(1:3) = alpha1_tt(:,T-numPeriods-1);
  beta1(1:3,1:3)=  beta1_tt(:,:,T-numPeriods-1);
  tt=T-numPeriods-1;
  
[gamma1_1(:,:,tt), gamma2_1, gamma3_1(:,:,tt), E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,T-numPeriods-1,r_bar1,r_bar2);


%ZLB regime, VAR-learning
[gamma1_3(:,:,tt), gamma2_3, gamma3_3(:,:,tt), E3, F3]=NKPC_sysmat_regime3(param(:,2),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,T-numPeriods-1,r_bar1,r_bar2);



  
  
  index=0;
for tt=T-numPeriods:T
    index=index+1;



imp1(index,:,:,:)=impulse_response(param(:,1),gamma1_1(:,:,tt-1),gamma3_1(:,:,tt-1),periods);
imp3(index,:,:,:)=impulse_response(param(:,2),gamma1_3(:,:,tt-1),gamma3_3(:,:,tt-1),periods);

imp_avg(index,:,:,:) = pp_filtered(tt,1) * imp1(index,:,:,:) + ...
                        pp_filtered(tt,2) * imp3(index,:,:,:);




   alpha1(1:3) = alpha1_tt(:,tt);
  beta1(1:3,1:3)=  beta1_tt(:,:,tt);
  
[gamma1_1(:,:,tt), gamma2_1, gamma3_1(:,:,tt), E1, F1]=NKPC_sysmat_regime1(param(:,1),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);


%ZLB regime, VAR-learning
[gamma1_3(:,:,tt), gamma2_3, gamma3_3(:,:,tt), E3, F3]=NKPC_sysmat_regime3(param(:,2),beta1,alpha1,phi_pi_taylor,phi_y_taylor,phi_dy_taylor,rho_r_taylor,zlb_threshold,zlb_threshold2,tt,r_bar1,r_bar2);


 

   
end


gamma1_1=reshape(gamma1_1,[T numVar numVar ]);

gamma1_3=reshape(gamma1_3,[T numVar numVar ]);


gamma3_1 = reshape(gamma3_1,[T numVar numExo]);

gamma3_3 = reshape(gamma3_1,[T numVar numExo]);

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

index=0;
    for jj=1:2
   figure;    
        index=index+1;
%          subplot(2,1,index);
%         subplot(numVar-2,numShocks,index);
plot3(refLine1',refLine2',imp_avg(2:end,:,ii,jj)','lineWidth',0.5);
% hold on;
% plot3(refLine1(1,1:end)',refLine2(1,1:end)',impREE_normal(1:periods,index),'lineWidth',3,'color','black');
% hold on;
% plot3(refLine1(end,1:end)',refLine2(end,1:end)',impREE_zlb(1:periods,index),'lineWidth',3,'color','red');
ylim([startDate endDate])
  datetick('y','yyyy','keeplimits');
  set(gca,'YTickLabel',[])
%   view([115 8])
% set(gca, 'CameraPosition', [362,7.053250612537066e+05,3.6]);


 %plot3(refLine1',refLine2',imp11(:,:,ii,jj)','color','red','lineWidth',0.5);
 %hold on;
 %plot3(refLine1',refLine2',imp22(:,:,ii,jj)','color','black','lineWidth',0.5);
% hold on;
% plot(imp22(10,:,ii,jj),'lineWidth',3,'color','green');
%        title([vars(ii) shocks(jj)],'FontSize',35);

title([shocks(jj)],'FontSize',35);

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
