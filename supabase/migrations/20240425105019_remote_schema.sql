alter table "public"."accounts" drop constraint "accounts_number_key";

alter table "public"."transactions" drop constraint "public_transactions_account_number_fkey";

drop index if exists "public"."accounts_number_key";

create table "public"."organizations" (
    "id" uuid not null default uuid_generate_v7(),
    "name" character varying not null
);


alter table "public"."organizations" enable row level security;

alter table "public"."accounts" drop column "created_at";

alter table "public"."accounts" drop column "normal";

alter table "public"."accounts" add column "direction" smallint;

alter table "public"."accounts" add column "organization_id" uuid;

alter table "public"."accounts" alter column "id" set default uuid_generate_v7();

alter table "public"."transactions" drop column "account_number";

alter table "public"."transactions" drop column "created_at";

alter table "public"."transactions" drop column "direction";

alter table "public"."transactions" add column "account_id" uuid;

alter table "public"."transactions" alter column "id" set default uuid_generate_v7();

CREATE UNIQUE INDEX accounts_organization_id_number_key ON public.accounts USING btree (organization_id, number);

CREATE UNIQUE INDEX organizations_pkey ON public.organizations USING btree (id);

alter table "public"."organizations" add constraint "organizations_pkey" PRIMARY KEY using index "organizations_pkey";

alter table "public"."accounts" add constraint "accounts_organization_id_number_key" UNIQUE using index "accounts_organization_id_number_key";

alter table "public"."accounts" add constraint "fk_organizations_id" FOREIGN KEY (organization_id) REFERENCES organizations(id) not valid;

alter table "public"."accounts" validate constraint "fk_organizations_id";

alter table "public"."transactions" add constraint "fk_accounts_account_id" FOREIGN KEY (account_id) REFERENCES accounts(id) not valid;

alter table "public"."transactions" validate constraint "fk_accounts_account_id";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_debits_credits_balance()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$DECLARE
    journal_balance NUMERIC;
BEGIN
    RAISE NOTICE 'check_debits_credits_balance called';
    -- Calculate the balance by subtracting the sum of credits from the sum of debits
    SELECT SUM(amount) INTO journal_balance
    FROM transactions
    WHERE journal_entry = NEW.journal_entry;

    -- If the balance is not zero, raise an exception
    IF journal_balance != 0 THEN
        RAISE EXCEPTION 'The sum of debits and credits for journal entry % does not equal zero.', NEW.journal_entry;
    END IF;

    -- If the balance is zero, allow the transaction to proceed
    RETURN NEW;
END;$function$
;

CREATE OR REPLACE FUNCTION public.timestamp_from_uuid_v7(_uuid uuid)
 RETURNS timestamp without time zone
 LANGUAGE sql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
  SELECT to_timestamp(('x0000' || substr(_uuid::text, 1, 8) || substr(_uuid::text, 10, 4))::bit(64)::bigint::numeric / 1000);
$function$
;

CREATE OR REPLACE FUNCTION public.uuid_generate_v7()
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$function$
;

CREATE OR REPLACE FUNCTION public.uuid_generate_v8()
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
declare
  timestamp    timestamptz;
  microseconds int;
begin
  timestamp    = clock_timestamp();
  microseconds = (cast(extract(microseconds from timestamp)::int - (floor(extract(milliseconds from timestamp))::int * 1000) as double precision) * 4.096)::int;

  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 8 and add microseconds
  return encode(
    set_byte(
      set_byte(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from timestamp) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        6, (b'1000' || (microseconds >> 8)::bit(4))::bit(8)::int
      ),
      7, microseconds::bit(8)::int
    ),
    'hex')::uuid;
end
$function$
;

grant delete on table "public"."organizations" to "anon";

grant insert on table "public"."organizations" to "anon";

grant references on table "public"."organizations" to "anon";

grant select on table "public"."organizations" to "anon";

grant trigger on table "public"."organizations" to "anon";

grant truncate on table "public"."organizations" to "anon";

grant update on table "public"."organizations" to "anon";

grant delete on table "public"."organizations" to "authenticated";

grant insert on table "public"."organizations" to "authenticated";

grant references on table "public"."organizations" to "authenticated";

grant select on table "public"."organizations" to "authenticated";

grant trigger on table "public"."organizations" to "authenticated";

grant truncate on table "public"."organizations" to "authenticated";

grant update on table "public"."organizations" to "authenticated";

grant delete on table "public"."organizations" to "service_role";

grant insert on table "public"."organizations" to "service_role";

grant references on table "public"."organizations" to "service_role";

grant select on table "public"."organizations" to "service_role";

grant trigger on table "public"."organizations" to "service_role";

grant truncate on table "public"."organizations" to "service_role";

grant update on table "public"."organizations" to "service_role";

CREATE TRIGGER trigger_check_debits_credits_balance AFTER INSERT OR DELETE OR UPDATE ON public.transactions FOR EACH STATEMENT EXECUTE FUNCTION check_debits_credits_balance();


