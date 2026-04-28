% plots target spaces (for all items and for averaged "centroids").

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
addpath(genpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/WISC_MVPA/'));
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root); 

% load stimuli names
load('/group/mlr-lab/Saskia/ECoG_RSL/src/stimuli.mat');
% load Dilkina norms
load('/group/mlr-lab/Saskia/ECoG_RSL/src/dilkina_norms.mat');
% convert to three-dimensional target space
[U,z] = embed_similarity_matrix(dilkinaNorms,3);
coordinates = rescale_embedding(U,z);

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

% first, plot for all items

% initialise figure
fig = figure('Units','pixels','Position',[100 100 1120 430]);

% initialise graphics handle arrays to keep track of
% the dots in each category - one for D2; one for D3
coordinatesScatterD2 = gobjects(8,1);
coordinatesScatterD3 = gobjects(8,1);

% subplot D2
subplot(2,5,[1,2,6,7])
% for each stimulus category
for c = 1:8
    % plot dots in the right colour
    coordinatesScatterD2(c) = scatter(coordinates(categories == c,2),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
    hold on
end
xlabel('Dimension 2')
ylabel('Dimension 1')
box on

% subplot D3
subplot(2,5,[3,4,8,9])
% for each stimulus category
for c = 1:8
    % plot dots in the right colour
    coordinatesScatterD3(c) = scatter(coordinates(categories == c,3),coordinates(categories == c,1),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
    hold on
end
xlabel('Dimension 3')
box on

% make a legend
axisLegend = subplot(2,5,[5,10]);
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
title('Key','FontSize',10)
box on

% make it a bit less pixellated
set(fig,'Renderer','painters')
% control the output size
set(fig,'PaperPositionMode','auto')

% save the figure
if ~exist([root,'/results/figures/targets/'])
    mkdir([root,'/results/figures/targets/'])
end
print(fig,[root,'/results/figures/targets/allitems.png'],'-dpng','-r600');

% then averaged coordinates

delete(coordinatesScatterD2);
delete(coordinatesScatterD3);
clear coordinatesScatterD2 coordinatesScatterD3

% subplot D2
subplot(2,5,[1,2,6,7])
% for each stimulus category
for c = 1:8
    % plot dots in the right colour
    coordinatesScatterD2(c) = scatter(mean(coordinates(categories == c,2)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
    hold on
end
xlim([-0.6,0.8])
ylim([-0.8,0.8])
xlabel('Dimension 2')
ylabel('Dimension 1')
box on

% subplot D3
subplot(2,5,[3,4,8,9])
% for each stimulus category
for c = 1:8
    % plot dots in the right colour
    coordinatesScatterD3(c) = scatter(mean(coordinates(categories == c,3)),mean(coordinates(categories == c,1)),dotSize,colours(c,:),'filled','MarkerEdgeColor','k');
    hold on
end
xlim([-0.6,0.8])
ylim([-0.8,0.8])
xlabel('Dimension 3')
box on

% make a legend
axisLegend = subplot(2,5,[5,10]);
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
title('Key','FontSize',10)
box on

% make it a bit less pixellated
set(fig,'Renderer','painters')
% control the output size
set(fig,'PaperPositionMode','auto')

% save the figure
if ~exist([root,'/results/figures/targets/'])
    mkdir([root,'/results/figures/targets/'])
end
print(fig,[root,'/results/figures/targets/categories.png'],'-dpng','-r600');


