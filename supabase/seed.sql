SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 15.5 (Ubuntu 15.5-1.pgdg20.04+1)

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

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: supabase_admin
--



--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."organizations" ("id", "name") VALUES
	('018f1064-1fc1-7734-99c4-75c2c9684a7c', 'test1');


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."accounts" ("id", "name", "number", "direction", "organization_id") VALUES
	('018f1074-79b7-72ad-a932-e13164543d32', 'Assets', 100, 1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-7417-9ee5-f7768fe3bec6', 'Cash', 110, 1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-7d83-a803-222630267a54', 'Merchandise', 120, 1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-767a-a100-a281d2a93dfa', 'Liabilities', 200, -1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-7f7d-bf13-0723e1dc460f', 'Deferred Revenue', 210, -1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-74a7-a1dd-73ca5b42b50e', 'Revenues', 300, -1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-70cc-b24a-228e23de08b4', 'Expenses', 400, 1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-7653-9fba-38abd40b2b1d', 'Cost of Goods Sold', 410, 1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-7972-952b-8a936bcce7d3', 'Equity', 500, -1, '018f1064-1fc1-7734-99c4-75c2c9684a7c'),
	('018f1074-79b7-7c12-8099-4aa5ed076729', 'Capital', 510, -1, '018f1064-1fc1-7734-99c4-75c2c9684a7c');


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."transactions" ("id", "journal_entry", "date", "amount", "account_id") VALUES
	('018f1070-deb6-74ec-8206-b96f0423dfaa', 1, '2022-01-01 00:00:00+00', 500.0, '018f1074-79b7-7417-9ee5-f7768fe3bec6'),
	('018f1070-deb7-75f1-a8d7-7127c02ed462', 1, '2022-01-01 00:00:00+00', -500.0, '018f1074-79b7-7c12-8099-4aa5ed076729'),
	('018f1070-deb7-7da4-b093-288647d38324', 2, '2022-01-01 00:00:00+00', 100.0, '018f1074-79b7-7d83-a803-222630267a54'),
	('018f1070-deb7-71ce-836f-62005572b021', 2, '2022-01-01 00:00:00+00', -100.0, '018f1074-79b7-7417-9ee5-f7768fe3bec6'),
	('018f1070-deb7-7f2d-a3f6-3efba79c3e21', 3, '2022-02-01 00:00:00+00', 15.0, '018f1074-79b7-7417-9ee5-f7768fe3bec6'),
	('018f1070-deb7-7b98-aca0-f0796cbe8645', 3, '2022-02-01 00:00:00+00', -15.0, '018f1074-79b7-7f7d-bf13-0723e1dc460f'),
	('018f1070-deb8-7e8a-8304-3a8f6694d2c1', 4, '2022-02-05 00:00:00+00', 15.0, '018f1074-79b7-7f7d-bf13-0723e1dc460f'),
	('018f1070-deb8-7281-bbd1-66d5e42576fb', 4, '2022-02-05 00:00:00+00', -15.0, '018f1074-79b7-74a7-a1dd-73ca5b42b50e'),
	('018f1070-deb8-7ef9-a074-d7e9798ea099', 5, '2022-02-05 00:00:00+00', 3.0, '018f1074-79b7-7653-9fba-38abd40b2b1d'),
	('018f1070-deb8-7eea-b0ee-508a8ab16bac', 5, '2022-02-05 00:00:00+00', -3.0, '018f1074-79b7-7d83-a803-222630267a54');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--



--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, false);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('"pgsodium"."key_key_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

RESET ALL;
