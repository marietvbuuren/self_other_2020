   
function soconnect_roi_analyzer_MT
%Mariet van Buuren 2019, June
warning('off','all')
subjects = [1,3,4,6:1:10,12,14:1:20,22:1:27,33,34,36:1:39,41:1:43,45:1:51,53:1:55,57:1:62,64,66:1:75,77:1:79,82:1:86]; %No MT for subject 52 & excluded subjects with motion>3mm or no hormone or MT beh responses false 


dirs.home = fullfile('/data','mariet','SoConnect','DATA');
dirs.scripts=  fullfile('/data','mariet','scripts', 'VU','soconnect','MRI');
dirs.root = fullfile(dirs.home,'MRI');

dirs.mtroot = fullfile(dirs.root,'Experimental', 'data_group', 'MT');
dirs.masks=fullfile(dirs.mtroot,'masks','Denny_conj'); %directory where rois (.nii) are located

maskname='Denny_conj';  %%used for outputdirectory
description='Denny_5rois';  %%used for outputfile
dirs.outputroot = fullfile(dirs.mtroot, 'roi_analyses');
dirs.output=fullfile(dirs.outputroot, maskname);  %% outputdirectory
dirs.statsroot=fullfile(dirs.root,'Experimental', 'data_indiv');
if  ~exist([dirs.output,'dir']); mkdir(dirs.output); end

addpath(genpath('/data/mariet/programmes/SPM/spm12/'))
addpath(genpath('/data/mariet/programmes/marsbar-0.44/'))

roi_mat = cellstr(spm_select('FPList',dirs.masks,'.mat'));
for j=1 : length(roi_mat),
    roiname_tmp=char(roi_mat(j));
    [p n e v] = spm_fileparts(roiname_tmp);
    roiname=n;
    
    for isubject = 1: numel(subjects)
        subj = subjects(isubject);   %subj
        if subj<10,
            subjname = ['SoConnect_1_0',num2str(subj)];
        else
            subjname = ['SoConnect_1_',num2str(subj)];
        end
        name{isubject}=subjname;
        dirs.stats= fullfile(dirs.statsroot,subjname,'MT_workdir/');
                
        marsbar('on');                                      % Initialise MarsBar
        
        spm_mat = fullfile(dirs.stats,'SPM.mat');
        
        D = mardo(spm_mat);                             % Make MarsBar design object
        R = maroi('load_cell',cellstr(roi_mat{j}));               % Make MarsBar ROI object
        Y = get_marsy(R{:},D,'mean');
        xCon = get_contrasts(D);
        E = estimate(D,Y);
        E = set_contrasts(E,xCon);
        b = betas(E);
        [rep_strs, marsS, marsD, changef] = stat_table(E, [1:length(xCon)]);
        
        for c=1:length(xCon),
            con_values(isubject,c)=marsS.con(c);
        end
        clear  spm_mat D R Y  E b rep_strs marsS marsD changef dirs_stats
    end
    
    fid = fopen(fullfile(dirs.output,['Group_mean_',roiname,'_',description,'.txt']),'w+');
    fprintf(fid,['Data from ',roiname,'\n','subjectname']);
    for v=1:length(xCon),
        fprintf(fid,['\t', xCon(v).name]);
    end
    fprintf(fid,'\n');
    
    for cv=1: size(con_values,1)
        fprintf(fid,[name{cv},'\t',num2str(con_values(cv,:))]);
        fprintf(fid,'\n');
    end
    clear outputfile con_values t_values p stats mean_values fid cv roiname_tmp p n e v  roiname xCon D R Y file spm_mat
end