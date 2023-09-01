import json

# files to test
# fname = 'sensor-DRUCK-DRUCK_2900PSIA-11698373.json'
# fname = 'sensor-AANDERAA-AANDERAA_OPTODE_3830-498.json'
# fname = 'sensor-SBE-SBE41CP-13875.json'
fname = 'sensor-SBE-SBE41CP-11643.json'
# fname = 'sensor-WETLABS-MCOMS_FLBBCDX-0157.json'

# Open JSON file
with open('examples/'+fname) as f:

    # returns JSON object as a dictionary
    data = json.load(f)

    print('sensor_info:')
    for key, value in data['sensor_info'].items():
        print(key, value)
    
    # Iterate through portions of the json list
    print('sensors:')
    for sensor in data['SENSORS']:
        for key, value in sensor.items() :
            print(key, value)
        # print(sensor['SENSOR'][:])
        # print(sensor['SENSOR_MAKER'][:])

    print('parameters:')
    for param in data['PARAMETERS']:
        for key, value in param.items() :
            if key != 'PREDEPLOYMENT_CALIB_COEFFICIENT_LIST' :
                print(key, value)

        print('REDEPLOYMENT_CALIB_COEFFICIENT_LIST:')
        for key, calcoef in param['PREDEPLOYMENT_CALIB_COEFFICIENT_LIST'].items():
            print(key, calcoef)


1

    # print('\nvendor:')
    # print(data['vendor'][0]['SENSOR_MAKER'])
