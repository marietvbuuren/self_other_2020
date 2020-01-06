function soconnect_mri_pipeline_main_task(jobinputs)

%% script to preprocess & analyze fMRI task data of main project SoConnect
%% calls the following functions:
% - copy data from RAW to experimental folder & converts PAR/REC to niftii (3D)
% - preprocess data; 3 seperate steps & using samplespecific tissuepriors
%   created with CerebroMatic- M. Wilke
% - runs data quality check on realigned data
% - runs data quality check on normalized data
% - runs first level analyses


%% version 3.1 02/09/2019 - Mariët van Buuren - used to analyze self-other data
% (dd/mm/yyyy)
% 24/08/2018 based on soconnect_mri_pipeline_main: removed resting-state
% related analyses and added task-analyses
% 04/12/2018 added quality check on normalized data
% 02/09/2019 added gPPI analyses and F contrast for task effects

global dirs subj info

subj = cell2mat(jobinputs(1));
scan= cell2mat(jobinputs(2));
todo.sort = cell2mat(jobinputs(3));
todo.pre_realcoreg = cell2mat(jobinputs(4));
todo.tsnr = cell2mat(jobinputs(5));
todo.uniseg= cell2mat(jobinputs(6)); 
todo.smoothing= cell2mat(jobinputs(7)); 
todo.wtsnr= cell2mat(jobinputs(8));
todo.firstlevel= cell2mat(jobinputs(9));
todo.addcontrast= cell2mat(jobinputs(10));
todo.gppi=cell2mat(jobinputs(11));


%%relevant directories % subjectname
rawdirroot=fullfile(dirs.rootraw, 'RAW');
cd(rawdirroot);

if subj<10,
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['SoConnect_1_0',num2str(subj)]);
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    t=dir(['SoConnect_1_0',num2str(subj), '*']);
    rawdirsubj= fullfile(dirs.rootraw, 'RAW',t.name);
    subjname = ['SoConnect_1_0',num2str(subj)];
else
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['SoConnect_1_',num2str(subj)]);
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    t=dir(['SoConnect_1_',num2str(subj), '*']);
    rawdirsubj= fullfile(dirs.rootraw, 'RAW',t.name);
    subjname = ['SoConnect_1_',num2str(subj)];
end
clear t;

symlinkdir_stat_MT=fullfile(dirs.root,'Experimental','data_group','MT','MT_firstlevel');
symlinkdir_gppi_MT=fullfile(dirs.root,'Experimental','data_group','MT','gPPI_firstlevel');


whatscans=info.whatscans;
run=info.run;
cd(dirs.reports);
% settings
description=[];
hpf_qa=128;
isi_qa=2;

%% sort raw data
if todo.sort == true
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    soconnect_prepare_sort_main(rawdirsubj,niidirsubj,info, scan)
end


%% preprocessing
%(-)reallign functional
%(-)coregister T1 to mean functional

if todo.pre_realcoreg == true
    for i = 2:numel(whatscans)
        if scan(whatscans(i))>0
            whattodo= ['preprocess_rc_', run{whatscans(i)}];
            nrun = 1; % enter the number of runs here
            clear jobfile jobs inputs matlabbatch mbatch;
            jobfile =cellstr(fullfile(dirs.scripts,'soconnect_preprocess_rc_batch_job.m'));
                       
            jobs = repmat(jobfile, 1, nrun);
            inputs = cell(2, nrun);
            reallign_input= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['.*\.nii$']));
            coreg_inputsrc= cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['.*\.nii$']));
            
            for crun = 1:nrun
                inputs{1, crun} = reallign_input; % Realign: Estimate & Reslice: Session - cfg_files
                inputs{2, crun} = coreg_inputsrc; % Coregister: Estimate: Source Image - cfg_files
            end
            spm('defaults', 'FMRI');
            if subj<10
                jobfilename = [whattodo,'SoConnect_1_0',num2str(subj), '.mat'];
            else  jobfilename = [whattodo,'SoConnect_1_',num2str(subj), '.mat'];
            end
            mbatch=spm_jobman('serial', jobs, '', inputs{:});
            eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
            cd ([niidirsubj,'/',run{whatscans(i)}]);
         else
        end
    end
end


