function PLMmetrics = calculatePLMmetricsWithEEG(mat_events_epoch_cycle_stage, stage_dur_hour,mat_resp,sample_rate,key, plm_params,respiratoryRemovalType,eeg_params)
%mat_events_epoch - 3 column matrix of predicted leg movements (start,
%stop, epoch)
%mat_resp - 2 column matrix of respiratory events to be removed
%PLMmetrics is a structure with the following fields
%     PLMmetrics.periodicity = periodicity_results;
%     PLMmetrics.hrs_evaluated = stage_dur_hour;
%     PLMmetrics.attrition_strength = strength_attrition_results;
%     PLMmetrics.attrition_plm = plm_attrition_results;
%     PLMmetrics.strength =strength_results;
%     PLMmetrics.PLMI = PLMI_results;
%     PLMmetrics.HR_delta = change in heart rate from min to max
%     PLMmetrics.HR_slope = slope of heart rate change
%respiratoryRemovalType - optional string, which can be 
%   'both' remove around offset and onset [default]
%   'offset' remove around offset
%   'onset' remove around onset
%   'beforeoffset' remove before offset
%   'beforeonset' remove before onset to onset
%   'afteroffset' remove offset to after offset
%   'afteronset' remove from onset to exclude_win after onset
%   'custom' see the final function exclude_artifact
%
% Written by Hyatt Moore IV
% created May 7, 2013 as a modification to calculatePLMmetrics.m 
% to include EEG PSD shifts around PLM
    liteMetrics = false;
    eeg_fields = {'slow','delta','theta','alpha','sigma','beta','gamma'};

