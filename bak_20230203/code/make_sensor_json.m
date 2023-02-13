% This Matlab script is intended to make a json file to store metadata
% about a single sensor on an Argo float.
%
% This draft by Brian King, January 2023.
%
% The intention is to merge efforts already undertaken by RBR and SeaBird
%
% The suggestion is that metadata can be provided for a float deployment in
% 3 files, or sets of files:
% (1) Argo metadata about the float deployment and mission (one file per
% float)
% (2) Data about the platform (one file per float)
% (3) Data about the sensors (one file per sensor)
%
% Each platform or sensor file can be compiled separately. The metadata for a float will
% consist of a platform json file, and a collection of sensor json files.
% For a BGC float, the sensor json files might describe sensors from
% several different sensor makers. It is therefore highly desirable to users and data centres if all
% the sensor makers provide consistent sensor metadata in json format. So
% far, at least RBR and SeaBird have expressed willingness to work towards
% this.
%
% I envisage a script that would load a platform json file and a collection
% of one or more sensor json files, and append the sensor metadata to create a
% single Argo meta NetCDF file.

% I propose the json files be stored with filenames that are easy to read
% and sort consisting of
%
% sensor_<sensor_maker>_<sensor_model>_<serial_number>.json
% platform_<platform_maker>_<platform_type>_<serial_number>.json

% There are controlled vocabulary tables for (table_number:argo_name)
% 22:PLATFORM_FAMILY
% 23:PLATFORM_TYPE
% 24:PLATFORM_MAKER
% 25:SENSOR
% 26:SENSOR_MAKER
% 27:SENSOR_MODEL
%
% At any time, the current list of recognised names can be found at
% http://tinyurl.com/nwpqvp2



% On 19 Jan 2023 the list of SENSORs was
% SENSOR
% ACOUSTIC
% ACOUSTIC_GEOLOCATION
% CTD_PRES
% CTD_TEMP
% CTD_CNDC
% EM
% FLUOROMETER_CDOM
% FLUOROMETER_CHLA
% IDO_DOXY
% OPTODE_DOXY
% RADIOMETER_DOWN_IRR<nnn>
% RADIOMETER_PAR
% RADIOMETER_UP_RAD<nnn>
% BACKSCATTERINGMETER_BBP<nnn>
% BACKSCATTERINGMETER_TURBIDITY
% SPECTROPHOTOMETER_NITRATE
% SPECTROPHOTOMETER_BISULFIDE
% STS_CNDC
% STS_TEMP
% TRANSISTOR_PH
% TRANSMISSOMETER_CP<nnn>
% FLOATCLOCK_MTIME
%
% On 19 Jan 2023 the list of SENSOR_MAKERs was
%
% SENSOR_MAKER
% AANDERAA
% AMETEK
% DRUCK
% FSI
% KISTLER
% PAINE
% SBE
% SEASCAN
% WETLABS
% MBARI
% SATLANTIC
% JAC
% APL_UW
% TSK
% RBR
% Unknown
% KELLER
% MICRON
% SEAPOINT
% TURNER_DESIGN
%
% On 19 Jan 2023 the list of SENSOR_MODELs included around 150
% possibilities, too many to usefully list here.


% The sample json file provided by SeaBird had space for SENSOR_FIRMWARE.
% I'm not sure that's a recognised Argo thing yet, but at least let us make
% space for it in the json files for the time being.

% I have tried to create two examples, based on samle json files provided
% by sensor makers, for a SBE41 CTD and a RBR CTD. Also a 'blank' file.

% sensor = 'blank';
sensor = 'sbe41cp';
sensor = 'rbrargo3';
sensor = 'aanderaaoptode';


% generally for a single sensor, N_SENSOR = 1; But for a SBE41 CTD,
% N_SENSOR = 3, because P,T,S are entered as separate sensors. So a single
% SBE41 CTD unit provides 3 'SENSOR's and 3 'PARAMETER's.
% For other sensors, eg DO optode, one sensor can send multiple parameters

switch sensor
    case 'sbe41cp'
        N_SENSOR = 3;
        N_PARAM = 3;

    case 'rbrargo3'
        N_SENSOR = 4;
        N_PARAM = 4;

    case 'aanderaaoptode'
        N_SENSOR = 1;
        N_PARAM = 5;

    otherwise
        N_SENSOR = 1;
        N_PARAM = 1;

