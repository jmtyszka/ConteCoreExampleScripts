clear all; home; 
load loi2_design.mat
pdir = fullfile(pwd, 'photos');
outdir = fullfile(pwd, 'out');
designnum           = 3; 
design              = alldesign{designnum};
ordered_questions   = design.preblockcues(design.blockSeeker(:,4));
pbc_brief           = regexprep(design.preblockcues,'Is the person ','');
isicues             = design.isicues;
preblockcues        = design.preblockcues; 
blockSeeker         = design.blockSeeker;
trialSeeker         = design.trialSeeker;
trialSeeker(:,6:9)  = 0;
qim                 = design.qim;
qdata               = design.qdata;
totalTime           = design.totalTime;
yn = cell(size(qdata,1), 1); 
yn(qdata(:,2)==1) = {'Y_'}; 
yn(qdata(:,2)==2) = {'N_'};
q = regexprep(qim(:,1),'Is the person ','');
q = regexprep(q, ' ', '_'); 
q = regexprep(q, '?', '');
out = fullfile(outdir, q);
u = unique(out)
for i = 1:length(u), mkdir(u{i}); end
out = fullfile(out, strcat(yn, qim(:,2))); 
im = fullfile(pdir, qim(:,2)); 
for i = 1:length(im), copyfile(im{i}, out{i}); end