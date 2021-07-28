figure
hold on
lapLength = 1378;
%lapLength = 1400;
lapCount = 1;
i = 1;
lapStart = 0;
j = 1;
while lapCount < 16 && i < length(distance)
    
    lapDistance(j) = distance(i) - lapStart;
    lapSpeed(j) = speed(i);
    
    if (distance(i) - lapStart > lapLength)
        
       %plot lap that car just ran 
        
       
       hold on
       if lapCount > 8
           color = 'r'; 
       else
           color = 'b';
       end
       
       plot(lapDistance, lapSpeed*2.37, color)
       ylabel('Speed, mph');
       xlabel('Lap Distance Traveled, m');

       %prep for next lap
       lapCount = lapCount+1;
       if lapCount > 8
           lapStart = 11162 + lapLength * (lapCount - 9);
           %lapStart = 20000 + lapLength * (lapCount - 9);
       else
            lapStart = lapLength * (lapCount - 1); %distance(i);
       end
       while(distance(i) < lapStart);
          i = i+1; 
       end
       lapSpeed = [];
       lapDistance = [];
       j = 0;
       
    end
    j = j+1;
    i = i+1;
end