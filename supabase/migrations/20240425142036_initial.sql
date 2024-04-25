
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "vector" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."check_debits_credits_balance"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
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
END;$$;

ALTER FUNCTION "public"."check_debits_credits_balance"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."direction_to_sign"(boolean) RETURNS smallint
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $_$select case when $1 then 1 else -1 end;$_$;

ALTER FUNCTION "public"."direction_to_sign"(boolean) OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."timestamp_from_uuid_v7"("_uuid" "uuid") RETURNS timestamp without time zone
    LANGUAGE "sql" IMMUTABLE STRICT PARALLEL SAFE
    AS $$
  SELECT to_timestamp(('x0000' || substr(_uuid::text, 1, 8) || substr(_uuid::text, 10, 4))::bit(64)::bigint::numeric / 1000);
$$;

ALTER FUNCTION "public"."timestamp_from_uuid_v7"("_uuid" "uuid") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."uuid_generate_v7"() RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
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
$$;

ALTER FUNCTION "public"."uuid_generate_v7"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."uuid_generate_v8"() RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
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
$$;

ALTER FUNCTION "public"."uuid_generate_v8"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."accounts" (
    "id" "uuid" DEFAULT "public"."uuid_generate_v7"() NOT NULL,
    "name" character varying NOT NULL,
    "number" smallint NOT NULL,
    "direction" smallint,
    "organization_id" "uuid"
);

ALTER TABLE "public"."accounts" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."organizations" (
    "id" "uuid" DEFAULT "public"."uuid_generate_v7"() NOT NULL,
    "name" character varying NOT NULL
);

ALTER TABLE "public"."organizations" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "id" "uuid" DEFAULT "public"."uuid_generate_v7"() NOT NULL,
    "journal_entry" integer NOT NULL,
    "date" timestamp with time zone NOT NULL,
    "amount" numeric NOT NULL,
    "account_id" "uuid"
);

ALTER TABLE "public"."transactions" OWNER TO "postgres";

ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_organization_id_number_key" UNIQUE ("organization_id", "number");

ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("id");

CREATE OR REPLACE TRIGGER "trigger_check_debits_credits_balance" AFTER INSERT OR DELETE OR UPDATE ON "public"."transactions" FOR EACH STATEMENT EXECUTE FUNCTION "public"."check_debits_credits_balance"();

ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "fk_accounts_account_id" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("id");

ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "fk_organizations_id" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id");

ALTER TABLE "public"."accounts" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."organizations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."transactions" ENABLE ROW LEVEL SECURITY;

ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";

ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."accounts";

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."check_debits_credits_balance"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_debits_credits_balance"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_debits_credits_balance"() TO "service_role";

GRANT ALL ON FUNCTION "public"."direction_to_sign"(boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."direction_to_sign"(boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."direction_to_sign"(boolean) TO "service_role";

GRANT ALL ON FUNCTION "public"."timestamp_from_uuid_v7"("_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."timestamp_from_uuid_v7"("_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."timestamp_from_uuid_v7"("_uuid" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."uuid_generate_v7"() TO "anon";
GRANT ALL ON FUNCTION "public"."uuid_generate_v7"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."uuid_generate_v7"() TO "service_role";

GRANT ALL ON FUNCTION "public"."uuid_generate_v8"() TO "anon";
GRANT ALL ON FUNCTION "public"."uuid_generate_v8"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."uuid_generate_v8"() TO "service_role";

GRANT ALL ON TABLE "public"."accounts" TO "anon";
GRANT ALL ON TABLE "public"."accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts" TO "service_role";

GRANT ALL ON TABLE "public"."organizations" TO "anon";
GRANT ALL ON TABLE "public"."organizations" TO "authenticated";
GRANT ALL ON TABLE "public"."organizations" TO "service_role";

GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
