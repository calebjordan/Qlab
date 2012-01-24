function compileSequence78(basename, pg, patseq, calseq, numsteps, nbrRepeats, fixedPt, cycleLength, makePlot)

% load config parameters from file
load(getpref('qlab','pulseParamsBundleFile'), 'Ts', 'delays', 'measDelay', 'bufferDelays', 'bufferResets', 'bufferPaddings', 'offsets');

nbrPatterns = length(patseq)*nbrRepeats;
calPatterns = length(calseq)*nbrRepeats;
segments = nbrPatterns*numsteps + calPatterns;
fprintf('Number of sequences: %i\n', segments);

% pre-allocate space
ch1 = zeros(segments, cycleLength);
ch2 = ch1; ch3 = ch1; ch4 = ch1;
ch1m1 = ch1; ch1m2 = ch1; ch2m1 = ch1; ch2m2 = ch1;
ch3m1 = ch1; ch3m2 = ch1; ch4m1 = ch1; ch4m2 = ch1;
delayDiff = delays('34') - delays('78');
PulseCollection = [];

for n = 1:nbrPatterns;
    [I_seq{n}, Q_seq{n}, ~, PulseCollection] = pg.build(patseq{floor((n-1)/nbrRepeats)+1}, numsteps, delays('78'), fixedPt, PulseCollection);

    for stepct = 1:numsteps
        patx = pg.linkListToPattern(I_seq{n}, stepct)';
        paty = pg.linkListToPattern(Q_seq{n}, stepct)';
        
        % remove difference of delays
        patx = circshift(patx, delayDiff);
        paty = circshift(paty, delayDiff);
        ch4m1((n-1)*stepct + stepct, :) = pg.bufferPulse(patx, paty, 0, bufferPaddings('78'), bufferResets('78'), bufferDelays('78'));
    end
end

for n = 1:calPatterns;
    [I_seq{nbrPatterns + n}, Q_seq{nbrPatterns + n}, ~, PulseCollection] = pg.build(calseq{floor((n-1)/nbrRepeats)+1}, 1, delays('78'), fixedPt, PulseCollection);
    patx = pg.linkListToPattern(I_seq{nbrPatterns + n}, 1)';
    paty = pg.linkListToPattern(Q_seq{nbrPatterns + n}, 1)';

    % remove difference of delays
    patx = circshift(patx, delayDiff);
    paty = circshift(paty, delayDiff);
    ch4m1(nbrPatterns*numsteps + n, :) = pg.bufferPulse(patx, paty, 0, bufferPaddings('78'), bufferResets('78'), bufferDelays('78'));
end

% trigger at beginning of measurement pulse
% measure from (6000:9000)
% turn off 'passThru' when creating non-APS pulses
pg.passThru = 0;
measLength = 3000;
measSeq = {pg.pulse('M', 'width', measLength)};
ch1m1 = repmat(pg.makePattern([], fixedPt-500, ones(100,1), cycleLength), 1, segments)';
ch1m2 = repmat(int32(pg.getPatternSeq(measSeq, n, measDelay, fixedPt+measLength)), 1, segments)';

% unify LLs and waveform libs
ch7seq = I_seq{1}; ch6seq = Q_seq{1};
for n = 2:(nbrPatterns+calPatterns)
    for m = 1:length(I_seq{n}.linkLists)
        ch7seq.linkLists{end+1} = I_seq{n}.linkLists{m};
        ch8seq.linkLists{end+1} = Q_seq{n}.linkLists{m};
    end
end
ch7seq.waveforms = deviceDrivers.APS.unifySequenceLibraryWaveformsSingle(I_seq);
ch8seq.waveforms = deviceDrivers.APS.unifySequenceLibraryWaveformsSingle(Q_seq);


if makePlot
    myn = 20;
    figure
    ch7 = pg.linkListToPattern(ch5seq, myn);
    ch8 = pg.linkListToPattern(ch6seq, myn);
    plot(ch7)
    hold on
    plot(ch8, 'r')
    plot(5000*ch4m1(myn,:), 'k')
    plot(5000*ch1m1(myn,:),'.')
    plot(5000*ch1m2(myn,:), 'g')
    grid on
    hold off
end

% add offsets to unused channels
ch1 = ch1 + offsets('12');
ch2 = ch2 + offsets('12');
ch3 = ch3 + offsets('34');
ch4 = ch4 + offsets('34');
ch5seq = pg.build({'QId'}, 1, 0, fixedPt, cycleLength);
ch6seq = ch5seq;

strippedBasename = basename;
basename = [basename '78'];
% make APS file
exportAPSConfig(tempdir, basename, ch5seq, ch6seq, ch7seq, ch8seq);
disp('Moving APS file to destination');
pathAPS = ['U:\APS\' strippedBasename '\' basename '.mat'];
movefile([tempdir basename '.mat'], pathAPS);
% make TekAWG file
options = struct('m21_high', 2.0, 'm41_high', 2.0);
TekPattern.exportTekSequence(tempdir, basename, ch1, ch1m1, ch1m2, ch2, ch2m1, ch2m2, ch3, ch3m1, ch3m2, ch4, ch4m1, ch4m2, options);
disp('Moving AWG file to destination');
pathAWG = ['U:\AWG\' strippedBasename '\' basename '.awg'];
movefile([tempdir basename '.awg'], pathAWG);

end