%      liteMetrics = false;
    if(liteMetrics)
        PLMmetrics.PLMI = 'PLMI';
        PLMmetrics.PLM_count = 'PLM count';
        PLMmetrics.PLM_first_half = 'PLM first half count';
        PLMmetrics.PLM_second_half = 'PLM first half count';        
        PLMmetrics.lmcount = 'LM count';
        PLMmetrics.periodicity = 'Periodicity Index';
        PLMmetrics.hrs_evaluated = 'Hours evaluated';
        PLMmetrics.HR_delta = 'Heart rate (delta)';
        PLMmetrics.HR_slope = 'Heart rate (slope)';
        PLMmetrics.ratio_plm = 'PLM night ratio';%number of plm in first half of study/number of plm in second half of study
        PLMmetrics.ratio_lm = 'LM night ratio'; %number of lm in first half of study/number of lm in second half of study
        PLMmetrics.slow = 'slow (0.5-4) Hz';
        PLMmetrics.delta = 'delta [0.5,4) Hz';
        PLMmetrics.theta = 'theta [4,8) Hz';
        PLMmetrics.alpha = 'alpha [8,12) Hz';
        PLMmetrics.sigma = 'sigma [12,16) Hz';
        PLMmetrics.beta =  'beta [16,30) Hz';
        PLMmetrics.gamma = 'gamma (30,50) Hz';
        PLMmetrics.all_slow = 'all slow (0.5-4) Hz';
        PLMmetrics.all_delta = 'all delta [0.5,4) Hz';
        PLMmetrics.all_theta = 'all theta [4,8) Hz';
        PLMmetrics.all_alpha = 'all alpha [8,12) Hz';
        PLMmetrics.all_sigma = 'all sigma [12,16) Hz';
        PLMmetrics.all_beta =  'all beta [16,30) Hz';
        PLMmetrics.all_gamma = 'all gamma (30,50) Hz';
        PLMmetrics.auc = 'Area Under the Curve (PLM)';
        PLMmetrics.all_auc = 'Area Under the Curve (All)';
        
        PLMmetrics.plm_duration_sec = 'PLM Duration (sec)';
        PLMmetrics.all_duration_sec = 'All Duration (sec)';
        
        PLMmetrics.rms = 'Root mean square (PLM)';
        PLMmetrics.all_rms = 'Root mean square (All)';
        
        PLMmetrics.median = 'Median absolute value (PLM)';
        PLMmetrics.all_median = 'Median absolute value (All)';
        
        PLMmetrics.abs_amplitude = 'absolute amplitude (PLM)';
        PLMmetrics.all_abs_amplitude = 'absolute amplitude (All)';

    else
        PLMmetrics.PLMI = 'PLMI';
        PLMmetrics.PLM_count = 'PLM count';
        PLMmetrics.PLM_first_half = 'PLM first half count';
        PLMmetrics.PLM_second_half = 'PLM first half count';
        PLMmetrics.PLM_hr_1 = 'PLM hour 1';
        PLMmetrics.PLM_hr_2 = 'PLM hour 2';
        PLMmetrics.PLM_hr_3 = 'PLM hour 3';
        PLMmetrics.PLM_hr_4 = 'PLM hour 4';
        PLMmetrics.PLM_hr_5 = 'PLM hour 5';
        PLMmetrics.PLM_hr_6 = 'PLM hour 6';
        PLMmetrics.PLM_hr_7 = 'PLM hour 7';
        PLMmetrics.PLM_hr_8 = 'PLM hour 8';
        
        PLMmetrics.PLM_stage_1 = 'PLM stage 1';
        PLMmetrics.PLM_stage_2 = 'PLM stage 2';
        PLMmetrics.PLM_stage_SWS = 'PLM SWS';
        PLMmetrics.PLM_stage_5 = 'PLM REM';
        PLMmetrics.PLM_stage_WASO = 'PLM WASO';

        
        PLMmetrics.lmcount = 'Leg Movement count';
        PLMmetrics.periodicity = 'Periodicity Index';

        
        PLMmetrics.auc = 'Area Under the Curve (PLM)';
        PLMmetrics.all_auc = 'Area Under the Curve (All)';
        
        PLMmetrics.plm_duration_sec = 'PLM Duration (sec)';
        PLMmetrics.all_duration_sec = 'All Duration (sec)';
        
        PLMmetrics.rms = 'Root mean square (PLM)';
        PLMmetrics.all_rms = 'Root mean square (All)';
        
        PLMmetrics.median = 'Median absolute value (PLM)';
        PLMmetrics.all_median = 'Median absolute value (All)';
        
        PLMmetrics.abs_amplitude = 'absolute amplitude (PLM)';
        PLMmetrics.all_abs_amplitude = 'absolute amplitude (All)';
        
        %     PLMmetrics.periodicity_with_plmi_5 = 'Periodicity Index > 0.3 and PLMI > 5';
        %     PLMmetrics.periodicity_with_plmi_10 = 'Periodicity Index > 0.3 and PLMI > 10';
        %     PLMmetrics.periodicity_with_plmi_15 = 'Periodicity Index > 0.3 and PLMI > 15';
        %     PLMmetrics.periodicity_with_plmi_30 = 'Periodicity Index > 0.3 and PLMI > 30';
        
        PLMmetrics.plmi_periodicity_product = 'PLMI*Periodicity Index';
        PLMmetrics.plm_to_lm_ratio = 'PLM:LM ratio';
        PLMmetrics.normalized_PLMI = 'Normalized PLMI (PLMI*PLM/LM)';
        PLMmetrics.plm_periodicity_product = 'PLM*Periodicity Index';
        PLMmetrics.lm_periodicity_product = 'LM*Periodicity Index';
        PLMmetrics.onset2onset_sec = 'mean Onset to onset (sec) all';
        PLMmetrics.onset2onset_plm_sec = 'mean onset to onset PLM interval (sec)';
        PLMmetrics.onset2onset_plm_std_sec = 'std onset to onset PLM interval (sec)';
        PLMmetrics.onset2onset_sec_plm_60 = 'PLM onset to onset < 60(sec)';
        PLMmetrics.onset2onset_sec_5_60 = 'Number of LM with onset to onset between 5 and 60 (sec)';
        PLMmetrics.onset2onset_sec_5_60 = 'Number of LM with onset to onset between 5 and 60 (sec)';
        
        PLMmetrics.strength = 'Strength';
        
            PLMmetrics.inter_interval_frequency = 'Inter interval frequency';
            PLMmetrics.attrition_plm_by_hour = 'Attrition (PLM/hour)';
            PLMmetrics.attrition_plm_by_cycle = 'Attrition (PLM/cycle)';
            PLMmetrics.attrition_lm_by_hour = 'Attrition (LM/hour)';
            PLMmetrics.attrition_lm_by_cycle = 'Attrition (LM/cycle)';
            PLMmetrics.attrition_strength = 'Attrition (strength)';
        PLMmetrics.hrs_evaluated = 'Hours evaluated';
        PLMmetrics.HR_delta = 'Heart rate (delta)';
        PLMmetrics.HR_slope = 'Heart rate (slope)';
        PLMmetrics.ratio_plm = 'PLM night ratio (first half/second half)';%number of plm in first half of study/number of plm in second half of study
        PLMmetrics.ratio_lm = 'LM night ratio (first half/second half)'; %number of lm in first half of study/number of lm in second half of study
        
        PLMmetrics.slow = 'slow (0.5-4) Hz';
        PLMmetrics.delta = 'delta [0.5,4) Hz';
        PLMmetrics.theta = 'theta [4,8) Hz';
        PLMmetrics.alpha = 'alpha [8,12) Hz';
        PLMmetrics.sigma = 'sigma [12,16) Hz';
        PLMmetrics.beta =  'beta [16,30) Hz';
        PLMmetrics.gamma = 'gamma (30,50) Hz';
        PLMmetrics.all_slow = 'all slow (0.5-4) Hz';
        PLMmetrics.all_delta = 'all delta [0.5,4) Hz';
        PLMmetrics.all_theta = 'all theta [4,8) Hz';
        PLMmetrics.all_alpha = 'all alpha [8,12) Hz';
        PLMmetrics.all_sigma = 'all sigma [12,16) Hz';
        PLMmetrics.all_beta =  'all beta [16,30) Hz';
        PLMmetrics.all_gamma = 'all gamma (30,50) Hz';

    end
    
