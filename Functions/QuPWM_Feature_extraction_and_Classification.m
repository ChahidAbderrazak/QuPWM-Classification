   
%% ###############   Biomedical signals classification 2019 ############################
% This script detects epileptic spikes bases on Quantization based Position Weight Matrices (QuPWM)

%% ###########################################################################
%  Author:
%  Abderrazak Chahid (abderrazak.chahid@gmail.com)
% Done: Dec,  2018
%
%% ###########################################################################
warning('off');
% clear all;  close all ;format shortG;  addpath ./Functions ;Include_function ;%log_html_file
global kk y h filename  root_folder 

%% ###########################################################################
beta=0;EN_starplus=0;

if exist('Comp_results_Table','var') == 0 , Comp_results_Table = table;  end                   % Table to save results

for EN_FFT=1
    for Normalization=0
        
        %  get the dataset  for classification
        X=X0;y=y0; y_PatientID=y_PatientID0;
        global y_patient
        y_patient=y_PatientID;     
    
   %% Feature generation  & Classification
            Classification_Parameters                

    %% ### PWM-based Classification 
         list_M=2*[3,4]; 
         list_k=[0.6,0.7];   

    %% PWM-based features
        tic
            PWM2_Classification;
        Time_PWM2=toc

    %% PWM8-based features
        kk=1;
        tic
            PWM8_Classification;
        Time_PWM8=toc

    end
end
 
fprintf('\n################  Data classification Round is done  ################\n\n')
