
% Specify the input and output file paths
inputFilePath = 'ES_9_df.csv';
outputFilePath = 'ES_9_df_fix.csv';

% Load the CSV file
data = readtable(inputFilePath);

% Specify the columns to be removed
columnsToRemove = [3, 5];

% Remove the specified columns
data(:, columnsToRemove) = [];

% Write the modified data to a new CSV file
writetable(data, outputFilePath);

disp('Columns removed and data saved to output.csv');