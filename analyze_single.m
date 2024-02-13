function result_struct = analyze_single(prop_size, freq)
    result_struct.status = 1;
    
    % Read in data
    cd phase1_data
    test_name = sprintf("prop%d_%d",prop_size,freq);
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

    % Package results
    result_struct.prop_size = prop_size;
    result_struct.freq = freq;
    result_struct.time = time_arr;
    result_struct.thrust = thrust_arr;
    result_struct.thrust_zeroed = thrust_zeroed;
    result_struct.thrust_avg = thrust_avg;
    result_struct.rpm = rpm_arr;
    result_struct.rpm_avg = rpm_avg;
    result_struct.power_start_idx = power_start;
    result_struct.rotation_start_idx = rpm_start;
    
    
    % Plot results
    plot_single(result_struct);
end



function plot_single(result_struct)
    fig_name = sprintf("prop %d @ %d Hz", result_struct.prop_size, result_struct.freq);
    figure('Name', fig_name);
    sgtitle(fig_name);
    subplot(2,2,1)
    plot(result_struct.time, result_struct.thrust);
    xlabel("Time (s)");
    ylabel("Thrust (kgf)");
    title("Thrust over time");
    
    subplot(2,2,2);
    plot(result_struct.rpm, result_struct.thrust_zeroed, '-b');
    yline(0,'--');
    xlabel("RPM");
    ylabel("Thrust (kgf)");
    title("Thrust vs RPM (zeroed)");
    
    subplot(2,2,3);
    
    subplot(2,2,4);
    plot(result_struct.rpm_avg, result_struct.thrust_avg, '-r');
    yline(0,'--');
    xlabel("RPM");
    ylabel("Thrust (kgf)");
    title("Thrust vs RPM (zeroed & averaged)");
end
