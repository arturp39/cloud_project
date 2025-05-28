--
-- PostgreSQL database dump
--

-- Dumped from database version 13.20
-- Dumped by pg_dump version 17.5

-- Started on 2025-05-28 20:46:18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3 (class 3079 OID 24760)
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;


--
-- TOC entry 3843 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- TOC entry 7 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: azure_pg_admin
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO azure_pg_admin;

--
-- TOC entry 4 (class 3079 OID 24814)
-- Name: azure; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS azure WITH SCHEMA pg_catalog;


--
-- TOC entry 3846 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION azure; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION azure IS 'azure extension for PostgreSQL service';


--
-- TOC entry 2 (class 3079 OID 24577)
-- Name: pgaadauth; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgaadauth WITH SCHEMA pg_catalog;


--
-- TOC entry 3847 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgaadauth; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgaadauth IS 'Azure Active Directory Authentication';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 211 (class 1259 OID 24830)
-- Name: customer; Type: TABLE; Schema: public; Owner: foodadmin
--

CREATE TABLE public.customer (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255)
);


ALTER TABLE public.customer OWNER TO foodadmin;

--
-- TOC entry 210 (class 1259 OID 24828)
-- Name: customer_id_seq; Type: SEQUENCE; Schema: public; Owner: foodadmin
--

CREATE SEQUENCE public.customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_id_seq OWNER TO foodadmin;

--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 210
-- Name: customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: foodadmin
--

ALTER SEQUENCE public.customer_id_seq OWNED BY public.customer.id;


--
-- TOC entry 217 (class 1259 OID 24869)
-- Name: customer_order; Type: TABLE; Schema: public; Owner: foodadmin
--

CREATE TABLE public.customer_order (
    id integer NOT NULL,
    customer_name character varying(255),
    customer_address text
);


ALTER TABLE public.customer_order OWNER TO foodadmin;

--
-- TOC entry 216 (class 1259 OID 24867)
-- Name: customer_order_id_seq; Type: SEQUENCE; Schema: public; Owner: foodadmin
--

CREATE SEQUENCE public.customer_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_order_id_seq OWNER TO foodadmin;

--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 216
-- Name: customer_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: foodadmin
--

ALTER SEQUENCE public.customer_order_id_seq OWNED BY public.customer_order.id;


--
-- TOC entry 221 (class 1259 OID 24893)
-- Name: delivery; Type: TABLE; Schema: public; Owner: foodadmin
--

