%% soconnect_mri_input_main_task.m 
%% input script for preproccessing and analyses of task-fMRI data SoConnect project - Mariët van Buuren

%% Using this script:
% 1)change paths to correct directories
% 2)fill in the subjectcodes (numbers only) of the to-be-processed subjects
% 3)series: fill in the number of scan of the task/period of interest and place a 0 for scans not of interest or missing
% 4)change info.whatscans so it holds the number of the scans of interest.  
% 5)jobinput: fill in 1 and 0 indicating which steps you want to run (1) or want to skip (0)

%% version 3.1 02/09/2019 - Mariët van Buuren- used to analyze self-other data
% (dd/mm/yyyy)
% 24/08/2018 based on soconnect_mri_input_main: removed resting-state related stuff
% 02/09/2019 added gPPI and F contrast add

clear all
close all
clc

global dirs info
%% first set paths and directories

dirs.home = fullfile('/data','mariet','SoConnect','DATA');
dirs.scripts=  fullfile('/data','mariet','scripts','VU','soconnect','MRI'); % directory of scripts
dirs.root = fullfile(dirs.home,'MRI');
dirs.rootraw=fullfile('/data','mariet','SoConnect','DATA','MRI');
dirs.mtroot = fullfile(dirs.root,'Experimental', 'data_group', 'MT');
dirs.masks=fullfile(dirs.mtroot,'masks','Denny_conj','gPPI_masks'); %directory of masks/vois for gPPI analyses of MT

cd(dirs.root)
dirs.reports = fullfile(dirs.root, 'Experimental','jobreports');

dirs.behav=fullfile(dirs.home,'behavioral');
if ~exist(char(dirs.reports),'dir'); mkdir(char(dirs.reports)); end

addpath(genpath('/data/mariet/programmes/SPM/spm12/'))  %% directory to spm -->change
addpath([dirs.scripts,'/']);
addpath(fullfile(dirs.scripts,'data_quality/'));
addpath (fullfile(dirs.scripts,'dicm2nii/'));


%% then specify subjects and scans
load([dirs.scripts,'/scanlisttot_T1.mat']); %% mat files containing number of scans/run of T1 with subjects as rows
load([dirs.scripts,'/scanlisttot_MT.mat']); %% mat files containing number of scans/run of self other task with subjects as rows

subjects = [1,3,4,6:1:10,12,14:1:20,22:1:27,33,34,36:1:39,41:1:43,45:1:51,53:1:55,57:1:62,64,66:1:75,77:1:79,82:1:86]; %No MT for subject 52 & excluded subjects with motion>3mm or no hormone or MT beh responses false 

series{1}= scanlisttot_T1; %T1
series{2}= zeros(1,(length(series{1}))); %TG, not included in current analyses
series{3}= scanlisttot_MT; %MT= trait judgement task
series{4}= zeros(1,(length(series{1}))); %RS, not included in current analyses
info.run = {'T1','TG','MT','RS'}; 
info.whatscans=[1,3];  %% numbers refer to series so 1 refers to series{1} ie T1. Remove the number of the scans you are not interested in


%% specify which jobs need to run/inputs 0=skip, 1= perform
clear jobinputs
for i =1:numel(subjects)
    clear scans   
    scans=[series{1}(i),series{2}(i),series{3}(i),series{4}(i)];
          
                jobinputs{i,1} = subjects(i);   %subj
                jobinputs{i,2} = scans;         %scans
                jobinputs{i,3} = 0;             %sort data 
                jobinputs{i,4} = 0;             %preprocessing realigment and coregistration
                jobinputs{i,5} = 0;             %tsnr check
                jobinputs{i,6} = 0;             %unified segmentation
                jobinputs{i,7} = 0;             %smoothing
                jobinputs{i,8} = 0;             %tsnr check normalized data
                jobinputs{i,9} = 0;             %first level analysis
                jobinputs{i,10} = 0;            %add contrast 
                jobinputs{i,11} = 0;            %gPPI analyses
end
for i = 1:size(jobinputs,1)
          soconnect_mri_pipeline_main_task(jobinputs(i,:))
end