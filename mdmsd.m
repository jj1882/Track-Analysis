function [md, msd, mdstd, msdstd, number]=mdmsd(traces)
% calculates MD and MSD from all data points, in a non-overlapping way
% traces should end with NaN
% d: displacement
% sd: squared displacement

[runs,maxlength]=size(traces);

for(n=1:1:maxlength-1) % loop through intervals
    
    for(a=1:1:floor(maxlength/n)) % loop through non-overlapping pairs
        
        if(a*n+1 <= maxlength)
            d((a-1)*runs+1:a*runs)=traces(:,a*n+1)-traces(:,(a-1)*n+1);
        end
        
    end
    
    sd=d.*d;
    
    md(n)=nanmean(d);
    
    mdstd(n)=nanstd(d);
    
    msd(n)=nanmean(sd);
    
    msdstd(n)=nanstd(sd);
    
    number(n)=sum(~isnan(d));
    
    clear d;
    
end

        


       
        
        
            
       
    
    
