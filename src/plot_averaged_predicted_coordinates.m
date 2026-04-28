% Averages predicted coordinates to create category centroids and plots
% these at each timepoint.

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root); 

% if predicted coordinates are missing
if ~exist([root,'/results/averaged_adjusted_coordinates.mat'])
    % generate them
    calculate_average_coordinates;
% otherwise, load them
else
    load([root,'/results/averaged_adjusted_coordinates.mat']);
end

% also load ordinary decoding results
load([root,'/results/timecourses.mat']);

% also load stimuli names
load('/group/mlr-lab/Saskia/ECoG_RSL/src/stimuli.mat')

% set data types - phase, power, or voltage
dataType = {'power','phase','voltage'};
% set frequency ranges
frequencyRange = {'all','theta','alpha','beta','gamma','highGamma'};
% set timepoints on which the wavelet used to extract time-frequency power
% or phase is centred (or, for voltage jobs, the window on which the window
% is centred)
waveletCentre = 0:10:1650;

% set item catgories - this vector is in the same order as stimuli.mat
% 1 = land mammal (red)
% 2 = bird (orange)
% 3 = invertebrate (mustard)
% 4 = other animal (magenta)
% 5 = vehicle (navy)
% 6 = instrument (green)
% 7 = clothes (teal)
% 8 = other inanimate (grey)
categories = [4; 2; 3; 4; 3; 4; 4; 3; 3; 1; 3; 1; 1; 3; 1; 1; 1; 2; 2; 1; 4; 3; 1; 4; 1; 1; 1; 1; 1; 1; 3; 1; 1; 2; 2; 2; 2; 1; 1; 1; 1; 3; 1; 3; 4; 3; 1; 2; 1; 1; 6; 8; 8; 8; 5; 8; 8; 5; 8; 8; 8; 6; 8; 8; 8; 8; 8; 8; 7; 7; 6; 8; 6; 7; 6; 8; 8; 6; 5; 8; 8; 8; 7; 5; 8; 6; 5; 7; 5; 8; 8; 8; 8; 5; 6; 8; 6; 8; 6; 8];
categoryLabels = {'Land mammals', 'Birds', 'Invertebrates', 'Other animals', 'Vehicles', 'Instruments', 'Clothes', 'Other inanimate'};
                
% colours (RGB triplets) - these are picked with an online colour picker to
% correspond to Figure 1 in Chris's paper (Cox et al., 2024, Imaging
% Neuroscience)
colours = [216, 34, 44;
    252, 163, 20;
    219, 165, 37;
    185, 80, 163;
    56, 79, 166;
    34, 138, 63;
    50, 191, 201;
    189, 189, 189]/255;

% dot size (originally 25)
dotSize = 50;
% line width 
% calcuate this to be the same as the dot diameter, to make a
% smooth trajectory
% lineWidth = 2 * sqrt(dotSize/pi);
% alternatively, make it thin
lineWidth = 1;

