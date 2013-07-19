function [filename, segmentPoints] = Pi2CalChannelSequence(obj, qubit, direction, numPulses, makePlot)

if ~exist('direction', 'var')
    direction = 'X';
elseif ~strcmp(direction, 'X') && ~strcmp(direction, 'Y')
    warning('Unknown direction, assuming X');
    direction = 'X';
end
if ~exist('makePlot', 'var')
    makePlot = false;
end

[status, result] = system(sprintf('python Pi2Cal.py "%s" %s %s %d %f', getpref('qlab', 'PyQLabDir'), qubit, direction, numPulses, obj.channelParams.pi2Amp));

nbrRepeats = 2;
segmentPoints = 1:nbrRepeats*(1+2*numPulses);

filename = obj.getAWGFileNames('Pi2Cal');

end

