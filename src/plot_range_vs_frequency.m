function f = plot_range_vs_frequency(rangeFlag,range,frequency)

    % plot hold-out correlations for time-frequency data within a specific range vs. data from all ranges (power or phase). 

    % Arguments:
    % rangeFlag - which range the data comes from (this controls the colour; character vector)
    % range - matrix of power or phase data within a specific frequency range (participants x timepoints; double)
    % frequency - matrix of power or phase data from all frequency ranges (participants x timepoints; double)

    % set colour to plot timecourse of specific frequency  (all frequencies is always blue)
    switch rangeFlag
        case 'theta'
            colour = '#A50026';
        case 'alpha'
            colour = '#F46D43';
        case 'beta'
            colour = '#FDCC3F';
        case 'gamma'
            colour = '#66BD63';
        case 'highGamma'
            colour = '#006837';
    end

    % for each timepoint
    for i = 1:size(frequency,2)
        % calculate two-tailed 95% confidence intervals
        confInt.range(i) = 1.96*(std(range(:,i))/sqrt(size(range,1)));
        confInt.frequency(i) = 1.96*(std(frequency(:,i))/sqrt(size(frequency,1)));
        % calculate whether difference from zero is significant (one-sample
        % t-test, one-tailed)
        [~,p.zero.range(i)] = ttest(range(:,i),0,'Tail','right');
        [~,p.zero.frequency(i)] = ttest(frequency(:,i),0,'Tail','right');
        % calculate whether difference between specific range and all ranges is
        % significant (paired t-test, two-tailed)
        [~,p.difference(i)] = ttest(range(:,i),frequency(:,i));
    end
    % if there is no variance (i.e. if the model performs at chance), we
    % cannot perform a t-test. So set p to 1
    p.zero.range(isnan(p.zero.range)) = 1;
    p.zero.frequency(isnan(p.zero.frequency)) = 1;
    p.difference(isnan(p.difference)) = 1;

    % control the false discovery rate (Benjamini & Hochberg, 1995)
    p.zero.range = mafdr(p.zero.range,'BHFDR',1);
    p.zero.frequency = mafdr(p.zero.frequency,'BHFDR',1);
    p.difference = mafdr(p.difference,'BHFDR',1);

    % plot
    f = figure;
    % plot timecourse for all frequencies in blue
    plot(1:size(frequency,2),mean(frequency),'Color',hex2rgb('#0066FF'),'LineWidth',1.5)
    % plot 95% confidence interval for all frequencies as a ribbon
    hold on
    fill([1:size(frequency,2),fliplr(1:size(frequency,2))],[mean(frequency)-confInt.frequency,fliplr(mean(frequency)+confInt.frequency)],hex2rgb('#0066FF'),'FaceAlpha',0.2,'EdgeColor','None') 
    % plot timecourse for specific frequency range in the specified colour
    plot(1:size(range,2),mean(range),'Color',hex2rgb(colour),'LineWidth',1.5)
    % plot 95% confidence interval as a ribbon
    fill([1:size(range,2),fliplr(1:size(range,2))],[mean(range)-confInt.range,fliplr(mean(range)+confInt.range)],hex2rgb(colour),'FaceAlpha',0.2,'EdgeColor','None')
    
    % set axes
    axes = gca(f);
    % x axis
    xlim(axes,[0,size(frequency,2)]);
    xticks(1:50:size(frequency,2));
    xticklabels(num2cell(0:500:1650));
    xlabel('Time (ms)');
    % y axis
    ylim(axes,[-0.1,1]);
    yticks(-0.1:0.1:1);
    yline(0,'--');
    ylabel('Cross-validated correlation');

    % plot dots to show significance
    % all frequencies - difference from zero
    tmp = 1:size(frequency,2);
    tmp(p.zero.frequency >= 0.05) = [];
    dots = plot(tmp,repmat(0.975,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots) % (if there are no dots, we can't set their colour)
        dots.Color = hex2rgb('#0066FF');
    end
    % specific frequency range - difference from zero
    tmp = 1:size(range,2);
    tmp(p.zero.range >= 0.05) = [];
    dots = plot(tmp,repmat(0.95,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots)
        dots.Color = hex2rgb(colour);
    end
    % difference from each other
    tmp = 1:size(frequency,2);
    tmp(p.difference >= 0.05) = [];
    dots = plot(tmp,repmat(0.925,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots)
        dots.Color = hex2rgb('#000000');
    end
    
end