%% Data quality check
% perform quality check on realigned data (creates mask of resliced T1) including signal change per scan, motion and tsnr
% maps, uses scripts following bzbtx, see https://github.com/bramzandbelt/fmri_preprocessing_and_qa_code
if todo.tsnr == true
    for i = 2:numel(whatscans)
        clear qadir srcimgs rpfile t1img 
        if scan(whatscans(i))>0
        qadir=fullfile(niidirsubj,[run{whatscans(i)},'_qadir']);
        if ~exist(qadir,'dir'); mkdir(qadir); end
        srcimgs= spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^S','.*\.nii$']);
        rpfile=spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^rp_','.*\.txt$']);
        t1img=spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^rS','.*\.nii$']);
        hpf = hpf_qa;
        isi = isi_qa;
        cd (qadir)
        mvb_qa_fast('preproc',srcimgs,t1img,rpfile,isi,hpf,qadir)
        cd ([niidirsubj,'/',run{whatscans(i)}]);
        else
        end
    end
end 

%% performs segmentation based on matched priors (CerebroMatic) and normalization
%% preprocessing
%(-)segment T1 using priors created by CerebroMatic (based on N=84)
%(-)use deformation maps to normalize T1 & functional images
if todo.uniseg== true
    for i = 2:numel(whatscans)
        if scan(whatscans(i))>0
            whattodo= ['preprocess_uniseg_', run{whatscans(i)}];
            nrun = 1; % enter the number of runs here
            clear jobfile jobs inputs matlabbatch mbatch;
            jobfile =cellstr(fullfile(dirs.scripts,'soconnect_preprocess_uniseg_batch_job.m'));
            jobs = repmat(jobfile, 1, nrun);
             
            segment_inputsrc= cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^S','.*\.nii$']));
            norm_input1= cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^S','.*\.nii$']));
            norm_input2= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^S','.*\.nii$']));
            inputs = cell(3, nrun);
            for crun = 1:nrun
                inputs{1, crun} = segment_inputsrc; % Segment: Volumes - cfg_files
                inputs{2, crun} = norm_input1; % Normalise: Write: Images to Write - cfg_files
                inputs{3, crun} = norm_input2; % Normalise: Write: Images to Write - cfg_files
            end
            spm('defaults', 'FMRI');
            if subj<10
                jobfilename = [whattodo,'SoConnect_1_0',num2str(subj), '.mat'];
            else  jobfilename = [whattodo,'SoConnect_1_',num2str(subj), '.mat'];
            end
            mbatch=spm_jobman('serial', jobs, '', inputs{:});
            eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
            cd ([niidirsubj,'/',run{whatscans(i)}]);
           else
        end
    end
end

%% performs smoothing
% smoothing with 6 6 6 mm smoothing kernel
if todo.smoothing== true
    whatscans=info.whatscans;
    run=info.run;
    for i = 2:numel(whatscans)
        if scan(whatscans(i))>0
            whattodo= ['preprocess_smoothing_', run{whatscans(i)}];
            nrun = 1; % enter the number of runs here
            clear jobfile jobs inputs matlabbatch mbatch;
            jobfile =cellstr(fullfile(dirs.scripts,'soconnect_preprocess_smoothing_batch_job.m'));
            jobs = repmat(jobfile, 1, nrun);
            smoothing_input= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^wS','.*\.nii$']));
            inputs = cell(1, nrun);
            for crun = 1:nrun
                inputs{1, crun} = smoothing_input; % Smoothing: Volumes - cfg_files
            end
            spm('defaults', 'FMRI');
            if subj<10
                jobfilename = [whattodo,'SoConnect_1_0',num2str(subj), '.mat'];
            else  jobfilename = [whattodo,'SoConnect_1_',num2str(subj), '.mat'];
            end
            mbatch=spm_jobman('serial', jobs, '', inputs{:});
            eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
            cd ([niidirsubj,'/',run{whatscans(i)}]);
        else
        end
    end
end