if(nargin>0)
    fnames = fieldnames(PLMmetrics);
    for f=1:numel(fnames)
        PLMmetrics.(fnames{f}) = NaN;        
    end
    if(stage_dur_hour>2)
        if(~isempty(mat_events_epoch_cycle_stage))
            mat_predictor = mat_events_epoch_cycle_stage(:,1:2);
            predictor_epochs = mat_events_epoch_cycle_stage(:,3);
            predictor_cycles = mat_events_epoch_cycle_stage(:,4);
            predictor_stages = mat_events_epoch_cycle_stage(:,5);
        else
            mat_predictor = [];
            predictor_epochs = [];
            predictor_cycles = [];
            predictor_stages = [];
        end
        if(nargin<7)
            respiratoryRemovalType = 'custom';
        end
        if(nargin>2 && ~isempty(mat_resp) && ~strcmpi(respiratoryRemovalType,'none'))
            [mat_predictor,held_indices] = removeOverlappingRespiratoryEvents(mat_predictor,mat_resp,respiratoryRemovalType);
            plm_params = plm_params(held_indices);
            eeg_params = eeg_params(held_indices);
            predictor_epochs = predictor_epochs(held_indices);
            predictor_cycles = predictor_cycles(held_indices);
            predictor_stages = predictor_stages(held_indices);
        end
        
        LM_count = size(mat_predictor,1); %number of rows available
        if(LM_count>2) %otherwise, may have a divide by 0 for ferri's periodicity calculation
            plm_params_mat = cell2mat(plm_params);
            eeg_params_mat = cell2mat(eeg_params);
            
            lm_struct.new_events = mat_predictor;
            if(isfield(plm_params_mat,'median'))

                high_noise_uV = cells2mat(plm_params_mat.high_uV);
                auc = cells2mat(plm_params_mat.auc);
                held_ind = auc>0.5*(high_noise_uV);

                lm_struct.new_events =lm_struct.new_events(held_ind,:);
                plm_params_mat = plm_params_mat(held_ind);
                predictor_epochs = predictor_epochs(held_ind);
                predictor_cycles = predictor_cycles(held_ind);
                predictor_stages = predictor_stages(held_ind);
                try
                    eeg_params_mat = eeg_params_mat(held_ind);
                catch me %shut down the EEG analysis for now
                    eeg_params_mat = []; 
                    eeg_fields = [];
