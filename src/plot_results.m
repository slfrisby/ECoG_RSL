% plot results!

% setup
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src/');
addpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/');
root = '/group/mlr-lab/Saskia/ECoG_RSL/derivatives/';
cd(root);

% initialise directory in which to save results
if ~exist([root,'/results/figures/'])
    mkdir([root,'/results/figures']);
end
figuresDir = [root,'/results/figures'];

% load results
load([root,'/results/timecourses.mat']);

% set patient IDs - excluding patient 17 
patients = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 20, 21, 22];
% set subsets of patients: 
% - Chris's original LH patients (2024, Imaging Neuroscience; n = 8) - 01, 02, 03, 04, 05, 07, 09, 10
% - my new LH patients (under review, Imaging Neuroscience; n = 7) - 11, 13, 14, 15, 20, 21, 22
% - the RH patients (also reported in Frisby et al., under review, Imaging Neuroscience; n = 3) - 06, 08, 12
reanalysedLH = [1, 2, 3, 4, 5, 7, 9, 10];
newLH = [11, 13, 14, 15, 16, 17, 18];
RH = [6, 8, 12];
% set data types - power or phase (here, voltage is always used as a
% comparator)
dataType = {'power','phase'};
% set frequency ranges (the whole range is used as a comparator)
frequencyRange = {'theta','alpha','beta','gamma','highGamma'};
% set dimensions
dimension = {'D1','D2','D3'};
% set subsets of items
item = {'all','animate','inanimate'};

% plot results for individual patients
for q = 1:length(patients)

    % initialise directory
    if ~exist([figuresDir,'/individual/sub-',sprintf('%02d',patients(q)),'/'])
        mkdir([figuresDir,'/individual/sub-',sprintf('%02d',patients(q)),'/']);
    end

    % for each data type
    for t = 1:length(dataType)
         % for each dimension
        for d = 1:length(dimension)
            % for each set of items
            for i = 1:length(item)

                % plot power and phase against voltage
                f = plot_frequency_vs_voltage(individualTimecourses.(dataType{t}).all.(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))]),individualTimecourses.voltage.(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))]));
                title(['Patient ',sprintf('%02d',patients(q))]);
                saveas(f,[figuresDir,'/individual/sub-',sprintf('%02d',patients(q)),'/',dataType{t},'_all_',dimension{d},'_',item{i},'.png']);
                close(f);

                % plot different frequency ranges
                f = plot_frequency_ranges(individualTimecourses.(dataType{t}).theta.(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))]),individualTimecourses.(dataType{t}).alpha.(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))]),individualTimecourses.(dataType{t}).beta.(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))]),individualTimecourses.(dataType{t}).gamma.(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))]),individualTimecourses.(dataType{t}).highGamma.(dimension{d}).(item{i}).(['patient',sprintf('%02d',patients(q))]));
                title(['Patient ',sprintf('%02d',patients(q))]);
                saveas(f,[figuresDir,'/individual/sub-',sprintf('%02d',patients(q)),'/',dataType{t},'_ranges_',dimension{d},'_',item{i},'.png']);
                close(f);

            end
        end
    end
end

  
% initialise group directory
if ~exist([figuresDir,'/group/'])
    mkdir([figuresDir,'/group/']);
end

% for each data type
for t = 1:length(dataType)
     % for each dimension
    for d = 1:length(dimension)
        % for each set of items
        for i = 1:length(item)

            % Before composing group results inspect the three subsamples of patients:
            % - Chris's original LH patients (2024, Imaging Neuroscience; n = 8) - 01, 02, 03, 04, 05, 07, 09, 10
            % - my new LH patients (under review, Imaging Neuroscience; n = 7) - 11, 13, 14, 15, 20, 21, 22
            % - the RH patients (also reported in Frisby et al., under review, Imaging Neuroscience; n = 3) - 06, 08, 12

            % plot power and phase against voltage
            % reanalysed LH
            f = plot_frequency_vs_voltage(groupTimecourses.(dataType{t}).all.(dimension{d}).(item{i})(reanalysedLH,:),groupTimecourses.voltage.(dimension{d}).(item{i})(reanalysedLH,:));
            saveas(f,[figuresDir,'/group/',dataType{t},'_all_',dimension{d},'_',item{i},'_reanalysedLH.png']);
            close(f);
            % "new" LH
            f = plot_frequency_vs_voltage(groupTimecourses.(dataType{t}).all.(dimension{d}).(item{i})(newLH,:),groupTimecourses.voltage.(dimension{d}).(item{i})(newLH,:));
            saveas(f,[figuresDir,'/group/',dataType{t},'_all_',dimension{d},'_',item{i},'_newLH.png']);
            close(f);
            % RH
            f = plot_frequency_vs_voltage(groupTimecourses.(dataType{t}).all.(dimension{d}).(item{i})(RH,:),groupTimecourses.voltage.(dimension{d}).(item{i})(RH,:));
            saveas(f,[figuresDir,'/group/',dataType{t},'_all_',dimension{d},'_',item{i},'_RH.png']);
            close(f);

            % plot power and phase against voltage for the whole sample
            f = plot_frequency_vs_voltage(groupTimecourses.(dataType{t}).all.(dimension{d}).(item{i}),groupTimecourses.voltage.(dimension{d}).(item{i}));
            saveas(f,[figuresDir,'/group/',dataType{t},'_all_',dimension{d},'_',item{i},'.png']);
            close(f);

            % plot different frequency ranges
            f = plot_frequency_ranges(groupTimecourses.(dataType{t}).theta.(dimension{d}).(item{i}),groupTimecourses.(dataType{t}).alpha.(dimension{d}).(item{i}),groupTimecourses.(dataType{t}).beta.(dimension{d}).(item{i}),groupTimecourses.(dataType{t}).gamma.(dimension{d}).(item{i}),groupTimecourses.(dataType{t}).highGamma.(dimension{d}).(item{i}));
            saveas(f,[figuresDir,'/group/',dataType{t},'_ranges_',dimension{d},'_',item{i},'.png']);
            close(f);

            % for each frequency range
            for r = 1:length(frequencyRange)
                % plot that range against all frequencies
                f = plot_range_vs_frequency(frequencyRange{r},groupTimecourses.(dataType{t}).(frequencyRange{r}).(dimension{d}).(item{i}),groupTimecourses.(dataType{t}).all.(dimension{d}).(item{i}));
                saveas(f,[figuresDir,'/group/',dataType{t},'_',frequencyRange{r},'_',dimension{d},'_',item{i},'.png']);
                close(f);
            end
        end
    end
end

