close all
clear

save_all = true;

propSizes = {90,95,100}; % inch * 10^-1

combined_kt_J = figure('Name', 'combined_kt_J');
hold on
title("Advance Ratio vs Thrust Coefficient");


for propID = 1:3
    combined_struct = analyze_prop(propSizes{propID});
    
    figure(combined_kt_J);
    plot(combined_struct.J, combined_struct.Kt,'*');
    
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

if (save_all)
    saveas(combined_kt_J, 'combined_kt_J.png');
end

