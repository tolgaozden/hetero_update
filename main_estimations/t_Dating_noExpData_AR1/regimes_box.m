function[]=regimes_box(XX,zlb_regimes,date)

%         miny=min(min(XX));
%         maxy=max(XX);
%         
%         if maxy>miny
%             ylim([miny maxy]);
%         end
        
            yy=ylim;
            yy_lower=yy(1);yy_upper=yy(2);
            for mm=1:size(zlb_regimes,1)
            pp=patch([date(zlb_regimes(mm,1)),date(zlb_regimes(mm,2)),date(zlb_regimes(mm,2)),date(zlb_regimes(mm,1))],...
    [yy_lower,yy_lower,yy_upper,yy_upper],'k');
            pp.EdgeColor=[1 1 1 ];
            hold on;
            alpha 0.3;
            end
            
            
          set(gca,'YLim',yy)  
            
end