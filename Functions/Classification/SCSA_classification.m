%% ###############   Epileptic Spikes Detection 2019  ############################
% This script applies classification using the  Semi-Classical
% Signal Analysis (SCSA) method features

%% ###############   Feature selection using combinaision  ############################
% This script finds the best combinaison  bases on  SCSA features

% Important: the input data are stored in "./Input_data/DSP_features/*.mat' files  containning:
% [X: biomedical signal with/without Spikes ] 
% [y : Mbiomedical signal  class ]     
%% ###########################################################################
%  Author:
%  Abderrazak Chahid (abderrazak.chahid@gmail.com)
% Done: Dec,  2018
%
%% ###########################################################################
% warning('off','all'); 
%% ###########################################################################
% clear all;  close all ;format shortG;  addpath ./Functions ;Include_function ;%log_html_file
global h ;clearvars op_combinaison op_comb_name SCSA_parameters_op  SCSA_parameters_op

% SCSA based features
gm=0.5; fs=1;

%% Find the optimal combination of the features  
feature_TAG={'F_','S_'};        % features TAG to be combined
feature_type='SCSA_';


%% #########################   Display   ################################
fprintf('\n --> Run CV  classification using : ');
d_data0=string(strcat(feature_type(1:end-1),'-based Features'));
fprintf(' %s\n ',d_data0);

%% ###################################################################

root_folder='./Classification_result/SCSA';
root_folder=strcat(Path_classification,'SCSA');

if exist(root_folder)~=7; mkdir(root_folder);end 
 
cnt=1;
Acc_op=0;
for h=h_list

    %% Find the optimal combination of the features  SCSA  
    [F_SCSA, S_SCSA, B_SCSA, P_SCSA,AF_SCSA,SFP_SCSA,SK_features,INVK_features,Nh_all, Eigen_Spectrum]=SCSA_Transform_features(X,y,h,gm,fs);

    % Save the SCSA features
    data_file=strcat(root_folder,'/SCSA_features',num2str(h),'.mat');
    save(data_file,'F_SCSA', 'S_SCSA', 'B_SCSA', 'P_SCSA', 'AF_SCSA','SFP_SCSA','SK_features','Nh_all','y');

    %% Test all possible conbinaisons of SCSA features and get the optimal combination
    [SCSA_X, op_comb, op_comb_name, perform_output,Acc]=Find_the_optimal_feature_combination(data_file,feature_TAG,K,CV_type,type_clf);
     %% Add the optimal results to the used h
    SCSA_parameters_op(1,cnt)=h;
    SCSA_parameters_op(2,cnt)=op_comb.Accuracy;
    SCSA_parameters_op(3,cnt)=op_comb.Vector_Size;
    SCSA_parameters_op(4,cnt)=mean(Nh_all);

    op_combinaison(cnt,:)=op_comb
    op_comb_name{cnt}=op_comb_name;
    cnt=cnt+1;
    
    
    if Acc_op<Acc
        SCSA_X_op=SCSA_X;sz_SCSA=size(SCSA_X_op,2);
        List_Features=op_comb;
        h_op=h;
        
        % {'Vector_Size','Accuracy','Sensitivity','Specificity','Precision','Gmean','F1score'};
        CV_results_op=[sz_SCSA, op_comb.Accuracy,op_comb.Sensitivity,op_comb.Specificity,op_comb.Precision,op_comb.Gmean,op_comb.F1score0,op_comb.AUC];
        
        %{'Dataset','Configuration','size','Method','parameters','CV','Classifier'}
        CV_config_op={noisy_file,num2str(Conf_Elctr), num2str(size(X,1)),feature_type(1:end-1), strcat('h=',num2str(h),', Nh=',num2str(op_comb.Mean_Nh),', ',op_comb.Combination),CV_type,type_clf };
        %{'Dataset','Configuration','size','L','step','Method','parameters','CV','K','Classifier'}
        CV_config_op={noisy_file,num2str(Conf_Elctr), num2str(size(X,1)),num2str(L_max),num2str(Frame_Step),feature_type(1:end-1), strcat('h=',num2str(h),', Nh=',num2str(op_comb.Mean_Nh),', ',op_comb.Combination),CV_type,num2str(K),type_clf };
 


        
    end
    
     clearvars op_comb perform_output data_file 

end
scsa_param=strcat('_h',num2str(h_op),'_gm',num2str(gm),'_fs',num2str(fs));

 %% save the optimal combinaision
Acc_op=max(op_combinaison.Accuracy);
save(strcat(Path_classification,feature_type,scsa_param,noisy_file,suff,'_norm',num2str(Normalization),'_',CV_type,'_',type_clf,'_Acc',num2str(Acc_op),'.mat'),'op_combinaison','op_combinaison', 'op_comb_name','K','SCSA_parameters_op',...
                                                             'scsa_param','gm','fs','List_Features','SCSA_X_op','y','L_max','noisy_file','suff','filename')                                                       

                                                                      
%% Get the best results of PWM8
   colnames_results={'Vector_Size','Accuracy','Sensitivity','Specificity','Precision','Gmean','F1score','AUC'};
   Comp_performance_Table= array2table(CV_results_op, 'VariableNames',colnames_results);
    
  
   colnames_results={'Dataset','Configuration','size','L','step','Method','parameters','CV','K','Classifier'};
   Comp_config_Table= array2table(CV_config_op, 'VariableNames',colnames_results);
    
   % Add the optimal parameters
   Comp_results_Table=[Comp_results_Table; [Comp_config_Table ,Comp_performance_Table]];
   
                                                        