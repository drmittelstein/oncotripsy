function varargout = wellplate_GUI(varargin)
% DRM_GUI MATLAB code for DRM_GUI.fig
%      DRM_GUI, by itself, creates a new DRM_GUI or raises the existing
%      singleton*.
%
%      H = DRM_GUI returns the handle to a new DRM_GUI or the handle to
%      the existing singleton*.
%
%      DRM_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRM_GUI.M with the given input arguments.
%
%      DRM_GUI('Property','Value',...) creates a new DRM_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DRM_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DRM_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DRM_GUI

% Last Modified by GUIDE v2.5 24-Jul-2016 16:05:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DRM_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DRM_GUI_OutputFcn, ...
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


% --- Executes just before DRM_GUI is made visible.
function DRM_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DRM_GUI (see VARARGIN)

% Choose default command line output for DRM_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DRM_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DRM_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function dX_Callback(hObject, eventdata, handles)
% hObject    handle to dX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dX as text
%        str2double(get(hObject,'String')) returns contents of dX as a double


% --- Executes during object creation, after setting all properties.
function dX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dY_Callback(hObject, eventdata, handles)
% hObject    handle to dY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dY as text
%        str2double(get(hObject,'String')) returns contents of dY as a double


% --- Executes during object creation, after setting all properties.
function dY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dZ_Callback(hObject, eventdata, handles)
% hObject    handle to dZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dZ as text
%        str2double(get(hObject,'String')) returns contents of dZ as a double


% --- Executes during object creation, after setting all properties.
function dZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
