% Create plots of predicted coordinates at each timepoint. 

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root); 

% if input data are missing
if ~exist([root,'/results/averaged_adjusted_coordinates.mat'])
    % generate them
    calculate_average_coordinates;
% otherwise, load them
else
    load([root,'/results/averaged_adjusted_coordinates.mat']);
end

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

% dot size
dotSize = 25;
% line width - calcuate this to be the same as the dot diameter, to make a
% smooth trajectory
lineWidth = 2 * sqrt(dotSize/pi);

% We need to creat 2 sets of plots - one with dimension 2 as the x-axis, and
% one with dimension 3 as the x-axis (both have dimension 1 as the y-axis)
for d = 2:3

    % for each data type
    for t = 1:length(dataType)

        % if this is a voltage job (and so we don't have frequency ranges)
        if strcmp(dataType{t},'voltage')

            % for each wavelet centre
            for w = 1:length(waveletCentre)

                % get the data
                tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & averagedAdjustedResults.waveletCentre == waveletCentre(w)), :);
                coordinates = tmp{1,4}{1};
   
                % if this is time 0 (stimulus onset)
                if w == 1

                    % initialise the figure
                    fig = figure('Units','pixels','Position',[100 100 1120 840]);
                    % for each stimulus category
                    for c = 1:8
                        % plot dots in the right colour
                        scatter(coordinates(categories == c,d),coordinates(categories == c,1),dotSize,colours(c,:),'filled');
                        hold on
                    end
                    % set axis 
                    xlim([-0.4,0.4])
                    ylim([-0.4,0.4])
                    % make it a bit less pixellated
                    set(fig,'Renderer','painters')
                    % control the output size
                    set(fig,'PaperPositionMode','auto')

                    % save the figure
                    if ~exist([root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/'])
                        mkdir([root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/'])
                    end
                    print(fig,[root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
    
                % otherwise, if this is a timepoint after 0
                else

                    % also get the coordinates from the previous
                    % timepoint
                    tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & averagedAdjustedResults.waveletCentre == waveletCentre(w - 1)), :);
                    previousCoordinates = tmp{1,4}{1};

                    % plot the coordinates at this timepoint - on top
                    % of the previous figure
                    for c = 1:8
                        % plot dots in the right colour
                        scatter(coordinates(categories == c,d),coordinates(categories == c,1),dotSize,colours(c,:),'filled');
                        % draw trajectories between these dots and the
                        % dots representing the previous timepoint
                        plot([previousCoordinates(categories == c,d)';coordinates(categories == c,d)'],[previousCoordinates(categories == c,1)';coordinates(categories == c,1)'],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                    end

                    % save the figure
                    if ~exist([root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/'])
                        mkdir([root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/'])
                    end
                    print(fig,[root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
    
                    % at the final timepoint
                    if w == length(waveletCentre)

                        % label the concepts
                        text(coordinates(:,d),coordinates(:,1),stimuli,'FontSize',10);
                        % save the figure
                        if ~exist([root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/'])
                            mkdir([root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/'])
                        end
                        print(fig,[root,'/results/figures/trajectories/',dataType{t},'/D',num2str(d),'/labels.png'],'-dpng','-r600');
        
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
                        % for each stimulus category
                        for c = 1:8
                            % plot dots in the right colour
                            scatter(coordinates(categories == c,d),coordinates(categories == c,1),dotSize,colours(c,:),'filled');
                            hold on
                        end
                        % set axis 
                        xlim([-0.4,0.4])
                        ylim([-0.4,0.4])
                        % make it a bit less pixellated
                        set(fig,'Renderer','painters')
                        % control the output size
                        set(fig,'PaperPositionMode','auto')

                        % save the figure
                        if ~exist([root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                            mkdir([root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                        end
                        print(fig,[root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
        
                    % otherwise, if this is a timepoint after 0
                    else

                        % also get the coordinates from the previous
                        % timepoint
                        tmp = averagedAdjustedResults((strcmp(averagedAdjustedResults.dataType,dataType{t}) & strcmp(averagedAdjustedResults.frequencyRange,frequencyRange{f}) & averagedAdjustedResults.waveletCentre == waveletCentre(w - 1)), :);
                        previousCoordinates = tmp{1,4}{1};

                        % plot the coordinates at this timepoint - on top
                        % of the previous figure
                        for c = 1:8
                            % plot dots in the right colour
                            scatter(coordinates(categories == c,d),coordinates(categories == c,1),dotSize,colours(c,:),'filled');
                            % draw trajectories between these dots and the
                            % dots representing the previous timepoint
                            plot([previousCoordinates(categories == c,d)';coordinates(categories == c,d)'],[previousCoordinates(categories == c,1)';coordinates(categories == c,1)'],'k-','Color',colours(c,:),'LineWidth',lineWidth);
                        end

                        % save the figure
                        if ~exist([root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                            mkdir([root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                        end
                        print(fig,[root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/',sprintf('%04d',waveletCentre(w)),'.png'],'-dpng','-r600');
        
                        % at the final timepoint
                        if w == length(waveletCentre)

                            % label the concepts
                            text(coordinates(:,d),coordinates(:,1),stimuli,'FontSize',10);
                            % save the figure
                            if ~exist([root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                                mkdir([root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/'])
                            end
                            print(fig,[root,'/results/figures/trajectories/',dataType{t},'/',frequencyRange{f},'/D',num2str(d),'/labels.png'],'-dpng','-r600');
            
                            % close the figure
                            close(fig)
                        end
                    end
                end
            end
        end
    end
end
