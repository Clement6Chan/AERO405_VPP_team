function combined_struct = analyze_prop(propSize, plotOn, inner_plotOn)
    combined_struct.J = [];
    combined_struct.Kt = [];
    combined_struct.effP = [];

    if(plotOn)
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

        %Plot 4
        eff_time = figure('Name', 'eff_time');
        hold on
        title(sprintf("prop %d Propulsive Efficiency over Time", propSize));
    end
    legend_labels = {};
    label_idx = 1;
    
    for freq = 10:2:24 % 10:2:24
        result_struct = analyze_single2(propSize, freq, inner_plotOn);
        
        if (result_struct.status)
            combined_struct.J = [combined_struct.J,result_struct.J];
            combined_struct.Kt = [combined_struct.Kt,result_struct.Kt];
            effP_filted = result_struct.effP_calc(result_struct.cutoff_idx:end)';
            combined_struct.effP = [combined_struct.effP,effP_filted];
            % Add legend entry
            legend_labels{label_idx} = sprintf("%d Hz", freq);
            label_idx = label_idx + 1;
            
            if (plotOn)
                %Plot 1
                figure(all_thrust_zero);
                plot(result_struct.time, result_struct.thrust_zeroed);

                %Plot 2
                figure(all_thrust);
                plot(result_struct.time, result_struct.thrust);

                %Plot 3
                figure(adv_ratio_kt);
                plot(result_struct.J, result_struct.Kt,'.');

                %Plot 4
                figure(eff_time);
                plot(result_struct.time, result_struct.effP_calc);
            end
        end
    end
    
    if (plotOn)
        figure(all_thrust_zero);
        legend(legend_labels);
        figure(all_thrust);
        legend(legend_labels);
        figure(adv_ratio_kt);
        ylim([0,0.1]);
        legend(legend_labels);
        figure(eff_time);
        legend(legend_labels);
        ylim([0,1]);
    end
    
    
    
end

