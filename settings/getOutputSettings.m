function os  =  getOutputSettings()

% toggles: 0 = "off", 1 = "on"

% directory where output will be stored
% if none specified, default is same directory as wav files
os.OT_outputdir = '~/test/analysis';

% directory where textgrid files are stored
%os.OT_Textgriddir = '~/vs-oct';

% directory where .mat files are stored
% os.OT_matdir = '~/vs-oct';

% toggle "output as single file"
os.asSingleFile = 0;
os.OT_Single = 'octave_output.csv'; % output filename for single-file-dump (used iff asSingleFile == 1)

% toggle outputting with / without segments
os.useSegments = 1;
os.OT_numSegments = 9; % number of segments to use; called iff noSegments == 0

% toggle "include textgrid labels"
os.OT_includeTextgridLabels = 0;

% EGG stuff
os.OT_includeEGG = 0;
os.OT_EGGdir = 'sounds';
os.OT_EGG = 'EGG.csv';

os.dirdelimiter = '/';
os.OT_selectedParams = [];
os.OT_includesubdir = 1;
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

% -- these are the filenames we actually use -- %
os.OT_F0CPPE = 'F0_CPP_E_HNR-OCT.csv';
os.OT_Formants = 'Formants-OCT.csv';
os.OT_HA = 'HA-OCT.csv';
os.OT_HxHx = 'HxHx-OCT.csv';
os.OT_HxAx = 'HxAx-OCT.csv';

os.O_smoothwinsize = 20; % 0 denotes no smoothing

end
