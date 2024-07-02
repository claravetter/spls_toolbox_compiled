%% SPLS Toolbox: Data Preparation Script [Template]
% Date: 21.06.2024
% Based on original script by David Popovic, adapted by Clara Weyer.

%% Information
% Add necessary paths (e.g., SPM, Neurominer) 
% Prepare your X and Y matrices. This part is not included in the script, needs to be added.  
% CAVE: Missing data needs to be imputed before the analysis. 
% CAVE: Number of features in X matrix must be >= Number of features in Y matrix.
% Replace all 'DEFINE's.

%% SETUP
% Parameters for IT infrastructure
setup.date                  = date; % automatic date
setup.spls_standalone_path  = 'DEFINE'; % Path of the SPLS Toolbox
    % Example: '/data/core-psy-pronia/opt/SPLS_Toolbox_Dev_2023_EXTERNAL'
setup.analysis_folder       = ['DEFINE', setup.date]; % analysis folder is created automatically using the current date
    % Example: ['/data/core-psy-archive/projects/CW_MED/Analysis/', setup.date]; 
setup.cache_path            = 'DEFINE'; % Path for output text files during hyperopt, permutation, bootstrapping => generally same as scratch space
    % Example: '/volume/mitnvp1_scratch/CW_Med'
setup.scratch_space         = 'DEFINE'; % Path for temporary file storage (hyperopt, permutation, bootstrapping) during analysis, please insert your own folder in the scratch space
    % Example: '/volume/mitnvp1_scratch/CW_Med';
setup.queue_name            = ''; % Choose queue for master and slave jobs, leave empty for now.
    % Example: 'all.q';
setup.email                 = 'DEFINE'; % your email address
    % Example: 'clara.weyer@med.uni-muenchen.de';
setup.max_sim_jobs          = 40; % Define how many parallel jobs are created
setup.parallel_jobs         = 20; % Define how many jobs run in parallel at the same time (soft threshold)
setup.mem_request           = 5; % Memory request for master and slave jobs, in GB, maybe decrease to 2 or 3
setup.matlab_version        = 'R2022a'; % Define the runtime engine
setup.compilation_subpath   = 'for_testing'; % default
setup.partition             = 'DEFINE'; % Or leave empty; Example: jobs-matlab
setup.account               = 'DEFINE'; % Or leave empty; Example: core-psy
setup.matlab_path           = 'DEFINE'; % Example: /data/core-psy-pronia/opt/matlab/v912

%% INPUT
input.name                  = 'DEFINE'; % Name of your Analysis 
    % Example: 'Immune_only_678_IQRadd_HCcorr_33_noval_min10_2020_1000AUC_1000boot';
input.AllVarNames           = 'DEFINE'; % Analysis Identifier for Visualization 
    % Example: 'DP_CTQ'
input.final_ID              = DEFINE; % ID of your subjects (cell array)
input.data_complete         = data_complete; % OPTIONAL, not needed for analysis.
input.sites                 = DEFINE; % Dummy coded vector for sites, if only one site, then enter a column vector of ones
input.sites_names           = DEFINE; % Names of the sites
input.Diag                  = DEFINE; % Column vector with diagnoses coded via numbers, i.e., [1 3 2 3 4 ]
input.DiagNames             = DEFINE; % Column cell array with diagnoses/labels, i.e., {'HC', 'ROD', 'CHR', 'HC', 'ROP'}

% MATRICES
input.X                     = DEFINE/'DEFINE'; % Path to .mat (double)/double: 1st data matrix, usually for MRI/biological data, if applicable. If MRI data, then either put in the path to a Matlab file, containing only one variable with vectorized MRI data, or put in vectorized MRI data itself, otherwise just put in the matrix (double format)
input.X_names               = DEFINE; % Define names of features in X, if MRI data, or no names applicable, leave empty ('[]')
input.Y                     = DEFINE; % 2nd data matrix, usually for behavioral/phenotypical data (double format) 
input.Y_names               = DEFINE; % Define names of features in X, if no names applicable, leave empty
input.subscales             = DEFINE; % Optional, only for post hoc visualization needed

% COVARIATES
input.covariates                    = DEFINE; % Input format: double (if no covariates: []; 
input.covariate_names               = DEFINE; % Input format: cell array (if no covariates: []); 
input.type_correction               = 'corrected'; % Define whether you want to correct for covariates, choose between: correct, uncorrected
input.correction_target             = DEFINE; % Define whether you want to remove covariate effects from 1) X, 2) Y or 3) both matrices
input.cs_method.correction_subgroup = 'DEFINE'; % Define whether you want to correct the covariates based on the betas of a subgroup, or simply across all individuals => for subgroup-based correction use the label, i.e., 'HC' or 'ROD, etc. Otherwise leave as empty string: ''.

