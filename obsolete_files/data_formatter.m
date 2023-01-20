file = 'home15.json';
str = fileread(file);
data = jsondecode(str);


% ground truth object: DataSource, LabelDefinitions, LabelData

% DataSource: Source (each row is path to frame), TimeStamps (each row is
% a time stamp - 0 sec, 1 sec, ...)

% LabelDefinitions: done

% LabelData: Rows - frames (0 sec, 1 sec, ...)
% Columns - Labels (Name column from LabelDefinitions)
% Each cell is the bbox coordinates for each class for each frame
%   If multiple instances of a class in a frame, separate with a ;