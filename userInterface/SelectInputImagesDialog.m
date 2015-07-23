function varargout = SelectInputImagesDialog(varargin)
% SELECTINPUTIMAGESDIALOG MATLAB code for SelectInputImagesDialog.fig
%      SELECTINPUTIMAGESDIALOG, by itself, creates a new SELECTINPUTIMAGESDIALOG or raises the existing
%      singleton*.
%
%      H = SELECTINPUTIMAGESDIALOG returns the handle to a new SELECTINPUTIMAGESDIALOG or the handle to
%      the existing singleton*.
%
%      SELECTINPUTIMAGESDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTINPUTIMAGESDIALOG.M with the given input arguments.
%
%      SELECTINPUTIMAGESDIALOG('Property','Value',...) creates a new SELECTINPUTIMAGESDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectInputImagesDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectInputImagesDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectInputImagesDialog

% Last Modified by GUIDE v2.5 12-Jun-2015 17:33:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectInputImagesDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectInputImagesDialog_OutputFcn, ...
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


% --- Executes just before SelectInputImagesDialog is made visible.
function SelectInputImagesDialog_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectInputImagesDialog (see VARARGIN)

% check input validity
if nargin ~= 4 || ~isa(varargin{1}, 'KymoRod')
    error('Requires an KymoRod object as input argument');
end

app = varargin{1};
setappdata(0, 'app', app);

app.logger.info('SelectInputImagesDialog.m', ...
    'Open dialog "SelectInputImagesDialog"');

% setup figure menu
gui = KymoRodGui(app);
buildFigureMenu(gui, hObject);

% some gui listener adjustments
set(handles.inputImagesPanel, 'SelectionChangeFcn', ...
    @channelSelectionPanel_SelectionChangeFcn);

% if some data are already initialized, display widgets
if getProcessingStep(app) > ProcessingStep.None
    % update visibility and content of widgets
    makeAllWidgetsVisible(handles);
    updateFrameSliderBounds(handles);
    handles = updateFramePreview(handles);
end


% setup some widgets with current settings
settings = app.settings;
set(handles.spatialResolutionEdit, 'String', num2str(settings.pixelSize));
set(handles.spatialResolutionUnitEdit, 'String', settings.pixelSizeUnit);
set(handles.timeIntervalEdit, 'String', num2str(settings.timeInterval));
set(handles.timeIntervalUnitEdit, 'String', settings.timeIntervalUnit);

set(handles.lazyLoadingCheckbox, 'Value', app.inputImagesLazyLoading);


% Choose default command line output for SelectInputImagesDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectInputImagesDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SelectInputImagesDialog_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Menu management

function mainFrameMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
KymoRodMenuDialog(app);


%% Input directory selection

% --- Executes on button press in chooseInputImagesButton.
function chooseInputImagesButton_Callback(hObject, eventdata, handles)  %#ok<INUSL>
% To select the images from a directory

% extract app data
app = getappdata(0, 'app');

% open a dialog to select input image folder, restricting type to images
folderName = app.inputImagesDir;
[fileName, folderName] = uigetfile(...
    {'*.tif;*.jpg;*.png;*.gif', 'All Image Files';...
    '*.tif;*.tiff;*.gif', 'Tagged Image Files (*.tif)';...
    '*.jpg;', 'JPEG images (*.jpg)';...
    '*.*','All Files' }, ...
    'Select Input Folder', ...
    fullfile(folderName, '*.*'));
      
% check if cancel button was selected
if fileName == 0;
    return;
end

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change input image folder to ' folderName]);

% update inner variables and GUI
set(handles.inputImageFolderEdit, 'String', folderName);
app.inputImagesDir = folderName;

if isfield(handles, 'currentFrameImage')
    handles = rmfield(handles, 'currentFrameImage');
end
updateImageNameList(handles);

% --- Executes on button change in channelSelectionPanel
function channelSelectionPanel_SelectionChangeFcn(hObject, eventdata)
% this function is used to catch selection of radiobuttons in selection panel


function filePatternEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to filePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filePatternEdit as text
%        str2double(get(hObject,'String')) returns contents of filePatternEdit as a double

