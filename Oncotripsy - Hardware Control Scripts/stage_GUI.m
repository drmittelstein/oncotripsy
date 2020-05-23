% Author: David Reza Mittelstein (drmittelstein@gmail.com)
% Medical Engineering, California Institute of Technology, 2020

% Activates a GUI that allows for control of Velmex stage

function varargout = stage_GUI(varargin)
% STAGE_GUI MATLAB code for stage_GUI.fig
%      STAGE_GUI, by itself, creates a new STAGE_GUI or raises the existing
%      singleton*.
%
%      H = STAGE_GUI returns the handle to a new STAGE_GUI or the handle to
%      the existing singleton*.
%
%      STAGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STAGE_GUI.M with the given input arguments.
%
%      STAGE_GUI('Property','Value',...) creates a new STAGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stage_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stage_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stage_GUI

% Last Modified by GUIDE v2.5 01-Aug-2017 03:30:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stage_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @stage_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before stage_GUI is made visible.
function stage_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stage_GUI (see VARARGIN)

%handles = sub_AllSettings('Stage_GUI');

% Choose default command line output for stage_GUI
handles.output = hObject;

% Update handles structure
sub_Close_All_Connections;
handles = sub_Stage_Initialize(handles);

handles.Stages.Speed = 2000;

handles.Stages.TargetLoc = handles.Stages.Position;
handles.Stages.TargetStepSize = 0.001 / handles.Stages.step_distance;
handles.Stages.GUIMotorsYZ = 1;

    if handles.Stages.GUIMotorsYZ
        set(findobj(handles.output, 'Tag', 'hRight'), 'String', sprintf('%s\n+Z',char(9658)))
        set(findobj(handles.output, 'Tag', 'hLeft'), 'String', sprintf('%s\n-Z',char(9668)))       
    else
        set(findobj(handles.output, 'Tag', 'hRight'), 'String', sprintf('%s\n+X',char(9658)))
        set(findobj(handles.output, 'Tag', 'hLeft'), 'String', sprintf('%s\n-X',char(9668)))
    end
    
        set(findobj(handles.output, 'Tag', 'hStep'), 'String', ...
        sprintf('%1.2f mm', 1000 * handles.Stages.TargetStepSize * handles.Stages.step_distance))

    p = handles.Stages.Position - handles.Stages.Origin;
    
    set(findobj(handles.output, 'Tag', 'hCurrent'), 'String', ...
        sprintf('Current Location:\n  X: %1.2f mm \n  Y: %1.2f mm \n  Z: %1.2f mm', ...
        1000 * p(handles.Stages.x_motor) * handles.Stages.step_distance, ...
        1000 * p(handles.Stages.y_motor) * handles.Stages.step_distance, ...
        1000 * p(handles.Stages.z_motor) * handles.Stages.step_distance))

handles.Ready = 1;

guidata(hObject, handles);

% UIWAIT makes stage_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stage_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

if handles.Ready
handles.Ready = 0;
guidata(hObject, handles);

k = eventdata.Key;

if strcmp(k, 'rightarrow')
    if handles.Stages.GUIMotorsYZ
        handles.Stages.TargetLoc(handles.Stages.z_motor) = ...
            handles.Stages.Position(handles.Stages.z_motor) + ...
            handles.Stages.TargetStepSize ;
    else
        handles.Stages.TargetLoc(handles.Stages.x_motor) = ...
            handles.Stages.Position(handles.Stages.x_motor) + ...
            handles.Stages.TargetStepSize ;     
    end
    handles = sub_Stage_Move_To(handles, handles.Stages.TargetLoc);
    
elseif strcmp(k, 'leftarrow')
    if handles.Stages.GUIMotorsYZ
        handles.Stages.TargetLoc(handles.Stages.z_motor) = ...
            handles.Stages.Position(handles.Stages.z_motor) - ...
            handles.Stages.TargetStepSize ;
    else
        handles.Stages.TargetLoc(handles.Stages.x_motor) = ...
            handles.Stages.Position(handles.Stages.x_motor) - ...
            handles.Stages.TargetStepSize ;     
    end
    handles = sub_Stage_Move_To(handles, handles.Stages.TargetLoc);
    
elseif strcmp(k, 'uparrow')
    handles.Stages.TargetLoc(handles.Stages.y_motor) = ...
            handles.Stages.Position(handles.Stages.y_motor) - ...
            handles.Stages.TargetStepSize ;
     handles = sub_Stage_Move_To(handles, handles.Stages.TargetLoc); 
     
