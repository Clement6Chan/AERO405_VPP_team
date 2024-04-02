close all
clear

save_all = true;

propSizes = {90,95,100}; % inch * 10^-1

combined_kt_J = figure('Name', 'combined_kt_J');
hold on
title("Thrust Coefficient vs Advance Ratio");

combined_eff_J = figure('Name', 'combined_eff_J');
hold on
title("Efficiency vs Advance Ratio");


for propID = 1:3
    combined_struct = analyze_prop(propSizes{propID}, 0, 0);
    
    figure(combined_kt_J);
    plot(combined_struct.J, combined_struct.Kt,'.');
    
    figure(combined_eff_J);
    plot(combined_struct.J, combined_struct.effO,'.');
    
    if (save_all)
        FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
        for iFig = 1:length(FigList)
            FigHandle = FigList(iFig);
            FigName   = get(FigHandle, 'Name');
            folderName = sprintf("prop%d_plots", propSizes{propID});
            if ~strcmp(FigName, 'combined_kt_J')
                saveas(FigHandle, fullfile(folderName,strcat(FigName, '.png')))
            end
        end
    end
end
figure(combined_kt_J);
ylim([0,0.1]);
xlim([0,1]);
legend({'9 inch','9.5 inch', '10 inch'});
xlabel("J");
ylabel("K_T");

figure(combined_eff_J);
ylim([0,0.1]);
xlim([0,1]);
legend({'9 inch','9.5 inch', '10 inch'});
xlabel("J");
ylabel("Efficiency (N/W)");

if (save_all)
    saveas(combined_kt_J, 'combined_kt_J.png');
    saveas(combined_eff_J, 'combined_eff_J.png');
end
