function analyze_all_static()
    addpath('phase1_data');
    propSizes = {90,95,100}; % inch * 10^-1
    
    %{
    torque: 9
    thrust: 10
    elec Power: 15
    mech power: 16
    motor eff: 17
    prop eff: 18
    overall eff: 19
    %}
    
    combined_O = figure;
    hold on;
    
    combined_P = figure;
    hold on;
    
    for propID = 1:3
        test_name = sprintf("prop%d_static",propSizes{propID});
        table_in = readtable(sprintf("%s.csv",test_name));
        arr_in = table2array(table_in);
        
        % Find portion of data that script is running
        cut_start = find(arr_in(:,1) == 0, 1, 'last');
        cut_end = find(arr_in(:, 1) > 23 & (isnan(arr_in(:, 2)) | arr_in(:,2) == 1000), 1);
        arr_cut = arr_in(cut_start:cut_end,:);
        
        time_arr = arr_cut(:,1);
        Q = arr_cut(:,9) - arr_in(1,9); % Nm
        T = arr_cut(:,10) - arr_cut(1,10); % Zero thrust readings
        T = T * -9.80665; %kgf to N
        V = arr_cut(:,13) .* (2*pi/60); % RPM to rad/s
        Pe = arr_cut(:,15); % W
        Pm = arr_cut(:,16); % W
        effM = arr_cut(:,17); % 
        effP = arr_cut(:,18) * 9.80665; % kgf/W to N/W
        effO = arr_cut(:,19) * 9.80665; % kgf/W to N/W
        
        Pm_calc = -Q .* V; % W
        effM_calc = Pm_calc ./ Pe;
        effP_calc = T ./ Pm_calc;
        effO_calc = effM_calc .* effP_calc;
        
        fig = figure;
        sgtitle(sprintf("%2.1f Inch Propeller Efficiency", propSizes{propID}/10));
        
        subplot(2,3,1)
        hold on
        %plot(time_arr, Pm);
        plot(time_arr, Pm_calc);
        title(sprintf("Mechanical Power\nW"));
        
        subplot(2,3,2)
        hold on
        plot(time_arr, Pe);
        title(sprintf("Electrical Power\nW"));
        
        subplot(2,3,3)
        hold on
        plot(time_arr, effM_calc);
        title("Motor Efficiency");
        
        subplot(2,3,4)
        hold on
        plot(time_arr, effP_calc,'r');
        title(sprintf("Propeller Efficiency\nN/W"));
        ylim([0,10]);
        yline(0,'--');
        
        subplot(2,3,5)
        hold on
        plot(time_arr, effO_calc,'r');
        title(sprintf("Overall Efficiency\nN/W"));
        yline(0,'--');

        saveas(fig, sprintf("prop%d_plots/prop%d_efficiency.png", propSizes{propID}, propSizes{propID}));
        
        
        figure(combined_O)
        plot(time_arr, effO_calc);
        
        figure(combined_P)
        plot(time_arr, effP_calc);
    
    end
    
    figure(combined_O)
    ylim([0,0.1]);
    yline(0,'--');
    xlabel("Time (s)")
    ylabel("Efficiency (N/W)");
    title("Overall Efficiency for static tests");
    legend({"9 inch","9.5 inch", "10 inch"});
    saveas(combined_O, "Combined_Overall_eff.png");
    
    figure(combined_P)
    ylim([0,10]);
    yline(0,'--');
    xlabel("Time (s)")
    ylabel("Efficiency (N/W)");
    title("Propeller Efficiency for static tests");
    legend({"9 inch","9.5 inch", "10 inch"});
    saveas(combined_O, "Combined_Prop_eff.png");
end



