function varargout = johannagui(varargin)
% JOHANNAGUI M-file for johannagui.fig
%      JOHANNAGUI, by itself, creates a new JOHANNAGUI or raises the existing
%      singleton*.
%
%      H = JOHANNAGUI returns the handle to a new JOHANNAGUI or the handle to
%      the existing singleton*.
%
%      JOHANNAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JOHANNAGUI.M with the given input arguments.
%
%      JOHANNAGUI('Property','Value',...) creates a new JOHANNAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before johannagui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to johannagui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help johannagui

% Last Modified by GUIDE v2.5 25-May-2010 15:36:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @johannagui_OpeningFcn, ...
                   'gui_OutputFcn',  @johannagui_OutputFcn, ...
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

global leftimage;
global rightimage;


% --- Executes just before johannagui is made visible.
function johannagui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to johannagui (see VARARGIN)

% Choose default command line output for johannagui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes johannagui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global leftimage;
global rightimage;
global limage;
global rimage;

imshow(leftimage,'Parent',handles.axes1);
imshow(rightimage,'Parent',handles.axes2);

set(handles.text3,'String','0.0');
set(handles.text4,'String','0.0');




% --- Outputs from this function are returned to the command line.
function varargout = johannagui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global leftimage;
global limage;

value=num2str(get(hObject,'Value'));
set(handles.text3,'String',value);

a=get(handles.slider1,'Value');

limage=bwmorph(im2bw(leftimage,a),'clean');

%limage=bwmorph(not(adaptivethreshold(leftimage,2,a)),'clean');


imshow(limage,'Parent',handles.axes1);




% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


global rightimage;
global rimage;

value=num2str(get(hObject,'Value'));
set(handles.text4,'String',value);

a=get(handles.slider2,'Value');

rimage=bwmorph(im2bw(rightimage,a),'clean');

% rimage=bwmorph(not(adaptivethreshold(rightimage,2,a)),'clean');

imshow(rimage,'Parent',handles.axes2);




% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ok Button

global leftthresh;
global rightthresh;

leftthresh=get(handles.slider1,'Value');
rightthresh=get(handles.slider2,'Value');

delete(handles.figure1);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Original Button

global leftimage;
global rightimage;

imshow(leftimage,'Parent',handles.axes1);
imshow(rightimage,'Parent',handles.axes2);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Thresholded button


global limage;
global rimage;

imshow(limage,'Parent',handles.axes1);
imshow(rimage,'Parent',handles.axes2);
