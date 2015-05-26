function evalpolarityscope

timeinterval=100    % time between two frames in ms
%maxangle=10         % angle in degrees to differentiate between stickers and nonstickers
stickytime=5       % time in seconds for sticker to be considered a sticker
linefiterrorthresh=0.8*0.0225   % error of the line fit to be considered a line, max average error of 0.15 um.
minendsticktime=2   % miniumum time required to be considered end-sticking, in seconds   

INTERPOLATE=1; % Set to 1 if 0-displacements should be interpolated
THROWOUTDETECTIONGAPS=0;

index=0;
filesread=0;


[name, path] = uigetfile('*.mat', 'select polarityscope file');

if(name==0)
    error('No directory selected');
end

cd(path);

filelist=dir('*.mat');
%filelist.name=name;

n=size(filelist,1);

if (n==0)
    error('No .mat files found in this directory');
end


for(b=1:1:n)

    name=filelist(b).name;

    load(name);

    disp(name);

    filesread=filesread+1;

    for(a=1:1:numresults)

        index=index+1;

        allresults(index)=result(a);
        
    end

    allnumresults(filesread)=numresults;
    allmaxusedtracklen(filesread)=maxusedtracklen;

    clear('result','md','msd','mdstderr','msdstderr','mdstd','msdstd','n','traces','numresults','maxusedtracklen');


    cd(path);



end


numresults=sum(allnumresults);
maxusedtracklen=max(allmaxusedtracklen);

rawtraces=nan(numresults,maxusedtracklen);
filtfiterrors=nan(size(rawtraces));
le=nan(size(rawtraces));


% mark stickers
for(a=1:1:numresults)

       
    % calculate traces;
    for(b=1:1:allresults(a).tracklen)
        allresults(a).trace(b)=allresults(a).position(b)-allresults(a).position(1);
    end
    
    
   
    % These two lines are left over from the angle filtering
    allresults(a).stick=0;
    allresults(a).filteredtracklen=allresults(a).tracklen;
  
    for(b=3:1:allresults(a).tracklen)
       [filtfiterrors(a,b),le(a,b)]=endstickfiterror(allresults(a).trace,b);
    end

    [tmp,filtminerror(a)]=min(filtfiterrors(a,:));  %position of smallest error (sum parabola and line)

    lineerror(a)=le(a,filtminerror(a));             %average error of the line fit part
    
    
    
    %this corresponds to the ratio of the optimal fit versus the worst fit
    maxovermin(a)=max(filtfiterrors(a,:))/min(filtfiterrors(a,:));

    
    %Cut ends off, but tracks have to have a minimum length
    cutofflength=allresults(a).tracklen-filtminerror(a);
    
    if(lineerror(a)<linefiterrorthresh && cutofflength >= minendsticktime*1000/timeinterval)
      allresults(a).trace(filtminerror(a):end)=[];   %nan;  % Kill the end sticking
      allresults(a).filteredtracklen=sum(~isnan(allresults(a).trace));
      allresults(a).endfiltered=1;
    else
      allresults(a).endfiltered=0;

    end


    if(maxovermin(a)<2 && allresults(a).tracklen > stickytime*1000/timeinterval && lineerror(a)<linefiterrorthresh )
        allresults(a).stick=1;
        allresults(a).filteredtracklen=0;
        allresults(a).endfiltered=0;
    end
    
    if(THROWOUTDETECTIONGAPS)
        allresults(a).trace=interpolatetracenan(allresults(a).trace);
    end
    
    if(INTERPOLATE)
         allresults(a).trace=interpolatetrace(allresults(a).trace);
    end
    
    
    
end

filterednumresults=numresults-sum([allresults(:).stick]);
filteredmaxtracklen=max([allresults(:).filteredtracklen]);

traces=nan(filterednumresults,filteredmaxtracklen);

index=0;

for(a=1:1:numresults)
    
     if(~allresults(a).stick) % Here are the filtered results
         
         index=index+1;
         
         for(b=1:1:allresults(a).filteredtracklen)

            traces(index,b)=allresults(a).trace(b);
                       
         end
         
         dwelltimes(index)=allresults(a).filteredtracklen*timeinterval/1000;
         meanintensity(index)=mean(allresults(a).intensity);
         mtlength(index)=allresults(a).linelength;
         [maxpos,tmax]=max(traces(index,:));
         [minpos,tmin]=min(traces(index,:));
                
         if(tmax>tmin)
            maxtraveldist(index)=maxpos-minpos;
         else
            maxtraveldist(index)=minpos-maxpos;
         end
         
         averagedisplacement(index)=nanmean(traces(index,:));
         averagevelocity(index)=averagedisplacement(index)/dwelltimes(index);

     end
         
     
     for(b=1:1:allresults(a).tracklen) % Here are the raw results


            rawtraces(a,b)=allresults(a).position(b)-allresults(a).position(1);
 
     end
    
     rawdwelltimes(a)=allresults(a).tracklen*timeinterval/1000;
     rawmeanintensity(a)=mean(allresults(a).intensity);
     rawmtlength(a)=allresults(a).linelength;
     
     [maxpos,tmax]=max(rawtraces(a,:));
     [minpos,tmin]=min(rawtraces(a,:));
                
     if(tmax>tmin)
         rawmaxtraveldist(a)=maxpos-minpos;
     else
         rawmaxtraveldist(a)=minpos-maxpos;
     end
         
     