% MACHINE LEARNING FRAMEWORK
input.framework             = 1; % Cross-validation setup: 1 = nested cross-validation, 2 = random hold-out splits, 3 = LOSOCV, 4 = random split-half
input.outer_folds           = 5; % Applicable only for nested cross-validation and Random Hold-Out Splits: Define Outer folds CV2
input.inner_folds           = 5; % Applicable only for nested cross-validation and Random Hold-Out Splits: Define Inner folds CV1
input.density               = 40; % See below for explanation.
input.permutation_testing   = 5000; % Number of permutations for significance testing of each LV, default: 5000
input.bootstrap_testing     = 100; % Number of bootstrap samples to measure Confidence intervals and bootstrap ratios for feature weights within LV: default 500 (100 also possible)
input.correlation_method    = 'Spearman'; % Define which correlation method is used to compute correlation between latent scores of X and Y (used for significance testing of LV): default 'Spearman', also possible 'Pearson'
input.cs_method.method      = 'mean-centering'; % Scaling of features, default: mean-centering (z transformation), also possible 'min_max' (scaling from 0 to 1) => preferred scaling is mean-centering!
input.coun_ts_limit         = 1; % Define after how many non-significant LVs the algorithm should stop, default: 1 (means that as soon as one LV is not significant, the operation ends)
input.outer_permutations    = 1; % Define number of permutations in the CV2 folds, default: 1 (Toolbox is so far not optimized for permutations on folds, also, permutating the folds would severely increase computation time and is therefore not recommended
input.inner_permutations    = 1; % Define number of permutations in the CV1 folds, default: 1 (Toolbox is so far not optimized for permutations on folds, also, permutating the folds would severely increase computation time and is therefore not recommended
input.selection_train       = 1; % 1) Define how the RHO values between X and Y are collected across the cross-validation structure, default: 1, possible options: 1) within one CV2 fold, 2) across all CV2 folds (option 2 not recommended)
input.selection_retrain     = 1; % 1) Define whether you want to pool data from all CV1 folds and retrain the model on these before applying on CV2 testing fold, default: 1, possible options: 1) retrain on all CV1 folds, 2) no retraining, use already existing model
input.merge_train           = 'median'; % Define how the RHO values are collected, default: median, possible options: mean, median
input.merge_retrain         = 'best'; % Define how the best hyperparameters will be chosen on the CV1 level, default: 'best' (winner takes all, the best performing CV1 hyperparameters will be chosen), possible options: mean, median, weighted_mean, best => mean, median and weighted mean lead to a merging of all CV1 models
input.validation_set        = false; % Define whether you want to hold out a validation set, default: false, possible options: false or number as percentage of the whole sample, i.e., 25, 50, etc. => 50 means 50% means random split half
input.val_stratification    = 1; % If applicable, define how you want to extract the validation set, options: 1) diagnosis, 2) sites, 3) both
input.validation_train      = 1; % If applicable, define how you want to test performance of the model on the validation set, options: 1) Retrain optimal model on permutations of the all samples, except for validation set, 2) use already computed permuted performances from the CV structure, default: 1
input.alpha_value           = 0.05; % Define overall threshold for significance
input.final_merge.type      = 'best'; % Define how the final LV model will be chosen on the CV2 level, default: 'best' (winner takes all, the best performing CV2 model will be the new LV), possible options: mean, median, weighted_mean, best => mean, median and weighted mean lead to a merging of all CV2 models => the feature weights of all CV2 models are merged via mean, median or weighted mean (based on RHO values)
input.final_merge.mult_test = 'Benjamini_Hochberg'; % Define how correction for multiple testing across CV2 folds is done, default: 'Benjamini_Hochberg', possible options: Bonferroni, Sidak, Holm_Bonferroni, Benjamini_Hochberg, Benjamini_Yekutieli, Storey, Fisher
input.final_merge.significant_only  = 'on'; % Only applicable if input.final_merge.type is not set to best! Defines type of CV2 fold merging: options: 'on' use only significant folds for merging, 'off' use all folds for merging
input.final_merge.majority_vote     = 'on'; % Only applicable if input.final_merge.type is not set to best! options: 'on' use majority voting across folds to determine whether a value in u or v should be zero or non-zero, 'off' no majority vote, merging is done for all features, irrespective of whether in the majority of folds the feature was zero
input.correct_limit         = 1; % Define in which iteration of the process covariate correction should be done, default: 1 (means that covariate correction is done before computing the first LV, then no more correction)
input.statistical_testing   = 1; % Define how the P value is computed during permutation testing: 1) Counting method (number of instance where permuted models outperformed opimized model/number of permutations), 2) AUC method (permuted RHO values are used to compute AUC for optimal RHO value => option 2 usually gives slightly lower P values

% Hyperopt grid search specifics: Define in which LV iteration you want to
    % use which grid, default: stable grid across all iterations
input.grid_dynamic.onset    = 1; % Choose the marks for grid applications, default: 1 (means that one grid is defined at first iteration and then not changed at all in later iterations)
input.grid_dynamic.LV_1.x   = struct('start', 1, 'end', 0, 'density', input.density); 
input.grid_dynamic.LV_1.y   = struct('start', 1, 'end', 0, 'density', input.density);
% Define grid for hyperparameter search for the X matrix (cu parameter) =>
    % 'start': 1 means start is at value 1, 10 means it starts at the lower 10
        % percentile of the grid, etc. 
    % 'end' defines the upper limit of the hyperparameter search, 0 means all
        % the way to the end, 10 means to stop at the upper 10 percentile, etc.,
    % 'density' defines the number of data points which are tested during the
        % grid, i.e., 20 means that between start and end point, 20 equidistant
        % values are tested for the hyperparameter

%% DATAFILE.MAT
% 1. Save 'input' and 'setup' as 'datafile.mat' 
    % Example: 
        % cd('/volume/projects/CW_Med/Analysis/')
        % mkdir([setup.date, '/', input.name])
        % cd([setup.date, '/', input.name])
        % save('datafile.mat', 'setup', 'input')

input.datafile              = 'DEFINE'; % Path to datafile.mat
    % Example: /data/core-psy-archive/projects/CW_MED/Data/CW_MED_LONGIT_diff_absolute_2mm_6FWHM_n245_5x5_1000perm_100boot_20density/datafile.mat

% 2. Copy "datafile.mat" (and all other files that are needed) to the cluster, 
% where you want to run SPLS analysis. 

