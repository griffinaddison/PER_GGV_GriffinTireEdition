function timestamp = getTimestamp(year, month, day, hour, minute, second, millis)
    timestamp = etime([year month day hour minute second], [2000 0 0 0 0 0]) * 1000 + millis;
end