end

% initialise arrays

clear SENSORS
for kl = 1:N_SENSOR
    SENSORS(kl).SENSOR = '';
    SENSORS(kl).SENSOR_MAKER = '';
    SENSORS(kl).SENSOR_MODEL = '';
    SENSORS(kl).SENSOR_SERIAL_NO = '';
    SENSORS(kl).SENSOR_FIRMWARE = '';
    SENSORS(kl).sensor_vendorinfo.example = '';
end

clear PARAMETERS
for kl = 1:N_PARAM
    PARAMETERS(kl).PARAMETER = '';
    PARAMETERS(kl).PARAMETER_SENSOR = '';
    PARAMETERS(kl).PARAMETER_UNITS = '';
    PARAMETERS(kl).PARAMETER_ACCURACY = '';
    PARAMETERS(kl).PARAMETER_RESOLUTION = '';
    PARAMETERS(kl).PREDEPLOYMENT_CALIB_EQUATION = '';
    PARAMETERS(kl).PREDEPLOYMENT_CALIB_COEFFICIENT = '';
    PARAMETERS(kl).PREDEPLOYMENT_CALIB_COEFFICIENTS = '';
    PARAMETERS(kl).PREDEPLOYMENT_CALIB_COMMENT = '';
    PARAMETERS(kl).PREDEPLOYMENT_CALIB_DATE = '';
    PARAMETERS(kl).parameter_vendorinfo.example = '';
    PARAMETERS(kl).predeployment_vendorinfo.example = '';
end



% set up defaults for PARAMETERS


