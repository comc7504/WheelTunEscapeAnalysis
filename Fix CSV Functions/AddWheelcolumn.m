% Specify the directory where your CSV files are located
csvDirectory = 'csvfiles';

% Get a list of all CSV files in the specified directory
csvFiles = dir(fullfile(csvDirectory, '*.csv'));


% Loop through each CSV file
for i = 1:length(csvFiles)
    % Construct the full file path
    filePath = fullfile(csvDirectory, csvFiles(i).name);
    
    % Read the CSV file using readtable
    dataTable = readtable(filePath);
    
    % Add a fifth column of zeros
    newColumn = zeros(height(dataTable), 1);
    newDataTable = [dataTable, array2table(newColumn, 'VariableNames', {'NewColumn'})];
    
    % Write the updated data back to the CSV file
    writetable(newDataTable, filePath);
    
    disp(['Processed file: ', csvFiles(i).name]);
end

disp('Processing complete.');