%                     showME(me);
                end
            end
            
            if(size(lm_struct.new_events,1)>2)
                
                plm_struct = calculatePLMstruct(lm_struct,sample_rate);
                params = plm_struct.paramStruct;
                %plmi
                PLM_ind = params.meet_AASM_PLM_criteria; %a logical vector
                PLM_count = sum(PLM_ind);
                

                PLMI_results = PLM_count/stage_dur_hour;
                
                %strength - plm/series
                %                         [paramCell{:}] = params.series;
                %                         paramMat = cell2mat(paramCell);
                %                         numSeries = max(paramMat);
                numSeries = max(params.series);
                if(numSeries>0);
                    strength_results = PLM_count/numSeries;
                    
                    %strength attrition
                    t = thresholdcrossings(params.series,0);
                    y = (t(:,2)-t(:,1))'; %the number of PLM's per unbroken series
                    x = 1:numel(y);
                    if(numel(y)>1)
                        p = polyfit(x,y,1);
                        strength_attrition_results = p(1);
                    else
                        strength_attrition_results = NaN;
                        
                    end
                else
                    strength_results = NaN;
                    strength_attrition_results = NaN;
                end
                %plm attrition
                %                 hrs_slept = round(qParams.epoch(end)/120);%30/60/60 (30 second epochs divided by 3600 seconds to get hours
                stage_dur_hr = round(stage_dur_hour);
                hrs2epochs = 1*3600/30;  %3600 seconds/hour * 1 epoch/30 seconds
                
                %                             PLM_epochs = qPredict.epoch(PLM_ind);
                
                halfway_epoch = (stage_dur_hr*hrs2epochs)/2;
                
                PLM_stages = predictor_stages(PLM_ind);
                PLM_stage_1 = sum(PLM_stages==1);
                PLM_stage_2 = sum(PLM_stages==2);
                PLM_SWS = sum(PLM_stages==3|PLM_stages==4);
                PLM_REM = sum(PLM_stages==5);
                PLM_WASO = sum(PLM_stages==0);
                
                
                PLM_epochs = predictor_epochs(PLM_ind);
                plm_first_half = sum(PLM_epochs<halfway_epoch);
                plm_second_half = sum(PLM_epochs>halfway_epoch);
                if(plm_second_half ==0 || plm_first_half==0)
                    ratio_plm = NaN;
                else
                    ratio_plm = plm_first_half/plm_second_half;
                end
                lm_first_half =  sum(predictor_epochs<halfway_epoch);
                lm_second_half = sum(predictor_epochs>halfway_epoch);
                if(lm_second_half ==0 || lm_first_half==0)
                    ratio_lm = NaN;
                else
                    ratio_lm = lm_first_half/lm_second_half;
                end
                PLM_hour = zeros(1,8);
                PLM_hour(1:stage_dur_hr) = histc(PLM_epochs/120,1:stage_dur_hr);
                
                try
                    p = polyfit(1:stage_dur_hr,PLM_hour(1:stage_dur_hr),1);
                catch me
                    showME(me);
                    p = NaN;
                end
                plm_attrition_by_hour_results = p(1);
                
                LM_epochs = predictor_epochs;
                
                y = histc(LM_epochs/120,1:stage_dur_hr)';
                try
                    p = polyfit(1:stage_dur_hr,y,1);
                catch me
                    showME(me)
                    p = NaN;
                end
                lm_attrition_by_hour_results = p(1);
                
                PLM_cycles = predictor_cycles(PLM_ind);
                num_cycles = max(PLM_cycles)-1;
                if(num_cycles>1)
                    y = histc(PLM_cycles(1:end-1),1:num_cycles)';
                    try
                        p = polyfit(1:num_cycles,y,1);
                    catch me
                        disp(me);
                        p = NaN;
                    end
                    plm_attrition_by_cycle_results = p(1);
                else
                    plm_attrition_by_cycle_results = NaN;                    
                end
                
                LM_cycles = predictor_cycles;
                num_cycles = max(LM_cycles)-1;
                if(num_cycles>1)
                    y = histc(LM_cycles(1:end-1),1:num_cycles)';
                    try
                        p = polyfit(1:num_cycles,y,1);
                    catch me
                        disp(me);
                        p = NaN;
                    end
                    lm_attrition_by_cycle_results = p(1);
                else
                    lm_attrition_by_cycle_results = NaN;
                end

                %             plm_params_mat = cell2mat(plm_params);
                x = cell(size(eeg_params_mat));
                for f=1:numel(eeg_fields)
                    
                    [x{:}] = eeg_params_mat.(eeg_fields{f});
                    paramStruct.(eeg_fields{f}) = cell2mat(x);
                    
                end
                
                x = cell(size(plm_params_mat));
                [x{:}] = plm_params_mat.HR_slope;
                HR_slope = cell2mat(x);
%                 x = cell(size(plm_params_mat));
                [x{:}] = plm_params_mat.HR_delta;
                HR_delta = cell2mat(x);
                
                bad_ind = isinf(HR_slope)|isinf(HR_delta)|isnan(HR_slope)|isnan(HR_delta);
                HR_slope(bad_ind) = [];
                HR_delta(bad_ind) = [];
                
                LM_duration_sec = (mat_predictor(:,2)-mat_predictor(:,1)+1)/sample_rate;
                PLMmetrics.all_duration_sec = mean(LM_duration_sec);

                %periodicity
                if(PLM_count>3)
                    PLMmetrics.PLM_first_half = plm_first_half;
                    PLMmetrics.PLM_second_half = plm_second_half;                    
                    PLMmetrics.PLM_hr_1 = PLM_hour(1);
                    PLMmetrics.PLM_hr_2 = PLM_hour(2);
                    PLMmetrics.PLM_hr_3 = PLM_hour(3);
                    PLMmetrics.PLM_hr_4 = PLM_hour(4);
                    PLMmetrics.PLM_hr_5 = PLM_hour(5);
                    PLMmetrics.PLM_hr_6 = PLM_hour(6);
                    PLMmetrics.PLM_hr_7 = PLM_hour(7);
                    PLMmetrics.PLM_hr_8 = PLM_hour(8);
                    
                    PLMmetrics.PLM_stage_1 = PLM_stage_1;
                    PLMmetrics.PLM_stage_2 = PLM_stage_2;
                    PLMmetrics.PLM_stage_SWS = PLM_SWS;
                    PLMmetrics.PLM_stage_5 = PLM_REM;
                    PLMmetrics.PLM_stage_WASO = PLM_WASO;
                    
                    PLMmetrics.plm_duration_sec = mean(LM_duration_sec(PLM_ind));
                    
                    periodicity_results = sum(params.meet_ferri_inter_lm_duration_criteria)/(LM_count-1);
                    PLMmetrics.plm_to_lm_ratio = sum(PLM_ind)/(LM_count);
                    
                    metricFields = [{'median','rms','abs_amplitude','auc'},eeg_fields];
                    for m=1:numel(metricFields)
                        if(isfield(plm_params_mat,metricFields{m}))
                            metric_values = cells2mat(plm_params_mat.(metricFields{m}));
                            PLMmetrics.(metricFields{m}) = mean(metric_values(PLM_ind));
                            PLMmetrics.(strcat('all_',metricFields{m})) = mean(metric_values);
%                             PLMmetrics.(metricFields{m}) = (metric_values(PLM_ind));
%                             PLMmetrics.(strcat('all_',metricFields{m})) = (metric_values);
                        elseif(isfield(eeg_params_mat,metricFields{m}))
                            metric_values = cells2mat(eeg_params_mat.(metricFields{m}));
                            PLMmetrics.(metricFields{m}) = mean(metric_values(PLM_ind));
                            PLMmetrics.(strcat('all_',metricFields{m})) = mean(metric_values);
                        end
                    end
                else
                    periodicity_results = NaN;
                    PLMmetrics.plm_to_lm_ratio = NaN;
                    HR_slope = NaN;
                    HR_delta = NaN;
                    ratio_plm = nan;
                end;
                
                %             if(PLMI_results>5)
                %                 periodicity_with_plmi_results = periodicity_results;
                %             else
                %                 periodicity_with_plmi_results = NaN;
                %             end
                PLMmetrics.PLMI = PLMI_results;
                PLMmetrics.PLM_count = PLM_count;
                PLMmetrics.lmcount = LM_count;
                PLMmetrics.periodicity = periodicity_results;
                %             PLMmetrics.periodicity_with_plmi = periodicity_with_plmi_results;
                PLMmetrics.plmi_periodicity_product = PLMI_results*PLMmetrics.periodicity;
                PLMmetrics.plm_periodicity_product = PLMmetrics.PLM_count*PLMmetrics.periodicity;
                PLMmetrics.lm_periodicity_product = PLMmetrics.lmcount*PLMmetrics.periodicity;
                PLMmetrics.normalized_PLMI = PLMI_results*PLMmetrics.plm_to_lm_ratio;
                
                
                PLMmetrics.onset2onset_sec = mean(params.onset2onset_sec(params.onset2onset_sec<90));
                PLMmetrics.onset2onset_plm_sec = mean(params.onset2onset_sec(params.onset2onset_sec<90 & PLM_ind));
                PLMmetrics.onset2onset_plm_std_sec = std(params.onset2onset_sec(params.onset2onset_sec<90 & PLM_ind));
                PLMmetrics.onset2onset_sec_plm_60 = mean(params.onset2onset_sec(params.onset2onset_sec<60 & PLM_ind));
                PLMmetrics.onset2onset_sec_5_60 = sum(params.onset2onset_sec<60& params.onset2onset_sec>5);
                
                %             PLMmetrics.inter_interval_frequency = 'Inter interval frequency';
                
                PLMmetrics.strength =strength_results;
                
                            PLMmetrics.attrition_plm_by_hour = plm_attrition_by_hour_results;
                            PLMmetrics.attrition_plm_by_cycle = plm_attrition_by_cycle_results;
                            PLMmetrics.attrition_lm_by_hour = lm_attrition_by_hour_results;
                            PLMmetrics.attrition_lm_by_cycle = lm_attrition_by_cycle_results;
                            PLMmetrics.attrition_strength = strength_attrition_results;
                
                PLMmetrics.hrs_evaluated = stage_dur_hour;
                PLMmetrics.HR_delta = mean(HR_delta);
                PLMmetrics.HR_slope = mean(HR_slope);
                
                PLMmetrics.ratio_plm = ratio_plm;
                PLMmetrics.ratio_lm = ratio_lm;
            else
                PLMmetrics.PLMI = 0;
                PLMmetrics.PLM_count = 0;
                PLMmetrics.lmcount = LM_count;
                PLMmetrics.onset2onset_sec = 0;
                PLMmetrics.hrs_evaluated = stage_dur_hour;
            end
        else
            PLMmetrics.PLMI = 0;
            PLMmetrics.PLM_count = 0;
            PLMmetrics.lmcount = LM_count;
            PLMmetrics.onset2onset_sec = 0;
            PLMmetrics.hrs_evaluated = stage_dur_hour;
        end
        if(liteMetrics)
            unwantedFields = setdiff(fieldnames(PLMmetrics),fnames);
            PLMmetrics = rmfield(PLMmetrics,unwantedFields);
 
        end
    else %stage duration less than 2 hours.
        PLMmetrics = [];
        fprintf(1,'Study less than 2 hours - studykey=%u\n',key);
    end
end