DROP FUNCTION IF EXISTS public.contacts_insert(int,varchar,varchar,varchar);

CREATE FUNCTION contacts_insert
(
 company_id int,
 first_name varchar,
 last_name varchar,
 email varchar,
 OUT id int
)
AS $$
	INSERT INTO contacts(company_id, first_name, last_name, email, created_at) 
				  VALUES(company_id, first_name, last_name, email, now())
	RETURNING contacts.id;

$$ LANGUAGE SQL;

--SELECT id FROM contacts_insert(1,'Marco', 'Reus', 'marco@anyemail.com');
--SELECT id FROM contacts_insert(2,'Tony', 'Montana', 'tony@anyemail.com');
--SELECT id FROM contacts_insert(3,'David', 'Haaland', 'david@anyemail.com');
--SELECT * FROM contacts ORDER by id DESC

