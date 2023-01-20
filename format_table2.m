function t = format_table2(input_file, classes)
tic
% read in json file and convert it to a table
data = jsondecode(fileread(input_file));
data_table = struct2table(data);
clear data;

num_rows = height(data_table);
num_cols = length(classes) + 1;
size = [num_rows num_cols];

% create a table containing all frames (rows) and their bbox labels (cols)
datatypes = string.empty;
datatypes(1) = 'string';
col_names = string.empty;
col_names(1) = 'img_path';

% iterate through columns and define their datatypes and names
for col = 2:num_cols
    datatypes(col) = 'cell';
    col_names(col) = classes(col - 1);
end
clear col;
t = table('Size', size, 'VariableTypes', datatypes);

% set column names
t.Properties.VariableNames = col_names;
clear datatypes col_names;

% add all image paths from data_table to t
t.img_path = data_table.filename;

% add bbox coordinates to t
for frame = 1:num_rows
    % extract bbox coords and associated labels from data_table
    bbox_data = [data_table.annotations{frame}];
    categories = [bbox_data.category_id];
    annotations = [bbox_data.bbox];
    % iterate through categories/labels
    for label = 1:length(categories)
        category_dbl = categories(label);
        category = int64(category_dbl) + 2;
        % pull bbox coords for that index/label and add to table
        coords = annotations(:,label);
        t(frame, category) = {round(coords)};
    end
end
for cols = 3:width(t)
    t(:,3) = [];
end
clear frame bbox_data categories annotations label category_dbl ...
    category coords;
toc
end