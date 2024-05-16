-- Create Role with new role name
BEGIN
 ORDS.create_role(
 p_role_name => 'security_role_stg'
 );
  COMMIT;
END;
/

SELECT id, name
FROM user_ords_roles
WHERE name = 'security_role_stg';

/
DECLARE
 l_roles_arr OWA.vc_arr;
 l_patterns_arr OWA.vc_arr;
BEGIN
 l_roles_arr(1) := 'security_role_stg';
 l_patterns_arr(1) := '/xxstg/hr/*';
 
 ORDS.define_privilege (
 p_privilege_name => 'security_priv_stg',
 p_roles => l_roles_arr,
 p_patterns => l_patterns_arr,
 p_label => 'EMP Data',
 p_description => 'Allow access to the EMP data.'
 );
 
 COMMIT;
END;
/


SELECT id, name
FROM user_ords_privileges
WHERE name = 'security_priv_stg';

SELECT privilege_id, privilege_name, role_id, role_name
FROM user_ords_privilege_roles
WHERE role_name = 'security_role_stg';


SELECT privilege_id, name, pattern
FROM user_ords_privilege_mappings
WHERE name = 'security_priv_stg';



BEGIN
 OAUTH.create_client(
 p_name => 'secuirty_client_stg',
 p_grant_type => 'client_credentials',
 p_owner => 'My Company Limited',
 p_description => 'A client for Emp management',
 p_support_email => 'dineshkumar.p@***.com',
 p_privilege_names => 'security_priv_stg'
 );
 COMMIT;
END;
/


SELECT id, name, client_id, client_secret
FROM user_ords_clients;


SELECT name, client_name
FROM user_ords_client_privileges;

--grand access to client name and role
BEGIN
 OAUTH.grant_client_role(
 p_client_name => 'secuirty_client_stg',
 p_role_name => 'security_role_stg'
 );
 COMMIT;
END;
/


SELECT client_name, role_name
FROM user_ords_client_roles;
