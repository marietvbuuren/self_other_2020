function soconnect_motion_calculation

%% to calculate scan to scan motion, or framewise displacement (FD)
% Mariet van Buuren 2018 v2
% based on Power et al. 2012 and DPARSFA_run by YAN Chao-Gan

subjects = [1,2,3,4,6:1:20,22:1:51,53:1:86];


dirs.home = fullfile('/data','mariet','SoConnect','DATA');
dirs.scripts=  fullfile('/data','mariet','scripts', 'VU','soconnect','MRI');
dirs.root = fullfile(dirs.home,'MRI');

cd(dirs.root)
dirs.output = fullfile(dirs.root,'Experimental', 'data_group', 'MT', 'motion');
addpath(genpath('/data/mariet/programmes/SPM/spm12/'))

if ~exist(dirs.output,'dir'); mkdir(dirs.output); end
for isubject = 1:numel(subjects)
 subj=subjects(isubject);       
 if subj<10,
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['SoConnect_1_0',num2str(subj)],'MT');
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    subjname = ['SoConnect_1_0',num2str(subj)];
else
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['SoConnect_1_',num2str(subj)], 'MT');
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    subjname = ['SoConnect_1_',num2str(subj)];
end
 
    name{isubject}=subjname;
    % SUBJECT LOOP
    rpfile = spm_select('FPList',[ niidirsubj,'/'],['^rp_','.*\.txt$']);
    rpmat = load(rpfile);
    rpmm=rpmat;
    rpmm(:,4:6)=rpmat(:,4:6)*50;
    rpmmabs=abs(rpmm);
    m=find(rpmmabs>3);
    if length(m)==0,
        mot=0;
    else mot=1;
    end
    RPDiff=diff(rpmat);
    RPDiff=[zeros(1,6);RPDiff];
    RPDiffSphere=RPDiff;
    RPDiffSphere(:,4:6)=RPDiffSphere(:,4:6)*50;% radius (i.e. distance between cortex and center of brain, in mm previously 65 mm, now 50 mm following Power et al. 2012)
    FD_Power=sum(abs(RPDiffSphere),2);
    save([niidirsubj,'/', subjname,'_FD_Power_05_','MT','.txt'], 'FD_Power', '-ASCII', '-DOUBLE','-TABS');
    
    MeanFD_Power(isubject) = mean(FD_Power);
    NumberFD_Power_05(isubject) = length(find(FD_Power>0.5));
    PercentFD_Power_05(isubject) = length(find(FD_Power>0.5)) / length(FD_Power);
    Motion_above_3mm(isubject)= mot;
    FD_above_3mm(isubject)=length(find(FD_Power>3));
    clear FD_Power RPDiff RPDiffSphere rpfile rpmat m mot
    
end

fid = fopen(fullfile(dirs.output,['FD_power_file_05_MT.txt']),'w+');
fprintf(fid,'subject \t MeanFD_power \t NumberFD_Power_05 \t PercentFD_Power_05 \t AbsMotionAbove3mm \t FDabove3mm \n');

for i=1: numel(subjects)
    fprintf(fid, [char(name{i}),'\t', num2str(MeanFD_Power(i)),'\t',num2str(NumberFD_Power_05(i)),'\t', num2str(PercentFD_Power_05(i)), '\t', num2str(Motion_above_3mm(i)),'\t',num2str(FD_above_3mm(i)),'\n']);
end

clear fid
