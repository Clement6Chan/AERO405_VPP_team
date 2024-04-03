close all
clear



num_runs = [7,9,10];
kT_plot = figure('Name', "kT_plot");
hold on
eff_plot = figure('Name', "eff_plot");
hold on

for a = 1:3
    for r = 1:num_runs(a)
        result = analyze_run(a,r);
        fprintf("%d_%d: %1.2f %1.2f %2.1f %1.2f\n",a,r, result.T, result.kT, result.J, result.effP_calc3);
        combined_J(a,r) = result.J;
        combined_kT(a,r) = result.kT;
        combined_effP_calc3(a,r) = result.effP_calc3;
    end
    figure(kT_plot)
    plot(combined_J(a,1:r), combined_kT(a,1:r), '*-');
    
    figure(eff_plot)
    plot(combined_J(a,1:r), combined_effP_calc3(a,1:r), '*-');
    
end

figure(kT_plot)
xlabel('Advance Ratio: J = U_\infty /(nD) ');
ylabel('Thrust Coefficient: k_T = T/(\rho n^2D^4)');
legend({'8\circ', '9\circ', '11\circ'}, 'Location', 'northeast');
xlim([0,0.7]);

figure(eff_plot)
xlabel('Advance Ratio: J = U_\infty /(nD) ');
ylabel('Efficiency: \eta_P = (Jk_T)/(2\pi k_Q) ');
legend({'8\circ', '9\circ', '11\circ'}, 'Location', 'northwest');
xlim([0,0.7]);
%ylim([0,0.6]);

save_plots = true;
if (save_plots)
    saveas(kT_plot, "kT_plot.png"); 
    saveas(eff_plot, "eff_plot.png"); 
end