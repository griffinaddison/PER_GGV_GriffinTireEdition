function points = quadspace(minVal, maxVal, n)
    points = minVal + (maxVal - minVal) * (0 : n-1).^2 / (n-1)^2;
end
