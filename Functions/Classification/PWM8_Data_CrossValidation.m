 %% Apply Leave One Out CV with PWM features using diffferent classifers
% X: The data  sample
% y  The Class
% clf: The calssifier:{'nbayes','logisticRegression','SVM','','',''}
% function [accuracy1,sz_fPWM]= Classify_LeaveOut_PWM(X,y,clf)
function [sz_fPWM, Avg_Accuracy,Avg_sensitivity,Avg_specificity,Avg_precision,Avg_gmean,Avg_f1score,Avg_AUC]=PWM8_Data_CrossValidation(X, y,CV_type, K,type_clf)

global Levels Level_intervals L y_PatientID

if strcmp(CV_type,'LOO')==1
    C = cvpartition(y, 'LeaveOut');
    
    fprintf('------------------------------------------------------------------\n')
    fprintf('            Leave-One-Out Cross Validation using %s           \n',type_clf )
    fprintf('------------------------------------------------------------------\n')
    Nb_folds=C.NumTestSets;

elseif strcmp(CV_type,'KFold')==1
    C = cvpartition(y, 'KFold',K);
    
    fprintf('------------------------------------------------------------------\n')
    fprintf('            The %d-Folds Cross Validation using %s           \n',K,type_clf )
    fprintf('------------------------------------------------------------------\n')
    Nb_folds=C.NumTestSets;

else
    fprintf('\n --> Error: undefined Cross-Validation : %s',CV_type);

end

Bi_classes=  unique(y);

for num_fold = 1:C.NumTestSets
    clearvars  PWM_* XP Xn
    trIdx = C.training(num_fold);                                            
    teIdx = C.test(num_fold);
    Idx= find(teIdx);

    %% Get the fold training and tesing samples
    X_train= X(trIdx,:);                                                     X_test= X(teIdx,:); 
    y_train= y(trIdx);                                                       y_test= y(teIdx);
    Np1=sum(y_test);
    
    %% Get the positive and negative training samples to build PWM matrices
    Xp=X_train(y_train==1,:);   Np=size(Xp, 1);
    Xn=X_train(y_train==0,:);   Nn=size(Xn, 1);
%     if abs(Np-Nn)>2
%         fprintf('Non balanced testing data\n\n')
%         CV_Status=No_blanced; 
% 
%     end

    %% Get the  QuPWM features
    script_get_QuPWM_features_for_train_test_split

    [Mdl,Accuracy(num_fold),sensitivity(num_fold),specificity(num_fold),precision(num_fold),gmean(num_fold),f1score(num_fold),AUC(num_fold),ytrue,yfit,score]...
    =Classify_Data(type_clf, fPWM_train, y_train, fPWM_test, y_test);

     Mdl_SVM_mPWM=Mdl;
     Accuracy
%     Accuracy(num_fold)
%         CV_results_op=[Accuracy(num_fold),sensitivity(num_fold),specificity(num_fold),precision(num_fold),gmean(num_fold),f1score(num_fold),AUC(num_fold)];
%         Fold_results= array2table(CV_results_op, 'VariableNames',{'Accuracy','Sensitivity','Specificity','Precision','Gmean','F1score','AUC'})

%     break;
 subjects_names=join(unique(y_PatientID),"");
 path_python=strcat('./python/mat/PWM8_2/',subjects_names,'/',num2str(L));
 if exist(path_python)~=7, mkdir(path_python); end
 save(strcat(path_python,'/dataset_MEG',subjects_names,'L',num2str(L),'_fold',num2str(num_fold),'.mat'),'fPWM_train', 'y_train', 'fPWM_test', 'y_test','Accuracy')
end

%% Average Accuracy 
Avg_Accuracy = mean(Accuracy);%/C.NumTestSets;
Avg_sensitivity = mean(sensitivity);%/C.NumTestSets;
Avg_specificity = mean(specificity);%/C.NumTestSets;
Avg_precision = mean(precision);%/C.NumTestSets;
Avg_f1score = mean(f1score);%/C.NumTestSets;
Avg_gmean = mean(gmean);%/C.NumTestSets;
Avg_AUC = mean(AUC);%/C.NumTestSets;

Accuracy;
Avg_Accuracy;
sz_fPWM=size(fPWM_train,2);



end

%% Funtions
