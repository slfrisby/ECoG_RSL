function f = plot_frequency_vs_voltage(frequency,voltage)

    % plot hold-out correlations for time-frequency data (all frequency ranges; power or phase)  vs voltage. 

    % Arguments:
    % frequency - matrix of cross-validated correlations for power or phase (participants x timepoints; double)
    % voltage - matrix of cross-validated correlations for voltage (participants x timepoints; double)

    % for each timepoint
    for i = 1:size(frequency,2)
        % calculate two-tailed 95% confidence intervals
        confInt.frequency(i) = 1.96*(std(frequency(:,i))/sqrt(size(frequency,1)));
        confInt.voltage(i) = 1.96*(std(voltage(:,i))/sqrt(size(voltage,1)));
        % calculate whether difference from zero is significant (one-sample
        % t-test, one-tailed)
        [~,p.zero.frequency(i)] = ttest(frequency(:,i),0,'Tail','right');
        [~,p.zero.voltage(i)] = ttest(voltage(:,i),0,'Tail','right');
        % calculate whether difference between frequency and voltage is
        % significant (paired t-test, two-tailed)
        [~,p.difference(i)] = ttest(frequency(:,i),voltage(:,i));
    end
    % if there is no variance (i.e. if the model performs at chance), we
    % cannot perform a t-test. So set p to 1
    p.zero.frequency(isnan(p.zero.frequency)) = 1;
    p.zero.voltage(isnan(p.zero.voltage)) = 1;
    p.difference(isnan(p.difference)) = 1;
    
    % control the false discovery rate (Benjamini & Hochberg, 1995)
    p.zero.frequency = mafdr(p.zero.frequency,'BHFDR',1);
    p.zero.voltage = mafdr(p.zero.voltage,'BHFDR',1);
    p.difference = mafdr(p.difference,'BHFDR',1);

    % plot
    f = figure;
    % plot voltage timecourse in brown
    plot(1:size(voltage,2),mean(voltage),'Color',hex2rgb('#996035'),'LineWidth',1.5)
    % plot voltage 95% confidence interval as a ribbon
    hold on
    fill([1:size(voltage,2),fliplr(1:size(voltage,2))],[mean(voltage)-confInt.voltage,fliplr(mean(voltage)+confInt.voltage)],hex2rgb('#996035'),'FaceAlpha',0.2,'EdgeColor','None') 
    % plot frequency timecourse in blue
    plot(1:size(frequency,2),mean(frequency),'Color',hex2rgb('#0066FF'),'LineWidth',1.5)
    % plot frequency 95% confidence interval as a ribbon
    fill([1:size(frequency,2),fliplr(1:size(frequency,2))],[mean(frequency)-confInt.frequency,fliplr(mean(frequency)+confInt.frequency)],hex2rgb('#0066FF'),'FaceAlpha',0.2,'EdgeColor','None')
    
    % set axes
    axes = gca(f);
    % x axis
    xlim(axes,[0,size(voltage,2)]);
    xticks(1:50:size(voltage,2));
    xticklabels(num2cell(0:500:1650));
    xlabel('Time (ms)');
    % y axis
    ylim(axes,[-0.1,1]);
    yticks(-0.1:0.1:1);
    yline(0,'--');
    ylabel('Cross-validated correlation');

    % plot dots to show significance
    % voltage - difference from zero
    tmp = 1:size(voltage,2);
    tmp(p.zero.voltage >= 0.05) = [];
    dots = plot(tmp,repmat(0.975,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots) % (if there are no dots, we can't set their colour)
        dots.Color = hex2rgb('#996035');
    end
    % frequency - difference from zero
    tmp = 1:size(frequency,2);
    tmp(p.zero.frequency >= 0.05) = [];
    dots = plot(tmp,repmat(0.95,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots)
        dots.Color = hex2rgb('#0066FF');
    end
    % frequency and voltage difference from each other
    tmp = 1:size(voltage,2);
    tmp(p.difference >= 0.05) = [];
    dots = plot(tmp,repmat(0.925,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots)
        dots.Color = hex2rgb('#000000');
    end

    % make it a bit less pixellated
    set(f,'Renderer','painters')

end
