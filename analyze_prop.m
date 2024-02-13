function combined_struct = analyze_prop(propSize)
    combined_struct.J = [];
    combined_struct.Kt = [];

    %Plot 1
    all_thrust_zero = figure('Name', 'all_thrust_zero');
    hold on
    title(sprintf("prop %d Thrust over Time\n(zeroed at initial Thrust)", propSize));
    
    %Plot 2
    all_thrust = figure('Name', 'all_thrust');
    hold on
    title(sprintf("prop %d Thrust over Time", propSize));
    
    %Plot 3
    adv_ratio_kt = figure('Name', 'adv_ratio_kt');
    hold on
    title(sprintf("prop %d Advance Ratio vs Thrust Coefficient", propSize));
    
    legend_labels = {};
    label_idx = 1;
    
    for freq = 10:2:24 % 10:2:24
        result_struct = analyze_single(propSize, freq);
        
        if (result_struct.status)
            combined_struct.J = [combined_struct.J,result_struct.J];
            combined_struct.Kt = [combined_struct.Kt,result_struct.Kt];
            % Add legend entry
            legend_labels{label_idx} = sprintf("%d Hz", freq);
            label_idx = label_idx + 1;
            
            %Plot 1
            figure(all_thrust_zero);
            plot(result_struct.time, result_struct.thrust_zeroed);
            
            %Plot 2
            figure(all_thrust);
            plot(result_struct.time, result_struct.thrust);
            
            %Plot 3
            figure(adv_ratio_kt);
            plot(result_struct.J, result_struct.Kt,'.');
            ylim([0,0.1]);
        end
    end
    
    figure(all_thrust_zero);
    legend(legend_labels);
    figure(all_thrust);
    legend(legend_labels);
    figure(adv_ratio_kt);
    legend(legend_labels);
end

