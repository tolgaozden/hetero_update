function []= adjust_labels(startDate,endDate,DateTick,font_size_gca,font_size_x,font_size_y,label_x,label_y)

xlim([startDate endDate])
datetick('x','yy','keeplimits');
  set(gca,'xtick',DateTick)
  datetick('x','yy','keepticks');  
  set(gca,'FontSize',font_size_gca);
    xlabel(label_x,'FontSize',font_size_x);
  ylabel(label_y,'FontSize',font_size_y);


end