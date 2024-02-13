close all
clear

%% Get all CSV filenames
fileList = dir('*.csv');
fileNames = {fileList(~[fileList.isdir]).name};
runNames = cellfun(@(x) erase(x, '.csv'), fileNames, 'UniformOutput', false);
propNames = {"prop9","prop95","prop10"};

csv_info = {{1,"time"},{2,"ESC"},{9,"Torque"},{10,"Thrust"},{13,"RPM"},...
    {15,"Elec pow"},{16,"Mech pow"}};

for runID = 1:1
    for freq = 10:2:24 % 10:2:24
        result_struct = analyze_single(propNames{runID}, freq);
    end
    
end
