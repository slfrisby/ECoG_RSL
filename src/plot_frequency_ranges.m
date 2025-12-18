function f = plot_frequency_ranges(theta,alpha,beta,gamma,highGamma)

    % plot hold-out correlations for different frequency ranges.

    % Arguments:
    % theta - matrix of theta data, either power or phase (participants x timepoints; double)
    % alpha - matrix of voltage data (participants x timepoints; double)
    % beta - matrix of power data (participants x timepoints; double)
    % gamma - matrix of voltage data (participants x x timepoints; double)
    % highGamma - matrix of power data (participants x x timepoints; double)

    % for each timepoint
    for i = 1:size(theta,2)
        % calculate two-tailed 95% confidence intervals
        confInt.theta(i) = 1.96*(std(theta(:,i))/sqrt(size(theta,1)));
        confInt.alpha(i) = 1.96*(std(alpha(:,i))/sqrt(size(alpha,1)));
        confInt.beta(i) = 1.96*(std(beta(:,i))/sqrt(size(beta,1)));
        confInt.gamma(i) = 1.96*(std(gamma(:,i))/sqrt(size(gamma,1)));
        confInt.highGamma(i) = 1.96*(std(highGamma(:,i))/sqrt(size(highGamma,1)));
        % calculate whether difference from zero is significant (one-sample
        % t-test, two-tailed)
        [~,p.zero.theta(i)] = ttest(theta(:,i),0,'Tail','right');
        [~,p.zero.alpha(i)] = ttest(alpha(:,i),0,'Tail','right');
        [~,p.zero.beta(i)] = ttest(beta(:,i),0,'Tail','right');
        [~,p.zero.gamma(i)] = ttest(gamma(:,i),0,'Tail','right');
        [~,p.zero.highGamma(i)] = ttest(highGamma(:,i),0,'Tail','right');
    end
    % if there is no variance (i.e. if the model performs at chance), we
    % cannot perform a t-test. So set p to 1
    p.zero.theta(isnan(p.zero.theta)) = 1;
    p.zero.alpha(isnan(p.zero.alpha)) = 1;
    p.zero.beta(isnan(p.zero.beta)) = 1;
    p.zero.gamma(isnan(p.zero.gamma)) = 1;
    p.zero.highGamma(isnan(p.zero.highGamma)) = 1;
    % control the false discovery rate (Benjamini & Hochberg, 1995)
    p.zero.theta = mafdr(p.zero.theta,'BHFDR',1);
    p.zero.alpha = mafdr(p.zero.alpha,'BHFDR',1);
    p.zero.beta = mafdr(p.zero.beta,'BHFDR',1);
    p.zero.gamma = mafdr(p.zero.gamma,'BHFDR',1);
    p.zero.highGamma = mafdr(p.zero.highGamma,'BHFDR',1);
    
    % plot
    f = figure;
    % plot theta timecourse in red
    plot(1:size(theta,2),mean(theta),'Color',hex2rgb('#A50026'),'LineWidth',1.5)
    % plot voltage 95% confidence interval as a ribbon
    hold on
    fill([1:size(theta,2),fliplr(1:size(theta,2))],[mean(theta)-confInt.theta,fliplr(mean(theta)+confInt.theta)],hex2rgb('#A50026'),'FaceAlpha',0.2,'EdgeColor','None') 
    % plot alpha timecourse and confidence interval in orange
    plot(1:size(alpha,2),mean(alpha),'Color',hex2rgb('#F46D43'),'LineWidth',1.5)
    fill([1:size(alpha,2),fliplr(1:size(alpha,2))],[mean(alpha)-confInt.alpha,fliplr(mean(alpha)+confInt.alpha)],hex2rgb('#F46D43'),'FaceAlpha',0.2,'EdgeColor','None') 
    % plot beta timecourse and confidence interval in yellow
    plot(1:size(beta,2),mean(beta),'Color',hex2rgb('#FDCC3F'),'LineWidth',1.5)
    fill([1:size(beta,2),fliplr(1:size(beta,2))],[mean(beta)-confInt.beta,fliplr(mean(beta)+confInt.beta)],hex2rgb('#FDCC3F'),'FaceAlpha',0.2,'EdgeColor','None') 
    % plot gamma timecourse and confidence interval in light green
    plot(1:size(gamma,2),mean(gamma),'Color',hex2rgb('#66BD63'),'LineWidth',1.5)
    fill([1:size(gamma,2),fliplr(1:size(gamma,2))],[mean(gamma)-confInt.gamma,fliplr(mean(gamma)+confInt.gamma)],hex2rgb('#66BD63'),'FaceAlpha',0.2,'EdgeColor','None') 
    % plot high gamma timecourse and confidence interval in dark green
    plot(1:size(highGamma,2),mean(highGamma),'Color',hex2rgb('#006837'),'LineWidth',1.5)
    fill([1:size(highGamma,2),fliplr(1:size(highGamma,2))],[mean(highGamma)-confInt.highGamma,fliplr(mean(highGamma)+confInt.highGamma)],hex2rgb('#006837'),'FaceAlpha',0.2,'EdgeColor','None') 
    
    % set axes
    axes = gca(f);
    % x axis
    xlim(axes,[0,size(theta,2)]);
    xticks(1:50:size(theta,2));
    xticklabels(num2cell(0:500:1650));
    xlabel('Time (ms)');
    % y axis
    ylim(axes,[-0.1,1]);
    yticks(-0.1:0.1:1);
    yline(0,'--');
    ylabel('Cross-validated correlation');

    % plot dots to show significance
    % theta - difference from zero
    tmp = 1:size(theta,2);
    tmp(p.zero.theta >= 0.05) = [];
    dots = plot(tmp,repmat(0.975,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots) % (if there are no dots, we can't set their colour)
        dots.Color = hex2rgb('#A50026');
    end
    % alpha - difference from zero
    tmp = 1:size(alpha,2);
    tmp(p.zero.alpha >= 0.05) = [];
    dots = plot(tmp,repmat(0.95,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots) % (if there are no dots, we can't set their colour)
        dots.Color = hex2rgb('#F46D43');
    end
    % beta - difference from zero
    tmp = 1:size(beta,2);
    tmp(p.zero.beta >= 0.05) = [];
    dots = plot(tmp,repmat(0.925,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots) % (if there are no dots, we can't set their colour)
        dots.Color = hex2rgb('#FDCC3F');
    end
    % gamma - difference from zero
    tmp = 1:size(gamma,2);
    tmp(p.zero.gamma >= 0.05) = [];
    dots = plot(tmp,repmat(0.9,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots) % (if there are no dots, we can't set their colour)
        dots.Color = hex2rgb('#66BD63');
    end
    % high gamma - difference from zero
    tmp = 1:size(highGamma,2);
    tmp(p.zero.highGamma >= 0.05) = [];
    dots = plot(tmp,repmat(0.875,1,length(tmp)),'.','MarkerSize',10);
    if ~isempty(dots) % (if there are no dots, we can't set their colour)
        dots.Color = hex2rgb('#006837');
    end

end
