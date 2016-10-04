--
-- Turn off autocommit and start a transaction so that we can use the temp tables
--

--SET AUTOCOMMIT = OFF;

START TRANSACTION;

--
-- Insert client information into the temporary tables. To add clients to the HSQL database, edit things here.
-- 

INSERT INTO client_details_TEMP (client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection) VALUES
	('client', 'secret', 'Test Client', false, null, 3600, 600, true);

INSERT INTO client_scope_TEMP (owner_id, scope) VALUES
	('client', 'openid'),
	('client', 'profile'),
	('client', 'email'),
	('client', 'address'),
	('client', 'phone'),
	('client', 'offline_access');

INSERT INTO client_redirect_uri_TEMP (owner_id, redirect_uri) VALUES
	('client', 'http://localhost/'),
	('client', 'http://localhost:8080/'),
    ('client', 'http://192.168.57.1:8080/');
	
INSERT INTO client_grant_type_TEMP (owner_id, grant_type) VALUES
	('client', 'authorization_code'),
	('client', 'urn:ietf:params:oauth:grant_type:redelegate'),
	('client', 'implicit'),
	('client', 'refresh_token');
	
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


