--
-- Turn off autocommit and start a transaction so that we can use the temp tables
--

--SET AUTOCOMMIT = OFF;

START TRANSACTION;

--
-- Insert client information into the temporary tables. To add clients to the HSQL database, edit things here.
-- 

INSERT INTO client_details_TEMP (client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection) VALUES
	('GE_Pledge_Tool', 'a3318aa1-031d-4357-8345-28512df77f2a', 'GE Pledge Tool', false, null, 3600, 600, true);

INSERT INTO client_scope_TEMP (owner_id, scope) VALUES
	('GE_Pledge_Tool', 'openid'),
	('GE_Pledge_Tool', 'profile'),
	('GE_Pledge_Tool', 'email'),
	('GE_Pledge_Tool', 'address'),
	('GE_Pledge_Tool', 'phone'),
	('GE_Pledge_Tool', 'offline_access');

INSERT INTO client_redirect_uri_TEMP (owner_id, redirect_uri) VALUES
	('GE_Pledge_Tool', 'http://localhost/'),
	('GE_Pledge_Tool', 'http://localhost:8080/'),
        ('GE_Pledge_Tool', 'http://192.168.57.1:8080/'),
        ('GE_Pledge_Tool', 'http://ec2-52-91-41-6.compute-1.amazonaws.com/');
	
INSERT INTO client_grant_type_TEMP (owner_id, grant_type) VALUES
	('GE_Pledge_Tool', 'authorization_code'),
	('GE_Pledge_Tool', 'urn:ietf:params:oauth:grant_type:redelegate'),
	('GE_Pledge_Tool', 'implicit'),
	('GE_Pledge_Tool', 'refresh_token');
	
--
-- Merge the temporary clients safely into the database. This is a two-step process to keep clients from being created on every startup with a persistent store.
--


INSERT INTO client_details (client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection)
  SELECT client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection FROM client_details_TEMP
  ON CONFLICT(client_id)
  DO UPDATE SET 
  	client_secret = EXCLUDED.client_secret,
  	client_name = EXCLUDED.client_name,
  	dynamically_registered = EXCLUDED.dynamically_registered,
  	refresh_token_validity_seconds = EXCLUDED.refresh_token_validity_seconds,
  	access_token_validity_seconds = EXCLUDED.access_token_validity_seconds,
  	id_token_validity_seconds = EXCLUDED.id_token_validity_seconds,
  	allow_introspection = EXCLUDED.allow_introspection;

INSERT INTO client_scope (owner_id, scope)
  SELECT id AS owner_id, scope FROM client_scope_TEMP, client_details WHERE client_details.client_id = client_scope_TEMP.owner_id
  ON CONFLICT(owner_id, scope)
  DO NOTHING;

INSERT INTO client_redirect_uri (owner_id, redirect_uri)
  SELECT id AS owner_id, redirect_uri FROM client_redirect_uri_TEMP, client_details WHERE client_details.client_id = client_redirect_uri_TEMP.owner_id
  ON CONFLICT(owner_id, redirect_uri)
  DO NOTHING;

INSERT INTO client_grant_type (owner_id, grant_type)
  SELECT id AS owner_id, grant_type FROM client_grant_type_TEMP, client_details WHERE client_details.client_id = client_grant_type_TEMP.owner_id
  ON CONFLICT(owner_id, grant_type)
  DO NOTHING;
    
-- 
-- Close the transaction and turn autocommit back on
-- 
    
COMMIT;

--SET AUTOCOMMIT = ON;


