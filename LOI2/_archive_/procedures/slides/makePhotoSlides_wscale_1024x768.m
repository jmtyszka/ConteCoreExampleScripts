% MAKE SLIDES 
% -----------------------------------------------------
clear all; close all hidden; basedir = pwd;

% | Border Width
npixels = 2;

% | Scale
sc = imread('scale_german.jpg');

% | Base Images
photodir    = [basedir filesep 'photos'];
outputdir   = [basedir filesep 'german'];
if ~exist(outputdir, 'dir'), mkdir(outputdir); end
[fn, d]     = files([photodir filesep '*.jpg']);

% begin photo loop
for p = 1:length(d)
    
    printcount(p, length(d));
    
    % read in photo
    op = imread(fn{p}); 
    dims = size(op);
    op = imresize(op,[750 1000]);
    
    % add border
    op(:,1:npixels,:) = 250;
    op(1:npixels,:,:) = 250;
    op(:,end-(npixels-1):end,:) = 250;
    op(end-(npixels-1):end,:,:) = 250;

    % create new image, add in resized photo
    sc(226:975,301:1300,:) = op;

    % resize image
    slide = imresize(sc,[900 1200]);

    % save the new image
    imwrite(slide, fullfile(outputdir, d{p}), 'jpg'); 
        
end









    