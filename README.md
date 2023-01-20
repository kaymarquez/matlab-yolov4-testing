# Matlab YOLOv4 Testing

## Scripts
**format_table2.m**: takes in a json data file and converts it to a data table. each row is an image/frame, and each column is an object class

**yolo_trainer.m**: further cleans the data after format_table2.m is run. takes only the data for the bison class and removes frames without bison present. then follows [this](https://www.mathworks.com/help/vision/ug/object-detection-using-yolov4-deep-learning.html) tutorial for object detection with YOLOv4 in Matlab

## Data Files
**t.mat**: contains data for all experiment 15 classes

**terrible_sol.mat**: contains data for just the bison class
