DROP FUNCTION IF EXISTS public.contacts_delete_by_contact_id(int);

CREATE FUNCTION contacts_delete_by_contact_id
(
 contact_id_input int,
 OUT id int
)
AS $$	
	DELETE FROM contacts
	WHERE contacts.id = contact_id_input
	RETURNING contacts.id;
$$ 
LANGUAGE SQL;

--SELECT id FROM contacts_delete_by_contact_id(85)
--SELECT * FROM contacts ORDER by id DESC