switch sensor
    case 'sbe41cp'
        created_by = 'BAK test';  % as defined by sensor maker

        % names for output files
        sensor_maker = 'SBE';
        sensor_model = 'SBE41CP';
        sensor_sno = '11643';

        sensor_described = [sensor_maker '-' sensor_model '-' sensor_sno];

        % How should we handle CTD serial numbers for SBE41 ?
        % The example json provided by SBS had a CTDSN of 11643, but the
        % SENSOR_SERIAL_NO recorded alongside the SENSORs had s/n 11698373
        % for the pressure and 13875 for the C-T pair.
        % I think the SBS cal sheet gives the 'CTDSN', which is common to
        % the PRES, TEMP, CNDC sensors. The SBS cal sheet also gives the
        % PRES SERIAL NUMBER, but not the C-T pair numbers that were
        % included in the SBS example json file.


        N_SENSOR = 3;
        N_PARAM = 3;

        SENSORS(1).SENSOR = 'CTD_PRES';
        SENSORS(1).SENSOR_MAKER = 'DRUCK';
        SENSORS(1).SENSOR_MODEL = 'DRUCK_2900PSIA';
        SENSORS(1).SENSOR_SERIAL_NO = '11698373';
        SENSORS(1).SENSOR_FIRMWARE = ' ';
        SENSORS(1).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        SENSORS(2).SENSOR = 'CTD_TEMP';
        SENSORS(2).SENSOR_MAKER = 'SBE';
        SENSORS(2).SENSOR_MODEL = 'SBE41CP'; % This could be a more detailed model from the table of models
        SENSORS(2).SENSOR_SERIAL_NO = '13875'; % CTD serial number or T-C sensor pair number ?
        SENSORS(2).SENSOR_FIRMWARE = ' ';
        SENSORS(2).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        SENSORS(3).SENSOR = 'CTD_CNDC';
        SENSORS(3).SENSOR_MAKER = 'SBE';
        SENSORS(3).SENSOR_MODEL = 'SBE41CP';
        SENSORS(3).SENSOR_SERIAL_NO = '13875';
        SENSORS(3).SENSOR_FIRMWARE = ' ';
        SENSORS(3).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        PARAMETERS(1).PARAMETER = 'PRES';
        PARAMETERS(1).PARAMETER_SENSOR = 'CTD_PRES';
        PARAMETERS(1).PARAMETER_UNITS = 'decibar';
        PARAMETERS(1).PARAMETER_ACCURACY = '2.4';
        PARAMETERS(1).PARAMETER_RESOLUTION = '0.1';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_EQUATION = 'y = thermistor_output; t = PTHA0 + PTHA1 * y + PTHA2 * y^2; x = pressure_output - PTCA0 - PTCA1 * t - PTCA2 * t^2; n = x * PTCB0 / (PTCB0 + PTCB1 * t + PTCB2 * t^2); pressure = PA0 + PA1 * n + PA2 * n^2;';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENT = '     PA0 = -9.688915E-01,     PA1 =  1.403562E-01,     PA2 = -4.016801E-08,   PTCA0 =  3.569194E+01,   PTCA1 = -3.100399E-01,   PTCA2 =  4.930107E-04,   PTCB0 =  2.519888E+01,   PTCB1 = -6.250000E-04,   PTCB2 =  0.000000E+00,   PTHA0 = -7.086474E+01,   PTHA1 =  5.159523E-02,   PTHA2 = -5.051388E-07,  POFFSET =  0.000000E+0,';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PA0 = ' -1.860485e-001';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PA1 = ' 3.913091e-004';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PA2 = '-2.833018e-013';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTCA0 = '6.794577e+003';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTCA1 = '-9.846636e+000';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTCA2 = '-6.839699e-001';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTCB0 = '3.203647e+005';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTCB1 = '2.935842e+001';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTCB2 = '-5.287902e-001';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTHA0 = '-8.015838e+001';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTHA1 = '4.998022e-002';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.PTHA2 = '-4.733751e-007';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COMMENT = 'Pressure Calibration Date              2021-03-31';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_DATE = '20210331000000'; % use argo date14
        PARAMETERS(1).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(1).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(2).PARAMETER = 'TEMP';
        PARAMETERS(2).PARAMETER_SENSOR = 'CTD_TEMP';
        PARAMETERS(2).PARAMETER_UNITS = 'degree_Celsius';
        PARAMETERS(2).PARAMETER_ACCURACY = '0.002';
        PARAMETERS(2).PARAMETER_RESOLUTION = '0.001';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_EQUATION = 'Temperature ITS-90 = 1/{a0 + a1[ln(n)] + a2[ln(n)^2] + a3[ln(n)^2]} - 273.15; n = instrument output;';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENT = '     TA0 =  -8.716632e-004,     TA1 =  2.937892e-004,     TA2 = -3.758125e-006,     TA3 =  1.520066e-007,';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.a0 = '-8.716632e-004';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.a1 = ' 2.937892e-004';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.a2 = '-3.758125e-006';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.a3 = ' 1.520066e-007';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COMMENT = 'Temperature Calibration Date           2021-03-31';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_DATE = '20210331000000'; % use argo date14
        PARAMETERS(2).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(2).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(3).PARAMETER = 'PSAL';
        PARAMETERS(3).PARAMETER_SENSOR = 'CTD_CNDC';
        PARAMETERS(3).PARAMETER_UNITS = 'psu';
        PARAMETERS(3).PARAMETER_ACCURACY = '0.005';
        PARAMETERS(3).PARAMETER_RESOLUTION = '0.001';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_EQUATION = 'f=INST_FREQ*sqrt(1.0+wBOTC*t)/1000.0;Conductivity=(g+h*f^2+i*f^3+j*f^4)/(1+delta*t+epsilon*p) Siemens/meter;t=temperature[degC];p=pressure[dbar];delta=CTcor;epsilon=CPcor;         ';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENT = '       g = -1.023943e+000,       h =  1.465505e-001,       i = 2.806563e-004,       j =  4.044779e-005,   CPcor = -9.570001E-08,   CTcor =  3.250000E-06,   WBOTC =  3.1475e-008,       ';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.g = '-1.023943e+000';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.h = ' 1.465505e-001';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.i = '-2.806563e-004';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.j = ' 4.044779e-005';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.CPcor = '-9.5700e-008';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.CTcor = '3.2500e-006';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.WBOTC = ' 3.1475e-008';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COMMENT = 'Conductivity Calibration Date          2021-03-31';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_DATE = '20210331000000'; % use argo date14
        PARAMETERS(3).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(3).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';



        % notes and queries
        %
        % The calib info is dimensioned on N_PARAM, not N_SENSOR
        %
        % 1) PARAMETER_SENSOR for PSAL is usually given the value CTD_CNDC
        % 2) Argo metadata expects all the calib coeffs to be put in a
        % string in PREDEPLOYMENT_CALIB_COEFFICIENT. We probably have to
        % continue to do this. But having a structure with fieldnames and
        % real values, saves DACs from having to parse a character string.
        % I introduced the structure PREDEPLOYMENT_CALIB_COEFFICIENTS
        % (added final character 'S'. We can use this in the json files,
        % even if it doesn't become an Argo thing.
        % 3) The calib date is included as a string in the calib comment
        % field. Identifying it in a field called CALIB_DATE in a recognised date format seems more
        % sensible. This isn't an argo thing yet, but we can put it into
        % these json files now. The relevant date is the date of the
        % calibration of the sensor referred to in PARAMETER_SENSOR



    case 'rbrargo3'
        created_by = 'BAK test'; % as defined by sensor maker

        sensor_maker = 'RBR';
        sensor_model = 'RBR_ARGO3';
        sensor_sno = '205908';

        sensor_described = [sensor_maker '-' sensor_model '-' sensor_sno];

        N_SENSOR = 4;
        N_PARAM = 4;

        SENSORS(1).SENSOR = 'CTD_PRES';
        SENSORS(1).SENSOR_MAKER = 'RBR';
        SENSORS(1).SENSOR_MODEL = 'RBR_PRES_A';
        SENSORS(1).SENSOR_SERIAL_NO = '205908';
        SENSORS(1).SENSOR_FIRMWARE = ' ';
        SENSORS(1).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        SENSORS(2).SENSOR = 'CTD_TEMP';
        SENSORS(2).SENSOR_MAKER = 'RBR';
        SENSORS(2).SENSOR_MODEL = 'RBR_ARGO3';
        SENSORS(2).SENSOR_SERIAL_NO = '205908';
        SENSORS(2).SENSOR_FIRMWARE = ' ';
        SENSORS(2).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        SENSORS(3).SENSOR = 'CTD_CNDC';
        SENSORS(3).SENSOR_MAKER = 'RBR';
        SENSORS(3).SENSOR_MODEL = 'RBR_ARGO3';
        SENSORS(3).SENSOR_SERIAL_NO = '205908';
        SENSORS(3).SENSOR_FIRMWARE = ' ';
        SENSORS(3).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        SENSORS(4).SENSOR = 'CTD_TEMP_CNDC'; % I don't think this is an accepted SENSOR. Is it an extra parameetr from the CTD_CNDC sensor ?
        SENSORS(4).SENSOR_MAKER = 'RBR';
        SENSORS(4).SENSOR_MODEL = 'RBR_ARGO3';
        SENSORS(4).SENSOR_SERIAL_NO = '205908';
        SENSORS(4).SENSOR_FIRMWARE = ' ';
        SENSORS(4).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        PARAMETERS(1).PARAMETER = 'PRES';
        PARAMETERS(1).PARAMETER_SENSOR = 'CTD_PRES';
        PARAMETERS(1).PARAMETER_UNITS = 'dbar';
        PARAMETERS(1).PARAMETER_ACCURACY = '1';
        PARAMETERS(1).PARAMETER_RESOLUTION = '0.02';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_EQUATION = 'Pcorr = X0+(Pmeas-X0-X1*(Tpres-X5)-X2*(Tpres-X5)^2-X3*(Tpres-X5)^3)/(1+X4*(Tpres-X5)); Pmeas = C0+C1*VR+C2*VR^2+C3*VR^3;';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENT = 'C0 = -55.76767, C1 = 4.0054912E3, C2 = -66.53745, C3 = 6.39357, X0 = 10.0361, X1 = 184.89905E-3, X2 = 330.90703E-6, X3 = -999.3263E-9, X4 = -86.53429E-6, X5 = 21.942171';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.C0 = '-55.76767';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.C1 = '4.0054912E3';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.C2 = '-66.53745';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.C3 = '6.39357';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.X0 = '10.0361';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.X1 = '184.89905E-3';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.X2 = '330.90703E-6';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.X3 = '-999.3263E-9';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.X4 = '-86.53429E-6';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.X5 = '21.942171';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COMMENT = 'Pressure Calibration Date              2020-12-03';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_DATE = '20201203000000'; % use argo date14
        PARAMETERS(1).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(1).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(2).PARAMETER = 'TEMP';
        PARAMETERS(2).PARAMETER_SENSOR = 'CTD_TEMP';
        PARAMETERS(2).PARAMETER_UNITS = 'degC (ITS-90)';
        PARAMETERS(2).PARAMETER_ACCURACY = '0.002';
        PARAMETERS(2).PARAMETER_RESOLUTION = '0.00005';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_EQUATION = 'Temperature = 1/(C0+C1*ln(1/VR-1)+C2*ln(1/VR-1)^2+C3*ln(1/VR-1)^3)-273.15;';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENT = 'C0 = 3.4669158E-3, C1 = -249.6654E-6, C2 = 2.4878973E-6, C3 = -60.271525E-9';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.C0 = '3.4669158E-3';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.C1 = '-249.6654E-6';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.C2 = '2.4878973E-6';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.C3 = '-60.271525E-9';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COMMENT = 'Temperature Calibration Date           2020-12-02';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_DATE = '20201202000000'; % use argo date14
        PARAMETERS(2).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(2).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(3).PARAMETER = 'PSAL';
        PARAMETERS(3).PARAMETER_SENSOR = 'CTD_CNDC';
        PARAMETERS(3).PARAMETER_UNITS = 'psu';
        PARAMETERS(3).PARAMETER_ACCURACY = '0.003';
        PARAMETERS(3).PARAMETER_RESOLUTION = '0.001';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_EQUATION = 'Salinity = PSS-78 (Temperature, Ccorr, Hydrostatic Pressure); Ccorr = (Cmeas-X0*(Tcond-X5))/(1+ X1*(Tcond-X5)+X2*(Pcorr-X6)+X3*(Pcorr-X6)^2+X4*(Pcorr-X6)^3); Cmeas = C0+C1*C2*VR;';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENT = 'C0 = 46.48405E-3, C1 = 152.28053, C2 = 1.0, X0 = 1.1667822E-3, X1 = 70.142356E-9, X2 = 1.8732E-6, X3 = -776.89E-12, X4 = 148.9E-15, X5 = 15.001777, X6 = 10';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.C0 = '46.48405E-3';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.C1 = '152.28053';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.C2 = '1.0';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.X0 = '1.1667822E-3';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.X1 = '70.142356E-9';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.X2 = '1.8732E-6';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.X3 = '-776.89E-12';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.X4 = '148.9E-15';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.X5 = '15.001777';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.X6 = '10';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COMMENT = 'Conductivity Calibration Date          2020-12-09';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_DATE = '20201209000000'; % use argo date14
        PARAMETERS(3).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(3).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(4).PARAMETER = 'TEMP_CNDC';
        PARAMETERS(4).PARAMETER_SENSOR = 'CTD_TEMP_CNDC'; % Only if it is agreed that this allowed
        PARAMETERS(4).PARAMETER_UNITS = 'degC (ITS-90)';
        PARAMETERS(4).PARAMETER_ACCURACY = '0.1';
        PARAMETERS(4).PARAMETER_RESOLUTION = '0.06';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_EQUATION = 'Temperature = 1/(C0+C1*ln(1/VR-1)+C2*ln(1/VR-1)^2+C3*ln(1/VR-1)^3)-273.15;';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENT = 'C0 = 3.1201642E-3, C1 = -285.56594E-6, C2 = 316.32993E-9, C3 = -1.0767272E-6';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C0 = '3.1201642E-3';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C1 = '-285.56594E-6';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C2 = '316.32993E-9';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C3 = '-1.0767272E-6';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COMMENT = 'Temperature_Conductivity Calibration Date          2020-12-02';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_DATE = '20201202000000'; % use argo date14
        PARAMETERS(4).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(4).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

    case 'aanderaaoptode'
        created_by = 'BAK test'; % as defined by sensor maker . test data loaded from 4903634

        sensor_maker = 'AANDERAA';
        sensor_model = 'AANDERAA_OPTODE_4330';
        sensor_sno = '3901';

        sensor_described = [sensor_maker '-' sensor_model '-' sensor_sno];

        N_SENSOR = 1;
        N_PARAM = 5;

        SENSORS(1).SENSOR = 'OPTODE_DOXY';
        SENSORS(1).SENSOR_MAKER = 'AANDERAA';
        SENSORS(1).SENSOR_MODEL = 'AANDERAA_OPTODE_4330';
        SENSORS(1).SENSOR_SERIAL_NO = '3901';
        SENSORS(1).SENSOR_FIRMWARE = ' ';
        SENSORS(1).sensor_vendorinfo.example = 'Vendors can add their own sensor info here; they can add any field they like as a fieldname below sensor_vendorinfo';

        PARAMETERS(1).PARAMETER = 'C1PHASE_DOXY';
        PARAMETERS(1).PARAMETER_SENSOR = 'OPTODE_DOXY';
        PARAMETERS(1).PARAMETER_UNITS = 'degree';
        PARAMETERS(1).PARAMETER_ACCURACY = ' ';
        PARAMETERS(1).PARAMETER_RESOLUTION = ' ';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_EQUATION = 'none';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENT = 'none';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COEFFICIENTS.A = 'n/a';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_COMMENT = 'Phase measurement with blue excitation light; see TD269 Operating manual oxygen optode 4330, 4835, 483';
        PARAMETERS(1).PREDEPLOYMENT_CALIB_DATE = 'unknown'; % use argo date14
        PARAMETERS(1).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(1).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(2).PARAMETER = 'C2PHASE_DOXY';
        PARAMETERS(2).PARAMETER_SENSOR = 'OPTODE_DOXY';
        PARAMETERS(2).PARAMETER_UNITS = 'degree';
        PARAMETERS(2).PARAMETER_ACCURACY = ' ';
        PARAMETERS(2).PARAMETER_RESOLUTION = ' ';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_EQUATION = 'none';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENT = 'none';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COEFFICIENTS.A = 'n/a';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_COMMENT = 'Phase measurement with red excitation light; see TD269 Operating manual oxygen optode 4330, 4835, 4831';
        PARAMETERS(2).PREDEPLOYMENT_CALIB_DATE = 'unknown'; % use argo date14
        PARAMETERS(2).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(2).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(3).PARAMETER = 'TEMP_DOXY';
        PARAMETERS(3).PARAMETER_SENSOR = 'OPTODE_DOXY';
        PARAMETERS(3).PARAMETER_UNITS = 'degC';
        PARAMETERS(3).PARAMETER_ACCURACY = '0.03';
        PARAMETERS(3).PARAMETER_RESOLUTION = '0.01';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_EQUATION = 'TEMP_DOXY=T0+T1*TEMP_VOLTAGE_DOXY+T2*TEMP_VOLTAGE_DOXY^2+T3*TEMP_VOLTAGE_DOXY^3+T4*TEMP_VOLTAGE_DOXY^4+T5*TEMP_VOLTAGE_DOXY^5; with TEMP_VOLTAGE_DOXY=voltage from thermistor bridge (mV)';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENT = 'T0=not available; T1=not available; T2=not available; T3=not available; T4=not available; T5=not available';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.T0 = 'not available';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.T1 = 'not available';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.T2 = 'not available';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.T3 = 'not available';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.T4 = 'not available';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COEFFICIENTS.T5 = 'not available';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_COMMENT = 'optode temperature, see TD269 Operating manual oxygen optode 4330, 4835, 4831';
        PARAMETERS(3).PREDEPLOYMENT_CALIB_DATE = 'unknown';  % use argo date14
        PARAMETERS(3).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(3).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(4).PARAMETER = 'DOXY';
        PARAMETERS(4).PARAMETER_SENSOR = 'OPTODE_DOXY'; % Only if it is agreed that this allowed
        PARAMETERS(4).PARAMETER_UNITS = 'umol/kg';
        PARAMETERS(4).PARAMETER_ACCURACY = '8 umol/kg or 10%';
        PARAMETERS(4).PARAMETER_RESOLUTION = '1 umol/kg';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_EQUATION = 'TPHASE_DOXY=C1PHASE_DOXY-C2PHASE_DOXY; Phase_Pcorr=TPHASE_DOXY+Pcoef1*PRES/1000; CalPhase=PhaseCoef0+PhaseCoef1*Phase_Pcorr+PhaseCoef2*Phase_Pcorr^2+PhaseCoef3*Phase_Pcorr^3; MOLAR_DOXY=[((c3+c4*TEMP_DOXY)/(c5+c6*CalPhase))-1]/Ksv; Ksv=c0+c1*TEMP_DOXY+c2*TEMP_DOXY^2; O2=MOLAR_DOXY*Scorr*Pcorr; Scorr=A*exp[PSAL*(B0+B1*Ts+B2*Ts^2+B3*Ts^3)+C0*PSAL^2]; A=[(1013.25-pH2O(TEMP,Spreset))/(1013.25-pH2O(TEMP,PSAL))]; pH2O(TEMP,S)=1013.25*exp[D0+D1*(100/(TEMP+273.15))+D2*ln((TEMP+273.15)/100)+D3*S]; Pcorr=1+((Pcoef2*TEMP+Pcoef3)*PRES)/1000; Ts=ln[(298.15-TEMP)/(273.15+TEMP)]; DOXY=O2/rho, where rho is the potential density [kg/L] calculated from CTD data';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENT = 'Spreset=0; Pcoef1=0.1, Pcoef2=0.00022, Pcoef3=0.0419; B0=-0.00624523, B1=-0.00737614, B2=-0.010341, B3=-0.00817083; C0=-4.88682e-07; PhaseCoef0=-1.652, PhaseCoef1=1, PhaseCoef2=0, PhaseCoef3=0; c0=0.00261275, c1=0.00011268, c2=2.2309e-06, c3=200.183, c4=-0.223497, c5=-43.6776, c6=4.10578; D0=24.4543, D1=-67.4509, D2=-4.8489, D3=-0.000544';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.Spreset = '0';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.Pcoef1 = '0.1';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.Pcoef2 = '0.00022';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.Pcoef3 = '0.0419';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.B0 = '0.00624523';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.B1 = '-0.00737614';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.B2 = '-0.010341';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.B3 = '-0.00817083';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C0 = '-4.88682e-07';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef0 = '-1.652';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef1 = '1';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef2 = '0';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef3 = '0';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.c0 = '0.00261275';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.c1 = '0.00011268';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.c2 = '2.2309e-06';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.c3 = '200.183';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.c4 = '-0.223497';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.c5 = '-43.6776';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.c6 = '4.10578';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.D0 = '24.4543';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.D1 = '-67.4509';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.D2 = '-4.8489';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.D3 = '-0.000544';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C0 = '3.1201642E-3';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C1 = '-285.56594E-6';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C2 = '316.32993E-9';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COEFFICIENTS.C3 = '-1.0767272E-6';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_COMMENT = 'see TD269 Operating manual oxygen optode 4330, 4835, 4831; see Processing Argo OXYGEN data at the DAC level, Version 2.2 (DOI: http://dx.doi.org/10.13155/39795)';
        PARAMETERS(4).PREDEPLOYMENT_CALIB_DATE = 'unknown';  % use argo date14
        PARAMETERS(4).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(4).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

        PARAMETERS(5).PARAMETER = 'PPOX_DOXY';
        PARAMETERS(5).PARAMETER_SENSOR = 'OPTODE_DOXY'; % Only if it is agreed that this allowed
        PARAMETERS(5).PARAMETER_UNITS = 'mbar';
        PARAMETERS(5).PARAMETER_ACCURACY = ' ';
        PARAMETERS(5).PARAMETER_RESOLUTION = ' ';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_EQUATION = 'TPHASE_DOXY=C1PHASE_DOXY-C2PHASE_DOXY; Phase_Pcorr=TPHASE_DOXY+Pcoef1*PRES/1000; CalPhase=PhaseCoef0+PhaseCoef1*Phase_Pcorr+PhaseCoef2*Phase_Pcorr^2+PhaseCoef3*Phase_Pcorr^3; Ksv=c0+c1*TEMP_DOXY+c2*TEMP_DOXY^2; MOLAR_DOXY=[((c3+c4*TEMP_DOXY)/(c5+c6*CalPhase))-1]/Ksv; Pcorr=1+((Pcoef2*TEMP+Pcoef3)*PRES)/1000; MOLAR_DOXY=MOLAR_DOXY*Pcorr; pH2Osat=1013.25*exp[D0+D1*(100/(TEMP+273.15))+D2*ln((TEMP+273.15)/100)]; Tcorr=44.6596*exp[2.00907+3.22014*Ts+4.05010*Ts^2+4.94457*Ts^3-2.56847e-1*Ts^4+3.88767*Ts^5]; Ts=ln[(298.15-TEMP)/(273.15+TEMP)]; PPOX_DOXY=MOLAR_DOXY*(0.20946*(1013.25-pH2Osat))/Tcorr*exp[0.317*PRES/(8.314*(TEMP+273.15))]';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENT = 'Pcoef1=0.1, Pcoef2=0.00022, Pcoef3=0.0419; PhaseCoef0=-1.652, PhaseCoef1=1, PhaseCoef2=0, PhaseCoef3=0; c0=0.00261275, c1=0.00011268, c2=2.2309e-06, c3=200.183, c4=-0.223497, c5=-43.6776, c6=4.10578; D0=24.4543, D1=-67.4509, D2=-4.8489';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.Pcoef1 = '0.1';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.Pcoef2 = '0.00022'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.Pcoef3 = '0.0419'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef0 = '-1.652'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef1 = '1';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef2 = '0'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.PhaseCoef3 = '0'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.c0 = '0.00261275'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.c1 = '0.00011268'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.c2 = '2.2309e-06'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.c3 = '200.183'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.c4 = '-0.223497'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.c5 = '-43.6776'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.c6 = '4.10578';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.D0 = '24.4543'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.D1 = '-67.4509'; 
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.D2 = '-4.8489';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.C0 = '3.1201642E-3';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.C1 = '-285.56594E-6';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.C2 = '316.32993E-9';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COEFFICIENTS.C3 = '-1.0767272E-6';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_COMMENT = 'see TD269 Operating manual oxygen optode 4330, 4835, 4831; see Processing Argo OXYGEN data at the DAC level, Version 2.2 (DOI: http://dx.doi.org/10.13155/39795)';
        PARAMETERS(5).PREDEPLOYMENT_CALIB_DATE = 'unknown';  % use argo date14
        PARAMETERS(5).parameter_vendorinfo.example = 'Vendors can add their own parameter info here; they can add any field they like as a fieldname below parameter_vendorinfo';
        PARAMETERS(5).predeployment_vendorinfo.example = 'Vendors can add their own predeployment info here; they can add any field they like as a fieldname below predeployment_vendorinfo';

    otherwise
        created_by = 'BAK test';  % as defined by sensor maker
        sensor_maker = 'maker';
        sensor_model = 'model';
        sensor_sno = 'serialnum';
        sensor_described = 'empty file for test';


