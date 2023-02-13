% matlab script to read in the json files for a platform and the attached
% sensors. A single json file is output

% The script will manage cases whrere a sensor or parameter are repeated
% In that case, a suffix will be chosen and added to the sensor and
% parameter names for that file

def_file = 'platdef-SBE-NAVIS_EBR-1101'; % root name for a platform definition text file and json output file
def_file_in = [def_file '.txt']; % this is a plain text list of json file names, which defines the float and its sensors
def_file_ot = [def_file '.json']; % The aggregated json is output to this file

created_by = 'BAK test';


% example of def_file contents might be
%
% % example of a platform definition that contains a platform file and 2 sensor files.
% % here is a second comment line
% platform-SBE-NAVIS_EBR-1101.json
% sensor-SBE-SBE41CP-11643.json
% sensor-RBR-RBR_ARGO3-205908.json suffix=2
%
% The definition file cna optionally request a suffix where it is known
% there are repeats of sensor or parameter names

fn_platform = {};
fn_sensors = {};
fid = fopen(def_file_in,'r');
while 1
    tline = fgetl(fid);
    if ~ischar(tline); break; end
    if strncmp('%',tline,1); continue; end % discard comment lines
    if strncmp('platform',tline,8)
        fn_platform = [fn_platform ; tline]; % expect only one of these
    end
    if strncmp('sensor',tline,6)
        fn_sensors = [fn_sensors ; tline];
    end
end
fclose(fid);


% read the platform json file

fnin = fn_platform{1};
fnin(strfind(fnin,' ')) = []; % remove any spaces in filename

fprintf(1,'%s %s\n','Reading',fnin)

fid = fopen(fnin);
raw = fread(fid,inf);
fclose(fid);

