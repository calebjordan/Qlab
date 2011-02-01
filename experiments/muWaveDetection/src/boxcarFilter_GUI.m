function settings_fcn = boxcarFilter_GUI(parent, bottom, left, settings)
%-------------------------------------------------------------------------------
% File name   : boxcarFilter_GUI.m       
% Generated on: 07-Oct-2010 16:13:57          
% Description :
%-------------------------------------------------------------------------------


% Initialize handles structure
handles = struct();

% if there is no parent figure given, generate one
if nargin < 1 || ~isnumeric(parent)
	handles.figure1 = figure( ...
			'Tag', 'figure1', ...
			'Units', 'characters', ...
			'Position', [103.833333333333 13.8571428571429 64 12], ...
			'Name', 'Boxcar Filter', ...
			'MenuBar', 'none', ...
			'NumberTitle', 'off', ...
			'Color', get(0,'DefaultUicontrolBackgroundColor'));
	
	left = 10.0;
	bottom = 10.0;
else
	handles.figure1 = parent;
end

% Create all UI controls
build_gui();

if nargin < 4
	settings = struct();
end
set_defaults(settings);

% Assign function output
settings_fcn = @get_settings;

%% ---------------------------------------------------------------------------
	function build_gui()
% Creation of all uicontrols

		% --- PANELS -------------------------------------
		handles.uipanel1 = uipanel( ...
			'Parent', handles.figure1, ...
			'Tag', 'uipanel1', ...
			'Units', 'pixels', ...
			'Position', [left bottom 290 90], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'Title', 'Boxcar Filter Settings');

		% --- STATIC TEXTS -------------------------------------
		handles.text1 = uicontrol( ...
			'Parent', handles.uipanel1, ...
			'Tag', 'text1', ...
			'Style', 'text', ...
			'Units', 'characters', ...
			'Position', [0.5 3.35714285714286 20 1.5], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', '# of pulses');

		handles.text2 = uicontrol( ...
			'Parent', handles.uipanel1, ...
			'Tag', 'text2', ...
			'Style', 'text', ...
			'Units', 'characters', ...
			'Position', [20.1666666666667 3.357142 7 1.5], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', 'Start');

		handles.text3 = uicontrol( ...
			'Parent', handles.uipanel1, ...
			'Tag', 'text4', ...
			'Style', 'text', ...
			'Units', 'characters', ...
			'Position', [35.3333333333333 3.35714285714286 8 1.5], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', 'Length');

		% --- EDIT TEXTS -------------------------------------
        handles.number = uicontrol( ...
			'Parent', handles.uipanel1, ...
			'Tag', 'number', ...
			'Style', 'edit', ...
			'Units', 'characters', ...
			'Position', [2.83333333333333 1.57142857142857 10 1.57142857142857], ...
			'BackgroundColor', [1 1 1], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', '1');
        
		handles.start = uicontrol( ...
			'Parent', handles.uipanel1, ...
			'Tag', 'start', ...
			'Style', 'edit', ...
			'Units', 'characters', ...
			'Position', [19.6666666666667 1.42857142857143 9.66666666666667 1.57142857142857], ...
			'BackgroundColor', [1 1 1], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', '');

		handles.length = uicontrol( ...
			'Parent', handles.uipanel1, ...
			'Tag', 'length', ...
			'Style', 'edit', ...
			'Units', 'characters', ...
			'Position', [35.8333333333333 1.42857142857143 9.66666666666667 1.57142857142857], ...
			'BackgroundColor', [1 1 1], ...
			'FontName', 'Helvetica', ...
			'FontSize', 10, ...
			'String', '');

	end

	function selected = get_selected(hObject)
		menu = get(hObject,'String');
		selected = menu{get(hObject,'Value')};
    end

	function set_selected(hObject, val)
		menu = get(hObject, 'String');
		index = find(strcmp(val, menu));
		if ~isempty(index)
			set(hObject, 'Value', index);
		end
	end

	function value = get_numeric(hObject)
		value = str2num(get(hObject, 'String'));
	end

	function settings = get_settings()
		settings = struct();
		
		settings.number = get_numeric(handles.number);
		settings.start = get_numeric(handles.start);
		settings.length = get_numeric(handles.length);
    end

    function set_defaults(settings)
		% define default values for fields. If given a settings structure, grab
		% defaults from it
		defaults.number = 1;
        defaults.start = '';
        defaults.length = '';

		if ~isempty(fieldnames(settings))
			fields = fieldnames(settings);
			for i = 1:length(fields)
				name = fields{i};
				defaults.(name) = settings.(name);
			end
		end
		
		set(handles.number, 'String', num2str(defaults.number));
		set(handles.start, 'String', num2str(defaults.start));
        set(handles.length, 'String', num2str(defaults.length));

	end

end
