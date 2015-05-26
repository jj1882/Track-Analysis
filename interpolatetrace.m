function outputtrace=interpolatetrace (inputtrace)

tracklen=length(inputtrace);

outputtrace(1)=inputtrace(1);

a=2;

while(a<=tracklen)
    
    if(inputtrace(a-1)~=inputtrace(a))  % copy if there is no gap in track
        
        outputtrace(a)=inputtrace(a);
        a=a+1;
        
    else % interpolate
        
        index=a;
        
        while(inputtrace(a-1)==inputtrace(index))  %count forward until displacement starts again
            
            if(index==tracklen)
                a=a-1;  % special case when the gap is at the end: interpolate from one position before
                break;
            else
                index=index+1;
            end
        end
        
        % now interpolate between the values between a and index
        
        gaplength=index-(a-1);
        
        outputtrace(a-1:index)=interp1([inputtrace(a-1) inputtrace(index)], 1:1/gaplength:2);
        
        a=index+1;  % set the loop forward
        
    end
    
end


end
        

    
    