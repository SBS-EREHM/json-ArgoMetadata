% simple example, to get started


PLATFORMS.version = ' ';
PLATFORMS.DATA_TYPE = 'Argo meta-data';
PLATFORMS.POSITIONING_SYSTEM = 'GPS';
PLATFORMS.PLATFORM_FAMILY = 'FLOAT';
PLATFORMS.PLATFORM_TYPE = 'NAVIS_EBR';
PLATFORMS.PLATFORM_MAKER = 'SBE';
PLATFORMS.FIRMWARE_VERSION = 'BGCi_OPTOx_MCOM_SUNA_PH_ICE_EXP 210521';
PLATFORMS.FLOAT_SERIAL_NO = '1101';
PLATFORMS.WMO_INST_TYPE = '863';
PLATFORMS.BATTERY_TYPE = 'ELECTROCHEM Lithium 15.0 V';
PLATFORMS.BATTERY_PACKS = '3DD Li';
PLATFORMS.CONTROLLER_BOARD_TYPE_PRIMARY = 'NAVIS N1';
PLATFORMS.CONTROLLER_BOARD_SERIAL_NO_PRIMARY = '00000';
PLATFORMS.CONTROLLER_BOARD_TYPE_SECONDARY = ' ';
PLATFORMS.CONTROLLER_BOARD_SERIAL_NO_SECONDARY = ' ';

% Test case

platform_maker = 'SBE';
platform_type = 'NAVIS_EBR';
platform_ser_no = '1101';

created_by = 'BAK test';  % as defined by platform maker


platform_described = [platform_maker '-' platform_type '-' platform_ser_no];


fnout = ['platform-' platform_maker '-' platform_type '-' platform_ser_no '.json' ];

clear allout
allout.PLATFORMS = PLATFORMS;

% Add any metadata about the json file
allout.info.created_by = created_by;
allout.info.creation_date = datestr(now,'yyyy-mm-dd HH:MM:SS');
allout.info.contents = 'json file to describe a platform for Argo. v0.1 draft';
allout.info.platform_described = platform_described;

jsp = jsonencode(allout,'PrettyPrint',true);
jsp_struct = jsondecode(jsp);
jsp2 = jsonencode(jsp_struct,'PrettyPrint',true);

fid = fopen(fnout,'w');
fprintf(fid,'%s\n',jsp2);
fclose(fid);