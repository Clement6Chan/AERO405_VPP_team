close all
clear

%% Get all CSV filenames
fileList = dir('*.csv');
fileNames = {fileList(~[fileList.isdir]).name};
runNames = cellfun(@(x) erase(x, '.csv'), fileNames, 'UniformOutput', false);
propNames = {"prop9","prop95","prop10"};

csv_info = {{1,"time"},{2,"ESC"},{9,"Torque"},{10,"Thrust"},{13,"RPM"},...
    {15,"Elec pow"},{16,"Mech pow"}};

home_dir = pwd;



for propID = 1:3
    all_thrust_zero = figure('Name', 'all_thrust_zero');
    hold on
    title(sprintf("%s Thrust over Time\n(zeroed at initial Thrust)", propNames{propID}));

    all_thrust = figure('Name', 'all_thrust');
    hold on
    title(sprintf("%s Thrust over Time", propNames{propID}));
    for freq = 10:2:24 % 10:2:24
        result_struct = analyze_single(propNames{propID}, freq);
        cd(home_dir);
        if (result_struct.status)
            figure(all_thrust_zero);
            plot(result_struct.time, result_struct.thrust_zero);
            figure(all_thrust);
            plot(result_struct.time, result_struct.thrust);
        end
    end
    
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
        FigHandle = FigList(iFig);
        FigName   = get(FigHandle, 'Name');
        folderName = sprintf("%s_plots", propNames{propID});
        saveas(FigHandle, fullfile(folderName,strcat(FigName, '.png')))
    end
    close all
end