%% perform signal to noise analysis again only on preprocessed data
if todo.wtsnr == true
    whatscans=info.whatscans;
    run=info.run;
    for i = 2:numel(whatscans)
        clear qadir srcimgs rpfile t1img 
        if scan(whatscans(i))>0
        qadir=fullfile(niidirsubj,[run{whatscans(i)},'_w_qadir']);
        if ~exist(qadir,'dir'); mkdir(qadir); end
        srcimgs= spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^wS','.*\.nii$']);
        rpfile=spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^rp_','.*\.txt$']);
        jobfile =cellstr(fullfile(dirs.scripts,'soconnect_reslic_anat_job.m'));
        nrun=1;
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(2, nrun);
        for crun = 1:nrun
            inputs{1, crun} = cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^wSo','.*\.nii$']));  % Coregister: Reslice: Image Defining Space - cfg_files
            inputs{2, crun} =   cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^wSo','.*\.nii$'])); % Coregister: Reslice: Images to Reslice - cfg_files
        end
        spm('defaults', 'FMRI');
        spm_jobman('run', jobs, inputs{:});
        if subj<10,
            jobfilename = ['reslanat_SoConnect_1_0',num2str(subj), '.mat'];
        else  jobfilename = ['reslanat_SoConnect_1_',num2str(subj), '.mat'];
        end
        mbatch=spm_jobman('serial', jobs, '', inputs{:});
        eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
        
        t1img=spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^rwSo','.*.nii$']);
        hpf = hpf_qa;
        isi = isi_qa;
        cd (qadir)
        mvb_qa_fast('preproc',srcimgs,t1img,rpfile,isi,hpf,qadir)
        cd ([niidirsubj,'/',run{whatscans(i)}]);
        else
        end
    end
end          


%% First-level analysis tasks
if todo.firstlevel == true
    for i = 2:numel(whatscans)
        rest=strcmp(run{whatscans(i)},'RS');
        if scan(whatscans(i))>0 && rest==0
            clear symlinkdir_stat workdir whattodo rpfile funcfiles
            whattodo= ['firstlevel_', run{whatscans(i)}];
         
            %set directories & scans & logfile
            workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']);
            if ~exist(workdir,'dir'); mkdir(workdir); end
            datadirbeh=fullfile(dirs.behav,'data_indiv',run{whatscans(i)},'outputfiles');  
            funcfiles= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^swS','.*\.nii$']));
            rpfile=cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^rp_','.*\.txt$']));
            
            if (strcmp(run{whatscans(i)},'TG'))==1  %% in current analyses, TG is not used
                symlinkdir_stat=symlinkdir_stat_TG; %% in current analyses, TG is not used
                logfile=[datadirbeh,'/','SC1_',num2str(subj),'_trustgame_run1.csv'];
            elseif (strcmp(run{whatscans(i)},'MT'))==1
                symlinkdir_stat=symlinkdir_stat_MT;
                if subj<10,
                    logfile=[datadirbeh, '/mentalizing_SC1_0',num2str(subj),'.txt'];
                else  logfile=[datadirbeh, '/mentalizing_SC1_',num2str(subj),'.txt'];
                end
            end
            if ~exist(symlinkdir_stat,'dir'); mkdir(symlinkdir_stat); end
            
            %create onsetfiles & run firstlevel analyses
            if (strcmp(run{whatscans(i)},'TG'))==1    %% in current analyses, TG is not used
                soconnect_firstlevel_TG(whattodo,workdir,logfile,funcfiles,rpfile,symlinkdir_stat,subjname);
            elseif (strcmp(run{whatscans(i)},'MT'))==1
                soconnect_firstlevel_MT(whattodo,workdir,logfile,funcfiles,rpfile,symlinkdir_stat,subjname);  
            end  
        else
        end
    end
end   


%% Add contrast for F task effects & motion - not used in analyses as gPPI creates own omnibus F-test
if todo.addcontrast == true
    clear matlabbatch workdir
    for i = 2:numel(whatscans)
        rest=strcmp(run{whatscans(i)},'RS');
        if scan(whatscans(i))>0 && rest==0
            workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']);
            cd(workdir)
            jobfile = fullfile(dirs.scripts,['soconnect_add_contrast.mat']);
            load(jobfile);
            matlabbatch{1}.spm.stats.con.spmmat=cellstr(spm_select('FPList',workdir,'^SPM.*\.mat$'));
            spm_jobman('initcfg')
            spm_jobman('run', matlabbatch);
        end
    end
end

if todo.gppi == true
    clear matlabbatch workdir PPI
    for i = 2:numel(whatscans)
        rest=strcmp(run{whatscans(i)},'RS');
        if scan(whatscans(i))>0 && rest==0
            workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']);
            
            VOI{1}.name = 'Sphere_10_vMPFC_-6_56_10_adj';
            
            for ivoi = 1 :size(VOI,2)
                voi = VOI{ivoi};
                VOI_name=voi.name;
                gPPI_workdir=fullfile(workdir,VOI_name);
                if ~exist(gPPI_workdir,'dir'); mkdir(gPPI_workdir); end
                soconnect_gppi_parameters(subjname,workdir,VOI_name,gPPI_workdir);
                clear P gPPI_workdir VOI_name    
            end
        end
    end
end

