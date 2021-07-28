function splitLog = splitLogsPCMTime(messages, IDs, startCursorData, endCursorData)

    startTime = startCursorData.Position(1);
    endTime = endCursorData.Position(1);

    splitLog = filterMessages(messages, IDs, [8212], @(x)(x(1) > startTime && x(1) < endTime));

end