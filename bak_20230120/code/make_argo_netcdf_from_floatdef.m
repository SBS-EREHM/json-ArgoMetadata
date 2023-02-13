% Matlab script to get everything ready for an Argo NetCDF meta file,
% starting with a floatdef json file that contains info about platform,
% sensors and parameters
%
% platform metadata are those that could be supplied by the platform maker, ie not mission specific.
%
% draft by BAK 20 Jan 2023
%

% First call a progam to create all the empty spaces for a complete argo
% nectdf meta file. This creates a structure m, which has all the needed
% fields.

make_empty_argo_meta

% Define the fields we expect to read if from a floatdef json file.
% These are matched up with the dimensions defined by the Argo users manual

fnin = 'platdef-SBE-NAVIS_EBR-1101.json';
ncfile = 'platdef-SBE-NAVIS_EBR-1101.nc';

fid = fopen(fnin);
raw = fread(fid,inf);
fclose(fid);

str = char(raw(:)');
js = jsondecode(str);



clear def

def.platform_argo_fields = {
    16  'DATA_TYPE'
    8   'POSITIONING_SYSTEM' % can be more than one. If more than one,
    % it will need some sort of dimension
    % maybe do transmission system here too
    256 'PLATFORM_FAMILY'
    32  'PLATFORM_TYPE'
    256 'PLATFORM_MAKER'
    32  'FIRMWARE_VERSION'
    32  'FLOAT_SERIAL_NO'
    4   'WMO_INST_TYPE'
    64  'BATTERY_TYPE'
    64  'BATTERY_PACKS'
    32  'CONTROLLER_BOARD_TYPE_PRIMARY'
    32  'CONTROLLER_BOARD_SERIAL_NO_PRIMARY'
    32  'CONTROLLER_BOARD_TYPE_SECONDARY'
    32  'CONTROLLER_BOARD_SERIAL_NO_SECONDARY'
    };

def.platform_nonargo_fields = {
    };

def.sensor_argo_fields = {
    32  'SENSOR'
    256 'SENSOR_MAKER'
    256 'SENSOR_MODEL'
    16  'SENSOR_SERIAL_NO'
    };

def.sensor_nonargo_fields = {
    'SENSOR_FIRMWARE' % not an argo field
    };

def.parameter_argo_fields = {
    64 'PARAMETER'
    128 'PARAMETER_SENSOR'
    32 'PARAMETER_UNITS'
    32 'PARAMETER_ACCURACY'
    32 'PARAMETER_RESOLUTION'
    4096 'PREDEPLOYMENT_CALIB_EQUATION'
    4096 'PREDEPLOYMENT_CALIB_COEFFICIENT'
    4096  'PREDEPLOYMENT_CALIB_COMMENT'
    };

def.parameter_nonargo_fields ={
    'PREDEPLOYMENT_CALIB_DATE' % not an argo field
    'PREDEPLOYMENT_CALIB_COEFFICIENTS' % a structure
    };


% Now write the metadata from json into the m structure

fields = def.platform_argo_fields;
nfield = size(fields,1);
for kl = 1:nfield
    fieldname = fields{kl,2};
    fieldlen = fields{kl,1};
    value = js.PLATFORMS.(fieldname);
    value = [value repmat(' ',1,fieldlen-length(value))];
    m.(fieldname) = value;
end


fields = def.sensor_argo_fields;
nfield = size(fields,1);
for kl = 1:nfield
    fieldname = fields{kl,2};
    fieldlen = fields{kl,1};
    num_s = length(js.SENSORS);
%     for ks = 1:num_s
%         value = js.SENSORS(ks).(fieldname);
%         value = [value repmat(' ',1,fieldlen-length(value))];
%         m.(fieldname)(ks,:) = value;
%     end
    varval = {js.SENSORS.(fieldname)};
    m.fieldname = char(cellfun(@(x) [x repmat(' ', 1, fieldlen-numel(x))], varval, 'UniformOutput', false));
end




fields = def.parameter_argo_fields;
nfield = size(fields,1);
for kl = 1:nfield
    fieldname = fields{kl,2};
    fieldlen = fields{kl,1};
    num_p = length(js.PARAMETERS);
    for kp = 1:num_p
        value = js.PARAMETERS(kp).(fieldname);
        value = [value repmat(' ',1,fieldlen-length(value))];
        m.(fieldname)(kp,:) = value;
    end
end

% The strcuture m is now ready to haev its fields written to an Argo NetCDF
% meta file, using whatever NetCDF toolbox you like

n.N_SENSOR = size(m.SENSOR,1);
n.N_PARAM = size(m.PARAMETER,1);


ncid = netcdf.create(ncfile,'CLOBBER');
% dimensions of strings

dimnamesd = fieldnames(d);
numdimd = length(dimnamesd)
dimidsd = nan(numdimd,1);
for kl = 1:numdimd
    dimname = dimnamesd{kl};
    dimval = d.(dimname);
    dimidsd(kl) = netcdf.defDim(ncid,dimname,dimval);
end

% other dimensions

dimnamesn = fieldnames(n);
numdimn = length(dimnamesn)
dimidsn = nan(numdimn,1);
for kl = 1:numdimn
    dimname = dimnamesn{kl};
    dimval = n.(dimname);
    dimidsn(kl) = netcdf.defDim(ncid,dimname,dimval);
end

%variables

varnames = fieldnames(m);
numvar = length(varnames)
varids = nan(numvar,1);

netcdf.endDef(ncid);

for kl = 1:numvar
    varname = varnames{kl};
    varval = m.(varname);
    varsize = size(varval);



    if strcmp('FIRMWARE_VERSION',varname)
        varval = [varval repmat(' ',1,1000)];
        varval = varval(1:32);
        varsize = size(varval);
    end

    if strncmp('SENSOR',varname,6)
        dimid1 = netcdf.inqDimID(ncid,'N_SENSOR');
        required_stringdim = ['STRING' sprintf('%d',varsize(2))];
        dimid2 = netcdf.inqDimID(ncid,required_stringdim);
    elseif strncmp('PARAMETER',varname,9)
        dimid1 = netcdf.inqDimID(ncid,'N_PARAM');
        required_stringdim = ['STRING' sprintf('%d',varsize(2))];
        dimid2 = netcdf.inqDimID(ncid,required_stringdim);
    elseif strncmp('PREDEPLOYMENT',varname,13)
        dimid1 = netcdf.inqDimID(ncid,'N_PARAM');
        required_stringdim = ['STRING' sprintf('%d',varsize(2))];
        dimid2 = netcdf.inqDimID(ncid,required_stringdim);
    else
        dimid1 = [];
        required_stringdim = ['STRING' sprintf('%d',varsize(2))];
        try dimid2 = netcdf.inqDimID(ncid,required_stringdim);
        catch
            dimid2 = netcdf.inqDimID(ncid,'DATE_TIME');
        end

    end

    % MATLAB = Column major arrays, netCDF = Row major arrays
    netcdf.reDef(ncid);
%     varids(kl) = netcdf.defVar(ncid,varname,2,[dimid1 dimid2]); % data type 2 is 'nc_char'
    varids(kl) = netcdf.defVar(ncid,varname,2,fliplr([dimid1 dimid2])); % data type 2 is 'nc_char'  %ECRFIX move from column major to row major ordering
    netcdf.endDef(ncid);
   try  netcdf.putVar(ncid,varids(kl),permute(varval, [2 1]));   %ECRFIX same comment as above
   catch 
%        keyboard
   end


end


netcdf.close(ncid)

% this doesnt work yet with the few meta parameteres that are double
% values instead of char, eg lat and lon


