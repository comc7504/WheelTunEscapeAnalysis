function saveFig(h,p,form)
    ax = findall(h,'type','axes');
    set(ax,'fontname','arial','fontweight','bold','fontsize',11);
    drawnow;
    
    checkP(p);
    STYLE = hgexport('factorystyle');
    %STYLE = hgexport('readstyle','default');
    hgexport(h, [p '.' form],STYLE, 'Format',form);
end