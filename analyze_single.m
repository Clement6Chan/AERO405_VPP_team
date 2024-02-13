function result_struct = analyze_single(prop_name, freq)
    result_struct.status = 1;
    
    % Read in data
    test_name = sprintf("%s_%d",prop_name,freq);
    table_in = readtable(sprintf("%s.csv",test_name));
    arr_in = table2array(table_in);
    
    % Find portion of data that script is running
    cut_start = find(arr_in(:,1) == 0, 1, 'last');
    cut_end = find(arr_in(:, 1) > 20 & isnan(arr_in(:, 2)), 1);
    arr_cut = arr_in(cut_start:cut_end,:);
    
    % Index of script arr when Prop starts turning
    rpm_start = find(arr_cut(:,13) == 0, 1, 'last');
    if (size(rpm_start,1) == 0) % Err when prop is already turning
        result_struct.status = 0;
        result_struct.code = 1;
        return; 
    end
    
    % Index when ESC starts increasing
    power_start = find(arr_cut(:,2) > 1000 , 1);
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
    
    figure
    subplot(2,2,1)
    plot(time_arr, thrust_arr);
    xlabel("Time (s)");
    ylabel("Thrust (kgf)");
    title("Thrust over time");
    
    subplot(2,2,2);
    plot(rpm_arr, thrust_zeroed, '-b');
    yline(0,'--');
    xlabel("RPM");
    xlabel("Thrust (kgf)");
    title("Thrust vs RPM (zeroed)");
    
    subplot(2,2,3);
    
    subplot(2,2,4);
    plot(rpm_avg, thrust_avg, '-r');
    yline(0,'--');
    xlabel("RPM");
    xlabel("Thrust (kgf)");
    title("Thrust vs RPM (zeroed & averaged)");

    result_struct.thrust = 1;
    result_struct.RPM = 5000;
end



function movingAvg = customMovingAverage(array, windowSize, threshold)
    arrayLength = numel(array);
    movingAvg = zeros(1, arrayLength);
    
    for i = 1:arrayLength
        % Define the window for each element
        startIdx = max(1, i - windowSize + 1);
        endIdx = i;
        window = array(startIdx:endIdx);
        
        % Calculate the mean of the window
        windowMean = mean(window);
        
        % Check if any element in the window exceeds the threshold
        if any(abs(window - windowMean) > threshold)
            % If any element exceeds the threshold, set the moving average at this position to NaN
            movingAvg(i) = NaN;
        else
            % Otherwise, set the moving average to the mean of the window
            movingAvg(i) = windowMean;
        end
    end
end