CREATE TABLE public.delivery (
    id integer NOT NULL,
    order_id integer NOT NULL,
    courier_name character varying(255) NOT NULL,
    status character varying(50) DEFAULT 'assigned'::character varying,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.delivery OWNER TO foodadmin;

--
-- TOC entry 220 (class 1259 OID 24891)
-- Name: delivery_id_seq; Type: SEQUENCE; Schema: public; Owner: foodadmin
--

CREATE SEQUENCE public.delivery_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.delivery_id_seq OWNER TO foodadmin;

--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 220
-- Name: delivery_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: foodadmin
--

ALTER SEQUENCE public.delivery_id_seq OWNED BY public.delivery.id;


--
-- TOC entry 209 (class 1259 OID 24822)
-- Name: menu_item; Type: TABLE; Schema: public; Owner: foodadmin
--

CREATE TABLE public.menu_item (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.menu_item OWNER TO foodadmin;

--
-- TOC entry 208 (class 1259 OID 24820)
-- Name: menu_item_id_seq; Type: SEQUENCE; Schema: public; Owner: foodadmin
--

CREATE SEQUENCE public.menu_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menu_item_id_seq OWNER TO foodadmin;

--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 208
-- Name: menu_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: foodadmin
--

ALTER SEQUENCE public.menu_item_id_seq OWNED BY public.menu_item.id;


--
-- TOC entry 219 (class 1259 OID 24880)
-- Name: order_item; Type: TABLE; Schema: public; Owner: foodadmin
--

CREATE TABLE public.order_item (
    id integer NOT NULL,
    order_id integer,
    item_name character varying(255),
    quantity integer
);


ALTER TABLE public.order_item OWNER TO foodadmin;

--
-- TOC entry 218 (class 1259 OID 24878)
-- Name: order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: foodadmin
--

CREATE SEQUENCE public.order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_item_id_seq OWNER TO foodadmin;

--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 218
-- Name: order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: foodadmin
--

ALTER SEQUENCE public.order_item_id_seq OWNED BY public.order_item.id;


--
-- TOC entry 215 (class 1259 OID 24856)
-- Name: order_items; Type: TABLE; Schema: public; Owner: foodadmin
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    item_name character varying(255) NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.order_items OWNER TO foodadmin;

--
-- TOC entry 214 (class 1259 OID 24854)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: foodadmin
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO foodadmin;

--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 214
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: foodadmin
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 213 (class 1259 OID 24841)
-- Name: orders; Type: TABLE; Schema: public; Owner: foodadmin
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    customer_id integer,
    status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO foodadmin;

--
-- TOC entry 212 (class 1259 OID 24839)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: foodadmin
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO foodadmin;

--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 212
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: foodadmin
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 3661 (class 2604 OID 24833)
-- Name: customer id; Type: DEFAULT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.customer ALTER COLUMN id SET DEFAULT nextval('public.customer_id_seq'::regclass);


--
-- TOC entry 3666 (class 2604 OID 24872)
-- Name: customer_order id; Type: DEFAULT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.customer_order ALTER COLUMN id SET DEFAULT nextval('public.customer_order_id_seq'::regclass);


--
-- TOC entry 3668 (class 2604 OID 24896)
-- Name: delivery id; Type: DEFAULT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.delivery ALTER COLUMN id SET DEFAULT nextval('public.delivery_id_seq'::regclass);


--
-- TOC entry 3660 (class 2604 OID 24825)
-- Name: menu_item id; Type: DEFAULT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.menu_item ALTER COLUMN id SET DEFAULT nextval('public.menu_item_id_seq'::regclass);


--
-- TOC entry 3667 (class 2604 OID 24883)
-- Name: order_item id; Type: DEFAULT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.order_item ALTER COLUMN id SET DEFAULT nextval('public.order_item_id_seq'::regclass);


--
-- TOC entry 3665 (class 2604 OID 24859)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 3662 (class 2604 OID 24844)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 3649 (class 0 OID 24764)
-- Dependencies: 205
-- Data for Name: job; Type: TABLE DATA; Schema: cron; Owner: azuresu
--

COPY cron.job (jobid, schedule, command, nodename, nodeport, database, username, active, jobname) FROM stdin;
\.


--
-- TOC entry 3651 (class 0 OID 24785)
-- Dependencies: 207
-- Data for Name: job_run_details; Type: TABLE DATA; Schema: cron; Owner: azuresu
--

COPY cron.job_run_details (jobid, runid, job_pid, database, username, command, status, return_message, start_time, end_time) FROM stdin;
\.


--
-- TOC entry 3827 (class 0 OID 24830)
-- Dependencies: 211
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: foodadmin
--

COPY public.customer (id, name, email) FROM stdin;
\.


--
-- TOC entry 3833 (class 0 OID 24869)
-- Dependencies: 217
-- Data for Name: customer_order; Type: TABLE DATA; Schema: public; Owner: foodadmin
--

COPY public.customer_order (id, customer_name, customer_address) FROM stdin;
1	John Smith	123 Main Street
\.


--
-- TOC entry 3837 (class 0 OID 24893)
-- Dependencies: 221
-- Data for Name: delivery; Type: TABLE DATA; Schema: public; Owner: foodadmin
--

COPY public.delivery (id, order_id, courier_name, status, assigned_at) FROM stdin;
1	0	string	assigned	2025-05-28 15:59:08.733712
\.


--
-- TOC entry 3825 (class 0 OID 24822)
-- Dependencies: 209
-- Data for Name: menu_item; Type: TABLE DATA; Schema: public; Owner: foodadmin
--

COPY public.menu_item (id, name, price) FROM stdin;
1	Margherita Pizza	9.99
2	Veggie Burger	8.50
3	Spaghetti Carbonara	12.25
\.


--
-- TOC entry 3835 (class 0 OID 24880)
-- Dependencies: 219
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: foodadmin
--

COPY public.order_item (id, order_id, item_name, quantity) FROM stdin;
1	1	Burger	2
\.


--
-- TOC entry 3831 (class 0 OID 24856)
-- Dependencies: 215
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: foodadmin
--

COPY public.order_items (id, order_id, item_name, quantity, price) FROM stdin;
\.


--
-- TOC entry 3829 (class 0 OID 24841)
-- Dependencies: 213
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: foodadmin
--

COPY public.orders (id, customer_id, status, created_at) FROM stdin;
\.


--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 204
-- Name: jobid_seq; Type: SEQUENCE SET; Schema: cron; Owner: azuresu
--

SELECT pg_catalog.setval('cron.jobid_seq', 1, false);


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 206
-- Name: runid_seq; Type: SEQUENCE SET; Schema: cron; Owner: azuresu
--

SELECT pg_catalog.setval('cron.runid_seq', 1, false);


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 210
-- Name: customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: foodadmin
--

SELECT pg_catalog.setval('public.customer_id_seq', 1, false);


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 216
-- Name: customer_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: foodadmin
--

SELECT pg_catalog.setval('public.customer_order_id_seq', 1, true);


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 220
-- Name: delivery_id_seq; Type: SEQUENCE SET; Schema: public; Owner: foodadmin
--

SELECT pg_catalog.setval('public.delivery_id_seq', 1, true);


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 208
-- Name: menu_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: foodadmin
--

SELECT pg_catalog.setval('public.menu_item_id_seq', 3, true);


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 218
-- Name: order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: foodadmin
--

SELECT pg_catalog.setval('public.order_item_id_seq', 1, true);


--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 214
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: foodadmin
--

SELECT pg_catalog.setval('public.order_items_id_seq', 1, false);


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 212
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: foodadmin
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, false);


--
-- TOC entry 3686 (class 2606 OID 24877)
-- Name: customer_order customer_order_pkey; Type: CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_pkey PRIMARY KEY (id);


--
-- TOC entry 3680 (class 2606 OID 24838)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- TOC entry 3690 (class 2606 OID 24900)
-- Name: delivery delivery_pkey; Type: CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.delivery
    ADD CONSTRAINT delivery_pkey PRIMARY KEY (id);


--
-- TOC entry 3678 (class 2606 OID 24827)
-- Name: menu_item menu_item_pkey; Type: CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.menu_item
    ADD CONSTRAINT menu_item_pkey PRIMARY KEY (id);


--
-- TOC entry 3688 (class 2606 OID 24885)
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- TOC entry 3684 (class 2606 OID 24861)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3682 (class 2606 OID 24848)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 3693 (class 2606 OID 24886)
-- Name: order_item order_item_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.customer_order(id);


--
-- TOC entry 3692 (class 2606 OID 24862)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- TOC entry 3691 (class 2606 OID 24849)
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: foodadmin
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(id);


--
-- TOC entry 3844 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA cron; Type: ACL; Schema: -; Owner: azuresu
--

GRANT USAGE ON SCHEMA cron TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3845 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: azure_pg_admin
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 3848 (class 0 OID 0)
-- Dependencies: 253
-- Name: FUNCTION alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean) TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3849 (class 0 OID 0)
-- Dependencies: 251
-- Name: FUNCTION job_cache_invalidate(); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.job_cache_invalidate() TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3850 (class 0 OID 0)
-- Dependencies: 249
-- Name: FUNCTION schedule(schedule text, command text); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.schedule(schedule text, command text) TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3851 (class 0 OID 0)
-- Dependencies: 252
-- Name: FUNCTION schedule(job_name text, schedule text, command text); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.schedule(job_name text, schedule text, command text) TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3852 (class 0 OID 0)
-- Dependencies: 254
-- Name: FUNCTION schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean) TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3853 (class 0 OID 0)
-- Dependencies: 250
-- Name: FUNCTION unschedule(job_id bigint); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.unschedule(job_id bigint) TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3854 (class 0 OID 0)
-- Dependencies: 255
-- Name: FUNCTION unschedule(job_name text); Type: ACL; Schema: cron; Owner: azuresu
--

