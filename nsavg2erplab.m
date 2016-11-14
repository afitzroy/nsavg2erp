%{
NetStation GrandAverage import to ERPLab

This is most needed when you are trying to create plots using ERPLab plots
instead of plotting in NetStation.

This script only works with NetStation File Export 
    Format: MATLAB MAT-file
    Name: Replace Extension with ".mat"

You will need to know your epoch limits!

After running script and then loading your ERPset, you will need to give your ERPset 
file channel location information by:
    Go to ERPLAB -> Plot ERP -> Load ERP channel location info using EEG
    
    If you get a box "look up channel locations?" select cancel
    
    In the "edit channel info--popchanedit()" box select "read locations",
    which is bottom left
    
    Then, browse to Glacier_Storage -> GL_Lab_Business -> labcode
    ->GSN-HydroCel-129_mod_VREF.sfp and press open

    It will ask you to select a file format select "autodetect" press ok

    Channel information should be filled in now so Press "ok"

You are done! Happy plotting!
    
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