app = getappdata(0, 'app');
string = get(handles.filePatternEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change input images file pattern to ' string]);

app.inputImagesFilePattern = string;
disp(['update file pattern: ' string]);

updateImageNameList(handles);


% --- Executes during object creation, after setting all properties.
function filePatternEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imageChannelPopup.
function imageChannelPopup_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to imageChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imageChannelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageChannelPopup

app = getappdata(0, 'app');
stringArray = get(handles.imageChannelPopup, 'String');
value = get(handles.imageChannelPopup, 'Value');
channelString = strtrim(stringArray(value,:));

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change image segmentation channel to ' channelString]);

app.settings.imageSegmentationChannel = channelString;

% --- Executes during object creation, after setting all properties.
function imageChannelPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateImageNameList(handles)
% should be called after change of input directory, or file pattern

% extract app data
app = getappdata(0, 'app');

app.logger.info('SelectInputImagesDialog.m', ...
    'Update image name list');

% read new list of image names, used to compute frame number
folderName  = app.inputImagesDir;
filePattern = app.inputImagesFilePattern;
imageNames  = readImageNameList(folderName, filePattern);
app.imageNameList = imageNames;

if isempty(app.imageNameList)
    errordlg({'The chosen directory contains no file.', ...
        'Please choose another one'}, ...
        'Empty Directory Error', 'modal');
    
    % disable preview and other settings
    set(handles.calibrationPanel, 'Visible', 'Off');
    set(handles.frameSelectionPanel, 'Visible', 'Off');
    set(handles.currentFrameLabel, 'Visible', 'Off');
    cla(handles.currentFrameAxes);
    set(handles.currentFrameAxes, 'Visible', 'Off');
    set(handles.framePreviewSlider, 'Visible', 'Off');
    set(handles.selectImagesButton, 'Visible', 'On');

    return;
end

setProcessingStep(app, ProcessingStep.Selection);

% choose to display color image selection
info = imfinfo(fullfile(app.inputImagesDir, app.imageNameList{1}));
if strcmpi(info(1).ColorType, 'grayscale')
    set(handles.imageChannelLabel, 'Enable', 'Off');
    set(handles.imageChannelPopup, 'Enable', 'Off');
else
    set(handles.imageChannelLabel, 'Enable', 'On');
    set(handles.imageChannelPopup, 'Enable', 'On');
end

% init image selection indices
frameNumber = length(app.imageNameList);
app.firstIndex = 1;
app.lastIndex = frameNumber;
app.indexStep = 1;

makeAllWidgetsVisible(handles);

updateFrameSliderBounds(handles);
handles = updateFramePreview(handles);

guidata(handles.figure1, handles);


function imageNames = readImageNameList(folderName, filePattern)
    
fprintf('Read image name list...');

% list files in chosen directory
fileList = dir(fullfile(folderName, filePattern));
fileList = fileList(~[fileList.isdir]);

% no file matching pattern
if isempty(fileList)
    fprintf(' no file found\n');
    imageNames = {};
    return;
end

% populate the list of image names
frameNumber = length(fileList);
imageNames = cell(frameNumber, 1);
parfor i = 1:frameNumber
    imageNames{i} = fileList(i).name;
end

fprintf(' done\n');

function makeAllWidgetsVisible(handles)

% update widgets with app information
app = getappdata(0, 'app');

% show all panels
set(handles.inputImagesPanel, 'Visible', 'On');
set(handles.calibrationPanel, 'Visible', 'On');
set(handles.frameSelectionPanel, 'Visible', 'On');

% update input data widgets
set(handles.inputImageFolderEdit, 'String', app.inputImagesDir);
set(handles.filePatternEdit, 'String', app.inputImagesFilePattern);

% choose to display color image selection
info = imfinfo(fullfile(app.inputImagesDir, app.imageNameList{1}));
if strcmpi(info(1).ColorType, 'grayscale')
    set(handles.imageChannelLabel, 'Enable', 'Off');
    set(handles.imageChannelPopup, 'Enable', 'Off');
else
    set(handles.imageChannelLabel, 'Enable', 'On');
    set(handles.imageChannelPopup, 'Enable', 'On');
end

% update calibration widgets
settings = app.settings;
set(handles.spatialResolutionEdit, 'String', num2str(settings.pixelSize));
set(handles.timeIntervalEdit, 'String', num2str(settings.timeInterval));

% display image preview
set(handles.currentFrameLabel, 'Visible', 'On');
set(handles.currentFrameAxes, 'Visible', 'On');

frameSelectionHandles = [...
    handles.firstFrameIndexLabel, handles.firstFrameIndexEdit, ...
    handles.lastFrameIndexLabel, handles.lastFrameIndexEdit, ...
    handles.frameIndexStepLabel, handles.frameIndexStepEdit  ];

frameNumber = length(app.imageNameList);
if app.firstIndex == 1 && app.lastIndex == frameNumber && app.indexStep == 1
    set(handles.keepAllFramesRadioButton, 'Value', 1);
    set(handles.selectFrameIndicesRadioButton, 'Value', 0);
    % make file selection widgets invisible
    set(frameSelectionHandles, 'Visible', 'Off');

else
    set(handles.keepAllFramesRadioButton, 'Value', 0);
    set(handles.selectFrameIndicesRadioButton, 'Value', 1);
    % make file selection widgets visible
    set(frameSelectionHandles, 'Visible', 'On');
end

string = sprintf('Keep All Frames (%d)', frameNumber);
set(handles.keepAllFramesRadioButton, 'String', string);
string = sprintf('Select a range among the %d frames', frameNumber);
set(handles.selectFrameIndicesRadioButton, 'String', string);

set(handles.firstFrameIndexEdit, 'String', num2str(app.firstIndex));
set(handles.lastFrameIndexEdit, 'String', num2str(app.lastIndex));
set(handles.frameIndexStepEdit, 'String', num2str(app.indexStep));

set(handles.wholeWorkflowButton, 'Visible', 'On');
set(handles.selectImagesButton, 'Visible', 'On');


%% Calibration section

function spatialResolutionEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to spatialResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatialResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of spatialResolutionEdit as a double

app = getappdata(0, 'app');
resolString = get(handles.spatialResolutionEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change spatial resolution to ' resolString]);

resol = str2double(resolString);
app.settings.pixelSize = resol;


% --- Executes during object creation, after setting all properties.
function spatialResolutionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatialResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spatialResolutionUnitEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to spatialResolutionUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatialResolutionUnitEdit as text
%        str2double(get(hObject,'String')) returns contents of spatialResolutionUnitEdit as a double

app = getappdata(0, 'app');
unitString = get(handles.spatialResolutionUnitEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change spatial resolution unit to ' unitString]);

app.settings.pixelSizeUnit = unitString;

% --- Executes during object creation, after setting all properties.
function spatialResolutionUnitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatialResolutionUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeIntervalEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeIntervalEdit as text
%        str2double(get(hObject,'String')) returns contents of timeIntervalEdit as a double

app = getappdata(0, 'app');
timeString = get(handles.timeIntervalEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change time interval between frames to ' timeString]);

time = str2double(timeString);
app.settings.timeInterval = time;

% --- Executes during object creation, after setting all properties.
function timeIntervalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeIntervalUnitEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to timeIntervalUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeIntervalUnitEdit as text
%        str2double(get(hObject,'String')) returns contents of timeIntervalUnitEdit as a double

app = getappdata(0, 'app');
unitString = get(handles.timeIntervalUnitEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change time interval unit to ' unitString]);

app.settings.timeIntervalUnit = unitString;


% --- Executes during object creation, after setting all properties.
function timeIntervalUnitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeIntervalUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in keepAllFramesRadioButton.
function keepAllFramesRadioButton_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to keepAllFramesRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keepAllFramesRadioButton
set(handles.selectImagesButton, 'Visible', 'On');

% make file selection widgets invisible
set(handles.firstFrameIndexLabel, 'Visible', 'Off');
set(handles.lastFrameIndexLabel, 'Visible', 'Off');
set(handles.frameIndexStepLabel, 'Visible', 'Off');
set(handles.firstFrameIndexEdit, 'Visible', 'Off');
set(handles.lastFrameIndexEdit, 'Visible', 'Off');
set(handles.frameIndexStepEdit, 'Visible', 'Off');

% select appropriate radio button
set(handles.keepAllFramesRadioButton, 'Value', 1);
set(handles.selectFrameIndicesRadioButton, 'Value', 0);

app = getappdata(0, 'app');
setProcessingStep(app, ProcessingStep.Selection);

guidata(hObject, handles);

% --- Executes on button press in selectFrameIndicesRadioButton.
function selectFrameIndicesRadioButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to selectFrameIndicesRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectFrameIndicesRadioButton
set(handles.selectImagesButton, 'Visible', 'On');

% make file selection widgets visible
set(handles.firstFrameIndexLabel, 'Visible', 'On');
set(handles.lastFrameIndexLabel, 'Visible', 'On');
set(handles.frameIndexStepLabel, 'Visible', 'On');
set(handles.firstFrameIndexEdit, 'Visible', 'On');
set(handles.lastFrameIndexEdit, 'Visible', 'On');
set(handles.frameIndexStepEdit, 'Visible', 'On');

% select appropriate radio button
set(handles.keepAllFramesRadioButton,'Value', 0);
set(handles.selectFrameIndicesRadioButton, 'Value', 1);

app = getappdata(0, 'app');
setProcessingStep(app, ProcessingStep.Selection);

guidata(hObject, handles);


function firstFrameIndexEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to firstFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstFrameIndexEdit as text
%        str2double(get(hObject,'String')) returns contents of firstFrameIndexEdit as a double

app = getappdata(0, 'app');
string = strtrim(get(hObject, 'String'));

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change first frame index to ' string]);

% convert string to valid index
val = parseValue(string);
val = max(val, 1);

% update app data
app.firstIndex = val;
setProcessingStep(app, ProcessingStep.Selection);

updateFrameSliderBounds(handles);
updateFramePreview(handles);


% --- Executes during object creation, after setting all properties.
function firstFrameIndexEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lastFrameIndexEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to lastFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lastFrameIndexEdit as text
%        str2double(get(hObject,'String')) returns contents of lastFrameIndexEdit as a double

app = getappdata(0, 'app');
string = strtrim(get(hObject, 'String'));

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change last frame index to ' string]);

val = parseValue(string);
nFiles = length(app.imageNameList);
val = min(val, nFiles);

app.lastIndex = val;
setProcessingStep(app, ProcessingStep.Selection);

updateFrameSliderBounds(handles);
updateFramePreview(handles);


% --- Executes during object creation, after setting all properties.
function lastFrameIndexEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frameIndexStepEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to frameIndexStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameIndexStepEdit as text
%        str2double(get(hObject,'String')) returns contents of frameIndexStepEdit as a double

string = strtrim(get(hObject, 'String'));

app = getappdata(0, 'app');
app.logger.info('SelectInputImagesDialog.m', ...
    ['Change frame index step to ' string]);

val = parseValue(string);

app.indexStep = val;
setProcessingStep(app, ProcessingStep.Selection);

updateFrameSliderBounds(handles);
updateFramePreview(handles);


% --- Executes during object creation, after setting all properties.
function frameIndexStepEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameIndexStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function val = parseValue(string)

if isempty(string)
    warning('empty string');
    string = '';
end

val = str2double(string);
if isnan(val)
    warning(['could not parse value: ' string]);
    val = 0;
end


function handles = updateFramePreview(handles)
% Determine the current frame from widgets, and display it

% extract app data
app = getappdata(0, 'app');

% extract global data
folderName  = app.inputImagesDir;
fileList = dir(fullfile(folderName, app.inputImagesFilePattern));

% ensure no directory is load (can happen under linux)
fileList = fileList(~[fileList.isdir]);

% determine indices of files to read
indices = app.firstIndex:app.indexStep:app.lastIndex;
frameNumber = length(indices);

% extract index of first frame to display
frameIndex = min(app.currentFrameIndex, length(indices));

% read sample image
if frameIndex > 0
    fileIndex = indices(frameIndex);
else
    fileIndex = 1;
end

currentImageName = fileList(fileIndex).name;
img = imread(fullfile(folderName, currentImageName));

% display current frame frame
if isfield(handles, 'currentFrameImage')
    set(handles.currentFrameImage, 'CData', img);
else
    axes(handles.currentFrameAxes);
    handles.currentFrameImage = imshow(img);
end

% display the index and name of current frame
string = sprintf('frame %d / %d (%s)', frameIndex, frameNumber, currentImageName);
set(handles.currentFrameLabel, 'String', string);


% --- Executes on button press in lazyLoadingCheckbox.
function lazyLoadingCheckbox_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to lazyLoadingCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lazyLoadingCheckbox

value = get(handles.lazyLoadingCheckbox, 'Value');
app = getappdata(0, 'app');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change lazy loading to ' char(value)]);

app.inputImagesLazyLoading = value > 0;


% --- Executes on slider movement.
function framePreviewSlider_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to framePreviewSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

app = getappdata(0, 'app');
frameIndex = round(get(handles.framePreviewSlider, 'Value'));
app.currentFrameIndex = frameIndex;

updateFramePreview(handles);


% --- Executes during object creation, after setting all properties.
function framePreviewSlider_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to framePreviewSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function updateFrameSliderBounds(handles)

% extract app data
app = getappdata(0, 'app');

% determine indices of files to read
indices = app.firstIndex:app.indexStep:app.lastIndex;
frameNumber = length(indices);

frameIndex = min(app.currentFrameIndex, frameNumber);

set(handles.framePreviewSlider, 'Visible', 'Off');
set(handles.framePreviewSlider, 'Value', frameIndex);
set(handles.framePreviewSlider, 'Min', 1);
set(handles.framePreviewSlider, 'Max', max(frameNumber, 1));
% setup slider such that 1 image is changed at a time
step1 = 1 / max(frameNumber, 1);
step2 = max(min(10 / frameNumber, .5), step1);
set(handles.framePreviewSlider, 'SliderStep', [step1 step2]);

if frameNumber > 1
    set(handles.framePreviewSlider, 'Visible', 'On');
end

%% Validation buttons

% --- Executes on button press in wholeWorkflowButton.
function wholeWorkflowButton_Callback(hObject, eventdata, handles)
% hObject    handle to wholeWorkflowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% extract global data
app = getappdata(0, 'app');
app.logger.info('SelectInputImagesDialog.m', ...
    'Compute the whole workflow');

computeAll(app);

delete(gcf);
DisplayKymograph(app);


% --- Executes on button press in selectImagesButton.
function selectImagesButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectImagesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% readAllImages();

% extract global data
app = getappdata(0, 'app');

computeImageNames(app);

nFrames = frameNumber(app);
app.currentFrameIndex = min(app.currentFrameIndex, nFrames);
delete(gcf);

ChooseThresholdDialog(app);

