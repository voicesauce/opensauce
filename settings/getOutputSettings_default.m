function os  =  getOutputSettings()

% toggles: 0 = "off", 1 = "on"

% directory where output will be stored
os.OT_outputdir = 'tests/sounds/data';

% directory where textgrid files are stored
os.OT_Textgriddir = 'tests/sounds/textgrid';

% directory where .mat files are stored
os.OT_matdir = 'tests/sounds/out';

% toggle "output as single file"
os.asSingleFile = 0;
os.OT_Single = 'output.csv'; % output filename for single-file-dump (used iff asSingleFile == 1)

% toggle outputting with / without segments
os.OT_noSegments = 0;
os.OT_numSegments = 9; % number of segments to use; called iff noSegments == 0

% toggle "include textgrid labels"
os.OT_includeTextgridLabels = 1;


os.dirdelimiter = '/';
os.OT_selectedParams = [];
os.OT_includesubdir = 1;
os.OT_includeEGG = 0;
os.OT_EGGdir = './';
os.OT_columndelimiter = 1;
os.OT_useSegments = 1;
os.OT_singleFile = 1;
os.OT_multipleFiles = 1;
os.OT_singleFilename = 'output.csv';
os.OT_F0CPPEfilename = 'F0_CPP_E_HNR.csv';
os.OT_Formantsfilename = 'Formants.csv';
os.OT_Hx_Axfilename = 'HA.csv';
os.OT_HxHxfilename = 'HxHx.csv';
os.OT_HxAxfilename = 'HxAx.csv';
os.OT_EGGfilename = 'EGG.csv';
os.OT_F0CPPE = 'F0_CPP_E_HNR.csv';
os.OT_Formants = 'Formants.csv';
os.OT_HA = 'HA.csv';
os.OT_HxHx = 'HxHx.csv';
os.OT_HxAx = 'HxAx.csv';
os.OT_EGG = 'EGG.csv';
os.O_smoothwinsize = 20; % 0 denotes no smoothing

end