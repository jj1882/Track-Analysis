function johanna

global leftimage;
global rightimage;

global leftthresh;
global rightthresh;

[fixedfile.name, fixedfile.path] = uigetfile('*.tif;*.stk;*.lsm', 'select fixed MT channel');

cd(fixedfile.path);

disp(fixedfile.path);

[loosefile.name, loosefile.path] = uigetfile('*.tif;*.stk;*.lsm', 'select free MT channel');

[slavefile.name, slavefile.path] = uigetfile('*.tif;*.stk;*.lsm', 'select slave channel');

fixedimage=tiffread25( fixedfile.name );

looseimage=tiffread25( loosefile.name);

slave=tiffread25( slavefile.name );

frames=size(fixedimage,2);


xlen=fixedimage(1).width;
ylen=fixedimage(1).height;



% This block is cropping the movie to take only the inner part that has
% maximum field flatness
% windowx1,x2: coordinates from 1 to max pixel for x window
% windowy1,y2: coordinates from 1 to max pixel for y window

windowx1=100
windowx2=412
windowy1=100
windowy2=412


for(n=1:1:frames)

    fixedimage(n).data(windowy2:ylen,:)=[];
    fixedimage(n).data(:,windowx2:xlen)=[];
    fixedimage(n).data(1:windowy1,:)=[];
    fixedimage(n).data(:,1:windowx1)=[];
    
    looseimage(n).data(windowy2:ylen,:)=[];
    looseimage(n).data(:,windowx2:xlen)=[];
    looseimage(n).data(1:windowy1,:)=[];
    looseimage(n).data(:,1:windowx1)=[];
    
    slave(n).data(windowy2:ylen,:)=[];
    slave(n).data(:,windowx2:xlen)=[];
    slave(n).data(1:windowy1,:)=[];
    slave(n).data(:,1:windowx1)=[];
      
end


leftimage=fixedimage(10).data;
rightimage=looseimage(10).data;

h=johannagui;

uiwait(h);

disp(leftthresh);

disp(rightthresh);


for(n=1:1:frames)
    
    seedsbw=bwmorph(im2bw(looseimage(n).data,rightthresh),'clean');

    singletubesbw=bwmorph(im2bw(fixedimage(n).data,leftthresh),'clean')-imdilate(seedsbw, strel('disk',4));
    
    alltubesbw=or(singletubesbw,seedsbw);
    
    backgroundbw=not( imdilate(alltubesbw, strel('disk',4)) );

%     seedsbw=bwmorph(not(adaptivethreshold(master(n).data,2,seedsthresh)),'clean');
% 
%     alltubesbw=bwmorph(not(adaptivethreshold(master(n).data,2,tubesthresh)),'clean');
%     
%     backgroundbw=not( imdilate(alltubesbw, strel('disk',4)) );
% 
%     singletubesbw=alltubesbw-imdilate(seedsbw, strel('disk',4));

    %test if skeleton helps
    % alltubesbw=bwmorph(alltubesbw,'skel',Inf);
    % seedsbw=bwmorph(seedsbw,'skel',Inf);
    % slavemin=min(slave(n).data(:));

    slavebackground=uint16(slave(n).data).*uint16(backgroundbw);

    slaveseeds=uint16(slave(n).data).*uint16(seedsbw);

    slavetubes=uint16(slave(n).data).*uint16(singletubesbw);
    
    backgroundintensity(n)=mean(slavebackground(find(slavebackground>0)));
    
    backgroundstdev=std(double(slavebackground(find(slavebackground>0))));
    
    % This approach does not consider density of signal on tubes for low signals 
    % but threshholding for background can be more relaxed
%     seedsintensity(n)=mean(slaveseeds(find(slaveseeds>(2*backgroundstdev+backgroundintensity(n)) )));
%     
%     tubesintensity(n)=mean(slavetubes(find(slavetubes>(2*backgroundstdev+backgroundintensity(n)) )));

    
%   This approach considers density, but underestimates signal in overlap     

    seedsstd=std(double(slaveseeds(find(slaveseeds>0))));
    seedsmean=mean(slaveseeds(find(slaveseeds>0)));
    seedsintensity(n)=mean(slaveseeds(find(slaveseeds>0 & slaveseeds < seedsmean + 2* seedsstd)));
    
    tubesstd=std(double(slaveseeds(find(slavetubes>0))));
    tubesmean=mean(slavetubes(find(slavetubes>0)));
    tubesintensity(n)=mean(slavetubes(find(slavetubes>0 & slavetubes < seedsmean + 2* seedsstd)));
    
    

