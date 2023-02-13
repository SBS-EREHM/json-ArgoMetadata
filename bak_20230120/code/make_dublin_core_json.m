function jsonDC = make_dublin_core_json(title, description, sensor_described, creator, creationdate, publisher)

%
% Create JSON string with Dublin Core (DC) metadata describing the creation
% of the Argo sensor, float, or platform metadata.
%
% Dublin Core (DC) is a is a set of fifteen "core" elements (properties) 
% for describing resources. 
%

DC.title = title;
DC.description = desciption;
DC.creator = creator;
DC.date = creationdate;
DC.format = 'application/json';
DC.languague = 'en';
DC.type = sensor_described;


