
function [stepsTaken] = nascdemov1(source, tstart, tend, tmin, tmax, sm)
data = xlsread(source);

 dataTime = data(:,1);
    xReading = data(:,2);
    yReading = data(:,3);
    zReading = data(:,4);

    later=0;
    if ~exist ('tend', 'var') || isempty(tend) || tend ==0
        tend = length(dataTime);
        findFinal = 0;
        later=1;
    else
        findFinal =1;
    end
   
     if ~exist ('tstart', 'var') || isempty(tstart) || tstart ==0
        tstart = dataTime(1);
        crop = 0;
     else
         crop = 1;
     end
   
      
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);
    
    for i=1:sz 
        timeVsAcceleration(i, 1) = dataTime(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i).^2) + (yReading(i).^2) + (zReading(i).^2));
    end
    
    
      %set timestamps to time elapsed
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
     %crop those less than start
     
     if crop == 1
         timeVsAcceleration(timeVsAcceleration(:, 1)<tstart, :) = [];
     end 
    
    if findFinal ==1
        final = find(timeVsAcceleration(:,1)>(tend), 1) - 1;
    else 
        later = 1; 
    end
     
    firstItem = timeVsAcceleration(1,1);
    toDelete = [];
    %shift all 
    timeVsAcceleration(:, 1) = timeVsAcceleration(:, 1) - firstItem;
       tlen = length(timeVsAcceleration(:,1));
       m=1;
    for k=2:tlen
        if (timeVsAcceleration(k,2) == timeVsAcceleration(k-1,2))
           toDelete(m) = k;
           m=m+1;
        end
    end
    
    for n =1: length(toDelete)
       timeVsAcceleration(n,:) = []; 
    end
    
    if sm ==1
       timeVsAcceleration(:,2) = smooth(timeVsAcceleration(:,2), 5);
    end
   
%sdWalkingThresh = 0.6;
RThresh = 0.4;

%walking = zeros(clen, 1);

if later == 1; 
    clen = length(timeVsAcceleration(:,1));
    final = clen;
end

timeElapsed = timeVsAcceleration(final,1);
toptResults = zeros(final,2);
z = 1;
for p = 1:final
        %sdData = std(acc);
        %if sdData < sdWalkingThresh
        %    toptResults(z, 1) = tOpt;
        %    toptResults(z, 2) = nascResult;
        %    z=z+1;
        %    continue;
        %end
        %do Nasc on all data
        [tOpt, nascResult] = nascv2(timeVsAcceleration, p, tmax, tmin);
                
        if nascResult > RThresh
            %walking(p, 1) = 1;
            toptResults(z, 1) = tOpt;
            toptResults(z, 2) = nascResult;
            z=z+1;
        else
            %walking(p, 1) = 0;
        end
end


[~, maxIdx] = max(toptResults(:,2));
maxTOpt = toptResults(maxIdx, 1);

%stepsTaken = 1 + floor((timeElapsed-half)/maxTOpt);
stepsTaken = floor(timeElapsed/(maxTOpt/2));
    
end