% Try mixing both:
% seedsintensity(n)=mean(slaveseeds(find(slaveseeds>(2*backgroundstdev+backgroundintensity(n)) )));
% tubesintensity(n)=mean(slavetubes(find(slavetubes>0)));
% but this is b.s. gives too high values. Stay with density and
% underestimation, work on more filtering


end


% seedsintensity=mean(slaveseeds(find(slaveseeds>0))) This is bullshit!!!
% only last frame!
% 
% tubesintensity=mean(slavetubes(find(slavetubes>0)))
% 
% backgroundintensity=mean(slavebackground(find(slavebackground>0)))
% 
% signalseeds=seedsintensity-backgroundintensity
% 
% signaltubes=tubesintensity-backgroundintensity
% 
% sumseeds=sum(find(slaveseeds>0))/frames
% 
% sumtubes=sum(find(slavetubes>0))/frames
% 
% signalratio=signalseeds/signaltubes


% Display a histogram of the background
% tempa=slavebackground(find(slavebackground>0));
% tempb=max(size(tempa));
% tempc=double(tempa(find(tempb*rand(1000,1))));
% hist(tempc,30);



%Saving the data

filename=[fixedfile.path 'slidinganalysisdata.txt']

if exist(filename,'file')
  filehandle=fopen('slidinganalysisdata.txt', 'a');
else
  filehandle=fopen('slidinganalysisdata.txt', 'a');
  fprintf(filehandle, '%s\n', fixedfile.path);
  fprintf(filehandle, 'File\tFrame\tOverlapIntensity\tSingleTubesIntensity\tBackgroundIntensity\n');  
end   

for(n=1:1:frames)
    fprintf(filehandle, '%s\t%8.0f\t%8.0f\t%8.0f\t%8.0f\n', slavefile.name, n, seedsintensity(n), tubesintensity(n), backgroundintensity(n));
end

fclose(filehandle);

end


% function [seedsintensity , tubesintensity, backgroundintensity] = slidinganalysis
% 
% [masterfile.name, masterfile.path] = uigetfile('*.tif;*.stk;*.lsm', 'select master channel');
% 
% cd(masterfile.path);
% 
% [slavefile.name, slavefile.path] = uigetfile('*.tif;*.stk;*.lsm', 'select slave channel');
% 
% master=tiffread25( masterfile.name );
% 
% slave=tiffread25( slavefile.name );
% 
% % master=tiffread25('master.tif');
% % slave=tiffread25('slave.tif');
% 
% frames=size(master,2);
% 
% seedsthresh=thresh_tool(master(1).data)/(2^master(1).bits-1);
% 
% tubesthresh=thresh_tool(master(1).data)/(2^master(1).bits-1);
% 
% for(n=1:1:frames)
% 
%     seedsbw=im2bw(master(n).data, seedsthresh);
% 
%     alltubesbw=im2bw(master(n).data, tubesthresh);
% 
%     backgroundbw=abs( imdilate(alltubesbw, strel('disk',4)) -1 );
% 
%     singletubesbw=alltubesbw-imdilate(seedsbw, strel('disk',4));
% 
%     % slavemin=min(slave(n).data(:));
% 
%     slavebackground=uint16(slave(n).data).*uint16(backgroundbw);
% 
%     slaveseeds=uint16(slave(n).data).*uint16(seedsbw);
% 
%     slavetubes=uint16(slave(n).data).*uint16(singletubesbw);
%     
%     seedsintensity(n)=mean(slaveseeds(find(slaveseeds>0)));
% 
%     tubesintensity(n)=mean(slavetubes(find(slavetubes>0)));
% 
%     backgroundintensity(n)=mean(slavebackground(find(slavebackground>0)));
%     
% end

    
    
% 
% figure;
% imshow(master.data);
% figure;
% imshow(seedsbw);
% figure;
% imshow(alltubesbw);
% figure;
% imshow(backgroundbw);
% figure;
% imshow(singletubesbw);
% figure;
% imshow(slavebackground,[slavemin, max(slavebackground(:))]);
% figure;
% imshow(slaveseeds,[slavemin, max(slaveseeds(:))]);
% figure;
% imshow(slavetubes, [slavemin, max(slavetubes(:))]);
% 
% seedsintensity=mean(slaveseeds(find(slaveseeds>0)))
% 
% tubesintensity=mean(slavetubes(find(slavetubes>0)))
% 
% backgroundintensity=mean(slavebackground(find(slavebackground>0)))
% 
% signalseeds=seedsintensity-backgroundintensity
% 
% signaltubes=tubesintensity-backgroundintensity
% 
% signalratio=signalseeds/signaltubes

