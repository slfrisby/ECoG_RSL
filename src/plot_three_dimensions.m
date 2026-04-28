function [lineD1, lineD2, lineD3] = plot_three_dimensions(D1,D2,D3,dataType,w)

    % plot hold-out correlations for all three dimensions on a single
    % subplot. 
    
    % Arguments:
    % D1 - matrix of cross-validated correlations for D1 - power, phase, or voltage (participants x timepoints; double)
    % D2 - matrix of cross-validated correlations for D2 (participants x timepoints; double)
    % D3 - matrix of cross-validated correlations for D2 (participants x timepoints; double)
    % dataType = 'voltage', 'all', 'theta', 'alpha', 'beta',
    % 'gamma', or 'highGamma' (character array)
    % w - timepoint index (integer). Data are plotted up to this timepoint. E.g. when
    % w = 2, the first and second timepoints (0 ms and 10 ms) are plotted.
    % When w = 166, all timepoints are plotted.

    % add plotting functions to path
    addpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies');

    % for each timepoint
    for i = 1:size(D1,2)
        % calculate two-tailed 95% confidence intervals
        confInt.D1(i) = 1.96*(std(D1(:,i))/sqrt(size(D1,1)));
        confInt.D2(i) = 1.96*(std(D2(:,i))/sqrt(size(D2,1)));
        confInt.D3(i) = 1.96*(std(D3(:,i))/sqrt(size(D3,1)));
        % calculate whether difference from zero is significant (one-sample
        % t-test, two-tailed)
        [~,p.zero.D1(i)] = ttest(D1(:,i),0,'Tail','right');
        [~,p.zero.D2(i)] = ttest(D2(:,i),0,'Tail','right');
        [~,p.zero.D3(i)] = ttest(D3(:,i),0,'Tail','right');
    end
    % if there is no variance (i.e. if the model performs at chance), we
    % cannot perform a t-test. So set p to 1
    p.zero.D1(isnan(p.zero.D1)) = 1;
    p.zero.D2(isnan(p.zero.D2)) = 1;
    p.zero.D3(isnan(p.zero.D3)) = 1;

    % control the false discovery rate (Benjamini & Hochberg, 1995)
    p.zero.D1 = mafdr(p.zero.D1,'BHFDR',1);
    p.zero.D2 = mafdr(p.zero.D2,'BHFDR',1);
    p.zero.D3 = mafdr(p.zero.D3,'BHFDR',1);

    % select colour
    switch dataType
        % power or phase at all frequencies - blue
        case 'all'
            colour = hex2rgb('#0066FF');
        % theta - red
        case 'theta'
            colour = hex2rgb('#A50026');
        % alpha - orange
        case 'alpha' 
            colour = hex2rgb('#F46D43');
        % beta - yellow
        case 'beta'
            colour = hex2rgb('#FDCC3F');
        case 'gamma'
            colour = hex2rgb('#66BD63');
        case 'highGamma'
            colour = hex2rgb('#006837');
        case 'voltage'
            colour = hex2rgb('#996035');
    end

    % select timepoints from 1 to w for plotting
    D1(:,(w + 1):end) = NaN;
    D2(:,(w + 1):end) = NaN;
    D3(:,(w + 1):end) = NaN;
    % select the corresponding dots for plotting
    p.zero.D1((w + 1):end) = 1;
    p.zero.D2((w + 1):end) = 1;
    p.zero.D3((w + 1):end) = 1;
          
    % plot timecourses in progressively less saturated colours
    lineD1 = plot(1:size(D1,2),mean(D1),'Color',colour,'LineWidth',1.5)
    hold on 
    lineD2 = plot(1:size(D2,2),mean(D2),'Color',[colour,0.5],'LineWidth',1.5)
    lineD3 = plot(1:size(D3,2),mean(D3),'Color',[colour,0.3],'LineWidth',1.5)

    % set axes
    axes = gca;
    % x axis
    xlim(axes,[0,size(D1,2)]);
    xticks(1:50:size(D1,2));
    xticklabels(num2cell(0:500:1650));
    xlabel('Time (ms)');
    % y axis
    ylim(axes,[-0.1,1]);
    yticks(-0.1:0.1:1);
    yline(0,'--');
    ylabel('Cross-validated correlation');

    % plot dots to show significance
    % D1 - difference from zero
    tmp = 1:size(D1,2);
    tmp(p.zero.D1 >= 0.05) = [];
    scatter(tmp,repmat(0.975,1,length(tmp)), 10, colour, 'filled', 'MarkerFaceAlpha', 1, 'MarkerEdgeColor', 'none');

    % D2 - difference from zero
    tmp = 1:size(D2,2);
    tmp(p.zero.D2 >= 0.05) = [];
    scatter(tmp,repmat(0.95,1,length(tmp)), 10, colour, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none');

    % D3 - difference from zero
    tmp = 1:size(D3,2);
    tmp(p.zero.D3 >= 0.05) = [];
    scatter(tmp,repmat(0.925,1,length(tmp)), 10, colour, 'filled', 'MarkerFaceAlpha', 0.3, 'MarkerEdgeColor', 'none');

    hold off
end
