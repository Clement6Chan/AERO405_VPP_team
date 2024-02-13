function result_struct = analyze_single(prop_name, freq)
    result_struct.status = 1;
    
    % Read in data
    cd phase1_data
    test_name = sprintf("%s_%d",prop_name,freq);
    table_in = readtable(sprintf("%s.csv",test_name));
    arr_in = table2array(table_in);
    
    % Find portion of data that script is running
    cut_start = find(arr_in(:,1) == 0, 1, 'last');
    cut_end = find(arr_in(:, 1) > 23 & (isnan(arr_in(:, 2)) | arr_in(:,2) == 1000), 1);
    arr_cut = arr_in(cut_start:cut_end,:);
    
    % Index of script arr when Prop starts turning
    rpm_start = find(arr_cut(:,13) == 0, 1, 'last');
    
    % Index when ESC starts increasing
    power_start = find(arr_cut(:,2) > 1000 , 1);
    
    
    fprintf("%d: %d, %d - %d\n", freq, rpm_start, power_start, arr_cut(power_start,13));
    
    if (size(rpm_start,1) == 0) % Err when prop is already turning
        result_struct.status = 0;
        result_struct.code = 1;
        return; 
    end
    
    if (power_start > rpm_start) % Err when prop is turning before power
        result_struct.status = 0;
        result_struct.code = 2;
        return; 
    end
    
    % Grab relevant data 
    time_arr = arr_cut(:,1);
    thrust_arr = arr_cut(:,10);
    rpm_arr = arr_cut(:,13);
    
    % Adjust data for plotting
    thrust_zeroed = thrust_arr - thrust_arr(1);
    avgs = 10;
    thrust_avg = movmean(thrust_zeroed, avgs);
    rpm_avg = movmean(rpm_arr, avgs);
    
    fig_name = sprintf("%s @ %d Hz", prop_name, freq);
    figure('Name', fig_name);
    sgtitle(fig_name);
    subplot(2,2,1)
    plot(time_arr, thrust_arr);
    xlabel("Time (s)");
    ylabel("Thrust (kgf)");
    title("Thrust over time");
    
    subplot(2,2,2);
    plot(rpm_arr, thrust_zeroed, '-b');
    yline(0,'--');
    xlabel("RPM");
    ylabel("Thrust (kgf)");
    title("Thrust vs RPM (zeroed)");
    
    subplot(2,2,3);
    
    subplot(2,2,4);
    plot(rpm_avg, thrust_avg, '-r');
    yline(0,'--');
    xlabel("RPM");
    ylabel("Thrust (kgf)");
    title("Thrust vs RPM (zeroed & averaged)");

    % Package results
    result_struct.time = time_arr;
    result_struct.thrust = thrust_arr;
    result_struct.thrust_zero = thrust_zeroed;
    result_struct.RPM = rpm_arr;
    result_struct.power_start_idx = power_start;
    result_struct.rotation_start_idx = rpm_start;
end