str = char(raw(:)');
jsplat = jsondecode(str);
platform_described = jsplat.info.platform_described;


% now read the sensor json files

num_sensorfiles = length(fn_sensors);

sufnumin = zeros(num_sensorfiles,1); % initialise array to store required suffix for multiple sensors. sufnumin is filled if a suffix is requested in the definition file
sufstrin = cell(num_sensorfiles,1);
sufnumot = zeros(num_sensorfiles,1); % initialise array to store required suffix for multiple sensors
sufstrot = cell(num_sensorfiles,1);

for kl = 1:num_sensorfiles
    fnin = fn_sensors{kl};

    % look for suffix instructions

    kmat = strfind(fnin,'suffix');
    if ~isempty(kmat)
        sufstrin{kl} = fnin(kmat:end);
        keq = strfind(sufstrin{kl},'=');
        sufstrin{kl} = sufstrin{kl}(keq+1:end);
        sufnumin(kl) = str2num(sufstrin{kl});

        fnin = fnin(1:kmat-1);
    end

    fnin(strfind(fnin,' ')) = []; % remove any spaces in filename
    fn_sensors{kl} = fnin;

    fprintf(1,'%s %s\n','Reading',fnin)

    fid = fopen(fnin,'r');
    raw = fread(fid,inf);
    fclose(fid);

    str = char(raw(:)');
    js = jsondecode(str);

    % keep a note of the length of the sensor and parameter names as read
    % in, to use when looking for multiple sensors
    num_s = length(js.SENSORS);
    num_p = length(js.PARAMETERS);

    jsall{kl} = js;
end

fprintf(1,'\n');

platformfields = fieldnames(jsplat.PLATFORMS);
sensorfields = fieldnames(jsall{1}.SENSORS);
parameterfields = fieldnames(jsall{1}.PARAMETERS);

% At this point, we expect the following fields to be present
% platformfields =
%     {'version'                             }
%     {'DATA_TYPE'                           }
%     {'POSITIONING_SYSTEM'                  }
%     {'PLATFORM_FAMILY'                     }
%     {'PLATFORM_TYPE'                       }
%     {'PLATFORM_MAKER'                      }
%     {'FIRMWARE_VERSION'                    }
%     {'FLOAT_SERIAL_NO'                     }
%     {'WMO_INST_TYPE'                       }
%     {'BATTERY_TYPE'                        }
%     {'BATTERY_PACKS'                       }
%     {'CONTROLLER_BOARD_TYPE_PRIMARY'       }
%     {'CONTROLLER_BOARD_SERIAL_NO_PRIMARY'  }
%     {'CONTROLLER_BOARD_TYPE_SECONDARY'     }
%     {'CONTROLLER_BOARD_SERIAL_NO_SECONDARY'}
% sensorfields =
%     {'SENSOR'          }
%     {'SENSOR_MAKER'    }
%     {'SENSOR_MODEL'    }
%     {'SENSOR_SERIAL_NO'}
%     {'SENSOR_FIRMWARE' }
% parameterfields =
%     {'PARAMETER'                       }
%     {'PARAMETER_SENSOR'                }
%     {'PARAMETER_UNITS'                 }
%     {'PARAMETER_ACCURACY'              }
%     {'PARAMETER_RESOLUTION'            }
%     {'PREDEPLOYMENT_CALIB_EQUATION'    }
%     {'PREDEPLOYMENT_CALIB_COEFFICIENT' }
%     {'PREDEPLOYMENT_CALIB_COEFFICIENTS'}
%     {'PREDEPLOYMENT_CALIB_COMMENT'     }
%     {'PREDEPLOYMENT_CALIB_DATE'        }

% now append all the sensor and parameter definitions
%
% If there is only one input file, no appending is needed
%
% If there are multiple sensor and parameter names that haven't already been
% taken care of by defining a suffix at the inpuut stage, take care of that
% below


clear SENSORS PARAMETERS
SENSORS = []; % empty to start with
PARAMETERS = [];
num_s = length(SENSORS);
num_p = length(PARAMETERS);

for kl = 1:num_sensorfiles

    % create a cell array of sensor and parameter names from all files read
    % before this one

    num_s = length(SENSORS);
    num_p = length(PARAMETERS);
    sensornames = {};
    paramnames = {};
    for ks = 1:num_s
        sensornames = [sensornames {SENSORS(ks).SENSOR}];
    end
    for kp = 1:num_p
        paramnames = [paramnames {PARAMETERS(kp).PARAMETER}];
    end



    js = jsall{kl}; % This is the new file definition being added
    % if any of the SENSORs or PARAMETERs already exist, we will need to
    % add a new unique suffix for this file
    S = js.SENSORS;
    P = js.PARAMETERS;
    numnew_s = length(S); % the number of sensors and parameters to be added from this file
    numnew_p = length(P);


    % This section of code should find the highest previous suffix for
    % either sensor or parameter names, and increase it by 1 if needed.
    % If any of the sensor or parameter names are found to have been used
    % before, then all the sensor and parameter names for the new file
    % get the new suffix.


    used_suffix_sensor = [];
    for ks = 1:numnew_s
        sname = S(ks).SENSOR; % This is the next sensor name
        snamelen = length(sname);
        kmat = find(strncmp(sname,sensornames,length(sname))); % find if this sensor name has been used before
        if length(kmat) > 0
            % This name, has been found before.
            % Find all previous instances of this sensor name
            for km = 1:length(kmat)
                oldname = sensornames{kmat(km)};
                suffixstr = oldname(snamelen+1:end); % find the chars after the sensor name
                if isempty(suffixstr)
                    suffixnum = 0;
                else
                    suffixnum = str2num(suffixstr);
                end
                used_suffix_sensor = [used_suffix_sensor suffixnum];
            end
        end
    end

    % used_suffix_sensior now contains the list of all suffixes previously
    % used for any sensors in this file

    used_suffix_param = [];
    for ks = 1:numnew_p
        pname = P(ks).PARAMETER;
        pnamelen = length(pname);
        kmat = find(strncmp(pname,paramnames,length(pname))); % find if this parameter name has been used before
        if length(kmat) > 0
            % This name, has been found before.
            % Find all previous instances of this sensor name
            for km = 1:length(kmat)
                oldname = paramnames{kmat(km)};
                suffixstr = oldname(pnamelen+1:end); % find the chars after the sensor name
                if isempty(suffixstr)
                    suffixnum = 0;
                else
                    suffixnum = str2num(suffixstr);
                end
                used_suffix_param = [used_suffix_param suffixnum];
            end
        end
    end

    % used_suffix_param now contains the list of all suffixes previously
    % used for any parameters in this file

    % Now decide whether to use a suffix for this file

    used_suffix_all = unique([used_suffix_sensor used_suffix_param]);
    requested_suffix = sufnumin(kl);
    min_available_suffix = min(setdiff([0 2:1000],used_suffix_all)); % zero corresponds to no suffix, 1 is never used, 2 is the first suffix for a replicate sensor or parameter

    % There are four possibilities now
    % 1) A suffix was requested and it is available, so use it
    % 2) A suffix was requested and it is not available, so use the lowest
    % available
    % 3) A suffix was not requested and is not needed, so no suffix used
    % 4) A suffix was not requetsed but one is needed, so use the next
    % available

    if requested_suffix > 1 % suffix requested, is it available
        if isempty(find(used_suffix_all == requested_suffix))
            % the requested suffix is available, use it
            sufnumot(kl) = requested_suffix;
        else
            % the requested suffix has already been used
            sufnumot(kl) = min_available_suffix;
        end
    else % suffix not requested
        if ~isempty(used_suffix_all)
            % sensor or parameter name has been used before, so find the
            % next available
            sufnumot(kl) = min_available_suffix;
        else
            sufnumot(kl) = 0; % empty suffix string
        end
    end

    if sufnumot(kl) == 0
        sufstrot{kl} = '';
        fprintf(1,'%s %40s\n','adding file',fn_sensors{kl})
    else
        sufstrot{kl} = sprintf('%d',sufnumot(kl));
        fprintf(1,'%s %40s %s %s\n','adding file',fn_sensors{kl},'with suffix',sufstrot{kl})
    end



    for ks = 1:numnew_s
        S(ks).SENSOR = [S(ks).SENSOR sufstrot{kl}];
    end

    for kp = 1:numnew_p
        P(kp).PARAMETER = [P(kp).PARAMETER sufstrot{kl}];
        P(kp).PARAMETER_SENSOR = [P(kp).PARAMETER_SENSOR sufstrot{kl}];
    end

    SENSORS = [SENSORS ; S];
    PARAMETERS = [PARAMETERS ; P];


end

clear allout
allout.PLATFORMS = jsplat.PLATFORMS;
allout.SENSORS = SENSORS;
allout.PARAMETERS = PARAMETERS;

% Add any metadata about the json file

allout.info.created_by = created_by;
allout.info.creation_date = datestr(now,'yyyy-mm-dd HH:MM:SS');
allout.info.contents = 'json file to describe a platform with sensors for Argo. v0.1 draft';
allout.info.platform_described = platform_described;

jsp = jsonencode(allout,'PrettyPrint',true);
jsp_struct = jsondecode(jsp);
jsp2 = jsonencode(jsp_struct,'PrettyPrint',true);

fid = fopen(def_file_ot,'w');
fprintf(fid,'%s\n',jsp2);
fclose(fid);