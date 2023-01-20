% home15.json taken from the SSD (/data/code/obj_loc/detectron2/datasets)
% the data in this json file had paths pointing to the images in the
% SSD, but I didn't have permission to read from the JPEGImages directory,
% so I made a copy of that folder path and images on my desktop 
file_name = 'home15.json';
exp15classes = {'bison', 'alligator', 'drop', 'kettle', 'koala', ...
    'lemon', 'mango', 'moose', 'pot', 'seal', 'pot_yellow', 'pot_black'};

% read in file_name and create t.mat. after t.mat is created, creates a 
% table with just data for the bison class
% t = format_table2(file_name, exp15classes);
% remove empty rows. NOTE: must run multiple times until no more empty rows
% for row = 1:height(class_data)
%     elem = t(row, 'bison');
%     elem_cell = table2array(elem);
%     elem_arr = cell2mat(elem_cell);
%     if isempty(elem_arr)
%         t(row, :) = [];
%     end
% end
t = load('matlab_files/terrible_sol.mat');
t = t.t;

% add full file path to each image file path
t.img_path = fullfile(pwd, t.img_path);

% change bbox datatype
empty_col = cell([height(t), 1]);

% convert bbox coords from tables to 1x4 matrices
for row = 1:height(t)
    strct = table2array(t(row, 'bison'));
    a = strct{1, 1}.';
    empty_col{row, 1} = a;
end

% code from Matlab YOLOv4 tutorial begins here
% https://www.mathworks.com/help/vision/ug/object-detection-using-yolov4-deep-learning.html

new_table = table(t.img_path, empty_col);
new_table.Properties.VariableNames = ["img_path", "bison"];
% split train, test, and validation data
rng("default");
shuffled_indices = randperm(height(t));
idx = floor(0.6 * length(shuffled_indices));

training_idx = 1:idx;
training_datatable = new_table(shuffled_indices(training_idx), :);

validation_idx = idx + 1 : idx + 1 + floor(0.1 * length(shuffled_indices));
validation_datatable = new_table(shuffled_indices(validation_idx), :);

test_idx = validation_idx(end) + 1 : length(shuffled_indices);
test_datatable = new_table(shuffled_indices(test_idx), :);

% create datastores for images and label data
imds_train = imageDatastore(training_datatable{:, 'img_path'});
blds_train = boxLabelDatastore(training_datatable(:, 'bison'));

imds_validation = imageDatastore(validation_datatable{:, 'img_path'});
blds_validation = boxLabelDatastore(validation_datatable(:, 'bison'));

imds_test = imageDatastore(test_datatable{:, 'img_path'});
blds_test = boxLabelDatastore(test_datatable(:, 'bison'));

% combine datastores
training_data = combine(imds_train, blds_train);
validation_data = combine(imds_validation, blds_validation);
test_data = combine(imds_test, blds_test);

% display training image with bbox drawn
% d = read(training_data);
% i = d{1};
% bbox = d{2};
% annotated_image = insertShape(i, 'Rectangle', bbox);
% annotated_image = imresize(annotated_image, 2);
% figure
% imshow(annotated_image)

% network input size
input_size = [608 608 3];

class_name = "bison";

% estimate anchor boxes based on the size of objects in the training data
% idk what's going on here, see the following links for more insight:
% https://mathworks.com/help/vision/ug/anchor-boxes-for-object-detection.html
% https://mathworks.com/help/vision/ug/estimate-anchor-boxes-from-training-data.html
rng("default");
data = read(training_data);
training_data_for_estimation = transform(training_data, @(data)preprocessData(data, input_size));
num_anchors = 9;
[anchors, meanIoU] = estimateAnchorBoxes(training_data_for_estimation, num_anchors);

area = anchors(:, 1).*anchors(:, 2);
[~, idx] = sort(area, 'descend');

anchors = anchors(idx, :);
anchor_boxes = {anchors(1:3, :)
    anchors(4:6, :)
    anchors(7:9, :)};

% perform data augmentation to improve training accuracy
augmented_training_data = transform(training_data, @augmentData);

% create detector and specify training options
detector = yolov4ObjectDetector("csp-darknet53-coco", class_name, anchor_boxes, InputSize=input_size);

% TODO change settings (MiniBatchSize, InitialLearnRate,
% ExecutionEnvironment mainly)
options = trainingOptions("adam",...
    GradientDecayFactor=0.9,...
    SquaredGradientDecayFactor=0.999,...
    InitialLearnRate=0.0005,...
    LearnRateSchedule="none",...
    MiniBatchSize=4,...
    L2Regularization=0.0005,...
    MaxEpochs=70,...
    BatchNormalizationStatistics="moving",...
    DispatchInBackground=false,...
    ResetInputNormalization=false,...
    Shuffle="every-epoch",...
    VerboseFrequency=20,...
    CheckpointPath="/home/kaylee/temp_out/",...
    ValidationData=validation_data,...
    ExecutionEnvironment="auto");% setting up multi-gpu

% train model
[detector, info] = trainYOLOv4ObjectDetector(augmented_training_data, detector, options);

% failed to use trained detector model to detect objects because of the
% following error:
% https://www.mathworks.com/matlabcentral/answers/394246-deep-learning-
% data-no-longer-exists-on-the-device?s_tid=prof_contriblnk

% evaluate detector
detection_results = detect(detector, test_data);
[ap, recall, precision] = evaluateDetectionPrecision(detection_results, test_data);





