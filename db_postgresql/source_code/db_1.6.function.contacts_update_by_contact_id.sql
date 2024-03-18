DROP FUNCTION IF EXISTS public.contacts_update_by_contact_id(int,int,varchar,varchar,varchar);

CREATE FUNCTION contacts_update_by_contact_id
(
 	contact_id_input int,
 	company_id_input int,
	first_name_input varchar,
	last_name_input varchar,
	email_input varchar,
 	OUT id int
)
AS $$	
	UPDATE contacts
	SET
		company_id = company_id_input,
		first_name = first_name_input,
		last_name = last_name_input,
		email = email_input
	WHERE contacts.id = contact_id_input
	RETURNING contacts.id;
$$ 
LANGUAGE SQL;

--SELECT id FROM contacts_update_by_contact_id(2, 1, 'Michelle', 'Doan', 'michelle@anyemail.com')
--SELECT * FROM contacts ORDER by id ASC
