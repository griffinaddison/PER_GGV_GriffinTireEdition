function millisSince2000 = time2017(month, day, militaryTime, minute, second)
    millisSince2000 = etime([2017 month day militaryTime minute second], [2000 0 0 0 0 0]) * 1000;
end