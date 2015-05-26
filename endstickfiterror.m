function [err,averagelineerror]=endstickfiterror(data,pos)
%gives the error (err) of a fit of the trace 'data' with a parabola from
%position 1:pos and a line of slope 0 from position pos:end
%averagelineerror is the average error of the line fit

%normalize orientation of the vector
vsize=size(data);
    
if(vsize(1)>vsize(2));
   data=data';
end

%n: number of positions in the trace
n=max(size(data))-sum(isnan(data));


% parabola fit
ppoints=1:pos;
parabola=polyfit(ppoints,data(1:pos),2);
fittedparabola=parabola(1)*ppoints.^2+parabola(2)*ppoints+parabola(3);

perrors=(data(1:pos)-fittedparabola(1:pos)).^2; %perrors: parabola errors

% line fit with slope=0
if(pos<n)
    fittedline(1:n-pos+1)=mean(data(pos+1:n));
    lerrors=(data(pos:n)-fittedline(1:n-pos+1)).^2; %lerrors: line errors
else
    
    lerrors=0; %No fit, 
    
end

%sum of squared errors
err=sum(perrors)+sum(lerrors);

%average error of the line fit
averagelineerror=mean(lerrors);


%this is necessary so that a non-existing line-fit does not get a small
%error
if(averagelineerror==0) % No fit
    averagelineerror=1000;
end


end



