import json

# files to test
# fname = 'sensor-DRUCK-DRUCK_2900PSIA-11698373.json'
# fname = 'sensor-AANDERAA-AANDERAA_OPTODE_3830-498.json'
# fname = 'sensor-SBE-SBE41CP-13875.json'
fname = 'sensor-WETLABS-MCOMS_FLBBCDX-0157.json'

# Open JSON file
f = open(fname)
  
# returns JSON object as a dictionary
data = json.load(f)
  
# Iterate through portions of the json list
print('SENSOR:')
for i in data['argo'][0]['SENSOR']:
    print(i)

print('\nPARAMETER:')
for i in data['argo'][1]['PARAMETER']:
    print(i)

print('\nvendor:')
print(data['vendor'][0]['SENSOR_MAKER'])

# Close file
f.close()