elseif strcmp(k, 'downarrow')
    handles.Stages.TargetLoc(handles.Stages.y_motor) = ...
            handles.Stages.Position(handles.Stages.y_motor) + ...
            handles.Stages.TargetStepSize ;
    handles = sub_Stage_Move_To(handles, handles.Stages.TargetLoc); 
    
elseif strcmp(k, 'space')
    handles.Stages.GUIMotorsYZ = ~handles.Stages.GUIMotorsYZ;
    
    if handles.Stages.GUIMotorsYZ
        set(findobj(handles.output, 'Tag', 'hRight'), 'String', sprintf('%s\n+Z',char(9658)))
        set(findobj(handles.output, 'Tag', 'hLeft'), 'String', sprintf('%s\n-Z',char(9668)))       
    else
        set(findobj(handles.output, 'Tag', 'hRight'), 'String', sprintf('%s\n+X',char(9658)))
        set(findobj(handles.output, 'Tag', 'hLeft'), 'String', sprintf('%s\n-X',char(9668)))
    end%----------
    
elseif strcmp(k, '9')
    handles.Stages.TargetStepSize = ...
        min(handles.Stages.TargetStepSize * 2, 0.064 / handles.Stages.step_distance);
    
    set(findobj(handles.output, 'Tag', 'hStep'), 'String', ...
        sprintf('%1.2f mm', 1000 * handles.Stages.TargetStepSize * handles.Stages.step_distance))
    
elseif strcmp(k, '8')
    handles.Stages.TargetStepSize = ...
        max(handles.Stages.TargetStepSize / 2, 1/32 * 0.001 / handles.Stages.step_distance);
    
    set(findobj(handles.output, 'Tag', 'hStep'), 'String', ...
        sprintf('%1.2f mm', 1000 * handles.Stages.TargetStepSize * handles.Stages.step_distance))
    
elseif strcmp(k, 'b')
    handles.Stages.TargetLoc = handles.Stages.Origin;
    handles = sub_Stage_Move_To(handles, handles.Stages.TargetLoc); 
elseif strcmp(k, 'o')
    handles.Stages.Origin = handles.Stages.Position;
    handles.Stages.TargetLoc = handles.Stages.Position;

end

    p = handles.Stages.Position - handles.Stages.Origin;
    
    set(findobj(handles.output, 'Tag', 'hCurrent'), 'String', ...
        sprintf('Current Location:\n  X: %1.2f mm \n  Y: %1.2f mm \n  Z: %1.2f mm', ...
        1000 * p(handles.Stages.x_motor) * handles.Stages.step_distance, ...
        1000 * p(handles.Stages.y_motor) * handles.Stages.step_distance, ...
        1000 * p(handles.Stages.z_motor) * handles.Stages.step_distance))
 
handles.Ready = 1;
guidata(hObject, handles);

end


% --- Executes on button press in hOrigin.
function hOrigin_Callback(hObject, eventdata, handles)
% hObject    handle to hOrigin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Stages.Origin = handles.Stages.Position;
handles.Stages.TargetLoc = handles.Stages.Position;

p = handles.Stages.Position - handles.Stages.Origin;

set(findobj(handles.output, 'Tag', 'hCurrent'), 'String', ...
    sprintf('Current Location:\n  X: %1.2f mm \n  Y: %1.2f mm \n  Z: %1.2f mm', ...
    1000 * p(handles.Stages.x_motor) * handles.Stages.step_distance, ...
    1000 * p(handles.Stages.y_motor) * handles.Stages.step_distance, ...
    1000 * p(handles.Stages.z_motor) * handles.Stages.step_distance))

guidata(hObject, handles);

% --- Executes on button press in hBack.
function hBack_Callback(hObject, eventdata, handles)
% hObject    handle to hBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.Ready
handles.Ready = 0;
guidata(hObject, handles);

    handles.Stages.TargetLoc = handles.Stages.Origin;
    handles = sub_Stage_Move_To(handles, handles.Stages.TargetLoc); 

handles.Ready = 1;
guidata(hObject, handles);

    p = handles.Stages.Position - handles.Stages.Origin;
    
    set(findobj(handles.output, 'Tag', 'hCurrent'), 'String', ...
        sprintf('Current Location:\n  X: %1.2f mm \n  Y: %1.2f mm \n  Z: %1.2f mm', ...
        1000 * p(handles.Stages.x_motor) * handles.Stages.step_distance, ...
        1000 * p(handles.Stages.y_motor) * handles.Stages.step_distance, ...
        1000 * p(handles.Stages.z_motor) * handles.Stages.step_distance))
end
