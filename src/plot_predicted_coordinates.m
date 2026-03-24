% Create plots of predicted coordinates at each timepoint.

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

            % plot the timecourse up to this point
            axisTimecourse = subplot(3,4,[1:3]);
            plot_three_dimensions(groupTimecourses.voltage.D1.all, groupTimecourses.voltage.D2.all, groupTimecourses.voltage.D3.all, 'voltage', w);
            xticks([1:25:151])
            xticklabels(0:250:1500)
            yticks([0:0.2:1])
            title('Decoding timecourse')

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
                    coordinatesScatterD2(c) = scatter(coordinates(categories == c,2),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
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
                    coordinatesScatterD3(c) = scatter(coordinates(categories == c,3),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
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
                % adjust the heights of all the titles up a bit
                axisTimecourse.Title.Position(2) = axisTimecourse.Title.Position(2) + 0.01;
                subtitle.Position(2) = subtitle.Position(2) + 0.01;
                axisLegend.Title.Position(2) = axisLegend.Title.Position(2) + 0.01;

                % save the figure
                if ~exist([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/'])
                    mkdir([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/'])
                end
                print(fig,[root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');

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
                    plot([previousCoordinates(categories == c,2)';coordinates(categories == c,2)'],[previousCoordinates(categories == c,1)';coordinates(categories == c,1)'],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                    % plot dots in the right colour
                    coordinatesScatterD2(c) = scatter(coordinates(categories == c,2),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                end

                % subplot D3
                axisD3 = subplot(3,4,[7,8,11,12]);
                for c = 1:8
                    % draw trajectories between these dots and the
                    % dots representing the previous timepoint
                    plot([previousCoordinates(categories == c,3)';coordinates(categories == c,3)'],[previousCoordinates(categories == c,1)';coordinates(categories == c,1)'],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                    % plot dots in the right colour
                    coordinatesScatterD3(c) = scatter(coordinates(categories == c,3),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                end

                % add the subtitle back on
                axisSubtitle = axes('Position',[axisD2.Position(1), axisD2.Position(2), axisD3.Position(1) + axisD3.Position(3) - axisD2.Position(1), axisD2.Position(4)], 'Visible', 'off');
                subtitle = title(axisSubtitle,'Predicted coordinates (averaged across patients)', 'Visible', 'on');
                subtitle.Position(2) = axisTimecourse.Title.Position(2);
                
                % save
                print(fig,[root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');

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

            % for each wavelet centre
            for w = 1:length(waveletCentre)

                % get the data
                tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & strcmp(averagedAdjustedResults.frequencyRange,frequencyRange{f}) & averagedAdjustedResults.waveletCentre == waveletCentre(w)), :);
                coordinates = tmp{1,4}{1};
   
                % if this is time 0 (stimulus onset)
                if w == 1

                    % initialise the figure
                    fig = figure('Units','pixels','Position',[100 100 1120 840]);
                    % initialise a graphics handle array to keep track of
                    % the dots in each category
                    coordinatesScatterD2 = gobjects(8,1);
                    % for each stimulus category
                    for c = 1:8
                        % plot dots in the right colour
                        coordinatesScatterD2(c) = scatter(coordinates(categories == c,d),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
                        hold on
                    end
                    % set axis 
                    xlim([-0.1,0.1])
                    ylim([-0.4,0.4])
                    % make it a bit less pixellated
                    set(fig,'Renderer','painters')
                    % control the output size
                    set(fig,'PaperPositionMode','auto')

                    % save the figure
                    if ~exist([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                        mkdir([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                    end
                    print(fig,[root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
    
                % otherwise, if this is a timepoint after 0
                else

                    % delete the points from the previous timepoint
                    delete(coordinatesScatterD2);
                    clear coordinatesScatterD2
                    % also get the coordinates from the previous
                    % timepoint
                    tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & strcmp(averagedAdjustedResults.frequencyRange,frequencyRange{f}) & averagedAdjustedResults.waveletCentre == waveletCentre(w - 1)), :);
                    previousCoordinates = tmp{1,4}{1};

                    % plot the coordinates at this timepoint - on top
                    % of the previous figure
                    coordinatesScatterD2 = gobjects(8,1);
                    for c = 1:8
                        % draw trajectories between these dots and the
                        % dots representing the previous timepoint
                        plot([previousCoordinates(categories == c,d)';coordinates(categories == c,d)'],[previousCoordinates(categories == c,1)';coordinates(categories == c,1)'],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                        % plot dots in the right colour
                        coordinatesScatterD2(c) = scatter(coordinates(categories == c,d),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');   
                    end

                    % save the figure
                    if ~exist([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                        mkdir([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                    end
                    print(fig,[root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
    
                    % at the final timepoint
                    if w == length(waveletCentre)

                        % label the concepts
                        text(coordinates(:,d),coordinates(:,1),stimuli,'FontSize',10);
                        % save the figure
                        if ~exist([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                            mkdir([root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                        end
                        print(fig,[root,'/results/figures/trajectories/allitems_tmp/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/labels.png'],'-dpng','-r600');
        
                        % close the figure
                        close(fig)
                    end
                end
            end
        end
    end
end

