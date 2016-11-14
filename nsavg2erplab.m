%{
NetStation average import to ERPLAB

This script takes averaged ERPs (individual or grand average) generated within NetStation and converts them
to the .erp format used by ERPLAB. This process will then allow the use of ERPLAB functions to plot the
ERP data or take measurements on the waveforms.

To import NetStation data using this script, you must first export your data from NetStation using the
NetStation File Export tool. Use the following settings in the File Export tool:
    Format: MATLAB MAT-file
    Name: Replace Extension with ".mat"

To import the resulting .MAT format data into ERPLAB you will need to know your original epoch limits from
NetStation (e.g., -100 to 500 ms)!

After running this script and loading your ERPset, you will need to give your ERPset 
file channel location information before plotting. The specific method for doing so will
vary as a function of what cap style you used for data collection.

Happy plotting!
    
Author: Ahren Fitzroy (University of Massachusetts, Amherst)
%}

function [] = nsavg2erplab()

%Load mat file here
[erpfn erpfolder] = uigetfile('*.mat', 'Pick which averaged ERP .mat file exported from NetStation to import into ERPLAB:');
cd(erpfolder);
load([erpfolder erpfn]);

%Find epoch times here
epochlims = str2num(cell2mat(inputdlg('What are the start and end times of your ERP epoch (e.g. [-100 600])?', 'Epoch limits')));

list = who();

count = 1;
for cur = 1:length(list);
    if isnumeric(eval(list{cur}))
        bins{count} = list{cur};
        count = count + 1;
    end
end

[c, ia, ib] = intersect(bins, {'ans', 'cur', 'samplingRate',...
    'epochlims', 'c', 'ia', 'ib', 'count'});
bins = bins(setdiff(1:length(bins), ia));

[outfn outfolder] = uiputfile([strrep(erpfn, '.mat', '') '.erp'], 'Where to save output .erp file?');

ERP.erpname = strrep(erpfn, '.mat', '');
ERP.filename = outfn;
ERP.filepath = outfolder;
ERP.workfiles = {};
ERP.subject = '';
ERP.nchan = size(eval(bins{1}),1);
ERP.nbin = length(bins);
ERP.pnts = size(eval(bins{1}),2);
ERP.srate = samplingRate;
ERP.xmin = epochlims(1);
ERP.xmax = epochlims(2);
ERP.times = ERP.xmin:(1000/ERP.srate):ERP.xmax;
ERP.bindata = [];
for bin = 1:length(bins)
    ERP.bindata(:,:,bin) = eval(bins{bin}); %bindata is chan x samp x bin
end
ERP.binerror = [];
ERP.datatype = 'ERP';
ERP.ntrials = [];
ERP.ntrials.accepted = zeros(1,ERP.nbin);
ERP.ntrials.rejected = zeros(1,ERP.nbin);
ERP.pexcluded = [];
ERP.isfilt = [];
ERP.chanlocs = [];
ERP.ref = '';
ERP.bindescr = bins;
ERP.saved = '';
ERP.history = [];
ERP.version = '';
ERP.splinefile = '';
ERP.EVENTLIST = [];

for ch = 1:ERP.nchan
    ERP.chanlocs(ch).labels = '';
    ERP.chanlocs(ch).ref = ERP.ref;
    ERP.chanlocs(ch).y = [];
    ERP.chanlocs(ch).x = [];
    ERP.chanlocs(ch).z = [];
    ERP.chanlocs(ch).sph_theta = [];
    ERP.chanlocs(ch).sph_phi = [];
    ERP.chanlocs(ch).sph_radius = [];
    ERP.chanlocs(ch).theta = [];
    ERP.chanlocs(ch).radius = [];
    ERP.chanlocs(ch).type = '';
    ERP.chanlocs(ch).urchan = [];
end

save([outfolder outfn], 'ERP');

end
