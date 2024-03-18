DROP TABLE IF EXISTS public.contacts;
DROP TABLE IF EXISTS public.companies;

CREATE TABLE "companies" (
  "id" SERIAL PRIMARY KEY,
  "name" varchar,
  "created_at" timestamp with time zone
);

CREATE TABLE "contacts" (
  "id" SERIAL PRIMARY KEY,
  "company_id" int,
  "first_name" varchar,
  "last_name" varchar,
  "email" varchar,
  "created_at" timestamp with time zone
);

ALTER TABLE "contacts" ADD FOREIGN KEY ("company_id") REFERENCES "companies" ("id");
