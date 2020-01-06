function soconnect_prepare_sort_main(rawdirsubj,niidirsubj,info, scan)

%% script to copy data from RAW directory to experimental/analysis directory- fMRI data of main project SoConnect
%% calls the following functions:
% - copy data from RAW to experimental folder
% - converts PAR/REC to niftii (3D)

%% version 1.0 12/04/2018 - Mariët van Buuren
% (dd/mm/yyyy)
% 12/04/2018 based on soconnect_prepare_sort_main: added help information, and added converting PAR/REC to .nii using dicm2nii

run=info.run;
whatscans=info.whatscans;

for i = 1:numel(whatscans)
    if scan(whatscans(i))>0
    cd(niidirsubj)
    clear newdir; newdir = fullfile(cd,run{whatscans(i)});
    clear pardir; pardir = fullfile(cd,'PR',run{whatscans(i)});
    if ~exist(newdir,'dir'); mkdir(newdir); end
    if ~exist(pardir,'dir'); mkdir(pardir); end
    
    cd(fullfile(rawdirsubj));
    clear scannum; scannum= num2str(scan(whatscans(i)));
    clear filename; filename = dir(['*',scannum,'_1*']);
    for l=1:2, %copy PAR and REC
        clear scanname; scanname=filename(l).name;
        unix(['cp ' scanname ' ' pardir]);
    end
    dicm2nii(pardir,newdir,'.nii 3D');    
    eval(['!rm -r ' pardir])   
    else
    end
end

for i = 2:(numel(whatscans))
    if scan(whatscans(i))>0
    cd(niidirsubj)
    clear T1dirnew; T1dirnew = fullfile(cd,['T1_',run{whatscans(i)}]);
    if ~exist(T1dirnew,'dir'); mkdir(T1dirnew); end
    cd (run{whatscans(1)})
    clear filename; filename = dir('*.nii');
    clear scanname; scanname=filename.name;
    unix(['cp ' scanname ' ' T1dirnew]);
    else 
    end;
end;
  cd(niidirsubj)
  clear removedir; removedir= run{whatscans(1)};
  eval(['!rm -r ' removedir])
    
    
       