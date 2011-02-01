function settings_fcn = PhaseSweepGUI(parent, bottom, left, name)
% PHASESWEEP_BUILD
%-------------------------------------------------------------------------------
% File name   : PhaseSweep_build.m            
% Generated on: 15-Oct-2010 15:06:09          
% Description :
%-------------------------------------------------------------------------------


% Initialize handles structure
handles = struct();


% if there is no parent figure given, generate one
if nargin < 1 || ~isnumeric(parent)
	handles.figure1 = figure( ...
			'Tag', 'figure1', ...
			'Units', 'characters', ...
			'Position', [103.833333333333 13.8571428571429 78 12], ...
			'Name', 'Phase Settings', ...
			'MenuBar', 'none', ...
			'NumberTitle', 'off', ...
			'Color', get(0,'DefaultUicontrolBackgroundColor'));
	
	left = 10.0;
	bottom = 10.0;
	name = ['Phase settings'];
else
	handles.figure1 = parent;
	name = ['Phase settings ' name];
end

% Create all UI controls
build_gui();

% Assign function output
settings_fcn = @get_settings;

%% ---------------------------------------------------------------------------
	function build_gui()
% Creation of all uicontrols

		% --- PANELS -------------------------------------
		handles.phasepanel1 = uipanel( ...
			'Parent', handles.figure1, ...
			'Tag', 'phasepanel1', ...
			'Units', 'pixels', ...
			'Position', [left bottom 425 115], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'Title', name);

		% --- STATIC TEXTS -------------------------------------
		handles.text1 = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'text1', ...
			'Style', 'text', ...
			'Units', 'characters', ...
			'Position', [6.8 2.23076923076923 12 1.07692307692308], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', 'Start phase');

		handles.text2 = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'text2', ...
			'Style', 'text', ...
			'Units', 'characters', ...
			'Position', [29 2.23076923076923 11.8 1.07692307692308], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', 'Stop phase');

		handles.text3 = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'text3', ...
			'Style', 'text', ...
			'Units', 'characters', ...
			'Position', [46.4 2.23076923076923 21 1.07692307692308], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', 'Step');

		handles.text4 = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'text4', ...
			'Style', 'text', ...
			'Units', 'characters', ...
			'Position', [28.8 5.61538461538462 12.8 1.07692307692308], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', 'Generator ID');

		% --- EDIT TEXTS -------------------------------------
		handles.phaseStart = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'phaseStart', ...
			'Style', 'edit', ...
			'Units', 'characters', ...
			'Position', [2.8 0.692307692307692 19.4 1.53846153846154], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'BackgroundColor', [1 1 1], ...
			'String', '0');

		handles.phaseStop = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'phaseStop', ...
			'Style', 'edit', ...
			'Units', 'characters', ...
			'Position', [25 0.692307692307692 19.4 1.53846153846154], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'BackgroundColor', [1 1 1], ...
			'String', '360');

		handles.phaseStep = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'phaseStep', ...
			'Style', 'edit', ...
			'Units', 'characters', ...
			'Position', [47.8 0.692307692307692 19.4 1.53846153846154], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'BackgroundColor', [1 1 1], ...
			'String', '10');

		% --- POPUP MENU -------------------------------------
		handles.genID = uicontrol( ...
			'Parent', handles.phasepanel1, ...
			'Tag', 'genIDphase', ...
			'Style', 'popupmenu', ...
			'Units', 'characters', ...
			'Position', [25 3.92307692307692 19 1.61538461538462], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'BackgroundColor', [1 1 1], ...
			'String', {'RF','LO','Spec'});


	end

	function selected = get_selected(hObject)
		menu = get(hObject,'String');
		selected = menu{get(hObject,'Value')};
	end

	function value = get_numeric(hObject)
		value = str2num(get(hObject, 'String'));
	end

	function settings = get_settings()
		settings = struct();
		
		settings.type = 'sweeps.Phase';
		settings.start = get_numeric(handles.phaseStart);
		settings.stop = get_numeric(handles.phaseStop);
		settings.step = get_numeric(handles.phaseStep);
		settings.genID = [get_selected(handles.genID) 'gen'];
	end

end
