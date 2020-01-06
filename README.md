# self_other_2020

Code used to analyze fMRI data in self-other in adolescence project. Scripts run in combination with packages mentioned in manuscript; SPM 12, generalized PPI (version 13.1) and marsbar, version 0.44.

Directory preprocessing_and_analyses contains main code used to run analyes. Function soconnect_mri_input_main_task.m is used to set the directories, subjects to be analyzed and the numbers of the scans to be used, as well as which steps to perform (i.e. various preprocessing steps, first-level analysis, gPPI). This function calls soconnect_mri_pipeline_main_task.m which runs the various preprocessing and analyses steps, by calling other functions and spm batches.

Two functions are run outside of the main pipeline:
soconnect_motion_calculation.m calculates absolute motion (>3mm) and framewise displacement.
soconnect_roi_analyzer_MT.m calculates signal changes in ROIs using marsbar.
