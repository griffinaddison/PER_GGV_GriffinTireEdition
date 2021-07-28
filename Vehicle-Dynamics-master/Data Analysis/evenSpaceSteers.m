steerTimeEvenSpace = linspace(0, 3080, 1000);
for i = 1:length(steerTimeEvenSpace);
    steerValEvenSpace(i) = interp1(steerTime, steerVal, steerTimeEvenSpace(i));
end
figure
plot(steerTime, steerVal);
hold on
plot(steerTimeEvenSpace, steerValEvenSpace);