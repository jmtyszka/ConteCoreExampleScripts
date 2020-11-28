clear all
for ii = 1:4
    
    
    if mod(ii,2)
        acttag = 1;
        firstcue = 'reaching?';
    else
        acttag = 0;
        firstcue = 'smiling?';
    end

    
    % DATA KEY
    % 1 - condition
    % 2 - answer
    % 3 - valence
    % 4 - luminance
    % 5 - hue 
    % 6 - saturation
    % 7 - value
    taskdir = '/Users/bobspunt/Drive/Research/Caltech/LOI_LOCALIZER/version3/task';
    stimdir = [taskdir filesep 'stimuli/loi2'];
    design = load('design1.txt');

    % save?
    FLAG = 0;
    PRINT = 0;

    % block level
    nBlocks = 16;           % # blocks
    nConds = 4;
    nTrialsBlock = 8;       % # trials/block
    nStim = 64;
    foilDists = [3 3 3 3];  % distribution of # foils/block

    % trial level
    stimDur = 1.7;
    cueDur = 2;
    ITI = .3;
    nYes = 40;
    nNo = 24;

    % read in data
    design = load('design1.txt');
    [cuen cues raw] = xlsread('cues.xlsx');
    cues = cues(2:end,2:3);
    preblockcues = cues(:,1);
    isicues = cues(:,2);
    [qdata qim r] = xlsread('MBLOI_FINAL_STIMULUS_SET.xlsx');
    qim = qim(2:end,1:2);

    % switch out emotion and action
    if acttag
    tmp = design;
    design(tmp(:,2)==1,2) = 2;
    design(tmp(:,2)==2,2) = 1;
    design(tmp(:,2)==3,2) = 4;
    design(tmp(:,2)==4,2) = 3;
    end

    % qdata
    % 1 - cond
    % 2 - ans
    % 3 - val
    % 4 - lum
    qdata = qdata(:,1:4);

    % adjust onsets 
    add = .25;
    tmp = design;
    soa = diff(tmp(:,3));
    adjust = soa + add;
    for i = 1:length(tmp)-1
        tmp(i+1,3) = tmp(i,3)+adjust(i);
    end
    design = tmp;

    % totalTime
    % -------------
    totalTime = 296;    % total time in seconds

    % blockSeeker
    % -------------
    % 1 - block #
    % 2 - condition (1=FH,2=AH,3=FL,4=AL)
    % 3 - onset (s)
    % 4 - cue idx 
    cues = regexprep(cues,'? ','?');


    blockSeeker = design(:,1:3);
    % restBegin = 4;
    % spacing = 17.4;
    % tmp = restBegin:spacing:totalTime;
    % blockSeeker(:,3) = tmp(1:nBlocks);
    notsmile = 1;
    while notsmile
        notsmile = 0;
        for i = 1:4
            tmp = find(cuen(:,1)==i);
            blockSeeker(blockSeeker(:,2)==i,4) = Shuffle(find(cuen(:,1)==i));
        end
        if ~strcmp(cues(blockSeeker(1,4),2),firstcue)
            notsmile = 1;
        end
    end

    % trialSeeker
    % -------------
    % 1 - block #
    % 2 - trial #
    % 2 - condition (1=FH,2=AH,3=FL,4=AL)
    % 4 - normative response (1=Yes, 2=No)
    % 5 - stimulus # (corresponds to order in qim+qdata)
    trialSeeker = zeros(nBlocks*nTrialsBlock,5);
    for i = 1:nBlocks
        start = 1+(i-1)*nTrialsBlock;
        finish = i*nTrialsBlock;
        trialSeeker(start:finish,1) = i;
    end
    for i = 1:nTrialsBlock
        trialSeeker(i:nTrialsBlock:end,2) = i;
    end
    trialSeeker(:,3) = reshape(repmat(design(:,2),1,nTrialsBlock)',nBlocks*nTrialsBlock,1);
    trialSeeker(:,4) = 1;
    stimfiles = files([stimdir filesep '*.jpg']);
    stimnames = files([stimdir filesep '*jpg'],'filename');

    badblocks = 1;
while badblocks
    
    badblocks = 0;
    
    for i = 1:nBlocks

        ccue = preblockcues{blockSeeker(i,4)};
        name = ccue;
        tmpname{i} = name;
        idx = find(strcmp(qim(:,1),name));
        norm = qdata(idx,2);
        bad = 1;

        while bad

            bad = 0;
            randorder = randperm(length(idx));
            idx2 = idx(randorder);
            norm2 = norm(randorder);
            if norm2(1)==2
                bad = 1;
                continue
            end
            tmp = norm2==2;
            tmp(:,2) = 0; tmp(2:end,2) = diff(tmp(:,1));
            idx3 = find(tmp(:,1)==1 & tmp(:,2)==0);
            if length(idx3)>1
                bad = 1;
                continue;
            else
                bad = 0;
                trialSeeker(trialSeeker(:,1)==i,[4 5]) = [norm2 idx2];
            end

        end

    end
    
    max_nrep = 4;
    tmp = trialSeeker(:,4)==2;
    tmp(:,2) = 0; tmp(2:end,2) = diff(tmp(:,1));
    idx = find(tmp(:,1)==1 & tmp(:,2)==0);
    if length(idx)>max_nrep
        badblocks = 1;
    end
   
end



    % % stimdata.name = list of stimuli as read in during createOrdering.m
    % % stimdata.data = 
    % % 1 - stimulus # (corresponds to order in stim dir + stimdata.name)
    % % 2 - valence
    % % 3 - luminance
    % 
    % stimidx = trialSeeker(:,5);
    % 
    % 
    % stimdata.name = stimnames(stimidx);
    % tmp = zeros(length(stimidx),3);
    % tmp(:,1) = stimidx;
    % for i = 1:length(stimidx)
    %     idx = cellstrfind(qim(:,2),stimidx(i));
    %     tmp(i,2:3) = qdata(idx,3:4);
    % end
    % stimdata.data = tmp;

    isicues = regexprep(isicues,'? ','?');
    alldesign{ii}.totalTime = totalTime;
    alldesign{ii}.blockSeeker = blockSeeker;
    alldesign{ii}.trialSeeker = trialSeeker;
    alldesign{ii}.preblockcues = preblockcues;
    alldesign{ii}.isicues = isicues;
    alldesign{ii}.qim = qim;
    alldesign{ii}.qdata = qdata;
    
    keep alldesign
    
end


save loi2_design.mat alldesign




    












































break
Seeker = zeros(length(design),5);
Seeker(:,[1 2 5]) = design(:,1:3);
maxrepinacc = 3;
for d = 1:4
    globalbad = 1;
    while globalbad
        globalbad = 0;
        bad = 1;
        tic; 
        while bad

            % this will ensure not too many correct vs. incorrect in a row
            bad = 0;
            Seeker(:,3) = 1;
            for c = 1:6
                idx = find(Seeker(:,2)==c);
                idx = idx(randperm(length(idx)));
                Seeker(idx(1:5),3) = 2;
            end
            tmp = Seeker(:,3)==2;
            tmp(:,2) = 0; tmp(2:end,2) = diff(tmp(:,1));
            idx = find(tmp(:,1)==1 & tmp(:,2)==0);
            if length(idx)>maxrepinacc
                bad = 1;
            else
                tmp = diff(tmp);
                idx = find(tmp(:,1)==1 & tmp(:,2)==0);
                if ~isempty(idx)
                    bad = 1;
                end
            end
        end   
        mindistance = 10;
        bad = 1;
        while bad

            bad = 0;
            % this will ensure the same action stimulus doesn't appear together too
            % close in time
            for c = 1:6
                for a = 1:2
                    seekidx = find(Seeker(:,2)==c & Seeker(:,3)==a);
                    seekidx = seekidx(randperm(length(seekidx)));
                    stimidx = find(data(:,2)==c & data(:,3)==a);
                    stimidx = stimidx(randperm(length(stimidx)));
                    Seeker(seekidx,4) = stimidx;
                end
            end
            allstim = stim(Seeker(:,4),2:3); 
            for i = 1:length(allstim)-mindistance
                cstim = allstim(i,:);
                futurestim = allstim(i+1:i+mindistance);
                futurestim = reshape(futurestim,numel(futurestim),1);
                repeats(i) = sum(ismember(futurestim,cstim));
            end
            if sum(repeats)>6, bad = 1; end

            if toc>10
                globalbad = 1;
                break
            end

        end
    end
    allSeeker{d} = Seeker;
    fprintf('\nFOUND ONE\n');
end
        
        
    
        
        
    
    

        
        

 
 
 
 
