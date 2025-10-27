# WheelTunEscapeAnalysis
Analysis pipeline for wheel turn scape photometry recordings

To run:
1. Download scrips and save in a common folder, e.g. PhotoAnalysis
2. Make sure matlab has the Add Ons:
   a) Signal Processing Toolbox
   b) Statistics and Machine Learning Toolbox
   c) Curve Fitting Toolbox
   d) DSP Sytem Toolbox
   
4. Open main_psth_mvb.m, saved in UserFunctions Folder
   a) set up experiment name, group, and other perameters (reccomend running all 100 trials first)
   b) run script, I usually commment out the functions for wheel_psth_mvb and FP_sig_spots_mvb for speed. You can always run these later, esp. when looking at first 10 / last 10 trials, etc.
   c) this should also save the 100 trials in a new folder CombinedData > "yourexperiment" > "yourgroup". To run further analysis, load up this .m file and adjust trial window with the variables Tstart and Tfinish (start trial and end trial). 
