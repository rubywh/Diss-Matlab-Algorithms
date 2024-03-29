data = xlsread('traces_test5.csv');

 idx = data(:,2) == 1;
    time = data(idx,1);
    xReading = data(idx,2);
    yReading = data(idx,3);
    zReading = data(idx,4);
    format long;
       
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);
    
    j = 1;   
   
    %set the values for acceleration magnitude
    for i=1:sz 
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i).^2) + (yReading(i).^2) + (zReading(i).^2));
    end
    
     
    %traces test 
    tstart = 44210000000;
    tend =95080000000;
    goal = 85; 
    
    %{
       tstart = 44210000000;
    tend =95080000000;
    %}
    
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
    timeVsAcceleration(timeVsAcceleration(:, 1)<=tstart, :) = [];
    timeVsAcceleration(timeVsAcceleration(:, 1)>=tend, :) = [];
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
    
    figure
    plot(timeVsAcceleration(:,1), timeVsAcceleration(:,2));
    title('Raw Data');
    xlabel('Time');
    ylabel('Acceleration (m/s^2)');
                
        
sdWindow = 900000000;
sdWalkingThresh = 0.6;

%calculate the standard deviations 
stdDeviation = StandardDeviation(timeVsAcceleration, sdWindow);

RThresh = 0.4;
tmin = 400000000;
nascWindowSize = 2000000000;
tmax = 1500000000;

time = timeVsAcceleration(:,1);
acc = timeVsAcceleration(:,2);

clen = length(time);

walking = zeros(clen, 1);

p = time(1);

        %set up the window
         mIdx = find(time>p,1);
        %If dealing with the first reading
        if p == 0
            %The window should start at this reading
            start = 1;
        else 
            start = mIdx;
        end
    
        
        %Set the time limit to the time at which the last item in the window
        %cannot exceed
       % timeLimit = time(start) + nascWindowSize;
        timeLimit = p + nascWindowSize;

        %Find the first item that exceeds the window timelimit
        %The last item in the window will be the reading before this one
        nIdx = find(time>timeLimit,1);
    
        sdThisWindow = std(acc(start:nIdx-1));
        if sdThisWindow > sdWalkingThresh
              
        windowEnd = nIdx - 1;
        windowCount = length(acc(start:windowEnd));
        %do Nasc on all in window
        [tOpt, nascForWindow] = nasc(timeVsAcceleration, start, windowEnd, tmax, tmin, windowCount);
        
        if nascForWindow > RThresh
            walking(start:windowEnd, 1) = 1;
        else
            walking(start:windowEnd, 1) = 0;
        end
        end
        
    %nascResult = nasc4(timeVsAcceleration, tOpt);
            
firstTime = timeVsAcceleration(1,1);
lastTime = timeVsAcceleration(clen,1);
timeWalking = lastTime - firstTime; 
%{
meanTOpt = mean(toptResults(:,1));
stepsTaken = timeWalking./(meanTOpt./2);
%}

stepsTaken = timeWalking./(tOpt/2);
