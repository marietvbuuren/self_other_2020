%-----------------------------------------------------------------------
% Job saved on 30-Nov-2018 16:19:23 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.preproc.channel.vols = '<UNDEFINED>';
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'/data/mariet/SoConnect/DATA/MRI/Experimental/data_group/resting_state/templates_segment_wholesample/mw_com_prior_Age_0155.nii,1'};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'/data/mariet/SoConnect/DATA/MRI/Experimental/data_group/resting_state/templates_segment_wholesample/mw_com_prior_Age_0155.nii,2'};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'/data/mariet/SoConnect/DATA/MRI/Experimental/data_group/resting_state/templates_segment_wholesample/mw_com_prior_Age_0155.nii,3'};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'/data/mariet/SoConnect/DATA/MRI/Experimental/data_group/resting_state/templates_segment_wholesample/mw_com_prior_Age_0155.nii,4'};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'/data/mariet/SoConnect/DATA/MRI/Experimental/data_group/resting_state/templates_segment_wholesample/mw_com_prior_Age_0155.nii,5'};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'/data/mariet/SoConnect/DATA/MRI/Experimental/data_group/resting_state/templates_segment_wholesample/mw_com_prior_Age_0155.nii,6'};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'subj';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
matlabbatch{2}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{2}.spm.spatial.normalise.write.subj.resample = '<UNDEFINED>';
matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-93 -126 -81
                                                          93 90 105];
matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 7;
matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';
matlabbatch{3}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{3}.spm.spatial.normalise.write.subj.resample = '<UNDEFINED>';
matlabbatch{3}.spm.spatial.normalise.write.woptions.bb = [-93 -126 -81
                                                          93 90 105];
matlabbatch{3}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{3}.spm.spatial.normalise.write.woptions.interp = 7;
matlabbatch{3}.spm.spatial.normalise.write.woptions.prefix = 'w';
