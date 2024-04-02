function result_struct = analyze_single2(prop_size, freq, plotOn)
    result_struct.status = 1;
    
    % Read in data
    addpath('phase1_data');
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
    
    % For Debug
    fprintf("%d: %d, %d - %d\n", freq, rpm_start, power_start, arr_cut(power_start,13));
    
    % Err when prop is already turning or prop is turning before power
    if (size(rpm_start,1) == 0 || power_start > rpm_start) 
        result_struct.status = 0;
        result_struct.code = 1;
        return; 
    end
    
    % THRESHOLDS
    avgs = 10;
    rpm_cutoff = 1000;
    
    % Get data when script is running 
    time_arr = arr_cut(:,1);
    Q = arr_cut(:,9) - arr_in(1,9); % Nm
    T = arr_cut(:,10) - arr_cut(1,10); % Zero thrust readings
    T = T * 9.80665; %kgf to N
    V = arr_cut(:,13) .* (2*pi/60); % RPM to rad/s
    Pe = arr_cut(:,15); % W
    Pm = arr_cut(:,16); % W
    effM = arr_cut(:,17); % 
    effP = arr_cut(:,18) * 9.80665; % kgf/W to N/W
    effO = arr_cut(:,19) * 9.80665; % kgf/W to N/W
        
    thrust_arr = arr_cut(:,10);
    rpm = arr_cut(:,13);
    rpm_avg = movmean(rpm, avgs);
    T_avg = movmean(T, avgs);
    
    % Get relevant data points
    rpm_cutoff_idx = find(rpm > rpm_cutoff, 1, 'first');
    thrust_cutoff_idx = find(T_avg < -0.01, 1, 'first');
    fprintf("%d_%d\n", rpm_cutoff_idx, thrust_cutoff_idx);
    cutoff_idx = rpm_cutoff_idx;
    
    rpm_avg = rpm_avg(cutoff_idx:end);
    T_avg = T_avg(cutoff_idx:end);
    
    % Run Thrust Calculations
    Kt = [];
    J = [];
    U = tunnel_info('velocity',freq);
    dens = tunnel_info('density');
    D = prop_size/10 * 0.0254; % tenth inch to meters
    for i = 1:numel(rpm_avg)
        n = rpm_avg(i) / 60; % rpm to rps
        J(i) = U / (n * D);
        Kt(i) = -T_avg(i) / (dens * n^2 * D^4);
    end
    
    % Run Efficiency calculations
    %Pm_calc = -Q .* V; % W
    Pm_calc = 0;
    effM_calc = Pm_calc ./ Pe;
    A_disc = (prop_size/10 *0.0254)^2 * pi; %m^2
    %effP_calc = 2 ./ (1 + (-T./(A_disc * U^2 * dens/2) + 1).^(0.5));
    effP_calc = zeros(size(T));
    effO_calc = -T_avg./Pe(cutoff_idx:end);

    % Package results
    result_struct.prop_size = prop_size;
    result_struct.freq = freq;
    result_struct.time = time_arr;
    result_struct.thrust = thrust_arr;
    result_struct.thrust_zeroed = T;
    result_struct.thrust_avg = T_avg;
    result_struct.rpm = rpm;
    result_struct.rpm_avg = rpm_avg;
    result_struct.power_start_idx = power_start;
    result_struct.rotation_start_idx = rpm_start;
    result_struct.cutoff_idx = cutoff_idx;
    result_struct.J = J;
    result_struct.Kt = Kt;
    result_struct.Pm_calc = Pm_calc;
    result_struct.Pe = Pe;
    result_struct.effM_calc = effM_calc;
    result_struct.effP_calc = effP_calc;
    result_struct.effO_calc = effO_calc;
    
    
    % Plot results
    if (plotOn)
        plot_single_thrust(result_struct);
        plot_single_eff(result_struct);
    end
end



function plot_single_thrust(result_struct)
    figure('Name', sprintf("prop %d @ %d Hz Thrust", result_struct.prop_size, result_struct.freq));
    sgtitle(sprintf("%2.1f Inch Propeller Thrust @ %d Hz", result_struct.prop_size/10, result_struct.freq));
    
    subplot(2,2,1)
    plot(result_struct.time, result_struct.thrust);
    xlabel("Time (s)");
    ylabel("Thrust (kgf)");
    title("Thrust over time");
    
    subplot(2,2,2);
    hold on
    plot(result_struct.rpm, result_struct.thrust_zeroed, '-b');
    plot(result_struct.rpm_avg, result_struct.thrust_avg, '-r');
    yline(0,'--');
    xlabel("RPM");
    ylabel("Thrust (kgf)");
    title("Thrust vs RPM");
    
    subplot(2,2,3);
    plot(result_struct.rpm_avg, result_struct.Kt);
    yline(0,'--');
    title("RPM vs Thrust coefficient");
    
    subplot(2,2,4);
    plot(result_struct.J, result_struct.Kt);
    yline(0,'--');
    title("Thrust Coefficient vs Advance Ratio");
end

function plot_single_eff(result_struct)
    figure('Name', sprintf("prop %d @ %d Hz Eff", result_struct.prop_size, result_struct.freq));
    sgtitle(sprintf("%2.1f Inch Propeller Efficiency @ %d Hz", result_struct.prop_size/10, result_struct.freq));
    
    subplot(2,3,1)
    hold on
    %plot(time_arr, Pm);
    plot(result_struct.time, result_struct.Pm_calc);
    title(sprintf("Mechanical Power\nW"));

    subplot(2,3,2)
    hold on
    plot(result_struct.time, result_struct.Pe);
    title(sprintf("Electrical Power\nW"));

    subplot(2,3,3)
    hold on
    plot(result_struct.time, result_struct.effM_calc);
    title("Motor Efficiency");

    subplot(2,3,4)
    hold on
    plot(result_struct.time, result_struct.effP_calc,'r');
    title(sprintf("Propeller Efficiency"));
    ylim([0,1]);
    yline(0,'--');

    subplot(2,3,5)
    hold on
    plot(result_struct.time(result_struct.cutoff_idx:end), result_struct.effO_calc,'r');
    title(sprintf("Overall Efficiency\nN/W"));
    ylim([0,0.1]);
    yline(0,'--');
end
