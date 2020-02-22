# SYNERGY BASED EMG AND FORCE ESTIMATION WITH NEURAL NETWORKS
Student's project from Politecnico di Bari  
Authors: Coscia Claudia, Paparella Santorsola VIto  
Based on NINAPRO database 2

This project aims to obtain a good estimation of finger forces starting from emg signals.  
It tests four different estimation methods, three of them being synergy based:  
  1. Linear force recostrcution from EMG.  
  2. Non-Negative Matrix Factorization of EMG signals and force estimation with Hc model.  
  3. Autoencoder EMG recostruction and force estimation with Hae model.  
  4. Parallel EMG and force recostruction with a custom double output shallow neural network.  
    
The results shows that the NNMF is the best method to reconstruct the EMG signals, while the 
4th method is the best for the force reconstruction.

Folders list:  
  1. Figures - in this folder will be contained all the jpg plots
  2. NinaPro_DB2 - this folder MUST contain the second NinaPro database, sbj 1:40, exercise 3
  3. Tutorial - this folder contains several test scripts  

Data list:  
  1. Data_fullDataSet.mat (not loaded on GitHub) - this is the full processed dataset
  2. Data_sfDataSet.mat (not loaded on GitHun) - this is the single finger only processed dataset
  3. Data_fullResults.mat - this contains two structures; the first is the average results of the simulations; the second contain per subject results

Scripts list:  
  1. Script_DatasetCreation.m - this script deals with the data pre-processing; it requires the NinaPro database and generates Data_fullDataset and Data_sfDataset
  2. Script_FullSimulation.m - this script runs all the simulation of the 4 methods; it requires both datasets and generates Data_fullResults
  3. Script_PlotResults.m - this script plots some graphs to show the results and save them in Figures  

Data functions list (functions tha manipulates data):  
  1. dataDenormalize.m - function to denormalize matricial data
  2. dataPerformance.m - function to calculate MSE, RMSE and R2 of matricial data
  3. dataPlotSelector.m - function that generates an easy to plot array of data, from the selected scenarios of Data_fullResults
  4. dataSimResults.m - function that calculate the average of the performance indexes along the subjects  

Net function list (function that generates the neural networks):  
  1. netAutoEncoder.m - generation and configuration of the AutoEncoder
  2. netDoubleAutoEncoder.m - generation and configuration of the DoubleAutoEncoder
  3. netDAEoutputNorm.m - function to calculate the correct range of normalization for the outputs of the DAE  

Methods' functions list (one function for each one of the 4 methods):  
  1. meth1_LFR.m - application of the LFR method and calculation of its performances
  2. meth2_NNMF.m - application of the NNMF method and calculation of its performances
  3. meth3_AE.m - training and simulation of the AE and calculation of its performances
  4. meth4_DAE.m - training and simulation of the DAE and calculation of its performances
  
  

  
