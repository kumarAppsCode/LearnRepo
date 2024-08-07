BEGIN
 ORDS.create_role(
 p_role_name => 'security_role'
 );
  COMMIT;
END;
/

SELECT id, name
FROM user_ords_roles
WHERE name = 'security_role';


DECLARE
 l_roles_arr OWA.vc_arr;
 l_patterns_arr OWA.vc_arr;
BEGIN
 l_roles_arr(1) := 'security_role';
 l_patterns_arr(1) := '/haya/hr/*';
 
 ORDS.define_privilege (
 p_privilege_name => 'security_priv',
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
WHERE name = 'security_priv';

SELECT privilege_id, privilege_name, role_id, role_name
FROM user_ords_privilege_roles
WHERE role_name = 'security_role';


SELECT privilege_id, name, pattern
FROM user_ords_privilege_mappings
WHERE name = 'security_priv';



BEGIN
 OAUTH.create_client(
 p_name => 'secuirty_client',
 p_grant_type => 'client_credentials',
 p_owner => 'My Company Limited',
 p_description => 'A client for Emp management',
 p_support_email => 'rajkumar.kl@4iapps.com',
 p_privilege_names => 'security_priv'
 );
 COMMIT;
END;
/


SELECT id, name, client_id, client_secret
FROM user_ords_clients;


SELECT name, client_name
FROM user_ords_client_privileges;

BEGIN
 OAUTH.grant_client_role(
 p_client_name => 'secuirty_client',
 p_role_name => 'security_role'
 );
 COMMIT;
END;
/


SELECT client_name, role_name
FROM user_ords_client_roles;



BEGIN
  ORDS_METADATA.OAUTH.update_client(
    p_name            => 'secuirty_client1',
    p_description     => 'A client for Emp management',
    p_origins_allowed => null,
    p_redirect_uri    => null,
    p_support_email   => null,
    p_support_uri     => null,
    p_privilege_names => null,
    p_token_duration  => 5, 
    p_refresh_duration => null, 
    p_code_duration   => null
  );
  COMMIT;
END;
