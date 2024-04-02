close all
clear
Simulink.sdi.clear;


%% Get all CSV filenames
fileList = dir('*.csv');
fileNames = {fileList(~[fileList.isdir]).name};
runNames = cellfun(@(x) erase(x, '.csv'), fileNames, 'UniformOutput', false);
propNames = {"prop9","prop95","prop10"};

csv_info = {{1,"time"},{2,"ESC"},{9,"Torque"},{10,"Thrust"},{13,"RPM"},...
    {15,"Elec pow"},{16,"Mech pow"}};

%% Read in all files and create SDI runs
%{
for runID = 1:numel(runNames)
    table_in = readtable(runNames{runID});
    eval(sprintf("%s = table2array(table_in);", runNames{runID}));
    eval(sprintf("%s_run = Simulink.sdi.Run.create('%s');", runNames{runID}, runNames{runID}));
    for dataID = 2:size(csv_info,2)
        eval(sprintf("ts_obj = timeseries(%s(:,csv_info{%d}{1}), %s(:,1), 'Name', csv_info{%d}{2});",...
            runNames{runID}, dataID, runNames{runID}, dataID))
        eval(sprintf("add(%s_run,'vars',ts_obj);", runNames{runID}));
    end
end
%}

for runID = 1:numel(propNames)
    eval(sprintf("%s_run = Simulink.sdi.Run.create('%s');", propNames{runID}, propNames{runID}));
    for freq = 10:2:24
        test_name = sprintf("%s_%d",propNames{runID},freq);
        table_in = readtable(sprintf("%s.csv",test_name));
        eval(sprintf("%s = table2array(table_in);", test_name));
        eval(sprintf("ts_obj = timeseries(%s(:,%d), %s(:,1), 'Name', 'Thrust@%d');",...
            test_name, 10, test_name, freq))
        eval(sprintf("add(%s_run,'vars',ts_obj);", propNames{runID}));
    end
    
end


Simulink.sdi.view;






