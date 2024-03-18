DROP FUNCTION IF EXISTS public.contacts_get_by_pagination(int);
CREATE OR REPLACE FUNCTION contacts_get_by_pagination
(
	contact_id_input int,
	search_text_input varchar,
	contacts_created_at_start timestamp with time zone,
	contacts_created_at_finish timestamp with time zone,
	page_number int,
 	page_size int
)
RETURNS TABLE 
(
	id int,
	first_name varchar,
	last_name varchar,
	email varchar,
	created_at timestamp with time zone,
	company_id int
) 
AS $$
	DECLARE SELECT_QUERY text;
	DECLARE WHERE_QUERY text;
	DECLARE JOIN_QUERY text;
	DECLARE ORDER_BY_QUERY text;
	DECLARE PAGE_NUMBER_QUERY text;
	DECLARE PAGE_SIZE_QUERY text;
BEGIN
	SELECT_QUERY = '';
	WHERE_QUERY = '';
	JOIN_QUERY = '';
	PAGE_NUMBER_QUERY = '';
	PAGE_SIZE_QUERY = '';
	
	--SET datestyle = US, DMY;
	
    SELECT_QUERY = 
	'SELECT 
		contacts.id, 
		contacts.first_name,
		contacts.last_name,
		contacts.email,
		contacts.created_at,
		contacts.company_id
	FROM contacts ';
	
	JOIN_QUERY = ' 
	INNER JOIN companies ON contacts.company_id = companies.id ';
	
	WHERE_QUERY = ' 
	WHERE ( 1=1 ) ';
	
	IF contact_id_input > 0
	THEN
		WHERE_QUERY = WHERE_QUERY || ' AND contacts.id = ' || contact_id_input;
	END IF;
	
	IF CHAR_LENGTH(search_text_input) > 0
	THEN
		WHERE_QUERY = WHERE_QUERY || ' AND ( ';
		WHERE_QUERY = WHERE_QUERY || '    LOWER(contacts.first_name) LIKE LOWER(' || '''%' || search_text_input || '%'') ';
		WHERE_QUERY = WHERE_QUERY || ' OR LOWER(contacts.last_name)  LIKE LOWER(' || '''%' || search_text_input || '%'') ';
		WHERE_QUERY = WHERE_QUERY || ' OR LOWER(contacts.email)  	 LIKE LOWER(' || '''%' || search_text_input || '%'') ';
		WHERE_QUERY = WHERE_QUERY || ' OR LOWER(companies.name)  	 LIKE LOWER(' || '''%' || search_text_input || '%'') ';
		WHERE_QUERY = WHERE_QUERY || ' )';
	END IF;
		
	IF (contacts_created_at_start) > '0001.01.01'::date
	THEN
		WHERE_QUERY = WHERE_QUERY || ' AND ( contacts.created_at > ''' || contacts_created_at_start || '''';
		WHERE_QUERY = WHERE_QUERY || ' )';
	END IF;
	
	IF (contacts_created_at_finish) > '0001.01.01'::date
	THEN
		WHERE_QUERY = WHERE_QUERY || ' AND ( contacts.created_at < ''' || contacts_created_at_finish || '''';
		WHERE_QUERY = WHERE_QUERY || ' )';
	END IF;
	
	ORDER_BY_QUERY = ' 
	ORDER BY contacts.created_at ASC, contacts.id ASC ';
		
	PAGE_NUMBER_QUERY = ' 
	OFFSET (' || page_number || ' - 1) * ' || page_size;
	
	PAGE_SIZE_QUERY = ' 
	FETCH NEXT ' || page_size || ' ROWS ONLY ';
	
	RAISE NOTICE '%', SELECT_QUERY || JOIN_QUERY || WHERE_QUERY || ORDER_BY_QUERY || PAGE_SIZE_QUERY || PAGE_NUMBER_QUERY || ' ;';
	
	RETURN QUERY
		EXECUTE (SELECT_QUERY || JOIN_QUERY || WHERE_QUERY || ORDER_BY_QUERY || PAGE_SIZE_QUERY || PAGE_NUMBER_QUERY || ' ;');
	
END
$$ LANGUAGE PLPGSQL;

--SELECT '0001.01.01'::date;
--SELECT id, first_name, last_name, email, created_at, company_id FROM contacts_get_by_pagination(0,'amazon','0001.01.01','0001.01.01', 1, 15);
--SELECT id, first_name, last_name, email, created_at, company_id FROM contacts_get_by_pagination(0,'amazon','0001.01.01','0001.01.01', 1, 5);
--SELECT id, first_name, last_name, email, created_at, company_id FROM contacts_get_by_pagination(0,'amazon','0001.01.01','0001.01.01', 2, 5);
--SELECT id, first_name, last_name, email, created_at, company_id FROM contacts_get_by_pagination(0,'amazon','0001.01.01','0001.01.01', 3, 5);