end

[md,msd,mdstd,msdstd,n]=mdmsd(traces);
mdstderr=mdstd./sqrt(n);
msdstderr=msdstd./sqrt(n);

[rawmd,rawmsd,rawmdstd,rawmsdstd,raw_n]=mdmsd(rawtraces);
rawmdstderr=rawmdstd./sqrt(raw_n);
rawmsdstderr=rawmsdstd./sqrt(raw_n);



rawtimepoints=([0:maxusedtracklen-1]*timeinterval/1000);
timepoints=([0:filteredmaxtracklen-1]*timeinterval/1000);


disp(' ');
disp('Percent of traces that were sticker filtered:');
disp(100-filterednumresults*100/numresults);
disp('Percent of traces that were end filtered:');
disp(sum([allresults(:).endfiltered])*100/numresults)
disp('Number of unfiltered traces:');
disp(numresults);
disp('Number of filtered traces:');
disp(filterednumresults);


% filtered data plots

figure;
plot(timepoints(2:end),md,'b',timepoints(2:end),md+mdstderr,':b', timepoints(2:end),md-mdstderr,':b');
title('filtered MD');
xlabel('time (s)');
ylabel('MD (µm)');

figure;
plot(timepoints(2:end),msd,'b',timepoints(2:end),msd+msdstderr,':b', timepoints(2:end),msd-msdstderr,':b');
title('filtered MSD');
xlabel('time (s)');
ylabel('MSD (µm^2)');


figure;
plot(timepoints,traces);
title('filtered traces');
xlabel('time (s)');
ylabel('position (µm)');


figure;
hist(dwelltimes,50);
title('filtered dwell times');
xlabel('dwell time (s)');
ylabel('counts');



figure;
scatter(dwelltimes,meanintensity);
xlabel('dwell time');
ylabel('intensity');
title('filtered dwell times vs. intensity');
dwtfit=polyfit(dwelltimes,meanintensity,1);
hold on;
line(dwelltimes,dwtfit(1)*dwelltimes+dwtfit(2));
hold off;

% raw data plots

figure;
plot(rawtimepoints(2:end),rawmd,'b',rawtimepoints(2:end),rawmd+rawmdstderr,':b', rawtimepoints(2:end),rawmd-rawmdstderr,':b');
title('raw MD');
xlabel('time (s)');
ylabel('MD (µm)');


figure;
plot(rawtimepoints(2:end),rawmsd,'b',rawtimepoints(2:end),rawmsd+rawmsdstderr,':b', rawtimepoints(2:end),rawmsd-rawmsdstderr,':b');
title('raw MSD');
xlabel('time (s)');
ylabel('MSD (µm^2)');


figure;
plot(rawtimepoints(1:round(allmaxusedtracklen/2)),rawtraces(:,1:round(allmaxusedtracklen/2)));
title('raw traces');
xlabel('time (s)');
ylabel('position (µm)');

figure;
hist(rawdwelltimes,50);
title('raw dwell times');
xlabel('dwell time (s)');
ylabel('counts');

figure;
scatter(rawdwelltimes,rawmeanintensity);
xlabel('dwell time');
ylabel('intensity');
title('raw dwell times vs. intensity');
dwtfit=polyfit(rawdwelltimes,rawmeanintensity,1);
hold on;
line(rawdwelltimes,dwtfit(1)*rawdwelltimes+dwtfit(2));
hold off;



[savefilename,savepath]=uiputfile('*.csv','Save polarityscope analysis data');

currentpath=cd(savepath);

savefile=savefilename(1:end-4);

csvwrite([savefile '_f_MD.csv'],cat(1,timepoints(2:end),md,mdstderr,mdstd)');
csvwrite([savefile '_f_MSD.csv'],cat(1,timepoints(2:end),msd,msdstderr,msdstd)');
csvwrite([savefile '_f_dwell_intensity.csv'],cat(1,dwelltimes,meanintensity)');
csvwrite([savefile '_f_traces.csv'],cat(1,timepoints,traces)');
csvwrite([savefile '_f_dwell_displ.csv'],cat(1,dwelltimes,averagedisplacement,averagevelocity,maxtraveldist)');



csvwrite([savefile '_raw_MD.csv'],cat(1,rawtimepoints(2:end),rawmd,rawmdstderr,rawmdstd)');
csvwrite([savefile '_raw_MSD.csv'],cat(1,rawtimepoints(2:end),rawmsd,rawmsdstderr,rawmsdstd)');
csvwrite([savefile '_raw_dwell_intensity.csv'],cat(1,rawdwelltimes,rawmeanintensity)');
csvwrite([savefile '_raw_traces.csv'],cat(1,rawtimepoints,rawtraces)');


%save([savefile '_everything.mat']);

cd(currentpath);


choice = questdlg('Close all figures?', 'Yes','No');


switch choice
    case 'Yes'
        close all;
    case 'No'
end


end
        