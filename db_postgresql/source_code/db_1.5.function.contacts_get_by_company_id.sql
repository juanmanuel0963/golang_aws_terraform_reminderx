DROP FUNCTION IF EXISTS public.contacts_get_by_company_id(integer);

CREATE FUNCTION contacts_get_by_company_id 
(
 company_id_input int, 
 OUT id int,
 OUT first_name varchar,
 OUT last_name varchar,
 OUT email varchar,
 OUT created_at timestamp with time zone,
 OUT company_id int
)
RETURNS SETOF record
AS $$
    SELECT 
		contacts.id, 
		contacts.first_name,
		contacts.last_name,
		contacts.email,
		contacts.created_at,
		contacts.company_id
	FROM contacts
	INNER JOIN companies ON contacts.company_id = companies.id
	WHERE companies.id = company_id_input
	ORDER BY contacts.id ASC;
$$ LANGUAGE SQL;

--SELECT id, first_name, last_name, email, created_at, company_id FROM contacts_get_by_company_id(1);
--SELECT * FROM contacts_get_by_company_id(2);
--SELECT * FROM contacts_get_by_company_id(3);

