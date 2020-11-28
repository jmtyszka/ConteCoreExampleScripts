clear all
[n t r] = xlsread('seek.xlsx');
soa = diff(n(:,6));
repgap = 0.5;
soa(soa==0) = repgap + 1;
restBegin = 5;
Seeker = n;
Seeker(1,6) = restBegin;
Seeker(2:end,6) = cumsum(soa) + restBegin;
totalTime = 186;
Seeker(1:end,1) = 1:length(Seeker);
save loi1_design.mat Seeker totalTime




[n t r] = xlsread('MBLOI_FINAL_STIMULUS_SET.xlsx');
qim = t(2:end,2);
qdata = n;


break
% DATA KEY
% 1 - condition
% 2 - answer
% 3 - valence
% 4 - luminance
% 5 - hue 
% 6 - saturation
% 7 - value

%% SEEKER column key %%
% 1 - trial #
% 2 - condition (1=FACE, 2=HAND, 3=SCRAMBLE, 4=REPEAT)
% 3 - stimulus IDX (corresponds to order in stimulus directory)
% 4 - stimulus VALENCE (from MTurk normative data) [NaN for ps]
% 5 - stimulus LUMINANCE (from bob_rgb2lum) [NaN for ps]
% 6 - scheduled stimulus onset
% 7 - actual stimulus onset
% 8 - response (0 = No Response, 1 = Response)
% 9 - if response, response time (s)
taskdir = '/Users/bobspunt/Drive/Research/Caltech/LOI_LOCALIZER/version3/task';
stimdir = [taskdir filesep 'stimuli/loi1'];
stimname = files([stimdir filesep '*jpg'],'filename');
design = load('design1.txt');
Seeker = zeros(length(design),9);
Seeker(:,[1 2 6]) = design(:,1:3);
Seeker(:,4) = NaN; Seeker(:,5) = NaN;

conpat = {'F_' 'H_' 'ps'};

bad = 1;
while bad 
    
    bad = 0;
    for c = 1:3
        conidx = cellstrfind(stimname,conpat{c});
        if c~=3
            rmidx = cellstrfind(stimname,['ps' conpat{c}]);
            conidx(find(ismember(conidx,rmidx))) = [];
        end
        randidx = Shuffle(conidx);
        randstim = stimname(randidx);
        Seeker(Seeker(:,2)==c,3) = randidx;
        if c~=3
        for i = 1:length(randstim)
            idx = cellstrfind(qim,randstim{i});
            cdata(i,1:2) = qdata(idx(1),3:4);
        end
        Seeker(Seeker(:,2)==c,4:5) = cdata;
        end
    end

    % check SD of valence in first and second half
    half1 = Seeker(1:48,:); 
    half2 = Seeker(49:end,:);
    for c = 1:2
        sdcheck(1,c) = nanstd(half1(half1(:,2)==c,4));
        sdcheck(2,c) = nanstd(half2(half2(:,2)==c,4));
    end
    sdcheck = round(sdcheck*10);
    if sum(abs(diff(sdcheck)))
        bad = 1;
    end

end




% add repeats
nreps = 2;
idx = [3 9 33 51 78 92];
tmp = Seeker;
Seeker = zeros(length(tmp)+3*nreps,9);
Seeker(1:end,1) = 1:length(Seeker);
Seeker(1:3,:) = tmp(1:3,:);



break
% for i = 1:length(idx)
%     if i==1, pos1 = 1; pos1a = 1; else pos1 = idx(i) + i; pos1a = idx(i); end
%     if i==length(idx), pos2 = length(Seeker); pos2a = length(tmp); else pos2 = idx(i+1)+i-1; pos2a = idx(i) + i - 1; end
%     Seeker(pos1:pos2,:) = tmp(pos1a:pos2a,:);
% end

    



 
 
 
 
