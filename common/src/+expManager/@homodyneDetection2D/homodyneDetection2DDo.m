function homodyneDetection2DDo(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USAGE: [errorMsg] = homodyneDetection2DDo(obj)
%
% Description: This method conducts an experiemnt of the type
% homodyneDetection.
%
% v1.1 25 JUNE 2009 William Kelly <wkelly@bbn.com>
% v1.2 25 JULY 2010 Tom Ohki
% v1.3 08 OCT 2010 Blake Johnson
% v1.4 12 OCT 2011 Blake Johnson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ExpParams = obj.inputStructure.ExpParams;
Instr = obj.Instr;
fid = obj.DataFileHandle;
SD_mode = obj.inputStructure.SoftwareDevelopmentMode;
displayScope = obj.inputStructure.displayScope;

persistent figureHandle;
persistent figureHandle2D;
persistent scopeHandle;

if isempty(figureHandle) || ~ishandle(figureHandle)
	figureHandle = figure;
end
if isempty(figureHandle2D) || ~ishandle(figureHandle2D)
        figureHandle2D = figure;
end
if isempty(scopeHandle) && displayScope
    scopeHandle = figure;
end

% Loop is a reparsing of the strucutres LoopParams and TaskParams that we
% will use in this method
Loop = obj.populateLoopStructure;

% Loop 2 is what we iterate over
if isempty(Loop.two)
    Loop.two.steps = 1;
    setLoop2Params = false;
else
    setLoop2Params = true;
end

%% Main Loop

%% If there's anything thats particular to any device do it here

InstrumentNames = fieldnames(Instr);
if ~SD_mode
    for Instr_index = 1:numel(InstrumentNames)
        InstrName = InstrumentNames{Instr_index};
        switch class(Instr.(InstrName))
            case 'deviceDrivers.AgilentAP240'
                scope = Instr.(InstrName); % we're going to need this later
            otherwise
                % unknown instrument type, for now do nothing
        end
    end
end

% stop the master and make sure it stopped
masterAWG = obj.awg{1};
masterAWG.stop();
masterAWG.operationComplete();
% start all the slave AWGs
for i = 2:length(obj.awg)
    awg = obj.awg{i};
    awg.run();
    [success_flag_AWG] = awg.waitForAWGtoStartRunning();
    if success_flag_AWG ~= 1, error('AWG %d timed out', i), end
end

%%
% for each loop we use the function iterateLoop to set the relevent
% parameters.  For now hard coding in one loop is fine, someday we might
% want to change this.
Amp2D = nan(Loop.two.steps, Loop.one.steps);
Phase2D = nan(Loop.two.steps, Loop.one.steps);
% loop "1" contains the step information in the pattern file segments
% so, we iterate over loop 2

x_range = Loop.one.sweep.points;

axesHandle1DAmp = subplot(2,1,1,'Parent', figureHandle);
grid(axesHandle1DAmp, 'on')
axesHandle1DPhase = subplot(2,1,2,'Parent', figureHandle);
grid(axesHandle1DPhase, 'on')

plotHandle1DAmp = plot(axesHandle1DAmp, x_range, nan(1,Loop.one.steps));
ylabel(axesHandle1DAmp, 'Amplitude');
plotHandle1DPhase = plot(axesHandle1DPhase, x_range, nan(1,Loop.one.steps));
ylabel(axesHandle1DPhase, 'Phase');

if Loop.two.steps > 1
    axesHandle2DAmp = subplot(2,1,1,'Parent', figureHandle2D);
    axesHandle2DPhase = subplot(2,1,2,'Parent', figureHandle2D);
    ylabel(axesHandle2DPhase, 'Phase');
    if isfield(Loop.two, 'plotRange')
        y_range = Loop.two.plotRange;
    else
        y_range = 1:Loop.two.sweep.points;
    end
    plotHandle2DAmp = imagesc(x_range, y_range, Amp2D, 'Parent', axesHandle2DAmp);
    ylabel(axesHandle2DAmp, 'Amplitude');
    plotHandle2DPhase = imagesc(x_range, y_range, Phase2D, 'Parent', axesHandle2DPhase);
    ylabel(axesHandle2DPhase, 'Phase');
end


for loop2_index = 1:Loop.two.steps
    if setLoop2Params
        Loop.two.sweep.step(loop2_index);
        fprintf('Loop 1: Step %d of %d\n', [loop2_index, Loop.two.steps]);
    end
    
    if ~SD_mode
        softAvgs = ExpParams.softAvgs;
        for avg_index = 1:softAvgs
            fprintf('Soft average %d\n', avg_index);

            % set the card to acquire
            scope.acquire();

            % set the Tek to run
            masterAWG.run();
            pause(0.5);
            
            %Poll the digitizer until it has all the data
            success = scope.wait_for_acquisition(60);
            if success ~= 0
                error('Failed to acquire waveform.')
            end

            % Then we retrive our data
            Amp_I = scope.transfer_waveform(1);
            Amp_Q = scope.transfer_waveform(2);
            if numel(Amp_I) ~= numel(Amp_Q)
                error('I and Q outputs have different lengths.')
            end
            
            %For the first soft average initialize, otherwise sum
            if avg_index == 1
                isoftAvg = Amp_I;
                qsoftAvg = Amp_Q;
            else
                isoftAvg = (isoftAvg .* (avg_index - 1) + Amp_I)./(avg_index);
                qsoftAvg = (qsoftAvg .* (avg_index - 1) + Amp_Q)./(avg_index);
            end

            if displayScope
                %scope_y = 1:size(Amp_I,2);
                figure(scopeHandle);
                foo = subplot(2,1,1);
                %imagesc(timesI,scope_y,Amp_I');
                imagesc(isoftAvg');
                xlabel('Time');
                ylabel('Segment');
                set(foo, 'YDir', 'normal');
                title('Ch 1 (I)');
                foo = subplot(2,1,2);
                %imagesc(timesQ,scope_y,Amp_Q');
                imagesc(qsoftAvg');
                xlabel('Time');
                ylabel('Segment');
                set(foo, 'YDir', 'normal');
                title('Ch 2 (Q)');
            end

            % signal processing and analysis
            range = ExpParams.filter.start:ExpParams.filter.start+ExpParams.filter.length - 1;
            switch (ExpParams.digitalHomodyne.DHmode)
                case 'OFF'
                    % calcuate average amplitude and phase
                    iavg = mean(isoftAvg(range,:))';
                    qavg = mean(qsoftAvg(range,:))';
                case 'DH1'
                    % TODO: update digital homodyne to do point by
                    % point conversion
                    [iavg qavg] = obj.digitalHomodyne(isoftAvg, ...
                        ExpParams.digitalHomodyne.IFfreq*1e6, ...
                        scope.horizontal.sampleInterval, ExpParams.filter.start, ExpParams.filter.length);
                case 'DIQ'
                    [iavg qavg] = obj.digitalHomodyneIQ(isoftAvg(range,:), qsoftAvg(range,:), ...
                        ExpParams.digitalHomodyne.IFfreq*1e6, ...
                        scope.horizontal.sampleInterval);
            end
            % convert I/Q to Amp/Phase
            amp = sqrt(iavg.^2 + qavg.^2);
            phase = (180.0/pi) * atan2(qavg, iavg);

            % Update the plots
            set(plotHandle1DAmp, 'YData', amp)
            set(plotHandle1DPhase, 'YData', phase)

            masterAWG.stop();
            % restart the slave AWGs so we can resync
            for i = 2:length(obj.awg)
                awg = obj.awg{i};
                awg.stop();
                awg.run();
            end
            pause(0.2);
        end

        % write the data to file
        fprintf(fid,'%g+%gi ',[iavg'; qavg']);
        fprintf(fid,'\n');

        %Store in the 2D array
        Amp2D(loop2_index,:) = amp;
        Phase2D(loop2_index,:) = phase;
        
        % display 2D data sets if there is a loop
        if Loop.two.steps > 1
            set(plotHandle2DAmp, 'CData', Amp2D);
            set(plotHandle2DPhase, 'CData', Phase2D);
        end
        
    else
        percentComplete = 100*(loop2_index-1 + (loop2_index)/Loop.two.steps)/Loop.one.steps;
        fprintf(fid,'%d\n',percentComplete);
    end
end

%% If there's anything thats particular to any device do it here

if ~SD_mode
    InstrumentNames = fieldnames(Instr);
    for Instr_index = 1:numel(InstrumentNames)
        InstrName = InstrumentNames{Instr_index};
        switch class(Instr.(InstrName))
            case 'deviceDrivers.Tek5014'
            case 'deviceDrivers.Agilent33220A'
            case 'deviceDrivers.AgilentE8363C'
                Instr.(InstrName).output = 'off';
            case 'deviceDrivers.HP8673B'
                Instr.(InstrName).output = 'off';
            case 'deviceDrivers.HP8340B'
                Instr.(InstrName).output = 'off';
            case 'deviceDrivers.TekTDS784A'
			case 'deviceDrivers.AgilentAP120'
			case 'deviceDrivers.DCBias'
            otherwise
                % unknown instrument type, for now do nothing
        end
    end
end

end