end




fnout = ['sensor-' sensor_maker '-' sensor_model '-' sensor_sno '.json']; % At the moment use '-' as delimiter in filenames because '_' can appear in sensor models


clear allout info instrument_vendorinfo

% Add any metadata about the json file
info.created_by = created_by;
info.date_creation = datestr(now,'yyyymmddHHMMSS'); % use Argo date14 format
info.format_version = '0.1'; % for some sort of version control
info.contents = 'json file to describe a sensor for Argo. v0.1 draft';
info.sensor_described = sensor_described;

instrument_vendorinfo.example = 'Vendors can add something about the whole instrument here; they can add field they like as a fieldname below instrument_vendorinfo';

allout.sensor_info = info;
allout.SENSORS = SENSORS;
allout.PARAMETERS = PARAMETERS;
allout.instrument_vendorinfo = instrument_vendorinfo; % This could be about a whole parent instrument, rather than child sensors. Needs a bit more thought.


jsp = jsonencode(allout,'PrettyPrint',true);
jsp_struct = jsondecode(jsp);
jsp2 = jsonencode(jsp_struct,'PrettyPrint',true);

fid = fopen(fnout,'w');
fprintf(fid,'%s\n',jsp2);
fclose(fid);


% then need a converter, json to argo netcdf, in which the SENSOR is a single array, not anything indexed.
% The converter to argo netcdf will accept a platform json and any collection of sensor jsons, read the sensor json filenames from a file.




% version: '1.0.1'
% DATA_TYPE: 'Argo meta-data'
% PLATFORM_FAMILY: 'FLOAT'
% PLATFORM_TYPE: 'NAVIS_EBR'
% PLATFORM_MAKER: 'SBE'
% FIRMWARE_VERSION: 'BGCi_OPTOx_MCOM_SUNA_PH_ICE_EXP 210521'
% FLOAT_SERIAL_NO: '0060'
% BATTERY_TYPE: 'ELECTROCHEM Lithium 15.0 V'
% BATTERY_PACKS: '3DD Li'
% CONTROLLER_BOARD_TYPE_PRIMARY: 'NAVIS N1'
% CONTROLLER_BOARD_SERIAL_NO_PRIMARY: '00000'
% SENSORS: [9×1 struct]