% for each data type
for t = 1:length(dataType)

    % if this is a voltage job (and so we don't have frequency ranges)
    if strcmp(dataType{t},'voltage')

        % initialise figure
        fig = figure('Units','pixels','Position',[100 100 1120 840]);

        % for each wavelet centre
        for w = 1:length(waveletCentre)

            % plot the timecourse up to this point - D1 for all stimuli, D2
            % for animate only, D3 for inanimate only
            axisTimecourse = subplot(3,4,[1:3]);
            [lineD1, lineD2, lineD3] = plot_three_dimensions(groupTimecourses.voltage.D1.all, groupTimecourses.voltage.D2.animate, groupTimecourses.voltage.D3.inanimate, 'voltage', w);
            xticks([1:25:151])
            xticklabels(0:250:1500)
            yticks([0:0.2:1])
            title('Decoding timecourse')
            legend([lineD1, lineD2, lineD3],'D1 - all stimuli','D2 - animate only','D3 - inanimate only')
            legend boxoff

            % then, get the predicted coordinates
            tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & averagedAdjustedResults.waveletCentre == waveletCentre(w)), :);
            coordinates = tmp{1,4}{1};

            % if this is time 0 (stimulus onset)
            if w == 1

                % initialise graphics handle arrays to keep track of
                % the dots in each category - one for D2; one for D3
                coordinatesScatterD2 = gobjects(8,1);
                coordinatesScatterD3 = gobjects(8,1);

                % subplot D2
                axisD2 = subplot(3,4,[5,6,9,10]);
                % for each stimulus category
                for c = 1:8
                    % plot dots in the right colour
                    coordinatesScatterD2(c) = scatter(mean(coordinates(categories == c,2)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                    hold on
                end
                % set axis 
                xlim([-0.1,0.1])
                xlabel('Dimension 2')
                ylim([-0.4,0.4])
                ylabel('Dimension 1')
                box on

                % subplot D3
                axisD3 = subplot(3,4,[7,8,11,12]);
                % for each stimulus category
                for c = 1:8
                    % plot dots in the right colour
                    coordinatesScatterD3(c) = scatter(mean(coordinates(categories == c,3)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                    hold on
                end
                % set axis 
                xlim([-0.1,0.1])
                xlabel('Dimension 3')
                ylim([-0.4,0.4])
                box on
               
                % make a legend
                axisLegend = subplot(3,4,4);
                % plot each marker and label it
                for c = 1:8
                   scatter(0.4, 9 - c, dotSize, colours(c,:), 'filled', 'MarkerEdgeColor', 'k'); 
                   text(0.6, 9 - c, categoryLabels{c}, 'FontSize', 10);
                   hold on
                end
                % set axis
                xlim([0,3])
                ylim([0,9])
                set(axisLegend,'xtick',[],'ytick',[])
                title('Key')
                box on

                % set the title of all the plots
                annotation('textbox', [0, 0.985, 1, 0], 'String', 'Voltage', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'EdgeColor', 'none', 'FontSize', 12, 'FontWeight', 'bold');
                % make a subtitle that spans both of the coordinate plots
                % (it is important to do this after setting the main title,
                % to get the right relative positioning)
                axisSubtitle = axes('Position',[axisD2.Position(1), axisD2.Position(2), axisD3.Position(1) + axisD3.Position(3) - axisD2.Position(1), axisD2.Position(4)], 'Visible', 'off');
                subtitle = title(axisSubtitle,'Predicted coordinates (averaged across patients)', 'Visible', 'on');
                subtitle.Position(2) = axisTimecourse.Title.Position(2);
                
                % make it a bit less pixellated
                set(fig,'Renderer','painters')
                % control the output size
                set(fig,'PaperPositionMode','auto')
             
                % save the full figure
                if ~exist([root,'/results/figures/trajectories/categories/',dataType{t},'/full/'])
                    mkdir([root,'/results/figures/trajectories/categories/',dataType{t},'/full/'])
                end
                print(fig,[root,'/results/figures/trajectories/categories/',dataType{t},'/full/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');

                % also save the subplots individually. This requires
                % copying each subplot into a new figure.

                % subplot D2
                panelD2 = figure;
                % make it square
                panelD2.Position(3:4) = [560 560];
                % copy the subplot in
                axisD2 = copyobj(axisD2, panelD2);
                % make it fill the figure
                set(axisD2, 'Position', [0.1,0.1,0.8,0.8]);
                % make it a bit less pixellated
                set(panelD2,'Renderer','painters')
                % control the output size
                set(panelD2,'PaperPositionMode','auto')
                % save
                if ~exist([root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D2/'])
                    mkdir([root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D2/'])
                end
                print(panelD2,[root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D2/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                % close
                close(panelD2)

                % subplot D3
                panelD3 = figure;
                % make it square
                panelD3.Position(3:4) = [560 560];
                % copy the subplot in
                axisD3 = copyobj(axisD3, panelD3);
                % make it fill the figure
                set(axisD3, 'Position', [0.1,0.1,0.8,0.8]);
                % make it a bit less pixellated
                set(panelD3,'Renderer','painters')
                % control the output size
                set(panelD3,'PaperPositionMode','auto')
                % save
                if ~exist([root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D3/'])
                    mkdir([root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D3/'])
                end
                print(panelD3,[root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D3/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                % close
                close(panelD3)

            % otherwise, if this is a timepoint after 0
            else

                % delete the points from the previous timepoint
                delete(coordinatesScatterD2);
                delete(coordinatesScatterD3);
                clear coordinatesScatterD2 coordinatesScatterD3
                % also get the coordinates from the previous
                % timepoint
                tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & averagedAdjustedResults.waveletCentre == waveletCentre(w - 1)), :);
                previousCoordinates = tmp{1,4}{1};

                % plot the coordinates at this timepoint - on top
                % of the previous figure
                % initialise graphics handle arrays to keep track of
                % the dots in each category - one for D2; one for D3
                coordinatesScatterD2 = gobjects(8,1);
                coordinatesScatterD3 = gobjects(8,1);

                % subplot D2
                axisD2 = subplot(3,4,[5,6,9,10]);
                for c = 1:8
                    % draw trajectories between these dots and the
                    % dots representing the previous timepoint
                    plot([mean(previousCoordinates(categories == c,2)');mean(coordinates(categories == c,2)')],[mean(previousCoordinates(categories == c,1)');mean(coordinates(categories == c,1)')],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                    % plot dots in the right colour
                    coordinatesScatterD2(c) = scatter(mean(coordinates(categories == c,2)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                end

                % subplot D3
                axisD3 = subplot(3,4,[7,8,11,12]);
                for c = 1:8
                    % draw trajectories between these dots and the
                    % dots representing the previous timepoint
                    plot([mean(previousCoordinates(categories == c,3)');mean(coordinates(categories == c,3)')],[mean(previousCoordinates(categories == c,1)');mean(coordinates(categories == c,1)')],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                    % plot dots in the right colour
                    coordinatesScatterD3(c) = scatter(mean(coordinates(categories == c,3)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                end

                % add the subtitle back on
                axisSubtitle = axes('Position',[axisD2.Position(1), axisD2.Position(2), axisD3.Position(1) + axisD3.Position(3) - axisD2.Position(1), axisD2.Position(4)], 'Visible', 'off');
                subtitle = title(axisSubtitle,'Predicted coordinates (averaged across patients)', 'Visible', 'on');
                subtitle.Position(2) = axisTimecourse.Title.Position(2);
                
                % save the full figure
                print(fig,[root,'/results/figures/trajectories/categories/',dataType{t},'/full/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');

                % also save the subplots individually

                % subplot D2
                panelD2 = figure;
                % make it square
                panelD2.Position(3:4) = [560 560];
                % copy the subplot in
                axisD2 = copyobj(axisD2, panelD2);
                % make it fill the figure
                set(axisD2, 'Position', [0.1,0.1,0.8,0.8]);
                % make it a bit less pixellated
                set(panelD2,'Renderer','painters')
                % control the output size
                set(panelD2,'PaperPositionMode','auto')
                % save
                print(panelD2,[root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D2/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                % close
                close(panelD2)

                % subplot D3
                panelD3 = figure;
                % make it square
                panelD3.Position(3:4) = [560 560];
                % copy the subplot in
                axisD3 = copyobj(axisD3, panelD3);
                % make it fill the figure
                set(axisD3, 'Position', [0.1,0.1,0.8,0.8]);
                % make it a bit less pixellated
                set(panelD3,'Renderer','painters')
                % control the output size
                set(panelD3,'PaperPositionMode','auto')
                % save
                print(panelD3,[root,'/results/figures/trajectories/categories/',dataType{t},'/panel/D3/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                % close
                close(panelD3)

                % at the final timepoint
                if w == length(waveletCentre)

                    % close the figure
                    close(fig)
                end
            end
        end

    % otherwise, for phase and power jobs (for which we do have frequency
    % ranges)
    else

        % for each frequency range
        for f = 1:length(frequencyRange)

            % initialise figure
            fig = figure('Units','pixels','Position',[100 100 1120 840]);

            % for each wavelet centre
            for w = 1:length(waveletCentre)

                % plot the timecourse up to this point - D1 for all stimuli, D2
                % for animate only, D3 for inanimate only
                axisTimecourse = subplot(3,4,[1:3]);
                [lineD1, lineD2, lineD3] = plot_three_dimensions(groupTimecourses.(dataType{t}).(frequencyRange{f}).D1.all, groupTimecourses.(dataType{t}).(frequencyRange{f}).D2.animate, groupTimecourses.(dataType{t}).(frequencyRange{f}).D3.inanimate, frequencyRange{f}, w);
                xticks([1:25:151])
                xticklabels(0:250:1500)
                yticks([0:0.2:1])
                title('Decoding timecourse')
                legend([lineD1, lineD2, lineD3],'D1 - all stimuli','D2 - animate only','D3 - inanimate only')
                legend boxoff

                % then, get the predicted coordinates
                tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & strcmp(averagedAdjustedResults.frequencyRange,frequencyRange{f}) & averagedAdjustedResults.waveletCentre == waveletCentre(w)), :);
                coordinates = tmp{1,4}{1};
   
                % if this is time 0 (stimulus onset)
                if w == 1

                    % initialise graphics handle arrays to keep track of
                    % the dots in each category - one for D2; one for D3
                    coordinatesScatterD2 = gobjects(8,1);
                    coordinatesScatterD3 = gobjects(8,1);
    
                    % subplot D2
                    axisD2 = subplot(3,4,[5,6,9,10]);
                    % for each stimulus category
                    for c = 1:8
                        % plot dots in the right colour
                        coordinatesScatterD2(c) = scatter(mean(coordinates(categories == c,2)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                        hold on
                    end
                    % set axis 
                    xlim([-0.1,0.1])
                    xlabel('Dimension 2')
                    ylim([-0.4,0.4])
                    ylabel('Dimension 1')
                    box on
    
                    % subplot D3
                    axisD3 = subplot(3,4,[7,8,11,12]);
                    % for each stimulus category
                    for c = 1:8
                        % plot dots in the right colour
                        coordinatesScatterD3(c) = scatter(mean(coordinates(categories == c,3)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                        hold on
                    end
                    % set axis 
                    xlim([-0.1,0.1])
                    xlabel('Dimension 3')
                    ylim([-0.4,0.4])
                    box on
                   
                    % make a legend
                    axisLegend = subplot(3,4,4);
                    % plot each marker and label it
                    for c = 1:8
                       scatter(0.4, 9 - c, dotSize, colours(c,:), 'filled', 'MarkerEdgeColor', 'k'); 
                       text(0.6, 9 - c, categoryLabels{c}, 'FontSize', 10);
                       hold on
                    end
                    % set axis
                    xlim([0,3])
                    ylim([0,9])
                    set(axisLegend,'xtick',[],'ytick',[])
                    title('Key')
                    box on

                    % set the title of all the plots (cheekily capitalising
                    % on the fact that both power and phase begin with p)
                    % if it is a high gamma job
                    if f == 6
                        % add the right spacing between words
                        annotation('textbox', [0, 0.985, 1, 0], 'String', ['P',dataType{t}(2:end),' - high gamma'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'EdgeColor', 'none', 'FontSize', 12, 'FontWeight', 'bold');
                    else
                        annotation('textbox', [0, 0.985, 1, 0], 'String', ['P',dataType{t}(2:end),' - ',frequencyRange{f}], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'EdgeColor', 'none', 'FontSize', 12, 'FontWeight', 'bold');
                    end
                    % make a subtitle that spans both of the coordinate plots
                    % (it is important to do this after setting the main title,
                    % to get the right relative positioning)
                    axisSubtitle = axes('Position',[axisD2.Position(1), axisD2.Position(2), axisD3.Position(1) + axisD3.Position(3) - axisD2.Position(1), axisD2.Position(4)], 'Visible', 'off');
                    subtitle = title(axisSubtitle,'Predicted coordinates (averaged across patients)', 'Visible', 'on');
                    subtitle.Position(2) = axisTimecourse.Title.Position(2);
                    
                    % make it a bit less pixellated
                    set(fig,'Renderer','painters')
                    % control the output size
                    set(fig,'PaperPositionMode','auto')
                   
                    % save the full figure
                    if ~exist([root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/full/'])
                        mkdir([root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/full/'])
                    end
                    print(fig,[root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/full/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');

                    % also save the subplots individually. This requires
                    % copying each subplot into a new figure.
    
                    % subplot D2
                    panelD2 = figure;
                    % make it square
                    panelD2.Position(3:4) = [560 560];
                    % copy the subplot in
                    axisD2 = copyobj(axisD2, panelD2);
                    % make it fill the figure
                    set(axisD2, 'Position', [0.1,0.1,0.8,0.8]);
                    % make it a bit less pixellated
                    set(panelD2,'Renderer','painters')
                    % control the output size
                    set(panelD2,'PaperPositionMode','auto')
                    % save
                    if ~exist([root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D2/'])
                        mkdir([root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D2/'])
                    end
                    print(panelD2,[root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D2/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                    % close
                    close(panelD2)
    
                    % subplot D3
                    panelD3 = figure;
                    % make it square
                    panelD3.Position(3:4) = [560 560];
                    % copy the subplot in
                    axisD3 = copyobj(axisD3, panelD3);
                    % make it fill the figure
                    set(axisD3, 'Position', [0.1,0.1,0.8,0.8]);
                    % make it a bit less pixellated
                    set(panelD3,'Renderer','painters')
                    % control the output size
                    set(panelD3,'PaperPositionMode','auto')
                    % save
                    if ~exist([root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D3/'])
                        mkdir([root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D3/'])
                    end
                    print(panelD3,[root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D3/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                    % close
                    close(panelD3)

                % otherwise, if this is a timepoint after 0
                else

                    % delete the points from the previous timepoint
                    delete(coordinatesScatterD2);
                    delete(coordinatesScatterD3);
                    clear coordinatesScatterD2 coordinatesScatterD3
                    % also get the coordinates from the previous
                    % timepoint
                    tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & strcmp(averagedAdjustedResults.frequencyRange,frequencyRange{f}) & averagedAdjustedResults.waveletCentre == waveletCentre(w - 1)), :);
                    previousCoordinates = tmp{1,4}{1};
    
                    % plot the coordinates at this timepoint - on top
                    % of the previous figure
                    % initialise graphics handle arrays to keep track of
                    % the dots in each category - one for D2; one for D3
                    coordinatesScatterD2 = gobjects(8,1);
                    coordinatesScatterD3 = gobjects(8,1);
    
                    % subplot D2
                    axisD2 = subplot(3,4,[5,6,9,10]);
                    for c = 1:8
                        % draw trajectories between these dots and the
                        % dots representing the previous timepoint
                        plot([mean(previousCoordinates(categories == c,2)');mean(coordinates(categories == c,2)')],[mean(previousCoordinates(categories == c,1)');mean(coordinates(categories == c,1)')],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                        % plot dots in the right colour
                        coordinatesScatterD2(c) = scatter(mean(coordinates(categories == c,2)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                    end
    
                    % subplot D3
                    axisD3 = subplot(3,4,[7,8,11,12]);
                    for c = 1:8
                        % draw trajectories between these dots and the
                        % dots representing the previous timepoint
                        plot([mean(previousCoordinates(categories == c,3)');mean(coordinates(categories == c,3)')],[mean(previousCoordinates(categories == c,1)');mean(coordinates(categories == c,1)')],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                        % plot dots in the right colour
                        coordinatesScatterD3(c) = scatter(mean(coordinates(categories == c,3)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                    end
    
                    % add the subtitle back on
                    axisSubtitle = axes('Position',[axisD2.Position(1), axisD2.Position(2), axisD3.Position(1) + axisD3.Position(3) - axisD2.Position(1), axisD2.Position(4)], 'Visible', 'off');
                    subtitle = title(axisSubtitle,'Predicted coordinates (averaged across patients)', 'Visible', 'on');
                    subtitle.Position(2) = axisTimecourse.Title.Position(2);
                    
                    % save
                    print(fig,[root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/full/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');

                    % also save the subplots individually

                    % subplot D2
                    panelD2 = figure;
                    % make it square
                    panelD2.Position(3:4) = [560 560];
                    % copy the subplot in
                    axisD2 = copyobj(axisD2, panelD2);
                    % make it fill the figure
                    set(axisD2, 'Position', [0.1,0.1,0.8,0.8]);
                    % make it a bit less pixellated
                    set(panelD2,'Renderer','painters')
                    % control the output size
                    set(panelD2,'PaperPositionMode','auto')
                    % save
                    print(panelD2,[root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D2/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                    % close
                    close(panelD2)
    
                    % subplot D3
                    panelD3 = figure;
                    % make it square
                    panelD3.Position(3:4) = [560 560];
                    % copy the subplot in
                    axisD3 = copyobj(axisD3, panelD3);
                    % make it fill the figure
                    set(axisD3, 'Position', [0.1,0.1,0.8,0.8]);
                    % make it a bit less pixellated
                    set(panelD3,'Renderer','painters')
                    % control the output size
                    set(panelD3,'PaperPositionMode','auto')
                    % save
                    print(panelD3,[root,'/results/figures/trajectories/categories/',dataType{t},'/',frequencyRange{f},'/panel/D3/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
                    % close
                    close(panelD3)
                   
                    % at the final timepoint
                    if w == length(waveletCentre)

                    % close the figure
                        close(fig)
                    end
                end
            end
        end
    end
end


