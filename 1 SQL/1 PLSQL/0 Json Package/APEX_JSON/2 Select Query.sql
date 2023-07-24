SELECT * FROM xxpm_property_master WHERE PROPERTY_NAME='The 2';
SELECT * FROM xxpm_property_area 
WHERE PROPERTY_ID in 
(SELECT PROPERTY_ID FROM xxpm_property_master WHERE PROPERTY_NAME='The 2');


SELECT * FROM xxpm_property_master WHERE PROPERTY_ID=1000400;
SELECT * FROM xxpm_property_area WHERE BUILD_ID IS NULL AND UNIT_ID IS NULL AND PROPERTY_ID=1000400;

delete FROM xxpm_property_area WHERE BUILD_ID IS NULL AND UNIT_ID IS NULL AND PROPERTY_ID=1000400 and CREATED_BY='API';
delete FROM xxpm_property_area 
WHERE PROPERTY_ID in 
(SELECT PROPERTY_ID FROM xxpm_property_master WHERE PROPERTY_NAME='The 2');
delete FROM xxpm_property_master WHERE PROPERTY_NAME='The 2';
commit;
