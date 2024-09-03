stats = extractAndSaveSingleValueFeatures()
% Load an image of any type
[filename, filepath] = uigetfile('*.*', 'Select an image');
fullImagePath = fullfile(filepath, filename);
originalImage = imread(fullImagePath);

% Convert the image to grayscale (if not already grayscale)
if size(originalImage, 3) == 3
    grayImage = rgb2gray(originalImage);
else
    grayImage = originalImage;
end

% Perform Otsu's thresholding to segment the largest object
level = graythresh(grayImage);
bwImage = imbinarize(grayImage, level);

% Remove small objects (noise) and keep the largest object
bwImage = bwareafilt(bwImage, 1);

% Extract morphological features using regionprops
stats = regionprops(bwImage, 'all');

% Display the segmented image with the bounding box of the largest object
figure;
imshow(originalImage);
hold on;
boundary = bwboundaries(bwImage);
for k = 1:length(boundary)
    b = boundary{k};
    plot(b(:, 2), b(:, 1), 'r', 'LineWidth', 2);
end
title('Segmented Image with Bounding Box');

% Filter out fields with more than one element
singleValueFields = struct();
for field = fieldnames(stats)'
    fieldValue = stats.(field{1});
    if isscalar(fieldValue)
        singleValueFields.(field{1}) = fieldValue;
    end
end

% Save single value fields to an Excel file
outputFilename = 'single_value_morphological_features.xlsx';
header = fieldnames(singleValueFields);
data = struct2cell(singleValueFields);

% Convert cell array to a table for better column headers
dataTable = cell2table(data.');
dataTable.Properties.VariableNames = header;

% Write the table to an Excel file
writetable(dataTable, outputFilename);
end