GRANT ALL ON FUNCTION cron.unschedule(job_name text) TO azure_pg_admin WITH GRANT OPTION;


--
-- TOC entry 3855 (class 0 OID 0)
-- Dependencies: 223
-- Name: FUNCTION pg_replication_origin_advance(text, pg_lsn); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_advance(text, pg_lsn) TO azure_pg_admin;


--
-- TOC entry 3856 (class 0 OID 0)
-- Dependencies: 224
-- Name: FUNCTION pg_replication_origin_create(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_create(text) TO azure_pg_admin;


--
-- TOC entry 3857 (class 0 OID 0)
-- Dependencies: 225
-- Name: FUNCTION pg_replication_origin_drop(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_drop(text) TO azure_pg_admin;


--
-- TOC entry 3858 (class 0 OID 0)
-- Dependencies: 226
-- Name: FUNCTION pg_replication_origin_oid(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_oid(text) TO azure_pg_admin;


--
-- TOC entry 3859 (class 0 OID 0)
-- Dependencies: 227
-- Name: FUNCTION pg_replication_origin_progress(text, boolean); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_progress(text, boolean) TO azure_pg_admin;


--
-- TOC entry 3860 (class 0 OID 0)
-- Dependencies: 228
-- Name: FUNCTION pg_replication_origin_session_is_setup(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_is_setup() TO azure_pg_admin;


--
-- TOC entry 3861 (class 0 OID 0)
-- Dependencies: 229
-- Name: FUNCTION pg_replication_origin_session_progress(boolean); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_progress(boolean) TO azure_pg_admin;


--
-- TOC entry 3862 (class 0 OID 0)
-- Dependencies: 230
-- Name: FUNCTION pg_replication_origin_session_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_reset() TO azure_pg_admin;


--
-- TOC entry 3863 (class 0 OID 0)
-- Dependencies: 231
-- Name: FUNCTION pg_replication_origin_session_setup(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_session_setup(text) TO azure_pg_admin;


--
-- TOC entry 3864 (class 0 OID 0)
-- Dependencies: 232
-- Name: FUNCTION pg_replication_origin_xact_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_reset() TO azure_pg_admin;


--
-- TOC entry 3865 (class 0 OID 0)
-- Dependencies: 233
-- Name: FUNCTION pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_replication_origin_xact_setup(pg_lsn, timestamp with time zone) TO azure_pg_admin;


--
-- TOC entry 3866 (class 0 OID 0)
-- Dependencies: 222
-- Name: FUNCTION pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_show_replication_origin_status(OUT local_id oid, OUT external_id text, OUT remote_lsn pg_lsn, OUT local_lsn pg_lsn) TO azure_pg_admin;


--
-- TOC entry 3867 (class 0 OID 0)
-- Dependencies: 234
-- Name: FUNCTION pg_stat_reset(); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset() TO azure_pg_admin;


--
-- TOC entry 3868 (class 0 OID 0)
-- Dependencies: 235
-- Name: FUNCTION pg_stat_reset_shared(text); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_shared(text) TO azure_pg_admin;


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 237
-- Name: FUNCTION pg_stat_reset_single_function_counters(oid); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_single_function_counters(oid) TO azure_pg_admin;


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 236
-- Name: FUNCTION pg_stat_reset_single_table_counters(oid); Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT ALL ON FUNCTION pg_catalog.pg_stat_reset_single_table_counters(oid) TO azure_pg_admin;


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 98
-- Name: COLUMN pg_config.name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(name) ON TABLE pg_catalog.pg_config TO azure_pg_admin;


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 98
-- Name: COLUMN pg_config.setting; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(setting) ON TABLE pg_catalog.pg_config TO azure_pg_admin;


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.line_number; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(line_number) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.type; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(type) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.database; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(database) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.user_name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(user_name) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.address; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(address) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.netmask; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(netmask) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.auth_method; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(auth_method) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.options; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(options) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 95
-- Name: COLUMN pg_hba_file_rules.error; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(error) ON TABLE pg_catalog.pg_hba_file_rules TO azure_pg_admin;


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 138
-- Name: COLUMN pg_replication_origin_status.local_id; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(local_id) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 138
-- Name: COLUMN pg_replication_origin_status.external_id; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(external_id) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 138
-- Name: COLUMN pg_replication_origin_status.remote_lsn; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(remote_lsn) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 138
-- Name: COLUMN pg_replication_origin_status.local_lsn; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(local_lsn) ON TABLE pg_catalog.pg_replication_origin_status TO azure_pg_admin;


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 99
-- Name: COLUMN pg_shmem_allocations.name; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(name) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 99
-- Name: COLUMN pg_shmem_allocations.off; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(off) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 99
-- Name: COLUMN pg_shmem_allocations.size; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(size) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 99
-- Name: COLUMN pg_shmem_allocations.allocated_size; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(allocated_size) ON TABLE pg_catalog.pg_shmem_allocations TO azure_pg_admin;


--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.starelid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(starelid) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.staattnum; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staattnum) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stainherit; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stainherit) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stanullfrac; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanullfrac) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stawidth; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stawidth) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stadistinct; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stadistinct) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stakind1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stakind2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stakind3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stakind4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stakind5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stakind5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.staop1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.staop2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.staop3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.staop4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.staop5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(staop5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stacoll1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stacoll2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stacoll3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stacoll4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stacoll5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stacoll5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stanumbers1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stanumbers2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stanumbers3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stanumbers4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stanumbers5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stanumbers5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stavalues1; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues1) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stavalues2; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues2) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stavalues3; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues3) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stavalues4; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues4) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 43
-- Name: COLUMN pg_statistic.stavalues5; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(stavalues5) ON TABLE pg_catalog.pg_statistic TO azure_pg_admin;


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.oid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(oid) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subdbid; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subdbid) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subname; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subname) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subowner; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subowner) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subenabled; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subenabled) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subconninfo; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subconninfo) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subslotname; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subslotname) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subsynccommit; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subsynccommit) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 68
-- Name: COLUMN pg_subscription.subpublications; Type: ACL; Schema: pg_catalog; Owner: azuresu
--

GRANT SELECT(subpublications) ON TABLE pg_catalog.pg_subscription TO azure_pg_admin;


-- Completed on 2025-05-28 20:46:25

--
-- PostgreSQL database dump complete
--

