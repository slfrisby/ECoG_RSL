% Make matrix X of fake data. This matrix "looks" (to WISC_MVPA) like real
% data - it matches a metadata entry - and it contains 100 signal-carrying
% features. It can be used for testing hyperband parameters and assessing
% whether particular combinations produce over-sparse solutions. 

% NOTE: the signal-carrying features in this matrix are correlated. This
% should not be a problem for optimising grOWL, but would be a problem when
% optimising LASSO. 

% setup
addpath(genpath('/group/mlr-lab/Saskia/ECoG_RSL/dependencies/'))
addpath('/group/mlr-lab/Saskia/ECoG_RSL/src');
root = '/group/mlr-lab/Saskia/ECoG_RSL/';
cd(root);

% Alphabetically, the first window of data is phase data - all frequencies,
% timepoint 0000. This is the first entry in the tune.yaml. Therefore, we
% will simulate data within this window for participant 01. 

% load metadata
load([root,'/derivatives/windowed/phase/range/all/waveletCentre/0000/metadata.mat']);

% initialise matrix X of fake data
X = zeros(metadata(1).nrow,metadata(1).ncol);

% create features that carry real signal. Decompose target representational
% similarity matrix into 3 singular vectors
[U,D] = embed_similarity_matrix(metadata(1).targets.target,3);
C = rescale_embedding(U,D);

% by adding the values on the 3 dimensions together, we create a feature
% that correlates with all 3 dimensions simultaneously. This is the kind of
% feature that grOWL searches for. 
signalCarryingFeature = C(:,1)+C(:,2)+C(:,3);

% make the first 100 features in X to be signal-carrying features
X(:,1:100) = repmat(signalCarryingFeature,1,100);

% add Gaussian noise with mean of 0 and standard deviation to match the
% standard deviation of the signal-carrying feature
rng('default');
randomNoise = normrnd(0,std(signalCarryingFeature),size(X,1),size(X,2));
X = X + randomNoise;

% save
if ~exist([root,'/derivatives/simulations/'])
    mkdir([root,'/derivatives/simulations/']);
end
save([root,'/derivatives/simulations/sub-01.mat'],'X','-v7.3');

