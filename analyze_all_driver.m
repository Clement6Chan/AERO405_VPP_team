close all
clear

save_all = false;

propSizes = {90,95,100}; % inch * 10^-1


for propID = 1:3
    analyze_prop(propSizes{propID});
    
    if (save_all)
        FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
        for iFig = 1:length(FigList)
            FigHandle = FigList(iFig);
            FigName   = get(FigHandle, 'Name');
            folderName = sprintf("prop%d_plots", propSizes{propID});
            saveas(FigHandle, fullfile(folderName,strcat(FigName, '.png')))
        end
    end
    close all
end
