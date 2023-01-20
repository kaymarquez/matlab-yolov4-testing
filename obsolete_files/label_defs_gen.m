exp15classes = ["bison", "alligator", "drop", "kettle", "koala", "lemon", "mango", "moose", "pot", "seal", "pot_yellow", "pot_black"];
ldc = labelDefinitionCreator();
for class = exp15classes
    addLabel(ldc, class,"Rectangle");
end
labelDefs = create(ldc);