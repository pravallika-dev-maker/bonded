--
-- PostgreSQL database dump
--

\restrict 1gWFZdEpKC1Z14nKPnH15sUm4zhdnoPN9TPjN7o0A9wSs3B2CerVbVzp8q2XF8Q

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg12+1)
-- Dumped by pg_dump version 18.1

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

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_daily_insights DROP CONSTRAINT IF EXISTS user_daily_insights_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_daily_comforts DROP CONSTRAINT IF EXISTS user_daily_comforts_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_daily_affirmations DROP CONSTRAINT IF EXISTS user_daily_affirmations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.separations DROP CONSTRAINT IF EXISTS separations_relationship_id_fkey;
ALTER TABLE IF EXISTS ONLY public.separations DROP CONSTRAINT IF EXISTS separations_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.separations DROP CONSTRAINT IF EXISTS separations_creator_id_fkey;
ALTER TABLE IF EXISTS ONLY public.relationships DROP CONSTRAINT IF EXISTS relationships_user2_id_fkey;
ALTER TABLE IF EXISTS ONLY public.relationships DROP CONSTRAINT IF EXISTS relationships_user1_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_sessions DROP CONSTRAINT IF EXISTS reflection_sessions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_sessions DROP CONSTRAINT IF EXISTS reflection_sessions_separation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_questions DROP CONSTRAINT IF EXISTS reflection_questions_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_comparisons DROP CONSTRAINT IF EXISTS reflection_comparisons_user_b_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_comparisons DROP CONSTRAINT IF EXISTS reflection_comparisons_user_a_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_comparisons DROP CONSTRAINT IF EXISTS reflection_comparisons_separation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_answers DROP CONSTRAINT IF EXISTS reflection_answers_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_answers DROP CONSTRAINT IF EXISTS reflection_answers_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reflection_answers DROP CONSTRAINT IF EXISTS reflection_answers_question_id_fkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_recipient_id_fkey;
ALTER TABLE IF EXISTS ONLY public.moods DROP CONSTRAINT IF EXISTS moods_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.letters DROP CONSTRAINT IF EXISTS letters_relationship_id_fkey;
ALTER TABLE IF EXISTS ONLY public.letters DROP CONSTRAINT IF EXISTS letters_partner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.letters DROP CONSTRAINT IF EXISTS letters_author_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invite_codes DROP CONSTRAINT IF EXISTS invite_codes_creator_id_fkey;
DROP INDEX IF EXISTS public.ix_users_phone_number;
DROP INDEX IF EXISTS public.ix_users_id;
DROP INDEX IF EXISTS public.ix_user_daily_insights_user_id;
DROP INDEX IF EXISTS public.ix_user_daily_insights_insight_date;
DROP INDEX IF EXISTS public.ix_user_daily_insights_id;
DROP INDEX IF EXISTS public.ix_user_daily_comforts_user_id;
DROP INDEX IF EXISTS public.ix_user_daily_comforts_id;
DROP INDEX IF EXISTS public.ix_user_daily_comforts_comfort_date;
DROP INDEX IF EXISTS public.ix_user_daily_affirmations_user_id;
DROP INDEX IF EXISTS public.ix_user_daily_affirmations_id;
DROP INDEX IF EXISTS public.ix_user_daily_affirmations_affirmation_date;
DROP INDEX IF EXISTS public.ix_separations_id;
DROP INDEX IF EXISTS public.ix_relationships_id;
DROP INDEX IF EXISTS public.ix_reflection_sessions_user_id;
DROP INDEX IF EXISTS public.ix_reflection_sessions_separation_id;
DROP INDEX IF EXISTS public.ix_reflection_sessions_id;
DROP INDEX IF EXISTS public.ix_reflection_questions_id;
DROP INDEX IF EXISTS public.ix_reflection_comparisons_id;
DROP INDEX IF EXISTS public.ix_reflection_answers_id;
DROP INDEX IF EXISTS public.ix_question_categories_id;
DROP INDEX IF EXISTS public.ix_notifications_id;
DROP INDEX IF EXISTS public.ix_moods_user_id;
DROP INDEX IF EXISTS public.ix_moods_id;
DROP INDEX IF EXISTS public.ix_letters_id;
DROP INDEX IF EXISTS public.ix_invite_codes_id;
DROP INDEX IF EXISTS public.ix_invite_codes_code;
DROP INDEX IF EXISTS public.ix_apscheduler_jobs_next_run_time;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.user_daily_insights DROP CONSTRAINT IF EXISTS user_daily_insights_pkey;
ALTER TABLE IF EXISTS ONLY public.user_daily_comforts DROP CONSTRAINT IF EXISTS user_daily_comforts_pkey;
ALTER TABLE IF EXISTS ONLY public.user_daily_affirmations DROP CONSTRAINT IF EXISTS user_daily_affirmations_pkey;
ALTER TABLE IF EXISTS ONLY public.reflection_sessions DROP CONSTRAINT IF EXISTS uq_user_day_sep;
ALTER TABLE IF EXISTS ONLY public.user_daily_insights DROP CONSTRAINT IF EXISTS uq_user_daily_insight;
ALTER TABLE IF EXISTS ONLY public.user_daily_comforts DROP CONSTRAINT IF EXISTS uq_user_daily_comfort;
ALTER TABLE IF EXISTS ONLY public.user_daily_affirmations DROP CONSTRAINT IF EXISTS uq_user_daily_affirmation;
ALTER TABLE IF EXISTS ONLY public.reflection_comparisons DROP CONSTRAINT IF EXISTS uq_sep_day;
ALTER TABLE IF EXISTS ONLY public.separations DROP CONSTRAINT IF EXISTS separations_pkey;
ALTER TABLE IF EXISTS ONLY public.relationships DROP CONSTRAINT IF EXISTS relationships_pkey;
ALTER TABLE IF EXISTS ONLY public.reflection_sessions DROP CONSTRAINT IF EXISTS reflection_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.reflection_questions DROP CONSTRAINT IF EXISTS reflection_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.reflection_questions DROP CONSTRAINT IF EXISTS reflection_questions_day_number_key;
ALTER TABLE IF EXISTS ONLY public.reflection_comparisons DROP CONSTRAINT IF EXISTS reflection_comparisons_pkey;
ALTER TABLE IF EXISTS ONLY public.reflection_answers DROP CONSTRAINT IF EXISTS reflection_answers_pkey;
ALTER TABLE IF EXISTS ONLY public.question_categories DROP CONSTRAINT IF EXISTS question_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.moods DROP CONSTRAINT IF EXISTS moods_pkey;
ALTER TABLE IF EXISTS ONLY public.letters DROP CONSTRAINT IF EXISTS letters_pkey;
ALTER TABLE IF EXISTS ONLY public.invite_codes DROP CONSTRAINT IF EXISTS invite_codes_pkey;
ALTER TABLE IF EXISTS ONLY public.apscheduler_jobs DROP CONSTRAINT IF EXISTS apscheduler_jobs_pkey;
ALTER TABLE IF EXISTS ONLY public.alembic_version DROP CONSTRAINT IF EXISTS alembic_version_pkc;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.user_daily_insights ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.user_daily_comforts ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.user_daily_affirmations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.separations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.relationships ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reflection_sessions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reflection_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reflection_comparisons ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reflection_answers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.question_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.notifications ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.moods ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.letters ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.invite_codes ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.user_daily_insights_id_seq;
DROP TABLE IF EXISTS public.user_daily_insights;
DROP SEQUENCE IF EXISTS public.user_daily_comforts_id_seq;
DROP TABLE IF EXISTS public.user_daily_comforts;
DROP SEQUENCE IF EXISTS public.user_daily_affirmations_id_seq;
DROP TABLE IF EXISTS public.user_daily_affirmations;
DROP SEQUENCE IF EXISTS public.separations_id_seq;
DROP TABLE IF EXISTS public.separations;
DROP SEQUENCE IF EXISTS public.relationships_id_seq;
DROP TABLE IF EXISTS public.relationships;
DROP SEQUENCE IF EXISTS public.reflection_sessions_id_seq;
DROP TABLE IF EXISTS public.reflection_sessions;
DROP SEQUENCE IF EXISTS public.reflection_questions_id_seq;
DROP TABLE IF EXISTS public.reflection_questions;
DROP SEQUENCE IF EXISTS public.reflection_comparisons_id_seq;
DROP TABLE IF EXISTS public.reflection_comparisons;
DROP SEQUENCE IF EXISTS public.reflection_answers_id_seq;
DROP TABLE IF EXISTS public.reflection_answers;
DROP SEQUENCE IF EXISTS public.question_categories_id_seq;
DROP TABLE IF EXISTS public.question_categories;
DROP SEQUENCE IF EXISTS public.notifications_id_seq;
DROP TABLE IF EXISTS public.notifications;
DROP SEQUENCE IF EXISTS public.moods_id_seq;
DROP TABLE IF EXISTS public.moods;
DROP SEQUENCE IF EXISTS public.letters_id_seq;
DROP TABLE IF EXISTS public.letters;
DROP SEQUENCE IF EXISTS public.invite_codes_id_seq;
DROP TABLE IF EXISTS public.invite_codes;
DROP TABLE IF EXISTS public.apscheduler_jobs;
DROP TABLE IF EXISTS public.alembic_version;
-- *not* dropping schema, since initdb creates it
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: apscheduler_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apscheduler_jobs (
    id character varying(191) NOT NULL,
    next_run_time double precision,
    job_state bytea NOT NULL
);


--
-- Name: invite_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invite_codes (
    id integer NOT NULL,
    code character varying(20) NOT NULL,
    creator_id integer,
    is_used boolean,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: invite_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invite_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invite_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invite_codes_id_seq OWNED BY public.invite_codes.id;


--
-- Name: letters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.letters (
    id integer NOT NULL,
    author_id integer NOT NULL,
    partner_id integer,
    title character varying(255),
    content text NOT NULL,
    letter_type character varying(50),
    ai_love_score integer,
    is_revealed boolean,
    created_at timestamp with time zone DEFAULT now(),
    relationship_id integer
);


--
-- Name: letters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.letters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: letters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.letters_id_seq OWNED BY public.letters.id;


--
-- Name: moods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moods (
    id integer NOT NULL,
    user_id integer NOT NULL,
    mood character varying NOT NULL,
    reflection text,
    created_at timestamp with time zone DEFAULT now(),
    ai_quote text,
    ai_advice text,
    partner_name character varying
);


--
-- Name: moods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moods_id_seq OWNED BY public.moods.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    recipient_id integer,
    notification_type character varying(50) NOT NULL,
    title character varying(200) NOT NULL,
    body text,
    is_read boolean,
    created_at timestamp without time zone,
    push_sent boolean DEFAULT false
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: question_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    color_hex character varying(10),
    sort_order integer
);


--
-- Name: question_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.question_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.question_categories_id_seq OWNED BY public.question_categories.id;


--
-- Name: reflection_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reflection_answers (
    id integer NOT NULL,
    session_id integer,
    user_id integer,
    question_id integer,
    text_answer text,
    ai_emotion_detected character varying(50),
    ai_tone character varying(30),
    ai_reaction_text text,
    ai_processed boolean,
    answered_at timestamp without time zone
);


--
-- Name: reflection_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reflection_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reflection_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reflection_answers_id_seq OWNED BY public.reflection_answers.id;


--
-- Name: reflection_comparisons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reflection_comparisons (
    id integer NOT NULL,
    separation_id integer,
    day_number integer NOT NULL,
    user_a_session_id integer,
    user_b_session_id integer,
    comparison_data jsonb,
    suggestions jsonb,
    generated_at timestamp without time zone
);


--
-- Name: reflection_comparisons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reflection_comparisons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reflection_comparisons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reflection_comparisons_id_seq OWNED BY public.reflection_comparisons.id;


--
-- Name: reflection_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reflection_questions (
    id integer NOT NULL,
    day_number integer NOT NULL,
    category_id integer,
    question_type character varying(20) NOT NULL,
    question_text character varying(600) NOT NULL,
    scenario_prefix text,
    hint_text character varying(300),
    is_active boolean
);


--
-- Name: reflection_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reflection_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reflection_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reflection_questions_id_seq OWNED BY public.reflection_questions.id;


--
-- Name: reflection_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reflection_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    separation_id integer,
    day_number integer NOT NULL,
    is_completed boolean,
    completed_at timestamp without time zone,
    created_at timestamp without time zone
);


--
-- Name: reflection_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reflection_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reflection_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reflection_sessions_id_seq OWNED BY public.reflection_sessions.id;


--
-- Name: relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relationships (
    id integer NOT NULL,
    user1_id integer NOT NULL,
    user2_id integer NOT NULL,
    status character varying(20),
    journey_score integer,
    created_at timestamp without time zone,
    ended_at timestamp without time zone,
    summary_insight character varying,
    relationship_type character varying(50),
    user1_name character varying(100),
    user2_name character varying(100)
);


--
-- Name: relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relationships_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relationships_id_seq OWNED BY public.relationships.id;


--
-- Name: separations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.separations (
    id integer NOT NULL,
    creator_id integer,
    partner_id integer,
    duration_label character varying(50),
    start_date date NOT NULL,
    reason text,
    status character varying(20),
    closing_insight text,
    expected_end_date date,
    ended_at timestamp without time zone,
    created_at timestamp without time zone,
    relationship_id integer
);


--
-- Name: separations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.separations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: separations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.separations_id_seq OWNED BY public.separations.id;


--
-- Name: user_daily_affirmations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_daily_affirmations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    affirmation_date date NOT NULL,
    text character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_daily_affirmations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_daily_affirmations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_daily_affirmations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_daily_affirmations_id_seq OWNED BY public.user_daily_affirmations.id;


--
-- Name: user_daily_comforts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_daily_comforts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    comfort_date date NOT NULL,
    text character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_daily_comforts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_daily_comforts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_daily_comforts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_daily_comforts_id_seq OWNED BY public.user_daily_comforts.id;


--
-- Name: user_daily_insights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_daily_insights (
    id integer NOT NULL,
    user_id integer NOT NULL,
    insight_date date NOT NULL,
    text character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    is_viewed boolean NOT NULL,
    viewed_at timestamp with time zone
);


--
-- Name: user_daily_insights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_daily_insights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_daily_insights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_daily_insights_id_seq OWNED BY public.user_daily_insights.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    phone_number character varying,
    country_code character varying,
    is_active boolean,
    created_at timestamp without time zone,
    user_name character varying,
    relation_type character varying,
    partner_name character varying,
    relationship_date date,
    dob date,
    partner_id integer,
    is_partnered boolean,
    gender character varying,
    relationship_score integer DEFAULT 0,
    fcm_token character varying,
    notifications_enabled boolean DEFAULT true,
    last_active_at timestamp without time zone,
    has_acknowledged_completion boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: invite_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invite_codes ALTER COLUMN id SET DEFAULT nextval('public.invite_codes_id_seq'::regclass);


--
-- Name: letters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letters ALTER COLUMN id SET DEFAULT nextval('public.letters_id_seq'::regclass);


--
-- Name: moods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moods ALTER COLUMN id SET DEFAULT nextval('public.moods_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: question_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_categories ALTER COLUMN id SET DEFAULT nextval('public.question_categories_id_seq'::regclass);


--
-- Name: reflection_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_answers ALTER COLUMN id SET DEFAULT nextval('public.reflection_answers_id_seq'::regclass);


--
-- Name: reflection_comparisons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_comparisons ALTER COLUMN id SET DEFAULT nextval('public.reflection_comparisons_id_seq'::regclass);


--
-- Name: reflection_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_questions ALTER COLUMN id SET DEFAULT nextval('public.reflection_questions_id_seq'::regclass);


--
-- Name: reflection_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_sessions ALTER COLUMN id SET DEFAULT nextval('public.reflection_sessions_id_seq'::regclass);


--
-- Name: relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships ALTER COLUMN id SET DEFAULT nextval('public.relationships_id_seq'::regclass);


--
-- Name: separations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.separations ALTER COLUMN id SET DEFAULT nextval('public.separations_id_seq'::regclass);


--
-- Name: user_daily_affirmations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_affirmations ALTER COLUMN id SET DEFAULT nextval('public.user_daily_affirmations_id_seq'::regclass);


--
-- Name: user_daily_comforts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_comforts ALTER COLUMN id SET DEFAULT nextval('public.user_daily_comforts_id_seq'::regclass);


--
-- Name: user_daily_insights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_insights ALTER COLUMN id SET DEFAULT nextval('public.user_daily_insights_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
15b8895c9f85
\.


--
-- Data for Name: apscheduler_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.apscheduler_jobs (id, next_run_time, job_state) FROM stdin;
halfway_mark_encouragement_job	1781697600	\\x8005954f040000000000007d94288c0776657273696f6e944b018c026964948c1e68616c667761795f6d61726b5f656e636f75726167656d656e745f6a6f62948c0466756e63948c3d6170702e73657276696365732e7363686564756c65725f736572766963653a72756e5f68616c667761795f6d61726b5f656e636f75726167656d656e74948c0774726967676572948c1961707363686564756c65722e74726967676572732e63726f6e948c0b43726f6e547269676765729493942981947d942868014b028c0874696d657a6f6e65948c086275696c74696e73948c07676574617474729493948c087a6f6e65696e666f948c085a6f6e65496e666f9493948c095f756e7069636b6c6594869452948c074574632f555443944b01869452948c0a73746172745f64617465944e8c08656e645f64617465944e8c066669656c6473945d94288c2061707363686564756c65722e74726967676572732e63726f6e2e6669656c6473948c09426173654669656c649493942981947d94288c046e616d65948c0479656172948c0a69735f64656661756c7494888c0b65787072657373696f6e73945d948c2561707363686564756c65722e74726967676572732e63726f6e2e65787072657373696f6e73948c0d416c6c45787072657373696f6e9493942981947d948c0473746570944e7362617562681d8c0a4d6f6e74684669656c649493942981947d942868228c056d6f6e74689468248868255d9468292981947d94682c4e7362617562681d8c0f4461794f664d6f6e74684669656c649493942981947d942868228c036461799468248868255d9468292981947d94682c4e7362617562681d8c095765656b4669656c649493942981947d942868228c047765656b9468248868255d9468292981947d94682c4e7362617562681d8c0e4461794f665765656b4669656c649493942981947d942868228c0b6461795f6f665f7765656b9468248868255d9468292981947d94682c4e7362617562681f2981947d942868228c04686f75729468248968255d9468278c0f52616e676545787072657373696f6e9493942981947d9428682c4e8c056669727374944b0c8c046c617374944b0c7562617562681f2981947d942868228c066d696e7574659468248968255d9468522981947d9428682c4e68554b0068564b007562617562681f2981947d942868228c067365636f6e649468248868255d9468522981947d9428682c4e68554b0068564b007562617562658c066a6974746572944e75628c086578656375746f72948c0764656661756c74948c046172677394298c066b7761726773947d9468228c1e72756e5f68616c667761795f6d61726b5f656e636f75726167656d656e74948c126d6973666972655f67726163655f74696d65944b018c08636f616c6573636594888c0d6d61785f696e7374616e636573944b018c0d6e6578745f72756e5f74696d65948c086461746574696d65948c086461746574696d65949394430a07ea06110c000000000094681886945294752e
evening_checkin_nudge_job	1781726400	\\x80059540040000000000007d94288c0776657273696f6e944b018c026964948c196576656e696e675f636865636b696e5f6e756467655f6a6f62948c0466756e63948c386170702e73657276696365732e7363686564756c65725f736572766963653a72756e5f6576656e696e675f636865636b696e5f6e75646765948c0774726967676572948c1961707363686564756c65722e74726967676572732e63726f6e948c0b43726f6e547269676765729493942981947d942868014b028c0874696d657a6f6e65948c086275696c74696e73948c07676574617474729493948c087a6f6e65696e666f948c085a6f6e65496e666f9493948c095f756e7069636b6c6594869452948c074574632f555443944b01869452948c0a73746172745f64617465944e8c08656e645f64617465944e8c066669656c6473945d94288c2061707363686564756c65722e74726967676572732e63726f6e2e6669656c6473948c09426173654669656c649493942981947d94288c046e616d65948c0479656172948c0a69735f64656661756c7494888c0b65787072657373696f6e73945d948c2561707363686564756c65722e74726967676572732e63726f6e2e65787072657373696f6e73948c0d416c6c45787072657373696f6e9493942981947d948c0473746570944e7362617562681d8c0a4d6f6e74684669656c649493942981947d942868228c056d6f6e74689468248868255d9468292981947d94682c4e7362617562681d8c0f4461794f664d6f6e74684669656c649493942981947d942868228c036461799468248868255d9468292981947d94682c4e7362617562681d8c095765656b4669656c649493942981947d942868228c047765656b9468248868255d9468292981947d94682c4e7362617562681d8c0e4461794f665765656b4669656c649493942981947d942868228c0b6461795f6f665f7765656b9468248868255d9468292981947d94682c4e7362617562681f2981947d942868228c04686f75729468248968255d9468278c0f52616e676545787072657373696f6e9493942981947d9428682c4e8c056669727374944b148c046c617374944b147562617562681f2981947d942868228c066d696e7574659468248968255d9468522981947d9428682c4e68554b0068564b007562617562681f2981947d942868228c067365636f6e649468248868255d9468522981947d9428682c4e68554b0068564b007562617562658c066a6974746572944e75628c086578656375746f72948c0764656661756c74948c046172677394298c066b7761726773947d9468228c1972756e5f6576656e696e675f636865636b696e5f6e75646765948c126d6973666972655f67726163655f74696d65944b018c08636f616c6573636594888c0d6d61785f696e7374616e636573944b018c0d6e6578745f72756e5f74696d65948c086461746574696d65948c086461746574696d65949394430a07ea061114000000000094681886945294752e
\.


--
-- Data for Name: invite_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invite_codes (id, code, creator_id, is_used, expires_at, created_at) FROM stdin;
1	IRIS-7	2	t	2026-05-20 06:33:23.760709	2026-05-19 06:33:23.761488
56	ROSE-1	15	f	2026-05-24 12:14:21.100752	2026-05-23 12:14:21.101085
5	SAGE-8	4	t	2026-05-20 07:47:28.132723	2026-05-19 07:47:28.132992
422	MIST-5754	74	f	2026-06-17 17:40:46.156583	2026-06-16 17:40:46.15689
7	IRIS-8	6	t	2026-05-20 07:59:19.222205	2026-05-19 07:59:19.22251
423	MOON-4531	73	f	2026-06-17 19:27:20.057249	2026-06-16 19:27:20.058114
373	CALM-5662	51	t	2026-06-16 12:41:04.504478	2026-06-15 12:41:04.50521
424	MIST-4041	75	f	2026-06-18 05:14:10.030757	2026-06-17 05:14:10.031792
375	DAWN-9797	22	t	2026-06-16 13:07:21.099148	2026-06-15 13:07:21.099474
376	BLISS-8224	22	f	2026-06-16 13:52:17.925002	2026-06-15 13:52:17.925323
377	MIST-4765	54	t	2026-06-16 14:06:22.850894	2026-06-15 14:06:22.851273
378	DOVE-6073	54	t	2026-06-16 14:10:15.189398	2026-06-15 14:10:15.189654
379	LARK-9783	54	f	2026-06-16 14:43:15.67334	2026-06-15 14:43:15.674084
380	TIDE-4857	55	f	2026-06-16 15:48:57.751686	2026-06-15 15:48:57.752659
381	TIDE-2769	50	t	2026-06-16 17:00:55.264576	2026-06-15 17:00:55.265544
75	SAGE-7	16	f	2026-06-05 06:16:20.634992	2026-06-04 06:16:20.635248
334	LARK-5767	22	t	2026-06-12 18:40:07.587684	2026-06-11 18:40:07.58812
339	ECHO-3672	25	f	2026-06-13 05:39:35.862391	2026-06-12 05:39:35.862745
386	MOON-8786	59	f	2026-06-16 20:37:48.301891	2026-06-15 20:37:48.302212
387	NOVA-4999	60	f	2026-06-17 03:37:23.328077	2026-06-16 03:37:23.32895
344	JEWEL-6633	26	t	2026-06-13 06:15:39.291016	2026-06-12 06:15:39.292587
389	SAGE-6464	61	f	2026-06-17 05:12:14.594344	2026-06-16 05:12:14.594697
390	LUNA-5863	62	f	2026-06-17 05:21:31.150075	2026-06-16 05:21:31.150429
248	GRACE-8635	4	t	2026-06-11 07:26:01.197294	2026-06-10 07:26:01.198216
49	LUNA-9	14	f	2026-05-24 11:12:41.754836	2026-05-23 11:12:41.755164
397	STAR-8092	64	f	2026-06-17 06:47:52.976009	2026-06-16 06:47:52.9763
355	IRIS-5622	36	t	2026-06-13 10:33:44.311408	2026-06-12 10:33:44.31217
356	MOON-1768	36	t	2026-06-13 14:40:12.837678	2026-06-12 14:40:12.838726
358	DOVE-3454	39	t	2026-06-14 19:20:48.677696	2026-06-13 19:20:48.678717
357	HAZE-9668	38	t	2026-06-14 10:25:34.301724	2026-06-13 10:25:34.303424
361	OPAL-6402	41	f	2026-06-15 11:36:39.543145	2026-06-14 11:36:39.544151
360	MIST-9099	4	t	2026-06-15 08:49:32.654808	2026-06-14 08:49:32.655151
362	WAVE-6083	43	t	2026-06-15 14:59:39.524244	2026-06-14 14:59:39.524882
364	MIST-9124	43	t	2026-06-15 15:05:47.871479	2026-06-14 15:05:47.871798
366	BLOOM-1448	46	f	2026-06-16 06:06:52.562856	2026-06-15 06:06:52.563658
367	MOON-6990	2	f	2026-06-16 08:04:40.734004	2026-06-15 08:04:40.734998
369	BLISS-2590	48	f	2026-06-16 08:17:32.985272	2026-06-15 08:17:32.985603
368	EDEN-8626	47	t	2026-06-16 08:14:13.595511	2026-06-15 08:14:13.595791
370	BLISS-7557	38	t	2026-06-16 09:38:54.520569	2026-06-15 09:38:54.521377
404	WAVE-4637	66	f	2026-06-17 07:44:01.990537	2026-06-16 07:44:01.9909
414	DOVE-1092	50	f	2026-06-17 12:52:13.73591	2026-06-16 12:52:13.736308
416	BLOOM-8163	70	f	2026-06-17 14:06:36.565224	2026-06-16 14:06:36.56636
388	DUSK-6606	4	t	2026-06-17 05:10:22.763991	2026-06-16 05:10:22.764285
417	FERN-2164	4	f	2026-06-17 14:53:09.855217	2026-06-16 14:53:09.855712
418	LUNA-4892	71	t	2026-06-17 15:50:41.522116	2026-06-16 15:50:41.522514
\.


--
-- Data for Name: letters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.letters (id, author_id, partner_id, title, content, letter_type, ai_love_score, is_revealed, created_at, relationship_id) FROM stdin;
1	3	2	Thinking of us	I know things have been hard lately, but I truly appreciate how much you tried. I miss your smile. I want us to communicate better and create a safer space for our love.	\N	0	f	2026-05-19 10:04:26.97569+00	1
2	3	2	A note for you	I am so grateful to have you in my life. Even in this space, I miss you and I cherish every memory we have made together.	\N	0	f	2026-05-19 11:17:11.946982+00	1
6	4	6	Reflection	hiiiiiiiiiiiiiiiiiiii	feelings	85	f	2026-06-06 09:02:42.354757+00	2
7	4	6	Reflection	hiiiiiiiiii	feelings	88	f	2026-06-06 09:27:09.36889+00	2
11	4	\N	Funny	hiiii	funny	82	f	2026-06-09 08:17:14.946006+00	\N
12	4	\N	Heartfelt	hiii	heartfelt	85	f	2026-06-09 08:27:20.849746+00	\N
14	4	\N	Apology	hiiii	apology	85	f	2026-06-10 06:06:33.856467+00	\N
15	4	\N	Heartfelt	hii	heartfelt	80	f	2026-06-10 06:16:53.418509+00	\N
17	4	\N	love123	love123	string	50	f	2026-06-10 06:35:41.865127+00	\N
18	4	\N	love123	love123	string	0	f	2026-06-10 06:36:15.797367+00	\N
22	36	38	Heartfelt	feeling missing him	heartfelt	85	f	2026-06-12 17:44:08.363621+00	16
23	38	36	Heartfelt	hello arjun	heartfelt	70	f	2026-06-12 18:16:22.546942+00	16
24	38	36	Heartfelt	feeling alone	heartfelt	85	f	2026-06-12 18:42:53.908789+00	16
27	47	48	Funny	hiiiiiiii	funny	85	f	2026-06-15 08:25:18.784688+00	23
28	73	72	Heartfelt	I miss her and I love very much	heartfelt	85	f	2026-06-16 17:17:59.141282+00	53
29	50	51	Heartfelt	I love her ,I ma missing her smile ,i love her very much	heartfelt	0	f	2026-06-17 05:53:53.417738+00	31
30	50	51	Heartfelt	hi	heartfelt	0	f	2026-06-17 07:58:11.06825+00	31
\.


--
-- Data for Name: moods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.moods (id, user_id, mood, reflection, created_at, ai_quote, ai_advice, partner_name) FROM stdin;
1	4	Peaceful		2026-05-19 07:07:10.016469+00	\N	\N	\N
2	3	longing	I heard our song on the radio today and it made me miss her a lot.	2026-05-19 07:12:39.237041+00	\N	\N	\N
3	4	Reflective		2026-05-19 07:20:42.453723+00	\N	\N	\N
4	3	longing	I heard our song on the radio today and it made me miss her a lot.	2026-05-19 07:23:45.506238+00	\N	\N	\N
5	4	Reflective		2026-05-19 08:04:21.700246+00	\N	\N	\N
6	3	peaceful	Feeling very calm and hopeful today.	2026-05-19 11:16:49.884011+00	\N	\N	\N
237	70	Peaceful	feeling peaceful	2026-06-16 14:19:36.075897+00	This quiet hum of peace, a gentle current found, flowing through the space that's now uniquely yours.	It's truly beautiful to hear you're feeling peaceful in this moment. This quiet calm is not just an absence of turmoil, but a profound space where gentle self-discovery can begin to blossom. Allow yourself to fully embrace and cherish this unexpected serenity; it's a profound affirmation of your inner resilience and a gentle invitation to explore what truly nourishes your soul going forward.	Bhagya
239	73	Peaceful	peace 🕊️	2026-06-16 16:54:43.245623+00	Sometimes, a quiet grace settles where endings used to be, revealing the gentle dawn of your own peace.	What a beautiful and profound space to find yourself in. Allow this peacefulness to simply be, like a soft blanket wrapped around your heart. There's no need to question its arrival; just breathe into its gentle comfort and know it's a gift you deserve.	Hh
241	73	Peaceful		2026-06-16 19:29:01.011013+00	Amidst the turning tides, you've found a quiet shore within, where peace whispers the promise of your own unfolding horizon.	Cherish this profound sense of peace; it's a precious gift, a testament to your inner strength and resilience. Allow it to be your gentle anchor, a quiet space where you can simply *be* and discover what unfolds next, without pressure or expectation.	\N
248	51	longing	peace	2026-06-17 07:56:28.970527+00	The ache of missing someone is love with nowhere to go — hold it gently.	Longing is a sign of how deeply you care. Let it remind you of what matters, not what's missing.	\N
16	13	peaceful	Listening to the rain and finding stillness inside.	2026-05-22 07:07:30.68524+00	\N	\N	\N
17	13	peaceful	i want more peace	2026-05-22 07:08:18.368892+00	\N	\N	\N
19	4	Peaceful		2026-06-06 08:48:38.238658+00	A quiet grace has settled in your soul, a soft, steady breath after the storm has passed.	That feeling of peace is a precious, vital thing right now. Allow yourself to truly sink into its quiet embrace, knowing it’s a testament to your resilience and capacity for gentle healing. Cherish this stillness, and simply observe with kindness whatever other feelings might softly rise and fall.	\N
20	4	Peaceful		2026-06-06 09:27:47.716543+00	The quiet after the storm isn't empty, but a soft, unexpected peace, a gentle dawn within your heart.	Embrace this profound and valid peace you're feeling right now. It's a precious gift, a quiet space to simply be and listen to the gentle whispers of your own heart. Allow it to guide you tenderly as you continue to navigate this path, without judgment, just quiet acceptance.	\N
21	1	loving	love	2026-06-11 07:14:14.002117+00	Even the hardest seasons leave something beautiful behind.	Take a breath. You are doing better than you think.	\N
22	4	Reflective		2026-06-11 07:24:39.880672+00	The quiet whispers of yesterday trace the soft contours of who you are becoming, piece by gentle piece.	Embrace this reflective space; it's a sacred pause where your heart gently sifts through memories, not to relive pain, but to unearth wisdom and understand the quiet strength you've cultivated. Allow yourself the grace to simply *be* in this moment, knowing that deep understanding often blooms in stillness.	\N
25	36	Peaceful	feeling peace today thinking about her	2026-06-12 10:52:24.536775+00	Peace is not the absence of pain — it is the decision to breathe through it.	This stillness you feel is earned. Stay in it. You don't have to fix anything today.	\N
26	36	Peaceful		2026-06-12 10:55:30.956725+00	Peace is not the absence of pain — it is the decision to breathe through it.	This stillness you feel is earned. Stay in it. You don't have to fix anything today.	\N
27	38	Growing	thinking about you	2026-06-12 19:10:54.938825+00	The spaces left behind are not empty, but rich soil. Feel your spirit stretch, reaching for its own new light.	That 'growing' feeling is a truly wonderful sign, showing how deeply your spirit is working to embrace change and find new strengths. It's okay for this process to feel tender and powerful all at once. Lean into this unfolding, honoring every small step and new insight you discover about yourself, and know that I'm always here, thinking of you too, holding steady space for your journey.	\N
28	38	Longing	love	2026-06-14 02:24:48.635332+00	Longing is the heart's quiet prayer for what was, a testament to the beautiful love you held.	That profound feeling of longing is a testament to the depth of love you've known, and it's okay to let it be present for a while. Allow yourself to feel that ache, gently, without judgment; it's a tender echo of something truly precious that shaped you.	\N
29	41	Growing	thinking	2026-06-14 12:20:52.18614+00	The quiet holds a whisper of new bloom. Your roots are deepening, finding new soil, as you courageously unfurl.	It sounds like you're in a powerful, introspective phase of transformation. Allow yourself the quiet space to feel and think deeply about what's emerging within you. Trust that this 'growing' is gently guiding you towards your truest self, one brave step at a time.	soma
30	43	Longing		2026-06-14 15:00:12.517628+00	The ache of missing someone is love with nowhere to go — hold it gently.	Longing is a sign of how deeply you care. Let it remind you of what matters, not what's missing.	Alex
228	55	Peaceful	hii	2026-06-15 16:37:20.571822+00	The quiet peace you find now isn't an ending, but the gentle whisper of your own unfolding truth.	That sense of peace is a gentle, precious gift to acknowledge right now. Allow yourself to simply rest within it, appreciating this quiet space for its own sake, without needing to define or rush anything.	Pra
232	50	Reflective	I am always thinking about her	2026-06-16 03:29:49.7945+00	Your heart, a quiet shore, still feels the ebb and flow of her memory, a constant, tender tide.	It's truly understandable that her presence lingers so vividly in your thoughts right now, especially when you're in this reflective space. Give yourself permission to sit with these memories and feelings without judgment; it's a tender, necessary part of processing your experience. Remember, even in reflection, you're gently moving through this, honoring the past while slowly understanding your way forward.	Al
236	4	Reflective		2026-06-16 14:18:22.205265+00	The quiet pause of reflection isn't an ending, but the sacred space where your soul gathers light for its next, truest becoming.	This reflective space you're in right now is truly precious. Allow yourself to wander through your thoughts gently, without judgment or the need to rush to any conclusions; it's a vital part of processing and understanding. This quiet time can reveal so much about your own strength and what truly matters to you moving forward.	hi
238	17	Longing		2026-06-16 15:41:01.987372+00	Your soul traces the lines of a missing embrace, a quiet ache for a story unfinished.	That deep longing you feel is a tender echo of the love and connection you once shared, a testament to how real it was. Allow it to be present without judgment, letting it gently remind you of your own capacity to love and be loved. Each breath you take is a quiet step towards discovering new warmth within your own heart.	\N
240	74	Longing		2026-06-16 17:27:07.405707+00	Your heart, a quiet shore, still feels the phantom touch of a tide that has turned.	This feeling of longing is a tender testament to the love you held and the deep connection that was real. Allow yourself to gently lean into it, acknowledging its presence without judgment, for it speaks volumes about your capacity to care. As you honor these feelings, remember to also wrap that same compassion around yourself, knowing it's a part of healing's tender journey.	Alex
242	50	Peaceful	feeling peace in her thoughts	2026-06-17 05:49:51.403783+00	Peace is not the absence of pain — it is the decision to breathe through it.	This stillness you feel is earned. Stay in it. You don't have to fix anything today.	Al
208	2	Peaceful		2026-06-15 05:57:03.466895+00	Peace is not the absence of pain — it is the decision to breathe through it.	This stillness you feel is earned. Stay in it. You don't have to fix anything today.	Sam
210	47	Longing		2026-06-15 08:23:47.445712+00	The ache of missing someone is love with nowhere to go — hold it gently.	Longing is a sign of how deeply you care. Let it remind you of what matters, not what's missing.	Charan
219	17	Longing		2026-06-15 12:28:00.772753+00	This ache is a phantom limb of us, reaching for a touch that only lives in memory.	Dear one, that deep longing you feel is a tender ache, a quiet testament to the love and connection you once shared. It's okay to let it gently wash over you, without judgment, for it speaks to the depth of your heart. In these moments, simply hold yourself with the same compassion you'd offer a dearest friend.	\N
221	54	Peaceful	hii	2026-06-15 14:14:12.57193+00	Peace is not the absence of pain — it is the decision to breathe through it.	This stillness you feel is earned. Stay in it. You don't have to fix anything today.	\N
229	50	Longing		2026-06-15 17:07:09.459646+00	The ache of missing someone is love with nowhere to go — hold it gently.	Longing is a sign of how deeply you care. Let it remind you of what matters, not what's missing.	Al
231	58	Peaceful		2026-06-15 19:44:33.92268+00	Peace is not the absence of pain — it is the decision to breathe through it.	This stillness you feel is earned. Stay in it. You don't have to fix anything today.	Hrllo
233	60	Longing		2026-06-16 03:40:07.130064+00	Your heart, a quiet ocean, still whispers the name of a shore it longs to touch once more.	That deep longing is a testament to the beautiful connection you once shared, and it’s okay for your heart to feel that pull. Give yourself permission to truly feel that ache, holding it gently without judgment. It’s a quiet conversation between your past and your present self, and with time, its intensity will gently soften.	Charan
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, recipient_id, notification_type, title, body, is_read, created_at, push_sent) FROM stdin;
1	2	separation_started	lucy has started a space	You're both in this together.	f	2026-05-19 06:46:57.901913	f
2	3	separation_started	Alex has started a space	You're both in this together.	f	2026-05-19 06:49:18.16013	f
3	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-19 08:49:42.404285	f
4	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-19 08:51:06.349083	f
5	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-19 08:53:03.768425	f
6	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-19 09:00:22.873515	f
7	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-19 09:03:44.670318	f
8	2	partner_checked_in	lucy completed today's reflection	Their answer is waiting. Complete yours to see the comparison.	f	2026-05-19 09:58:20.031435	f
9	3	comparison_ready	Your reflections are aligned ✨	Both of you completed today's reflection. See how your answers compare.	f	2026-05-19 09:58:20.671173	f
10	2	comparison_ready	Your reflections are aligned ✨	Both of you completed today's reflection. See how your answers compare.	f	2026-05-19 09:58:20.681013	f
11	2	separation_started	lucy has started a space	You're both in this together.	f	2026-05-19 11:31:24.10659	f
12	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-23 06:18:34.478747	f
13	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-23 06:56:46.573361	f
14	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-23 07:00:36.379017	f
15	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-23 10:11:24.160467	f
16	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-05-23 10:11:52.294565	f
17	6	separation_started	Your partner has started a space	You're both in this together.	f	2026-06-04 08:49:40.630498	f
20	6	partner_mood	🌤️ Your partner is feeling Peaceful	They logged how they're feeling today.	f	2026-06-06 08:48:49.600031	f
21	6	letter_written	💌 A letter arrived	Your partner wrote you something. It reveals when the time is right.	f	2026-06-06 09:02:46.196258	f
22	6	letter_written	💌 A letter arrived	Your partner wrote you something. It reveals when the time is right.	f	2026-06-06 09:27:17.199147	f
316	73	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-16 16:54:48.193126	t
24	6	partner_mood	🌤️ Your partner is feeling Peaceful	They logged how they're feeling today.	f	2026-06-06 09:27:55.09977	f
25	6	letter_written	💌 A letter arrived	Your partner wrote you something. It reveals when the time is right.	f	2026-06-06 10:31:06.85702	f
27	6	separation_started	🌿 Space has begun	Your partner started a separation.	f	2026-06-08 09:20:44.238387	f
328	73	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-16 19:29:07.768425	t
29	6	separation_started	🌿 Space has begun	Your partner started a separation.	f	2026-06-08 10:17:38.466897	f
335	46	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-17 06:28:26.586228	t
45	6	separation_started	🌿 Space has begun	Your partner started a separation.	f	2026-06-08 10:49:59.877638	f
46	6	separation_started	🌿 Space has begun	Your partner started a separation.	f	2026-06-08 10:53:51.581879	f
47	6	separation_ended	🌅 Space has ended	Your partner ended the separation.	f	2026-06-08 10:55:11.991547	f
48	6	partner_disconnected	Your bond has been disconnected	Your partner has disconnected.	f	2026-06-08 14:53:28.767541	f
52	19	letter_written	💌 A letter arrived	Your partner wrote you something. It reveals when the time is right.	f	2026-06-08 15:16:35.850815	f
53	19	partner_disconnected	Your bond has been disconnected	pravallika has disconnected.	f	2026-06-08 15:18:25.4896	f
58	21	letter_written	💌 A letter arrived	pravallika wrote you something. It reveals when the time is right.	f	2026-06-10 06:32:30.15297	f
19	4	self_insight	🔍 New self-discovery insight	Your days gently unfold with a lovely rhythm of peace and reflection.	t	2026-06-06 08:48:49.579278	f
23	4	self_insight	🔍 New self-discovery insight	You're dwelling in a gentle space of peace and introspection.	t	2026-06-06 09:27:55.072483	f
26	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 09:18:52.582313	f
28	4	separation_started	🌿 Space has begun	jnana illa started a separation.	t	2026-06-08 09:24:15.248275	f
30	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:31:44.647862	f
31	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:31:59.483959	f
32	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:32:14.362129	f
33	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:33:48.28653	f
34	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:33:53.256896	f
35	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:34:07.680669	f
36	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:34:46.181543	f
37	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:34:56.871077	f
38	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:35:01.100793	f
39	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:35:07.945388	f
40	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:35:16.725715	f
41	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:35:22.581769	f
42	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:35:46.291699	f
43	4	separation_ended	🌅 Space has ended	jnana illa ended the separation.	t	2026-06-08 10:36:32.006024	f
44	4	separation_started	🌿 Space has begun	jnana illa started a separation.	t	2026-06-08 10:36:53.549474	f
56	4	score_milestone	Love Milestone Unlocked! 🏆	You and your partner just reached 300 points! Keep growing together.	t	2026-06-09 05:51:05.907835	f
59	21	partner_disconnected	Your bond has been disconnected	pravallika has disconnected.	f	2026-06-10 07:24:58.230422	f
317	73	partner_joined	s joined your bond! 💕	You are now connected.	f	2026-06-16 16:56:23.887323	t
319	70	separation_started	🌿 Space has begun	sofi started a separation.	f	2026-06-16 17:18:17.102925	t
329	75	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-17 05:13:51.458314	t
336	51	self_insight	🔍 New self-discovery insight	You've found a lovely sense of peace.	f	2026-06-17 07:17:01.449517	f
60	4	partner_joined	pravallika joined your bond! 💕	You are now connected.	t	2026-06-10 07:29:12.722754	f
61	4	separation_started	🌿 Space has begun	pravallika started a separation.	t	2026-06-10 07:39:45.971244	f
62	4	letter_written	💌 A letter arrived	pravallika wrote you something. It reveals when the time is right.	t	2026-06-10 07:40:28.595115	f
66	4	letter_written	💌 A letter arrived	pravallika wrote you something. It reveals when the time is right.	t	2026-06-11 04:07:32.698776	f
67	4	partner_disconnected	Your bond has been disconnected	pravallika has disconnected.	t	2026-06-11 04:09:46.199386	f
72	1	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-11 07:14:19.423011	f
74	4	self_insight	🔍 New self-discovery insight	You're living in a beautiful rhythm of peace and reflection.	f	2026-06-11 07:24:48.44852	f
337	50	partner_mood	🌤️ jan is feeling peacfull	They logged how they're feeling today.	f	2026-06-17 07:17:01.46837	t
76	1	partner_mood	🌤️ pravallika is feeling peaceful	They logged how they're feeling today.	f	2026-06-11 08:23:58.598079	f
338	51	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-17 07:17:22.422517	f
78	1	partner_mood	🌤️ pravallika is feeling Peaceful	They logged how they're feeling today.	f	2026-06-11 18:15:57.500405	f
79	22	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-11 18:42:18.660126	f
80	26	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-12 06:19:03.21705	f
81	26	partner_disconnected	Your bond has been disconnected	Your partner has disconnected.	f	2026-06-12 06:21:46.690399	f
339	50	partner_mood	🌤️ jan is feeling longing	They logged how they're feeling today.	f	2026-06-17 07:17:22.47144	t
86	36	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-12 10:35:38.904413	f
87	36	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-12 10:52:25.822563	f
88	37	partner_mood	🌤️ sofy is feeling Peaceful	They logged how they're feeling today.	f	2026-06-12 10:52:25.831644	f
89	36	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-12 10:55:34.311596	f
90	37	partner_mood	🌤️ sofy is feeling Peaceful	They logged how they're feeling today.	f	2026-06-12 10:55:34.319043	f
91	37	separation_started	🌿 Space has begun	sofy started a separation.	f	2026-06-12 11:20:33.89035	f
92	37	separation_ended	🌅 Space has ended	sofy ended the separation.	f	2026-06-12 12:02:35.341959	f
93	37	partner_disconnected	Your bond has been disconnected	sofy has disconnected.	f	2026-06-12 14:38:18.4554	f
94	36	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-12 17:37:44.332341	f
97	36	letter_written	💌 A letter arrived	arjun wrote you something. It reveals when the time is right.	f	2026-06-12 18:16:29.404716	f
98	36	letter_written	💌 A letter arrived	arjun wrote you something. It reveals when the time is right.	f	2026-06-12 18:43:02.064271	f
100	36	partner_mood	🌤️ arjun is feeling Growing	They logged how they're feeling today.	f	2026-06-12 19:11:04.961716	f
101	36	score_milestone	Love Milestone Unlocked! 🏆	You and your partner just reached 50 points! Keep growing together.	f	2026-06-13 06:24:48.407431	f
102	36	partner_disconnected	Your bond has been disconnected	arjunnn has disconnected.	f	2026-06-13 15:42:29.226567	f
103	36	partner_disconnected	Your bond has been disconnected	arjunnn has disconnected.	f	2026-06-13 15:42:29.665358	f
104	36	partner_disconnected	Your bond has been disconnected	arjunnn has disconnected.	f	2026-06-13 15:42:31.034613	f
106	39	partner_joined	arjunnn joined your bond! 💕	You are now connected.	f	2026-06-13 19:21:04.412489	f
95	38	separation_started	🌿 Space has begun	sofy started a separation.	t	2026-06-12 17:42:04.995187	f
96	38	letter_written	💌 A letter arrived	sofy wrote you something. It reveals when the time is right.	t	2026-06-12 17:44:15.988982	f
99	38	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	t	2026-06-12 19:11:04.872214	f
105	38	score_milestone	Love Milestone Unlocked! 🏆	You and your partner just reached 50 points! Keep growing together.	t	2026-06-13 16:38:21.663196	f
107	38	self_insight	🔍 New self-discovery insight	You seem to hold love and connection very close to your heart.	f	2026-06-14 02:24:56.084342	f
108	39	partner_mood	🌤️ arjunnn is feeling Longing	They logged how they're feeling today.	f	2026-06-14 02:24:56.096655	f
109	39	partner_disconnected	Your bond has been disconnected	arjunnn has disconnected.	f	2026-06-14 03:43:09.254281	f
110	38	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-14 06:04:12.581868	f
111	41	self_insight	🔍 New self-discovery insight	You are thoughtfully cultivating your inner landscape.	f	2026-06-14 12:21:00.174501	f
112	4	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-14 14:43:14.622701	f
113	38	score_milestone	Love Milestone Unlocked! 🏆	You and your partner just reached 50 points! Keep growing together.	f	2026-06-14 14:53:42.571854	f
114	40	separation_started	🌿 Space has begun	arjunnn started a separation.	f	2026-06-14 14:56:55.407691	f
318	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 17:16:44.646176	t
321	72	partner_disconnected	Your bond has been disconnected	Pp has disconnected.	f	2026-06-16 17:22:47.682365	f
330	50	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-17 05:48:05.580075	t
340	51	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-17 07:31:25.489487	f
341	50	partner_mood	🌤️ jan is feeling longing	They logged how they're feeling today.	f	2026-06-17 07:31:25.499095	f
134	43	partner_mood	🌤️ Jnan is feeling Longing	They logged how they're feeling today.	f	2026-06-15 04:27:16.855464	t
115	43	self_insight	🔍 New self-discovery insight	You carry a gentle longing for something more.	t	2026-06-14 15:00:16.948415	t
116	43	partner_joined	Jnana joined your bond! 💕	You are now connected.	t	2026-06-14 15:04:28.401272	t
119	43	partner_joined	Jnana joined your bond! 💕	You are now connected.	t	2026-06-14 15:12:32.16114	t
121	43	partner_mood	🌤️ Jnana is feeling Reflective	They logged how they're feeling today.	t	2026-06-14 15:14:23.508576	t
123	43	score_milestone	Love Milestone Unlocked! 🏆	You and your partner just reached 50 points! Keep growing together.	t	2026-06-14 15:15:15.787928	t
124	38	insights_ready	✨ Your Journey Insights Are Ready	Your separation period is complete. Review your beautiful insights now.	f	2026-06-14 18:20:04.029833	f
126	43	insights_ready	✨ Your Journey Insights Are Ready	Your separation period is complete. Review your beautiful insights now.	f	2026-06-14 18:43:23.748866	t
128	43	score_milestone	Love Milestone Unlocked! 🏆	You and your partner just reached 150 points! Keep growing together.	f	2026-06-14 18:43:38.759731	t
129	38	score_milestone	Love Milestone Unlocked! 🏆	You and your partner just reached 300 points! Keep growing together.	f	2026-06-14 19:29:17.346232	f
130	43	daily_reminder	Time to check in 🌙	Take a quiet moment to reflect on today.	f	2026-06-14 20:00:00.006971	t
131	4	daily_reminder	Time to check in 🌙	Take a quiet moment to reflect on today.	f	2026-06-14 20:00:00.019705	t
136	2	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 05:30:47.692963	t
137	2	self_insight	🔍 New self-discovery insight	You're beginning your mood journey with a lovely sense of peace.	f	2026-06-15 05:57:07.572823	t
138	3	partner_mood	🌤️ Alex is feeling Peaceful	They logged how they're feeling today.	f	2026-06-15 05:57:07.626103	f
139	46	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 06:06:12.459677	t
140	2	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 08:03:10.130679	t
141	3	partner_disconnected	Your bond has been disconnected	Alex has disconnected.	f	2026-06-15 08:04:08.239142	f
142	3	partner_disconnected	Your bond has been disconnected	Alex has disconnected.	f	2026-06-15 08:04:09.703764	f
143	2	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 08:05:38.435605	t
144	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 08:11:38.1177	t
145	47	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 08:13:36.20466	t
146	48	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 08:17:11.15405	t
147	47	partner_joined	Sri joined your bond! 💕	You are now connected.	f	2026-06-15 08:17:46.698604	t
148	48	separation_started	🌿 Space has begun	Bhagya started a separation.	f	2026-06-15 08:19:18.670269	t
149	47	self_insight	🔍 New self-discovery insight	You're holding a quiet, tender longing within.	f	2026-06-15 08:23:52.599283	t
150	48	partner_mood	🌤️ Bhagya is feeling Longing	They logged how they're feeling today.	f	2026-06-15 08:23:52.612636	t
151	48	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 08:28:50.38409	t
152	48	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 08:28:50.784257	t
153	48	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 08:28:53.036313	t
154	48	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 08:28:54.566488	t
155	48	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 08:28:54.880593	t
156	48	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 08:28:55.789107	t
157	48	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 08:28:56.419146	t
158	40	partner_disconnected	Your bond has been disconnected	arjuu has disconnected.	f	2026-06-15 09:37:58.001484	f
159	40	partner_disconnected	Your bond has been disconnected	arjuu has disconnected.	f	2026-06-15 09:37:58.471105	f
160	38	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-15 09:42:12.651914	f
161	45	separation_started	🌿 Space has begun	pravallika started a separation.	f	2026-06-15 10:24:59.709368	f
162	43	separation_started	🌿 Space has begun	Jnan started a separation.	f	2026-06-15 10:44:35.595212	t
186	54	partner_joined	jan joined your bond! 💕	You are now connected.	f	2026-06-15 14:13:03.425392	f
164	45	separation_started	🌿 Space has begun	pravallika started a separation.	f	2026-06-15 11:06:08.293748	f
187	51	separation_started	🌿 Space has begun	sofy started a separation.	f	2026-06-15 14:13:33.242033	f
188	54	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-15 14:14:13.008437	f
167	45	separation_started	🌿 Space has begun	pravallika started a separation.	f	2026-06-15 11:16:06.776428	f
189	51	partner_mood	🌤️ sofy is feeling Peaceful	They logged how they're feeling today.	f	2026-06-15 14:14:13.020045	f
163	17	partner_joined	Your partner joined your bond! 💕	You are now connected.	t	2026-06-15 11:05:21.888901	t
165	17	partner_disconnected	Your bond has been disconnected	Your partner has disconnected.	t	2026-06-15 11:11:57.326133	t
166	17	partner_joined	Your partner joined your bond! 💕	You are now connected.	t	2026-06-15 11:13:42.857489	t
168	17	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	t	2026-06-15 12:26:17.592098	t
169	17	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-15 12:28:06.5495	t
170	45	partner_mood	🌤️ pravallika is feeling Longing	They logged how they're feeling today.	f	2026-06-15 12:28:06.576642	f
171	45	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 12:29:08.011006	t
172	17	partner_disconnected	Your bond has been disconnected	lilli has disconnected.	f	2026-06-15 12:39:37.118105	t
173	17	partner_disconnected	Your bond has been disconnected	lilli has disconnected.	f	2026-06-15 12:39:42.155963	t
174	51	partner_joined	lilli joined your bond! 💕	You are now connected.	f	2026-06-15 12:41:15.419074	f
175	51	separation_started	🌿 Space has begun	lilli started a separation.	f	2026-06-15 12:42:42.555029	f
190	51	partner_disconnected	Your bond has been disconnected	sofy has disconnected.	f	2026-06-15 14:41:40.43836	f
177	23	partner_disconnected	Your bond has been disconnected	sra has disconnected.	f	2026-06-15 13:08:23.24754	f
178	22	partner_joined	Bhagya joined your bond! 💕	You are now connected.	f	2026-06-15 13:48:52.855236	f
179	22	separation_started	🌿 Space has begun	Bhagya started a separation.	f	2026-06-15 13:49:56.813428	f
181	22	partner_mood	🌤️ Bhagya is feeling Longing	They logged how they're feeling today.	f	2026-06-15 13:51:41.221112	f
182	22	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-15 13:52:05.134444	f
183	45	partner_disconnected	Your bond has been disconnected	jan has disconnected.	f	2026-06-15 14:08:25.222357	t
184	54	partner_joined	jan joined your bond! 💕	You are now connected.	f	2026-06-15 14:09:18.28781	f
185	51	partner_disconnected	Your bond has been disconnected	sofy has disconnected.	f	2026-06-15 14:10:04.615355	f
191	55	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 15:48:09.835928	t
192	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 16:14:21.637363	t
193	55	self_insight	🔍 New self-discovery insight	You start your journey here feeling peaceful.	f	2026-06-15 16:37:32.458431	t
194	50	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 16:59:16.641581	t
195	50	partner_joined	jan joined your bond! 💕	You are now connected.	f	2026-06-15 17:06:08.552888	t
196	50	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-15 17:07:09.935315	t
197	51	partner_mood	🌤️ Sriiii is feeling Longing	They logged how they're feeling today.	f	2026-06-15 17:07:09.949097	f
198	51	separation_started	🌿 Space has begun	Sriiii started a separation.	f	2026-06-15 18:08:29.257281	f
342	51	self_insight	🔍 New self-discovery insight	You are longing for a deeper sense of peace.	f	2026-06-17 07:38:08.698608	f
201	57	separation_started	🌿 Space has begun	Dharma started a separation.	f	2026-06-15 18:43:44.867521	f
206	58	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 19:40:50.812017	t
202	57	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-15 19:01:20.350421	f
207	58	partner_joined	jan joined your bond! 💕	You are now connected.	f	2026-06-15 19:43:09.065919	t
208	57	separation_started	🌿 Space has begun	Hii started a separation.	f	2026-06-15 19:43:48.1424	f
209	58	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-15 19:44:34.496869	t
210	57	partner_mood	🌤️ Hii is feeling Peaceful	They logged how they're feeling today.	f	2026-06-15 19:44:34.551233	f
211	57	partner_disconnected	Your bond has been disconnected	Hii has disconnected.	f	2026-06-15 19:48:18.484646	f
212	4	daily_reminder	Time to check in 🌙	Take a deep breath. How is your heart feeling today? 🌿	f	2026-06-15 20:00:00.012392	t
213	46	daily_reminder	Time to check in 🌙	Take a deep breath. How is your heart feeling today? 🌿	f	2026-06-15 20:00:00.025398	t
214	44	daily_reminder	Time to check in 🌙	Take a deep breath. How is your heart feeling today? 🌿	f	2026-06-15 20:00:00.037381	t
215	45	daily_reminder	Time to check in 🌙	Take a deep breath. How is your heart feeling today? 🌿	f	2026-06-15 20:00:00.050885	t
216	43	daily_reminder	Time to check in 🌙	Take a deep breath. How is your heart feeling today? 🌿	f	2026-06-15 20:00:00.06066	t
217	48	daily_reminder	Time to check in 🌙	Take a deep breath. How is your heart feeling today? 🌿	f	2026-06-15 20:00:00.138559	t
218	54	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 20:36:22.631656	t
219	59	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 20:37:08.307505	t
220	59	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 20:37:22.452453	t
320	74	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 17:20:45.70782	t
322	74	partner_joined	Pp joined your bond! 💕	You are now connected.	f	2026-06-16 17:23:04.059543	t
323	73	separation_started	🌿 Space has begun	Bhagya started a separation.	f	2026-06-16 17:26:45.313304	t
324	74	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-16 17:27:13.07422	t
326	73	separation_started	🌿 Space has begun	Bhagya started a separation.	f	2026-06-16 17:39:52.57316	t
331	50	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-17 05:49:51.831773	t
343	50	partner_mood	🌤️ jan is feeling longing	They logged how they're feeling today.	f	2026-06-17 07:38:08.731036	f
221	54	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-15 20:40:16.961239	t
222	50	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 03:25:15.64629	t
223	50	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-16 03:29:55.030522	t
224	51	partner_mood	🌤️ Sriiii is feeling Reflective	They logged how they're feeling today.	f	2026-06-16 03:29:55.051678	f
225	60	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 03:37:05.611911	t
226	60	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-16 03:40:13.839597	t
227	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 05:05:15.173942	t
228	42	partner_disconnected	Your bond has been disconnected	sofi has disconnected.	f	2026-06-16 05:08:28.987105	f
229	61	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 05:11:58.933407	t
230	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 05:13:53.944947	t
231	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 05:19:53.977439	t
232	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 05:20:23.050403	t
233	62	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 05:21:08.623675	t
234	57	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 05:30:53.419889	t
235	58	partner_joined	jan joined your bond! 💕	You are now connected.	f	2026-06-16 05:31:15.412516	t
236	57	partner_disconnected	Your bond has been disconnected	Hii has disconnected.	f	2026-06-16 05:32:52.666353	t
237	58	partner_joined	jan joined your bond! 💕	You are now connected.	f	2026-06-16 05:47:49.423434	t
238	57	separation_started	🌿 Space has begun	Hii started a separation.	f	2026-06-16 05:54:16.138999	t
239	57	partner_disconnected	Your bond has been disconnected	Hii has disconnected.	f	2026-06-16 06:21:07.868758	t
241	62	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 06:38:41.146637	t
242	64	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 06:40:47.464482	t
243	64	partner_joined	Sri joined your bond! 💕	You are now connected.	f	2026-06-16 06:42:27.175404	t
325	73	partner_mood	🌤️ Bhagya is feeling Longing	They logged how they're feeling today.	f	2026-06-16 17:27:13.109099	t
273	67	partner_joined	k joined your bond! 💕	You are now connected.	f	2026-06-16 08:31:46.278659	t
332	51	partner_mood	🌤️ Sriiii is feeling Peaceful	They logged how they're feeling today.	f	2026-06-17 05:49:51.847801	f
344	51	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-17 07:56:32.148468	f
274	67	separation_started	🌿 Space has begun	k started a separation.	f	2026-06-16 08:32:30.872738	t
345	50	partner_mood	🌤️ jan is feeling longing	They logged how they're feeling today.	f	2026-06-17 07:56:32.158522	t
249	66	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 07:10:41.529608	t
275	67	partner_disconnected	Your bond has been disconnected	k has disconnected.	f	2026-06-16 09:00:32.060816	t
277	68	partner_joined	S joined your bond! 💕	You are now connected.	f	2026-06-16 09:29:04.631683	f
278	68	separation_started	🌿 Space has begun	S started a separation.	f	2026-06-16 09:30:04.926159	f
287	58	separation_started	🌿 Space has begun	k started a separation.	f	2026-06-16 09:49:02.565546	t
280	68	partner_mood	🌤️ S is feeling Reflective	They logged how they're feeling today.	f	2026-06-16 09:30:37.514891	f
281	68	partner_disconnected	Your bond has been disconnected	S has disconnected.	f	2026-06-16 09:32:10.018017	f
261	66	partner_joined	k joined your bond! 💕	You are now connected.	f	2026-06-16 07:42:08.635588	t
282	58	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 09:42:01.046403	t
283	58	partner_joined	Your partner joined your bond! 💕	You are now connected.	f	2026-06-16 09:43:14.462455	t
284	68	separation_started	🌿 Space has begun	Hii started a separation.	f	2026-06-16 09:45:06.721362	f
285	68	partner_disconnected	Your bond has been disconnected	Hii has disconnected.	f	2026-06-16 09:48:12.956452	f
272	67	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 08:27:52.845878	t
288	58	separation_started	🌿 Space has begun	k started a separation.	f	2026-06-16 10:39:33.729033	t
289	17	partner_joined	JJJ joined your bond! 💕	You are now connected.	f	2026-06-16 13:01:24.563965	t
290	68	separation_started	🌿 Space has begun	pravallika started a separation.	f	2026-06-16 13:02:06.040125	f
291	58	separation_started	🌿 Space has begun	k started a separation.	f	2026-06-16 13:18:31.824015	t
293	58	partner_mood	🌤️ k is feeling Peaceful	They logged how they're feeling today.	f	2026-06-16 13:19:43.440051	t
294	58	separation_started	🌿 Space has begun	k started a separation.	f	2026-06-16 13:29:56.435704	t
295	58	separation_started	🌿 Space has begun	k started a separation.	f	2026-06-16 13:31:11.841313	t
296	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 14:05:20.213821	t
297	70	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 14:06:17.66694	t
298	4	partner_joined	Jnana joined your bond! 💕	You are now connected.	f	2026-06-16 14:06:47.967403	t
299	4	self_insight	🔍 New self-discovery insight	You're embracing moments of peace and introspection.	f	2026-06-16 14:18:31.329203	t
300	70	partner_mood	🌤️ sofi is feeling Reflective	They logged how they're feeling today.	f	2026-06-16 14:18:31.346773	t
301	70	self_insight	🔍 New self-discovery insight	You've found a lovely sense of peace.	f	2026-06-16 14:19:45.218932	t
302	4	partner_mood	🌤️ Jnana is feeling Peaceful	They logged how they're feeling today.	f	2026-06-16 14:19:45.24581	t
303	68	separation_started	🌿 Space has begun	pravallika started a separation.	f	2026-06-16 15:27:04.263849	f
304	17	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 15:40:42.507294	t
305	17	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-16 15:41:07.701101	t
306	68	partner_mood	🌤️ pravallika is feeling Longing	They logged how they're feeling today.	f	2026-06-16 15:41:07.71569	f
307	4	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 15:49:39.914036	t
308	71	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 15:50:14.028341	t
309	68	partner_disconnected	Your bond has been disconnected	pravallika illa has disconnected.	f	2026-06-16 15:54:00.146241	f
310	71	partner_joined	pravallika illa joined your bond! 💕	You are now connected.	f	2026-06-16 15:54:29.575604	t
311	58	partner_disconnected	Your bond has been disconnected	k has disconnected.	f	2026-06-16 16:19:35.219051	t
327	73	partner_disconnected	Your bond has been disconnected	Bhagya has disconnected.	f	2026-06-16 17:40:38.749943	t
333	51	self_insight	🔍 New self-discovery insight	You are navigating this season with quiet strength.	f	2026-06-17 06:17:58.568311	f
314	72	separation_started	🌿 Space has begun	k started a separation.	f	2026-06-16 16:51:02.556963	f
315	73	system	Welcome to Bonded ✨	We are so glad you are here! Start your journey with your partner.	f	2026-06-16 16:53:52.992668	t
334	50	partner_mood	🌤️ jan is feeling peacfull	They logged how they're feeling today.	f	2026-06-17 06:17:58.578562	t
\.


--
-- Data for Name: question_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.question_categories (id, name, description, color_hex, sort_order) FROM stdin;
1	Memory & Connection	Moments that still hold warmth	#8A2E55	1
2	Missing & Absence	What the distance is teaching you	#9E7E5A	2
3	Self Reflection	Understanding your own patterns	#6A5A8E	3
4	Appreciation	Seeing their value more clearly	#4A7A5A	4
5	Hope & Future	What you want your relationship to be	#911746	5
6	Deep Emotional	What lives quietly in your heart	#C97A5A	6
7	Situational Reflection	Learning through others stories	#5A7A8E	7
\.


--
-- Data for Name: reflection_answers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reflection_answers (id, session_id, user_id, question_id, text_answer, ai_emotion_detected, ai_tone, ai_reaction_text, ai_processed, answered_at) FROM stdin;
1	1	2	1	love	neutral	neutral	That takes courage to share. Keep going.	t	2026-05-19 09:56:07.745517
2	2	3	1	sad	neutral	neutral	That takes courage to share. Keep going.	t	2026-05-19 09:57:46.038748
9	10	19	1	sharing coffee	joy	celebration	Oh, my heart just melts thinking about that! Remember that quiet morning we just sat, sipping coffee, not needing to say a single word? Just being there with you, feeling completely at peace and connected, that's a memory I cherish so deeply. It was truly perfect.	t	2026-06-08 15:03:45.514563
12	12	1	1	long drives	joy	supportive	There's a beautiful simplicity in choosing 'long drives' as your happiest memory. It often speaks to a comfortable ease and shared journey that can deepen connection and bring quiet joy to a relationship.	t	2026-06-11 06:27:05.310921
13	16	36	2	feeling low	grief	supportive	It takes real honesty to acknowledge that you're feeling low. Sitting with that truth can be a difficult but essential step in processing the changes in your daily life. Allowing yourself to feel these emotions is a crucial part of navigating this period of separation.	t	2026-06-13 08:19:44.02438
14	15	38	2	feeling low	grief	supportive	It's completely understandable to feel low when someone significant is no longer part of your daily rhythm. Acknowledging this feeling is a brave and important step in processing the change, and it's okay to sit with that honesty.	t	2026-06-13 08:52:04.067044
15	17	38	1	sharing coffe	love	supportive	That's a beautiful image of quiet connection. Often, it's these simple, shared rituals that weave the deepest threads of comfort and presence into a relationship. It speaks volumes about the value you place on those intimate moments together.	t	2026-06-14 06:21:37.148473
16	18	38	2	hq5etdgnfh	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-14 06:54:27.852953
17	19	38	3	sharing coffre	neutral	neutral	It sounds like you're reflecting on shared moments, wishing for a softer touch. That desire for gentleness in those times is a very understandable feeling. Simply allowing yourself to reflect on that is a kind step.	t	2026-06-14 06:59:07.838601
18	20	40	1	sharing coffe with him	neutral	neutral	That sounds like a truly peaceful and warm memory. There's something so special about those quiet, shared moments. It's lovely how a simple act like sharing coffee can hold so much happiness.	t	2026-06-14 08:38:52.907438
19	21	41	1	sharingf coffe	neutral	neutral	What a lovely, simple memory to cherish. Those quiet moments, just sharing coffee, can hold such a special kind of warmth. It's completely understandable why that stands out.	t	2026-06-14 11:56:28.780632
20	22	38	1	sharing coffe	neutral	neutral	How lovely to remember such a simple, shared moment. There's a special warmth in those quiet, everyday connections.	t	2026-06-14 14:54:16.703815
21	23	43	1	watching movie	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-14 15:08:03.110395
22	24	43	1	watching movies together	neutral	neutral	It's wonderful to remember those simple, happy times watching movies together. Those are beautiful moments to carry with you. It sounds like a truly sweet memory.	t	2026-06-14 15:13:12.10149
25	248	2	1	proposing her	neutral	neutral	That sounds like a truly special moment you shared. It's clear how much that memory means to you. Holding onto such cherished times can be powerful.	t	2026-06-15 05:57:44.109065
26	271	47	1	hii	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-15 08:23:08.089635
29	301	17	1	sharing coffe	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-15 11:06:50.260854
30	302	17	1	sharing coffe	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-15 11:16:59.08276
31	303	45	1	sharing coffee long drive	neutral	neutral	That sounds like such a warm and comforting memory. Those shared moments, like coffee on a long drive, often stay with us beautifully.	t	2026-06-15 12:44:55.902124
33	317	50	1	sharing coffee	neutral	neutral	Sharing coffee sounds like such a gentle, warm memory. It’s amazing how those simple, everyday moments can often be the happiest ones we carry with us.	t	2026-06-15 18:11:59.014896
34	318	57	1	sharing coffe	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-15 19:12:25.813551
35	347	50	2	my day is empty without her . I will miss her	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-16 03:26:52.064007
36	348	60	1	hi	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-16 04:15:44.917658
37	419	66	1	hiii.	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-16 07:43:06.922486
39	475	58	1	sharing coffe	neutral	neutral	It sounds like those quiet moments of sharing coffee held a special warmth for you. Simple times often bring the most treasured, gentle connections.	t	2026-06-16 09:45:56.065788
42	517	17	1	shRING coffee	neutral	neutral	Thank you for sharing that. It takes courage to look inward, and every reflection brings you a little more clarity.	t	2026-06-16 13:02:41.010351
46	560	70	1	sharing coffe	neutral	neutral	What a sweet memory to hold onto. There's a lot of gentle warmth in sharing coffee together, isn't there? Those quiet moments can be truly precious.	t	2026-06-16 14:08:38.664516
47	561	4	1	hiii	neutral	neutral	It's good to hear from you. Sometimes, just being present with these thoughts is enough for now. There's no rush to articulate everything.	t	2026-06-16 14:08:45.169657
48	587	17	1	jdfhgioetu	neutral	neutral	It sounds like you're navigating many thoughts and feelings right now. Sometimes, it's hard to put things into words, and that's completely okay. Just know I'm here, listening gently as you reflect.	t	2026-06-16 15:27:39.577973
50	589	73	1	coffe	neutral	neutral	That sounds like a beautiful, simple memory. Sometimes the quiet moments, like sharing coffee, are the ones that truly warm our hearts. It's gentle to remember such happiness.	t	2026-06-16 17:16:57.602704
51	604	50	3	I wish I had been gentler when expressing my feelings	neutral	neutral	It sounds like you're reflecting on those moments deeply. Acknowledging a desire to express feelings gently is a very human and thoughtful step.	t	2026-06-17 05:52:37.18072
\.


--
-- Data for Name: reflection_comparisons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reflection_comparisons (id, separation_id, day_number, user_a_session_id, user_b_session_id, comparison_data, suggestions, generated_at) FROM stdin;
1	2	1	2	1	\N	["Showing up every day is already progress."]	2026-05-19 09:58:20.66319
\.


--
-- Data for Name: reflection_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reflection_questions (id, day_number, category_id, question_type, question_text, scenario_prefix, hint_text, is_active) FROM stdin;
1	1	1	text	What is your happiest memory together?	\N	Take a moment to remember...	t
2	2	2	text	What feels different in your day without them?	\N	Be honest with yourself...	t
3	3	3	text	What do you wish you handled more gently?	\N	Speak your heart...	t
4	4	4	text	What do you admire most about your partner?	\N	Think of a specific quality...	t
5	5	5	text	How do you want your relationship to feel after this break?	\N	Imagine the best version...	t
6	6	6	text	What feeling stayed in your heart today?	\N	What is really there...	t
7	7	7	situational	If you were in this situation, what would you do first?	Your friend says: "My partner became silent after our argument."	What would be your first step...	t
8	8	1	text	What small thing about them do you miss today?	\N	Even the tiniest detail counts...	t
9	9	2	text	At what moment today did you think about them most?	\N	Walk through your day...	t
10	10	3	text	What do you understand better now?	\N	What has this space revealed...	t
11	11	4	text	What effort from them did you notice only after distance?	\N	Think carefully...	t
12	12	5	text	What kind of conversation do you hope to have when this ends?	\N	Picture that moment...	t
13	13	6	text	What silence between you feels unfinished?	\N	What was never said...	t
14	14	7	situational	If this was your relationship, how would you handle it?	Someone says: "I expect my partner to understand me without explaining."	What would you do differently...	t
15	15	1	text	What moment with them still makes you smile?	\N	Let yourself go back there...	t
16	16	2	text	What do you wish you could tell them right now?	\N	Say it here, safely...	t
17	17	3	text	What expectation did you never express clearly?	\N	Be honest with yourself...	t
18	18	4	text	What is one thing they always did for you?	\N	Something they did consistently...	t
19	19	5	text	What would make your relationship feel more peaceful?	\N	Dream a little...	t
20	20	6	text	What do you think your partner never understood about you?	\N	What was always missed...	t
21	21	7	situational	If you were one of them, what would you try to change?	Your friend says: "We love each other, but we still hurt each other often."	What change would matter most...	t
22	22	1	text	What place reminds you of your partner the most?	\N	Where does your mind go...	t
23	23	2	text	What part of your routine feels empty today?	\N	Notice the small gaps...	t
24	24	3	text	What do you think your partner needed from you most?	\N	What did they ask for...	t
25	25	4	text	What quality of theirs makes you feel calm?	\N	What settles you about them...	t
26	26	5	text	What does a healthy relationship mean to you now?	\N	How has your view changed...	t
27	27	6	text	What do you think you never understood about them?	\N	Look at them from their side...	t
28	28	7	situational	How would you feel if this happened to you?	Someone says: "I only realized my partner's value after distance."	What would that feel like...	t
29	29	1	text	What is one ordinary moment with them that now feels special?	\N	The simple things...	t
30	30	2	text	What do you miss more than you expected?	\N	What surprised you...	t
31	31	3	text	What would you do differently in your next conversation?	\N	Picture the conversation...	t
32	32	4	text	What made you feel loved by them?	\N	How did their love show up...	t
33	33	5	text	What is one change that could bring you both closer?	\N	Just one honest thing...	t
34	34	6	text	What moment made you realize they matter deeply to you?	\N	When did you truly know...	t
35	35	7	situational	If you felt emotionally unheard, what would you do?	Your friend says: "I stopped expressing my feelings because I felt unheard."	What would be your response...	t
36	36	1	text	What was the last moment you felt truly close to them?	\N	Go back to that feeling...	t
37	37	2	text	What feeling became stronger during this silence?	\N	What grew in the quiet...	t
38	38	3	text	What have you learned about yourself during this break?	\N	What did space reveal...	t
39	39	4	text	What is one thing they do better than anyone else?	\N	Their unique gift...	t
40	40	5	text	What do you want your partner to feel more often?	\N	What would you give them...	t
41	41	6	text	What hurt stayed with you quietly?	\N	The thing you carry silently...	t
42	42	7	situational	If you were in this situation, how would you express your pain better?	Someone says: "I become angry when I actually feel hurt."	What would healthier expression look like...	t
43	43	1	text	What song reminds you of your relationship?	\N	What does it bring up...	t
44	44	2	text	What small message from them would make you smile today?	\N	Just one line...	t
45	45	3	text	What feeling do you usually hide during arguments?	\N	What is underneath the reaction...	t
46	46	4	text	What is something about them you never appreciated enough?	\N	What did you overlook...	t
47	47	5	text	What kind of memories do you want to create together later?	\N	Dream forward...	t
48	48	6	text	What love language do you think they express naturally?	\N	How do they show love...	t
49	49	7	situational	If this happened in your relationship, what would you change?	Your friend says: "I wait for effort, but I never clearly express my expectations."	What would you do differently...	t
50	50	1	text	What habit of theirs do you miss unexpectedly?	\N	The small things you took for granted...	t
51	51	2	text	What did you take for granted before this break?	\N	Look at what was always there...	t
52	52	3	text	What makes you pull away emotionally?	\N	What triggers your distance...	t
53	53	4	text	What memory makes you feel grateful for them?	\N	One that stays with you...	t
54	54	5	text	What does emotional safety mean to you?	\N	What makes you feel safe with someone...	t
55	55	6	text	What emotional support from them do you miss?	\N	What did their presence give you...	t
\.


--
-- Data for Name: reflection_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reflection_sessions (id, user_id, separation_id, day_number, is_completed, completed_at, created_at) FROM stdin;
1	2	2	1	t	2026-05-19 09:56:18.676846	2026-05-19 09:36:52.226921
2	3	2	1	t	2026-05-19 09:58:19.91916	2026-05-19 09:57:05.32206
301	17	44	1	t	2026-06-15 11:06:50.267627	2026-06-15 11:06:20.197743
303	45	46	1	t	2026-06-15 12:44:55.907455	2026-06-15 12:44:18.668081
306	54	48	2	t	2026-06-09 00:00:00	2026-06-15 14:14:57.873108
307	54	48	3	t	2026-06-10 00:00:00	2026-06-15 14:14:57.873112
9	6	4	21	f	\N	2026-06-08 10:29:55.005533
71	38	34	2	t	2026-05-16 00:00:00	2026-06-14 18:19:27.777568
72	38	34	3	t	2026-05-17 00:00:00	2026-06-14 18:19:27.777572
73	38	34	4	t	2026-05-18 00:00:00	2026-06-14 18:19:27.777573
74	38	34	5	t	2026-05-19 00:00:00	2026-06-14 18:19:27.777574
75	38	34	6	t	2026-05-20 00:00:00	2026-06-14 18:19:27.777575
76	38	34	7	t	2026-05-21 00:00:00	2026-06-14 18:19:27.777575
77	38	34	8	t	2026-05-22 00:00:00	2026-06-14 18:19:27.777576
78	38	34	9	t	2026-05-23 00:00:00	2026-06-14 18:19:27.777577
10	19	\N	1	t	2026-06-08 15:03:45.52314	2026-06-08 15:02:54.753981
308	54	48	4	t	2026-06-11 00:00:00	2026-06-15 14:14:57.873113
12	1	\N	1	t	2026-06-11 06:27:05.318862	2026-06-11 05:14:30.605669
309	54	48	5	t	2026-06-12 00:00:00	2026-06-15 14:14:57.873114
14	38	32	1	f	\N	2026-06-12 18:17:25.490177
16	36	32	2	t	2026-06-13 08:19:44.03585	2026-06-13 08:15:13.591169
15	38	32	2	t	2026-06-13 08:52:04.074557	2026-06-13 08:12:12.623821
310	54	48	6	t	2026-06-13 00:00:00	2026-06-15 14:14:57.873115
242	45	\N	1	t	2026-06-08 00:00:00	2026-06-15 04:42:50.824371
311	51	48	1	t	2026-06-08 00:00:00	2026-06-15 14:14:57.873116
243	45	\N	2	t	2026-06-09 00:00:00	2026-06-15 04:42:50.824371
312	51	48	2	t	2026-06-09 00:00:00	2026-06-15 14:14:57.873116
244	45	\N	3	t	2026-06-10 00:00:00	2026-06-15 04:42:50.824373
313	51	48	3	t	2026-06-10 00:00:00	2026-06-15 14:14:57.873117
245	45	\N	4	t	2026-06-11 00:00:00	2026-06-15 04:42:50.824373
21	41	36	1	t	2026-06-14 11:56:28.787298	2026-06-14 11:56:18.021322
22	38	34	1	t	2026-06-14 14:54:16.709913	2026-06-14 14:54:04.787253
314	51	48	4	t	2026-06-11 00:00:00	2026-06-15 14:14:57.873118
315	51	48	5	t	2026-06-12 00:00:00	2026-06-15 14:14:57.873118
316	51	48	6	t	2026-06-13 00:00:00	2026-06-15 14:14:57.873119
346	54	52	1	f	\N	2026-06-16 03:24:35.153126
475	58	70	1	t	2026-06-16 09:45:56.076422	2026-06-16 09:45:45.026512
79	38	34	10	t	2026-05-24 00:00:00	2026-06-14 18:19:27.777578
80	38	34	11	t	2026-05-25 00:00:00	2026-06-14 18:19:27.777578
81	38	34	12	t	2026-05-26 00:00:00	2026-06-14 18:19:27.777579
82	38	34	13	t	2026-05-27 00:00:00	2026-06-14 18:19:27.77758
83	38	34	14	t	2026-05-28 00:00:00	2026-06-14 18:19:27.77758
84	38	34	15	t	2026-05-29 00:00:00	2026-06-14 18:19:27.777581
85	38	34	16	t	2026-05-30 00:00:00	2026-06-14 18:19:27.777581
86	38	34	17	t	2026-05-31 00:00:00	2026-06-14 18:19:27.777582
87	38	34	18	t	2026-06-01 00:00:00	2026-06-14 18:19:27.777583
88	38	34	19	t	2026-06-02 00:00:00	2026-06-14 18:19:27.777583
89	38	34	20	t	2026-06-03 00:00:00	2026-06-14 18:19:27.777584
90	38	34	21	t	2026-06-04 00:00:00	2026-06-14 18:19:27.777584
91	38	34	22	t	2026-06-05 00:00:00	2026-06-14 18:19:27.777585
92	38	34	23	t	2026-06-06 00:00:00	2026-06-14 18:19:27.777586
93	38	34	24	t	2026-06-07 00:00:00	2026-06-14 18:19:27.777586
94	38	34	25	t	2026-06-08 00:00:00	2026-06-14 18:19:27.777587
95	38	34	26	t	2026-06-09 00:00:00	2026-06-14 18:19:27.777588
96	38	34	27	t	2026-06-10 00:00:00	2026-06-14 18:19:27.777588
97	38	34	28	t	2026-06-11 00:00:00	2026-06-14 18:19:27.777589
98	38	34	29	t	2026-06-12 00:00:00	2026-06-14 18:19:27.777589
589	73	79	1	t	2026-06-16 17:16:57.617963	2026-06-16 17:16:45.178675
318	57	\N	1	t	2026-06-15 19:12:25.821903	2026-06-15 19:11:57.940201
248	2	9	1	t	2026-06-15 05:57:44.116329	2026-06-15 05:57:27.598069
319	57	\N	2	t	2026-06-10 00:00:00	2026-06-15 19:16:21.210875
320	57	\N	3	t	2026-06-11 00:00:00	2026-06-15 19:16:21.210879
321	57	\N	4	t	2026-06-12 00:00:00	2026-06-15 19:16:21.21088
322	57	\N	5	t	2026-06-13 00:00:00	2026-06-15 19:16:21.210881
323	57	\N	6	t	2026-06-14 00:00:00	2026-06-15 19:16:21.210882
324	57	\N	7	t	2026-06-15 00:00:00	2026-06-15 19:16:21.210883
348	60	53	1	t	2026-06-16 04:15:44.924141	2026-06-16 04:15:39.681837
356	58	57	1	t	2026-06-10 00:00:00	2026-06-16 05:55:39.557616
357	58	57	2	t	2026-06-11 00:00:00	2026-06-16 05:55:39.557622
358	58	57	3	t	2026-06-12 00:00:00	2026-06-16 05:55:39.557623
359	58	57	4	t	2026-06-13 00:00:00	2026-06-16 05:55:39.557624
360	58	57	5	t	2026-06-14 00:00:00	2026-06-16 05:55:39.557625
361	58	57	6	t	2026-06-15 00:00:00	2026-06-16 05:55:39.557625
362	58	57	7	t	2026-06-16 00:00:00	2026-06-16 05:55:39.557626
363	57	57	1	t	2026-06-10 00:00:00	2026-06-16 05:55:39.557627
364	57	57	2	t	2026-06-11 00:00:00	2026-06-16 05:55:39.557628
365	57	57	3	t	2026-06-12 00:00:00	2026-06-16 05:55:39.557628
366	57	57	4	t	2026-06-13 00:00:00	2026-06-16 05:55:39.557629
367	57	57	5	t	2026-06-14 00:00:00	2026-06-16 05:55:39.557629
368	57	57	6	t	2026-06-15 00:00:00	2026-06-16 05:55:39.55763
369	57	57	7	t	2026-06-16 00:00:00	2026-06-16 05:55:39.557631
17	38	\N	1	t	2026-06-14 06:21:37.169377	2026-06-14 06:21:10.404571
18	38	\N	2	t	2026-06-14 06:54:27.859437	2026-06-14 06:54:16.317089
19	38	\N	3	t	2026-06-14 06:59:07.844385	2026-06-14 06:58:54.008211
20	40	\N	1	t	2026-06-14 08:38:52.937994	2026-06-14 08:38:34.9596
249	38	\N	4	t	2026-06-04 00:00:00	2026-06-15 08:19:24.539849
250	38	\N	5	t	2026-06-05 00:00:00	2026-06-15 08:19:24.539849
251	38	\N	6	t	2026-06-06 00:00:00	2026-06-15 08:19:24.539849
252	38	\N	7	t	2026-06-07 00:00:00	2026-06-15 08:19:24.539849
253	38	\N	8	t	2026-06-08 00:00:00	2026-06-15 08:19:24.539849
254	38	\N	9	t	2026-06-09 00:00:00	2026-06-15 08:19:24.539849
255	38	\N	10	t	2026-06-10 00:00:00	2026-06-15 08:19:24.539849
256	38	\N	11	t	2026-06-11 00:00:00	2026-06-15 08:19:24.539849
257	38	\N	12	t	2026-06-12 00:00:00	2026-06-15 08:19:24.539849
258	38	\N	13	t	2026-06-13 00:00:00	2026-06-15 08:19:24.539849
259	40	\N	2	t	2026-06-02 00:00:00	2026-06-15 08:19:24.539849
260	40	\N	3	t	2026-06-03 00:00:00	2026-06-15 08:19:24.539849
261	40	\N	4	t	2026-06-04 00:00:00	2026-06-15 08:19:24.539849
262	40	\N	5	t	2026-06-05 00:00:00	2026-06-15 08:19:24.539849
263	40	\N	6	t	2026-06-06 00:00:00	2026-06-15 08:19:24.539849
264	40	\N	7	t	2026-06-07 00:00:00	2026-06-15 08:19:24.539849
265	40	\N	8	t	2026-06-08 00:00:00	2026-06-15 08:19:24.539849
266	40	\N	9	t	2026-06-09 00:00:00	2026-06-15 08:19:24.539849
267	40	\N	10	t	2026-06-10 00:00:00	2026-06-15 08:19:24.539849
246	45	\N	5	t	2026-06-12 00:00:00	2026-06-15 04:42:50.824374
247	45	\N	6	t	2026-06-13 00:00:00	2026-06-15 04:42:50.824375
23	43	\N	1	t	2026-06-14 15:08:03.116237	2026-06-14 15:07:35.30375
24	43	\N	1	t	2026-06-14 15:13:12.1081	2026-06-14 15:12:59.300327
120	43	\N	2	t	2026-06-08 00:00:00	2026-06-14 18:43:37.563951
121	43	\N	3	t	2026-06-09 00:00:00	2026-06-14 18:43:37.563951
122	43	\N	4	t	2026-06-10 00:00:00	2026-06-14 18:43:37.563952
123	43	\N	5	t	2026-06-11 00:00:00	2026-06-14 18:43:37.563953
124	43	\N	6	t	2026-06-12 00:00:00	2026-06-14 18:43:37.563954
268	40	\N	11	t	2026-06-11 00:00:00	2026-06-15 08:19:24.539849
269	40	\N	12	t	2026-06-12 00:00:00	2026-06-15 08:19:24.539849
270	40	\N	13	t	2026-06-13 00:00:00	2026-06-15 08:19:24.539849
271	47	41	1	t	2026-06-15 08:23:08.099451	2026-06-15 08:22:38.295601
302	17	45	1	t	2026-06-15 11:16:59.08971	2026-06-15 11:16:17.547479
476	58	70	2	t	2026-06-11 00:00:00	2026-06-16 09:46:10.669818
370	64	\N	1	t	2026-06-10 00:00:00	2026-06-16 06:45:44.307844
305	54	48	1	f	\N	2026-06-15 14:13:51.590267
317	50	49	1	t	2026-06-15 18:11:59.026317	2026-06-15 18:11:46.890325
332	57	51	1	t	2026-06-09 00:00:00	2026-06-15 19:45:20.053496
333	57	51	2	t	2026-06-10 00:00:00	2026-06-15 19:45:20.053501
334	57	51	3	t	2026-06-11 00:00:00	2026-06-15 19:45:20.053502
335	57	51	4	t	2026-06-12 00:00:00	2026-06-15 19:45:20.053502
336	57	51	5	t	2026-06-13 00:00:00	2026-06-15 19:45:20.053503
337	57	51	6	t	2026-06-14 00:00:00	2026-06-15 19:45:20.053504
338	57	51	7	t	2026-06-15 00:00:00	2026-06-15 19:45:20.053504
339	58	51	1	t	2026-06-09 00:00:00	2026-06-15 19:45:20.053505
340	58	51	2	t	2026-06-10 00:00:00	2026-06-15 19:45:20.053506
341	58	51	3	t	2026-06-11 00:00:00	2026-06-15 19:45:20.053507
342	58	51	4	t	2026-06-12 00:00:00	2026-06-15 19:45:20.053508
343	58	51	5	t	2026-06-13 00:00:00	2026-06-15 19:45:20.053508
344	58	51	6	t	2026-06-14 00:00:00	2026-06-15 19:45:20.053509
345	58	51	7	t	2026-06-15 00:00:00	2026-06-15 19:45:20.053509
347	50	49	2	t	2026-06-16 03:26:52.085542	2026-06-16 03:25:34.235692
349	4	54	1	t	2026-06-10 00:00:00	2026-06-16 05:11:18.727858
350	4	54	2	t	2026-06-11 00:00:00	2026-06-16 05:11:18.727861
351	4	54	3	t	2026-06-12 00:00:00	2026-06-16 05:11:18.727862
352	4	54	4	t	2026-06-13 00:00:00	2026-06-16 05:11:18.727863
353	4	54	5	t	2026-06-14 00:00:00	2026-06-16 05:11:18.727864
354	4	54	6	t	2026-06-15 00:00:00	2026-06-16 05:11:18.727865
294	45	\N	1	t	2026-06-08 00:00:00	2026-06-15 10:30:36.283539
295	45	\N	2	t	2026-06-09 00:00:00	2026-06-15 10:30:36.283541
296	45	\N	3	t	2026-06-10 00:00:00	2026-06-15 10:30:36.283542
297	45	\N	4	t	2026-06-11 00:00:00	2026-06-15 10:30:36.283543
298	45	\N	5	t	2026-06-12 00:00:00	2026-06-15 10:30:36.283543
299	45	\N	6	t	2026-06-13 00:00:00	2026-06-15 10:30:36.283544
355	4	54	7	t	2026-06-16 00:00:00	2026-06-16 05:11:18.727866
477	58	70	3	t	2026-06-12 00:00:00	2026-06-16 09:46:10.669824
280	43	\N	7	t	2026-06-06 00:00:00	2026-06-15 08:31:42.158953
281	43	\N	8	t	2026-06-07 00:00:00	2026-06-15 08:31:42.158954
282	43	\N	9	t	2026-06-08 00:00:00	2026-06-15 08:31:42.158955
283	43	\N	10	t	2026-06-09 00:00:00	2026-06-15 08:31:42.158955
284	43	\N	11	t	2026-06-10 00:00:00	2026-06-15 08:31:42.158956
285	43	\N	12	t	2026-06-11 00:00:00	2026-06-15 08:31:42.158956
286	43	\N	13	t	2026-06-12 00:00:00	2026-06-15 08:31:42.158957
287	43	\N	14	t	2026-06-13 00:00:00	2026-06-15 08:31:42.158958
478	58	70	4	t	2026-06-13 00:00:00	2026-06-16 09:46:10.669825
479	58	70	5	t	2026-06-14 00:00:00	2026-06-16 09:46:10.669826
480	58	70	6	t	2026-06-15 00:00:00	2026-06-16 09:46:10.669827
481	58	70	7	t	2026-06-16 00:00:00	2026-06-16 09:46:10.669828
482	68	70	1	t	2026-06-10 00:00:00	2026-06-16 09:46:10.669828
483	68	70	2	t	2026-06-11 00:00:00	2026-06-16 09:46:10.669829
484	68	70	3	t	2026-06-12 00:00:00	2026-06-16 09:46:10.66983
485	68	70	4	t	2026-06-13 00:00:00	2026-06-16 09:46:10.669831
486	68	70	5	t	2026-06-14 00:00:00	2026-06-16 09:46:10.669832
487	68	70	6	t	2026-06-15 00:00:00	2026-06-16 09:46:10.669833
488	68	70	7	t	2026-06-16 00:00:00	2026-06-16 09:46:10.669834
590	74	81	1	t	2026-06-10 00:00:00	2026-06-16 17:27:32.263659
591	74	81	2	t	2026-06-11 00:00:00	2026-06-16 17:27:32.263664
592	74	81	3	t	2026-06-12 00:00:00	2026-06-16 17:27:32.263665
593	74	81	4	t	2026-06-13 00:00:00	2026-06-16 17:27:32.263666
594	74	81	5	t	2026-06-14 00:00:00	2026-06-16 17:27:32.263667
595	74	81	6	t	2026-06-15 00:00:00	2026-06-16 17:27:32.263668
596	74	81	7	t	2026-06-16 00:00:00	2026-06-16 17:27:32.263669
597	73	81	1	t	2026-06-10 00:00:00	2026-06-16 17:27:32.26367
598	73	81	2	t	2026-06-11 00:00:00	2026-06-16 17:27:32.263671
599	73	81	3	t	2026-06-12 00:00:00	2026-06-16 17:27:32.263672
600	73	81	4	t	2026-06-13 00:00:00	2026-06-16 17:27:32.263673
601	73	81	5	t	2026-06-14 00:00:00	2026-06-16 17:27:32.263674
602	73	81	6	t	2026-06-15 00:00:00	2026-06-16 17:27:32.263675
603	73	81	7	t	2026-06-16 00:00:00	2026-06-16 17:27:32.263676
560	70	56	1	t	2026-06-16 14:08:38.671885	2026-06-16 14:08:25.463368
574	17	73	2	t	2026-06-11 00:00:00	2026-06-16 15:20:36.349868
575	17	73	3	t	2026-06-12 00:00:00	2026-06-16 15:20:36.349872
576	17	73	4	t	2026-06-13 00:00:00	2026-06-16 15:20:36.349873
577	17	73	5	t	2026-06-14 00:00:00	2026-06-16 15:20:36.349874
578	17	73	6	t	2026-06-15 00:00:00	2026-06-16 15:20:36.349874
371	64	\N	2	t	2026-06-11 00:00:00	2026-06-16 06:45:44.307849
372	64	\N	3	t	2026-06-12 00:00:00	2026-06-16 06:45:44.30785
373	64	\N	4	t	2026-06-13 00:00:00	2026-06-16 06:45:44.30785
374	64	\N	5	t	2026-06-14 00:00:00	2026-06-16 06:45:44.307851
375	64	\N	6	t	2026-06-15 00:00:00	2026-06-16 06:45:44.307852
376	64	\N	7	t	2026-06-16 00:00:00	2026-06-16 06:45:44.307852
579	17	73	7	t	2026-06-16 00:00:00	2026-06-16 15:20:36.349875
604	50	49	3	t	2026-06-17 05:52:37.186635	2026-06-17 05:50:30.673501
468	68	\N	1	t	2026-06-10 00:00:00	2026-06-16 09:31:27.435528
469	68	\N	2	t	2026-06-11 00:00:00	2026-06-16 09:31:27.435528
470	68	\N	3	t	2026-06-12 00:00:00	2026-06-16 09:31:27.435529
471	68	\N	4	t	2026-06-13 00:00:00	2026-06-16 09:31:27.435529
472	68	\N	5	t	2026-06-14 00:00:00	2026-06-16 09:31:27.43553
473	68	\N	6	t	2026-06-15 00:00:00	2026-06-16 09:31:27.43553
474	68	\N	7	t	2026-06-16 00:00:00	2026-06-16 09:31:27.435531
517	17	73	1	t	2026-06-16 13:02:41.020222	2026-06-16 13:02:31.76106
561	4	56	1	t	2026-06-16 14:08:45.176349	2026-06-16 14:08:27.440973
562	4	56	2	t	2026-06-11 00:00:00	2026-06-16 14:23:18.665447
563	4	56	3	t	2026-06-12 00:00:00	2026-06-16 14:23:18.665453
564	4	56	4	t	2026-06-13 00:00:00	2026-06-16 14:23:18.665453
565	4	56	5	t	2026-06-14 00:00:00	2026-06-16 14:23:18.665454
566	4	56	6	t	2026-06-15 00:00:00	2026-06-16 14:23:18.665455
567	4	56	7	t	2026-06-16 00:00:00	2026-06-16 14:23:18.665455
568	70	56	2	t	2026-06-11 00:00:00	2026-06-16 14:23:18.665456
569	70	56	3	t	2026-06-12 00:00:00	2026-06-16 14:23:18.665457
570	70	56	4	t	2026-06-13 00:00:00	2026-06-16 14:23:18.665457
571	70	56	5	t	2026-06-14 00:00:00	2026-06-16 14:23:18.665457
572	70	56	6	t	2026-06-15 00:00:00	2026-06-16 14:23:18.665458
573	70	56	7	t	2026-06-16 00:00:00	2026-06-16 14:23:18.665458
580	68	73	1	t	2026-06-10 00:00:00	2026-06-16 15:20:36.349875
581	68	73	2	t	2026-06-11 00:00:00	2026-06-16 15:20:36.349876
582	68	73	3	t	2026-06-12 00:00:00	2026-06-16 15:20:36.349876
583	68	73	4	t	2026-06-13 00:00:00	2026-06-16 15:20:36.349877
584	68	73	5	t	2026-06-14 00:00:00	2026-06-16 15:20:36.349877
585	68	73	6	t	2026-06-15 00:00:00	2026-06-16 15:20:36.349878
586	68	73	7	t	2026-06-16 00:00:00	2026-06-16 15:20:36.349878
587	17	77	1	t	2026-06-16 15:27:39.586037	2026-06-16 15:27:26.60463
419	66	\N	1	t	2026-06-16 07:43:06.939873	2026-06-16 07:43:01.26848
420	66	\N	2	t	2026-06-11 00:00:00	2026-06-16 07:43:19.011882
421	66	\N	3	t	2026-06-12 00:00:00	2026-06-16 07:43:19.011887
422	66	\N	4	t	2026-06-13 00:00:00	2026-06-16 07:43:19.011887
423	66	\N	5	t	2026-06-14 00:00:00	2026-06-16 07:43:19.011888
424	66	\N	6	t	2026-06-15 00:00:00	2026-06-16 07:43:19.011889
425	66	\N	7	t	2026-06-16 00:00:00	2026-06-16 07:43:19.011889
454	67	\N	1	t	2026-06-10 00:00:00	2026-06-16 08:49:41.058038
455	67	\N	2	t	2026-06-11 00:00:00	2026-06-16 08:49:41.058039
456	67	\N	3	t	2026-06-12 00:00:00	2026-06-16 08:49:41.058039
457	67	\N	4	t	2026-06-13 00:00:00	2026-06-16 08:49:41.05804
458	67	\N	5	t	2026-06-14 00:00:00	2026-06-16 08:49:41.05804
459	67	\N	6	t	2026-06-15 00:00:00	2026-06-16 08:49:41.058041
460	67	\N	7	t	2026-06-16 00:00:00	2026-06-16 08:49:41.058042
496	58	\N	1	t	2026-06-10 00:00:00	2026-06-16 09:50:47.338484
497	58	\N	2	t	2026-06-11 00:00:00	2026-06-16 09:50:47.338485
498	58	\N	3	t	2026-06-12 00:00:00	2026-06-16 09:50:47.338486
499	58	\N	4	t	2026-06-13 00:00:00	2026-06-16 09:50:47.338486
500	58	\N	5	t	2026-06-14 00:00:00	2026-06-16 09:50:47.338487
501	58	\N	6	t	2026-06-15 00:00:00	2026-06-16 09:50:47.338487
502	58	\N	7	t	2026-06-16 00:00:00	2026-06-16 09:50:47.338488
510	58	\N	1	t	2026-06-10 00:00:00	2026-06-16 10:40:40.60841
511	58	\N	2	t	2026-06-11 00:00:00	2026-06-16 10:40:40.608411
512	58	\N	3	t	2026-06-12 00:00:00	2026-06-16 10:40:40.608412
513	58	\N	4	t	2026-06-13 00:00:00	2026-06-16 10:40:40.608413
514	58	\N	5	t	2026-06-14 00:00:00	2026-06-16 10:40:40.608413
515	58	\N	6	t	2026-06-15 00:00:00	2026-06-16 10:40:40.608414
516	58	\N	7	t	2026-06-16 00:00:00	2026-06-16 10:40:40.608414
525	58	\N	1	t	2026-06-10 00:00:00	2026-06-16 13:20:00.566626
526	58	\N	2	t	2026-06-11 00:00:00	2026-06-16 13:20:00.566627
527	58	\N	3	t	2026-06-12 00:00:00	2026-06-16 13:20:00.566627
528	58	\N	4	t	2026-06-13 00:00:00	2026-06-16 13:20:00.566628
529	58	\N	5	t	2026-06-14 00:00:00	2026-06-16 13:20:00.566628
530	58	\N	6	t	2026-06-15 00:00:00	2026-06-16 13:20:00.566629
531	58	\N	7	t	2026-06-16 00:00:00	2026-06-16 13:20:00.566629
539	58	\N	1	t	2026-06-10 00:00:00	2026-06-16 13:30:47.439291
540	58	\N	2	t	2026-06-11 00:00:00	2026-06-16 13:30:47.439292
553	58	\N	1	t	2026-06-10 00:00:00	2026-06-16 13:41:09.963623
554	58	\N	2	t	2026-06-11 00:00:00	2026-06-16 13:41:09.963625
555	58	\N	3	t	2026-06-12 00:00:00	2026-06-16 13:41:09.963626
556	58	\N	4	t	2026-06-13 00:00:00	2026-06-16 13:41:09.963627
557	58	\N	5	t	2026-06-14 00:00:00	2026-06-16 13:41:09.963628
558	58	\N	6	t	2026-06-15 00:00:00	2026-06-16 13:41:09.963629
541	58	\N	3	t	2026-06-12 00:00:00	2026-06-16 13:30:47.439294
542	58	\N	4	t	2026-06-13 00:00:00	2026-06-16 13:30:47.439295
543	58	\N	5	t	2026-06-14 00:00:00	2026-06-16 13:30:47.439296
544	58	\N	6	t	2026-06-15 00:00:00	2026-06-16 13:30:47.439297
545	58	\N	7	t	2026-06-16 00:00:00	2026-06-16 13:30:47.439298
559	58	\N	7	t	2026-06-16 00:00:00	2026-06-16 13:41:09.96363
\.


--
-- Data for Name: relationships; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.relationships (id, user1_id, user2_id, status, journey_score, created_at, ended_at, summary_insight, relationship_type, user1_name, user2_name) FROM stdin;
2	4	6	archived	0	2026-06-08 14:29:05.852774	2026-06-08 14:53:28.764647	\N	\N	\N	\N
9	23	22	archived	0	2026-06-11 18:42:18.616106	2026-06-15 13:08:22.969272	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	partner	\N	sra
51	17	71	active	0	2026-06-16 15:54:29.566086	\N	\N	\N	\N	\N
27	45	51	archived	0	2026-06-15 12:41:15.405752	2026-06-15 14:08:24.914063	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	partners	lilli	jan
15	37	36	archived	0	2026-06-12 10:35:38.874515	2026-06-12 14:38:08.936518	Your journey, though nascent, unfolded with the profound strength of a singular, tender discernment, paving the way for each heart's truest path.	partner	\N	sofy
29	51	54	archived	0	2026-06-15 14:09:18.280944	2026-06-15 14:10:04.334042	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	partner	jan	sofy
16	38	36	archived	43	2026-06-12 17:37:44.32132	2026-06-13 15:42:22.194478	Even in a single day, your hearts bravely explored through tender letters and honest reflections, blooming into a deeper understanding.	friends	arjunnn	sofy
17	38	39	archived	11	2026-06-13 19:21:04.40392	2026-06-14 03:42:55.011142	Their brief, tender journey unfolded with such grace, it found its truths and gentle growth without need for long reflections, letters, or separations, a testament to swift, brave hearts.	Friend	arjunnn	prava
30	51	54	archived	116	2026-06-15 14:13:03.41855	2026-06-15 14:41:40.098985	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	\N	jan	sofy
31	51	50	active	0	2026-06-15 17:06:08.543091	\N	\N	\N	\N	\N
1	2	3	archived	49	2026-06-08 14:29:00.464801	2026-06-15 08:04:04.663776	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	partner	Alex	lucy
34	57	58	archived	128	2026-06-15 19:43:09.047813	2026-06-15 19:48:18.180137	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	partner	jan	Hii
19	42	4	archived	18	2026-06-14 14:43:14.593727	2026-06-16 05:08:15.836533	A brief, unbroken bloom, your journey was a tender testament to immediate truths and quiet growth, gracefully embraced in the shared now.	partner	alex	sofi
23	48	47	archived	31	2026-06-15 08:17:46.682986	2026-06-15 08:28:50.008542	A journey of tender brevity, yet rich with a shared letter and deep reflection, illuminated their brave hearts' growth and exploration.	partner	Sri	Bhagya
18	40	38	archived	477	2026-06-14 06:04:12.447962	2026-06-15 09:37:48.661702	Though your path was a tender sunrise, it held a brave separation, nurturing a unique spark of growth for both your souls.	Friend	sneha	arjuu
24	49	38	active	0	2026-06-15 09:42:12.644395	\N	\N	\N	\N	\N
25	45	17	archived	160	2026-06-15 11:05:21.876269	2026-06-15 11:11:57.060577	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	Friend	\N	pravallika
35	57	58	archived	128	2026-06-16 05:31:15.39612	2026-06-16 05:32:52.460132	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	\N	jan	Hii
26	45	17	archived	70	2026-06-15 11:13:42.850203	2026-06-15 12:39:33.317411	A single, brave reflection and a gentle pause etched a path of profound self-discovery, honoring the tender hearts that met on this journey.	partners	lilli	pravallika
36	57	58	archived	163	2026-06-16 05:47:49.384743	2026-06-16 06:21:06.476839	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	\N	jan	Hii
53	72	73	archived	28	2026-06-16 16:56:23.765034	2026-06-16 17:22:47.479069	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	partner	s	Pp
54	73	74	archived	0	2026-06-16 17:23:04.039818	2026-06-16 17:40:38.557426	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	partner	Pp	Bhagya
47	68	58	archived	8	2026-06-16 09:43:14.443054	2026-06-16 09:48:12.772411	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	PARTNER	JJJ	Hii
50	70	4	active	0	2026-06-16 14:06:47.885832	\N	\N	\N	\N	\N
49	68	17	archived	11	2026-06-16 13:01:24.470564	2026-06-16 15:53:59.896348	You navigated this journey with courage, leaving behind a path of quiet growth and shared understanding.	\N	JJJ	pravallika illa
\.


--
-- Data for Name: separations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.separations (id, creator_id, partner_id, duration_label, start_date, reason, status, closing_insight, expected_end_date, ended_at, created_at, relationship_id) FROM stdin;
1	2	\N	A week	2026-05-19	We need space to understand our triggers and heal our communication.	completed	\N	2026-05-26	2026-05-19 09:36:37.812273	2026-05-19 06:33:06.109135	\N
30	36	37	A week	2026-06-12	need space	completed	\N	2026-06-19	2026-06-12 12:02:35.330251	2026-06-12 11:20:33.801688	15
32	36	38	1 Week	2026-06-12	few days	completed	\N	2026-06-19	2026-06-13 15:42:29.22485	2026-06-12 17:42:04.985263	16
24	4	6	A few days	2026-06-08		completed	\N	2026-06-15	\N	2026-06-08 10:53:51.565865	2
2	3	2	A week	2026-05-19	We need space to understand our triggers and heal our communication.	completed	\N	2026-05-26	2026-05-19 11:17:47.162368	2026-05-19 06:46:57.891375	1
9	3	2	A week	2026-05-19	We need space to understand our triggers and heal our communication.	completed	{"coupleInsight": "Throughout this separation, you have both shown a courage that is quiet but profound. By taking space to look inward, you've created a landscape where understanding can slowly replace reaction, and where emotional safety can begin to take root.", "personalGrowths": ["You've shown a consistent willingness to explore the quieter corners of your heart, showing up with honesty even on the days when the emotions felt heavy.", "Together, you have honored this time of distance not as a separation, but as a bridge toward clearer, gentler connection."], "improvementAdvice": "Consider sharing your emotional needs when they first arise, rather than waiting for them to compound. Your feelings deserve to be heard when they are fresh, which also gives your partner the chance to meet you with empathy.", "reflection": "Your relationship is slowly shifting from reaction to understanding. Even the smallest pauses you took created space for something better to grow between you."}	2026-06-03	2026-06-15 08:04:08.238587	2026-05-19 11:31:24.093262	1
4	4	6	A few days	2026-05-19	hi	completed	\N	2026-05-26	2026-06-08 10:31:44.634965	2026-05-19 08:49:42.394687	2
5	4	6	A few days	2026-05-14	n	completed	\N	2026-05-21	2026-06-08 10:31:59.475765	2026-05-19 08:51:06.334385	2
6	4	6	A week	2026-05-19	to understand ouselves	completed	\N	2026-05-26	2026-06-08 09:18:52.571244	2026-05-19 08:53:03.762081	2
7	4	6	A week	2026-05-19	h	completed	\N	2026-05-26	2026-06-08 10:32:14.349284	2026-05-19 09:00:22.857239	2
8	4	6	A week	2026-05-19	hi	completed	\N	2026-05-26	2026-06-08 10:33:53.249932	2026-05-19 09:03:44.661994	2
13	4	6	A few days	2026-05-23		completed	\N	2026-05-30	2026-06-08 10:34:07.661295	2026-05-23 06:18:34.463587	2
14	4	6	A few days	2026-05-23	hi	completed	\N	2026-05-30	2026-06-08 10:34:46.175248	2026-05-23 06:56:46.566307	2
15	4	6	A few days	2026-05-23	hi	completed	\N	2026-05-30	2026-06-08 10:34:56.860407	2026-05-23 07:00:36.371752	2
16	4	6	A few days	2026-05-23	hi	completed	\N	2026-05-30	2026-06-08 10:35:01.092534	2026-05-23 10:11:24.057924	2
17	4	6	A few days	2026-05-23	hi	completed	\N	2026-05-30	2026-06-08 10:35:07.936826	2026-05-23 10:11:52.277289	2
18	4	6	A few days	2026-06-04	hi	completed	\N	2026-06-11	2026-06-08 10:35:16.718457	2026-06-04 08:49:40.617638	2
19	4	6	A few days	2026-06-08		completed	\N	2026-06-15	2026-06-08 10:35:22.574364	2026-06-08 09:20:44.228114	2
20	6	4	week	2026-06-19	space	completed	\N	2026-06-26	2026-06-08 10:35:46.27738	2026-06-08 09:24:15.049826	2
21	4	6	A few days	2026-06-08		completed	\N	2026-06-15	2026-06-08 10:36:31.995135	2026-06-08 10:17:38.446101	2
22	6	4	week	2026-06-19	space 1	completed	\N	2026-06-26	2026-06-08 10:55:11.9829	2026-06-08 10:36:53.528971	2
36	41	\N	1 Week	2026-06-14	space	completed	\N	2026-06-21	2026-06-15 09:21:58.363433	2026-06-14 11:55:59.230789	\N
37	38	40	2 Weeks	2026-06-14	space	completed	\N	2026-06-28	2026-06-15 09:21:58.363433	2026-06-14 14:56:55.390932	18
31	36	\N	1 Week	2026-06-07	few days	completed	\N	2026-06-14	2026-06-15 09:21:58.363433	2026-06-12 17:35:51.555649	\N
34	38	\N	1 Month	2026-05-15		completed	{"coupleInsight": "Arjuu and Sneha, your journey through this separation reveals a beautiful shared thread in the simple joy of 'sharing coffee,' a memory that holds warmth and love for Arjuu, hinting at a deep, gentle connection between you both. Arjuu's personal path was marked by a clear evolution from 'Longing' to 'Growing' and finding a 'Calm' space, demonstrating profound self-engagement and emotional processing. However, the contrast in your participation, with Sneha's reflections being very limited, highlights an emotional asymmetry in this particular process that will be important to tenderly explore as you move forward together.", "personalGrowths": ["Arjuu, your commitment to self-reflection and emotional honesty during this separation has been truly remarkable. Moving from an initial 'Longing' to a sustained period of 'Calm' and 'Growing' shows a beautiful capacity for internal processing and personal evolution. Your willingness to acknowledge 'feeling low' and 'grief' without Sneha speaks volumes about the depth of your feelings and your journey towards emotional clarity.", "While Sneha's reflections were minimal, her one shared memory of 'sharing coffe with him' offers a glimpse into a gentle affection that can be a valuable foundation for deeper emotional exploration. The journey of self-discovery through consistent reflection is still very much ahead for her, inviting her to lean into her feelings and share them more openly for both her own growth and the health of the relationship.", "Together, the shared recognition of 'sharing coffee' as a happy memory is a testament to the simple, yet profound, joys you've found in each other's company. This shared thread, even amidst differing levels of engagement in the reflection process, indicates a fundamental point of connection and warmth that can be revisited and nurtured as you rebuild and grow."], "partnerAImprovement": "Arjuu, your journey of self-reflection has been remarkably consistent and insightful, moving from longing to a place of calm and growth. To deepen this, consider bringing even more specific detail and emotional nuance to your reflections, especially when exploring areas you wish you handled differently, rather than simply stating 'neutral'. This continuous practice of vulnerability will not only further your own emotional clarity but also gently invite Sneha to meet you in that space.", "partnerBImprovement": "Sneha, your voice in this reflection period has been very quiet, with only one entry and no mood history. For your relationship to truly flourish and for both of you to grow, it's so important to find ways to express your own feelings, memories, and needs regularly. Opening up and engaging more deeply in self-reflection will not only help Arjuu understand your inner world better but will also be a profound gift to yourself in understanding your own emotions.", "reflection": "As you step forward from this separation, remember that every journey, no matter how unique, is a story of potential. The quiet moments, the expressed longings, and the varied paces of your individual growth all contribute to the rich tapestry of your shared life. Embrace the tenderness of your connection, the lessons learned, and the courage to continue exploring your hearts together, knowing that every step taken with awareness and love paves the way for deeper understanding and a stronger, more resilient bond."}	2026-06-14	2026-06-15 09:21:58.363433	2026-06-14 04:44:51.704134	\N
23	4	6	A few days	2026-06-08		completed	{"bondScore": {"score": 85, "explanation": "sofi's consistent engagement and reflective moods show a deep commitment to understanding herself and the relationship. This individual openness to processing emotions is a strong foundation for future growth."}, "holdsTogether": {"strengths": ["sofi's Self-reflection", "Desire for Understanding", "Effort to Communicate"], "explanation": "sofi's personal journey of reflection and her effort to communicate through letters show a powerful commitment to emotional processing."}, "trulyMissed": {"missed": ["Shared emotional processing", "Mutual understanding"], "interpretation": "The journey highlights a deep human longing for both partners to openly explore feelings and shared experiences together."}, "unspokenNeeds": {"individual": ["sofi: Open communication", "sofi: Mutual engagement"], "shared": ["Emotional safety", "Acknowledged perspectives"], "explanation": "sofi's reflective nature and letter writing suggest a need for deeper, reciprocated emotional sharing and understanding."}, "howYouGrown": {"areas": ["Increased Self-awareness", "Emotional Resilience", "Peaceful Introspection"], "examples": "sofi's 'Reflective' and 'Peaceful' moods indicate a growing ability to process emotions calmly and gain insight."}, "patternsNoticed": {"patterns": ["Asynchronous reflection", "sofi's proactive engagement"], "whyItMatters": "One partner's active engagement in reflection, while the other is silent, can reveal differing styles of processing."}, "quietLove": {"behaviors": ["sofi's continued effort", "Hope for connection"], "summary": "sofi's dedication to reflecting and writing letters is a quiet testament to her caring and hope for understanding."}, "leftUnsaid": {"themes": ["Alex's inner world", "Unexpressed shared feelings"], "summary": "The absence of Alex's reflections means many feelings and perspectives remain unvoiced within this shared space."}, "blindSpots": {"opportunities": ["Alex's perspective", "Shared reflection insights"], "explanation": "Understanding Alex's thoughts and feelings remains a crucial area for deeper shared insight into their dynamic."}, "futureWant": {"alignment": ["Deeper understanding", "Shared emotional path"], "summary": "sofi's engagement suggests a desire for a future where both partners can explore their relationship with openness."}, "aiLetter": "Dear sofi,\\n\\nYour dedication to self-reflection and your courage in expressing yourself through letters are truly admirable. Your 'Reflective' and 'Peaceful' moods highlight a beautiful capacity for inner calm amidst processing complex emotions. This journey, even when solo in its recorded moments, speaks volumes about your strength.\\n\\nIt\\u2019s clear you've been engaging deeply with your own experience, a powerful step toward personal growth and clarity. This individual path creates a strong foundation for understanding your own needs and desires within the relationship.\\n\\nWhile we don't have Alex's reflections here, your commitment to understanding yourself is a light you bring. Remember, growth often starts within, radiating outward.\\n\\nKeep nurturing this compassionate space within yourself. Your capacity for reflection is a gift, offering hope for deeper connection and understanding in your future, whatever form it takes. You're doing meaningful work."}	2026-06-15	\N	2026-06-08 10:49:59.87049	2
3	2	3	A week	2026-05-20	We need space 	completed	{"coupleInsight": "Alex, your journey during this separation reveals a beautiful, yet complex, emotional landscape shared between you and lucy. While your reflection pointed to a foundational 'love' for your happiest memory, lucy's answer evoked a sense of 'sadness' when recalling hers, hinting at differing internal experiences of your shared past. This contrast, coupled with lucy's clear expressions of 'longing' and her active step to write letters, suggests a significant difference in how you both process and express your emotions, particularly the impact of this time apart, creating a subtle emotional distance that yearns to be bridged.", "personalGrowths": ["Alex, your reflection on 'love' as your happiest memory, even if presented with a neutral tone, speaks to a deep, abiding affection at the core of your being. This quiet certainty is a beautiful strength, though your emotional journey during this separation also appears to have been a very internal one, with fewer outward expressions of your feelings or a documented mood history.", "As a couple, the simple act of both of you engaging with the initial reflection process is a significant step forward. It shows a shared willingness to look inward and acknowledge the relationship's past, even if your individual answers highlighted distinct emotional experiences. This mutual participation, however brief, forms a vital foundation for future open dialogue."], "improvementAdvice": "Alex, while your quiet 'love' for your shared past is powerful, lucy's recurring feelings of 'longing' and her expressed 'sadness' point to a deep emotional current within her that needs your gentle recognition. Try to lean into sharing more of your own nuanced feelings\\u2014not just the labels\\u2014and actively inquire about lucy's emotional experiences, particularly what her 'longing' truly feels like and means to her. Opening these channels of vulnerability from both sides will help you both navigate the emotional landscape more closely.", "reflection": "This period of separation has offered a unique mirror to your individual hearts, Alex. It's revealed a quiet strength within you, and a deep, yearning tenderness within lucy. These initial insights aren't judgments, but rather gentle invitations to understand each other's emotional worlds more deeply. Embrace this clarity with compassion, knowing that growth is a journey of both individual discovery and shared vulnerability, and that every step you take towards emotional understanding is a step closer to a more connected and healing future together."}	2026-05-27	2026-06-15 08:04:08.238574	2026-05-19 06:49:18.146755	1
41	47	48	1 Week	2026-06-15	to understand us better	completed	\N	2026-06-22	2026-06-15 08:28:50.382479	2026-06-15 08:19:18.620147	23
57	58	57	1 Week	2026-06-10	need space	completed	\N	2026-06-16	2026-06-16 05:55:39.619492	2026-06-16 05:54:16.127866	36
44	17	45	1 Week	2026-06-15	space	completed	\N	2026-06-22	2026-06-15 11:11:57.325646	2026-06-15 11:06:08.26842	25
45	17	45	1 Week	2026-06-15	space	completed	\N	2026-06-22	2026-06-15 12:39:37.115789	2026-06-15 11:16:06.718147	26
46	45	51	1 Week	2026-06-15	space	completed	\N	2026-06-22	2026-06-15 14:08:25.221915	2026-06-15 12:42:42.461912	27
51	58	57	1 Week	2026-06-09	surv	completed	{"58": {"bondScore": {"score": 70, "explanation": "Hii's inner peace is a strong personal foundation. While direct emotional sharing was limited, 7 days of shared reflection show mutual commitment."}, "holdsTogether": {"strengths": ["Shared simple joys", "Inner calm", "Mutual commitment"], "explanation": "Finding comfort in simple shared moments, like coffee, creates a gentle, enduring connection between you."}, "trulyMissed": {"missed": ["Shared simple rituals"], "interpretation": "Missing the quiet comfort of shared daily routines signifies a deep value for your togetherness."}, "unspokenNeeds": {"individual": ["Hii: Inner tranquility", "jan: Gentle connection"], "shared": ["Deeper emotional sharing"], "explanation": "Both may benefit from expressing internal feelings more openly to foster profound understanding."}, "howYouGrown": {"areas": ["Cultivating inner peace", "Self-awareness"], "examples": "Hii maintained peacefulness during this reflective period, demonstrating remarkable resilience and self-regulation."}, "patternsNoticed": {"patterns": ["Reserved emotional expression", "Subtle communication"], "whyItMatters": "Openly sharing feelings helps bridge understanding and builds a path toward deeper intimacy."}, "quietLove": {"behaviors": ["Shared simple rituals", "Calm presence"], "summary": "Quietly finding joy in everyday activities signifies a gentle, steady affection that underpins your connection."}, "leftUnsaid": {"themes": ["Unexpressed feelings", "Deeper thoughts"], "summary": "Many emotions and personal reflections likely remain unspoken, forming a rich, hidden emotional landscape."}, "blindSpots": {"opportunities": ["Articulating needs clearly", "Sharing vulnerable thoughts"], "explanation": "Explicitly sharing your thoughts and feelings can prevent misunderstandings and foster even deeper connection."}, "futureWant": {"alignment": ["Reconnecting through simple joys", "Peaceful togetherness"], "summary": "A shared desire to re-establish comforting, simple connections can lovingly guide your future path together."}, "aiLetter": "Dear Hii,\\n\\nIt's truly inspiring to see your 'Peaceful' mood during this reflective journey. This calm strength is a beautiful foundation for growth, allowing you to approach your relationship with a clear and gentle heart. Your inner serenity is a gift.\\n\\nFrom jan's reflection, 'sharing coffe' stands out as a cherished memory. It highlights the profound beauty in your simple, shared moments. These quiet joys often hold the deepest meaning and can gently guide you back to understanding each other.\\n\\nWhile direct emotional sharing was brief, the act of engaging in this process together shows a mutual commitment. Consider this an opportunity to softly encourage more open expressions of your feelings and needs.\\n\\nWith empathy, appreciation, and hope, you can continue to nurture your unique bond. Remember that gentle steps and heartfelt sharing can illuminate the path toward deeper connection. Your journey continues with kindness."}}	2026-06-15	2026-06-15 19:45:20.059157	2026-06-15 19:43:48.135037	34
52	54	\N	1 Week	2026-06-16	need space	active	\N	2026-06-23	\N	2026-06-15 20:41:02.351201	\N
48	54	51	1 Week	2026-06-08	space	completed	{"bondScore": {"score": 80, "explanation": "Your consistent engagement with the reflection process, alongside Jan's, shows a strong foundational commitment to understanding. This active participation suggests a deep care for exploring your relationship's journey."}, "holdsTogether": {"strengths": ["Shared commitment to reflection", "Desire for understanding", "Individual introspection"], "explanation": "Your consistent engagement with the reflection process highlights a shared desire to understand your relationship's path."}, "trulyMissed": {"missed": ["Unshared inner thoughts", "Deeper emotional insights"], "interpretation": "While specific reflections weren't shared, the very act of engaging hints at a longing for deeper emotional understanding."}, "unspokenNeeds": {"individual": ["Space for personal truth"], "shared": ["Emotional transparency"], "explanation": "The reflection journey offers a vital space to uncover and potentially share the important emotional needs of both partners."}, "howYouGrown": {"areas": ["Inner peace (sofy)", "Reflective mindset"], "examples": "Sofy's consistent 'Peaceful' and 'Calm' moods suggest a growing sense of serenity and self-awareness through introspection."}, "patternsNoticed": {"patterns": ["Consistent engagement in process"], "whyItMatters": "Your mutual dedication to completing reflections shows a valuable pattern of active effort towards understanding."}, "quietLove": {"behaviors": ["Thoughtful participation", "Ongoing introspection"], "summary": "The consistent effort both of you put into the reflection process speaks to a quiet, enduring care and presence."}, "leftUnsaid": {"themes": ["Unarticulated emotions", "Personal insights"], "summary": "Many valuable personal feelings and reflections remain unspoken, holding potential for future connection."}, "blindSpots": {"opportunities": ["Verbalizing inner thoughts", "Bridging unspoken gaps"], "explanation": "The biggest opportunity lies in transforming internal reflections into open, shared conversations to bridge emotional distance."}, "futureWant": {"alignment": ["Deeper understanding", "Potential for reconnection"], "summary": "Your shared commitment to reflection suggests a mutual hope for continued understanding and a potential path forward together."}, "aiLetter": "Dear sofy,\\n\\nIt\\u2019s truly moving to see your consistent dedication to this reflection journey. Your mood history, filled with peaceful and calm moments, shines a light on your resilience and capacity for inner serenity amidst exploration.\\n\\nBoth you and Jan showed a commendable commitment by engaging with the reflection process. This shared effort, even without words, speaks volumes about a deeper care for understanding your journey together. It\\u2019s in these quiet acts of introspection that so much growth begins.\\n\\nThis journey is about uncovering, not judging. Continue to nurture that inner calm, sofy. There\\u2019s profound strength in your quiet engagement, and it paves the way for deeper connections to emerge.\\n\\nRemember, every step taken in understanding yourself and your relationship is a step towards hope.\\nWith warmth,\\nBONDED AI"}	2026-06-15	2026-06-15 14:14:57.878632	2026-06-15 14:13:33.235875	30
49	50	51	1 Week	2026-06-15	space	active	\N	2026-06-22	\N	2026-06-15 18:08:29.247785	31
53	60	\N	1 Week	2026-06-16	hii	active	\N	2026-06-23	\N	2026-06-16 04:14:35.904723	\N
54	4	\N	1 Week	2026-06-10	ho.	completed	\N	2026-06-16	2026-06-16 05:11:18.735797	2026-06-16 05:10:22.267332	\N
55	61	\N	1 Week	2026-06-16	hi	active	\N	2026-06-23	\N	2026-06-16 05:12:40.195823	\N
56	4	70	1 Week	2026-06-10	hi	completed	{"4": {"bondScore": {"score": 75, "explanation": "Your consistent engagement over 7 days shows a strong commitment to your journey. Deeper emotional sharing is a beautiful next step."}, "holdsTogether": {"strengths": ["Consistent engagement", "Simple shared joys"], "explanation": "Your shared commitment to reflection and finding comfort in daily moments are core strengths."}, "trulyMissed": {"missed": ["Shared simple comforts", "Daily connection"], "interpretation": "There is a gentle longing for the simple, comforting presence you shared."}, "unspokenNeeds": {"individual": ["Sofi: Space to open", "Jnana: Calm connection"], "shared": ["Emotional safety", "Deeper understanding"], "explanation": "Both partners likely seek a safe, open space for more profound emotional sharing."}, "howYouGrown": {"areas": ["Commitment to reflect", "Engaging in process"], "examples": "You consistently participated, showing dedication to self-discovery and the relationship."}, "patternsNoticed": {"patterns": ["Brief emotional sharing", "Neutral initial responses"], "whyItMatters": "Gently opening up more can unlock deeper intimacy and understanding."}, "quietLove": {"behaviors": ["Comfort in routines", "Shared peaceful moments"], "summary": "Love expresses itself through shared, quiet comforts and simple daily rituals."}, "leftUnsaid": {"themes": ["Deeper feelings", "Personal reflections"], "summary": "Much of your inner world and profound emotions still wait to be expressed."}, "blindSpots": {"opportunities": ["Expressing inner thoughts", "Embracing vulnerability"], "explanation": "Fully sharing your feelings can deepen connection and foster greater understanding."}, "futureWant": {"alignment": ["Mutual engagement", "Seeking understanding"], "summary": "Both of you actively participated, showing a shared hope for clarity and connection."}, "aiLetter": "Dear sofi,\\n\\nIt's clear that both you and Jnana are truly dedicated to understanding your relationship, consistently engaging with your reflections for seven days. This shared commitment is a wonderful foundation, showing a deep care for what you have together.\\n\\nWe noticed the comfort found in simple moments, like sharing coffee. These quiet joys often hold the profoundest love and connection, reminding us of the warmth in everyday life. Your journey has just begun to unfold, with many beautiful layers yet to be discovered.\\n\\nThere\\u2019s so much potential for growth when you feel ready to gently share more of your inner world. Creating a safe space for deeper emotional expression can bring you closer, fostering an even richer understanding between you. Remember, every step of reflection is a step towards connection.\\n\\nWith appreciation and hope,\\nBONDED AI"}, "70": {"bondScore": {"score": 85, "explanation": "Your consistent engagement reflects a strong commitment to understanding and growth. Deeper emotional sharing is still emerging, showing room to connect further."}, "holdsTogether": {"strengths": ["Consistent engagement", "Shared commitment", "Peaceful presence"], "explanation": "Your mutual dedication to this reflection journey is a significant foundation for understanding."}, "trulyMissed": {"missed": ["Simple shared moments", "Daily comfort"], "interpretation": "There's a gentle yearning for the comfort of routine and presence you once shared."}, "unspokenNeeds": {"individual": ["Jnana: Calm connection", "sofi: Deeper insights"], "shared": ["Safe emotional expression"], "explanation": "Creating space for open and honest emotional expression can foster deeper understanding for both."}, "howYouGrown": {"areas": ["Consistent reflection", "Emotional stability", "Process dedication"], "examples": "Jnana maintains peace; both consistently completed reflections, showing commitment to self-discovery."}, "patternsNoticed": {"patterns": ["Brief communication", "Reserved emotional sharing"], "whyItMatters": "Exploring beyond brief answers can reveal richer, more profound insights into your connection."}, "quietLove": {"behaviors": ["Appreciating small moments", "Thoughtful engagement"], "summary": "Love shows in appreciating simple routines and a thoughtful, reflective approach to the relationship."}, "leftUnsaid": {"themes": ["Unexpressed emotions", "Private thoughts"], "summary": "Many significant feelings and deeper thoughts are still held privately, awaiting a safe space to emerge."}, "blindSpots": {"opportunities": ["Deeper emotional vulnerability"], "explanation": "Embracing vulnerability more fully can unlock profound mutual understanding and connection."}, "futureWant": {"alignment": ["Mutual understanding", "Relationship clarity"], "summary": "Both clearly desire clarity and a deeper understanding of your connection and path forward."}, "aiLetter": "Dear Jnana,\\n\\nIt\\u2019s clear you approach this journey with a peaceful heart, as your mood suggests. Reflecting on 'sharing coffe' highlights your appreciation for simple, cherished moments, which are the quiet anchors of a relationship. Your consistent engagement, alongside sofi's, truly speaks volumes about your commitment to understanding.\\n\\nThis commitment is a beautiful strength you both share. While some feelings remain unsaid, this process is gently guiding you towards a space where deeper thoughts can surface. There's a soft longing for those shared routines and comforting presences, a natural human desire.\\n\\nRemember, growth often happens in small, consistent steps. Your ability to remain peaceful while engaging in this reflection is a wonderful personal strength. As you both continue, consider allowing your hearts to share a little more, finding new ways to express the quiet love present.\\n\\nTrust in your shared desire for understanding. Every reflection, every moment of peace, brings you closer to clarity and strengthens the bond you're exploring."}}	2026-06-16	2026-06-16 14:23:18.676744	2026-06-16 05:14:18.736671	50
59	64	\N	1 Week	2026-06-16	hii	active	\N	2026-06-23	\N	2026-06-16 06:47:52.453536	\N
65	66	\N	1 Week	2026-06-16	hii	active	\N	2026-06-23	\N	2026-06-16 07:44:38.575296	\N
70	58	68	1 Week	2026-06-10	hiii	completed	\N	2026-06-16	2026-06-16 09:46:10.697017	2026-06-16 09:45:06.709753	47
82	74	73	1 Week	2026-06-16	hi	completed	{"74": {"bondScore": {"score": 85, "explanation": "You both showed quiet courage and honesty."}, "holdsTogether": {"strengths": ["Deep emotional care", "Willingness to try"], "explanation": "Your foundation remains strong."}, "trulyMissed": {"missed": ["Daily presence", "Quiet moments"], "interpretation": "Absence highlighted your deep bond."}, "unspokenNeeds": {"individual": ["Reassurance"], "shared": ["Emotional safety"], "explanation": "Both of you seek gentle understanding."}, "howYouGrown": {"areas": ["Patience", "Self-awareness"], "examples": "You chose reflection over reaction."}, "patternsNoticed": {"patterns": ["Holding back fears"], "whyItMatters": "Vulnerability brings you closer."}, "quietLove": {"behaviors": ["Showing up daily", "Writing letters"], "summary": "Love was present in the effort."}, "leftUnsaid": {"themes": ["Fear of disconnect"], "summary": "It's safe to share these now."}, "blindSpots": {"opportunities": ["Expressing needs sooner"], "explanation": "Don't wait for the 'perfect' moment."}, "futureWant": {"alignment": ["A peaceful reconnection"], "summary": "You both want the same thing."}, "aiLetter": "Dear Bhagya,\\n\\nThroughout this separation, you have both shown a courage that is quiet but profound. By taking space to look inward, you've created a landscape where understanding can slowly replace reaction.\\n\\nTogether, you have honored this time of distance not as a separation, but as a bridge toward clearer, gentler connection.\\n\\nWith warmth,\\nBonded AI"}, "73": {"bondScore": {"score": 85, "explanation": "You both showed quiet courage and honesty."}, "holdsTogether": {"strengths": ["Deep emotional care", "Willingness to try"], "explanation": "Your foundation remains strong."}, "trulyMissed": {"missed": ["Daily presence", "Quiet moments"], "interpretation": "Absence highlighted your deep bond."}, "unspokenNeeds": {"individual": ["Reassurance"], "shared": ["Emotional safety"], "explanation": "Both of you seek gentle understanding."}, "howYouGrown": {"areas": ["Patience", "Self-awareness"], "examples": "You chose reflection over reaction."}, "patternsNoticed": {"patterns": ["Holding back fears"], "whyItMatters": "Vulnerability brings you closer."}, "quietLove": {"behaviors": ["Showing up daily", "Writing letters"], "summary": "Love was present in the effort."}, "leftUnsaid": {"themes": ["Fear of disconnect"], "summary": "It's safe to share these now."}, "blindSpots": {"opportunities": ["Expressing needs sooner"], "explanation": "Don't wait for the 'perfect' moment."}, "futureWant": {"alignment": ["A peaceful reconnection"], "summary": "You both want the same thing."}, "aiLetter": "Dear Pp,\\n\\nThroughout this separation, you have both shown a courage that is quiet but profound. By taking space to look inward, you've created a landscape where understanding can slowly replace reaction.\\n\\nTogether, you have honored this time of distance not as a separation, but as a bridge toward clearer, gentler connection.\\n\\nWith warmth,\\nBonded AI"}}	2026-06-23	2026-06-16 17:40:38.748091	2026-06-16 17:39:52.558675	54
73	17	68	1 Week	2026-06-10	space	completed	\N	2026-06-16	2026-06-16 15:20:36.360374	2026-06-16 13:02:06.029369	49
77	17	68	1 Week	2026-06-16	hjnk	completed	\N	2026-06-23	2026-06-16 15:54:00.144052	2026-06-16 15:27:04.203938	49
80	4	70	1 Week	2026-06-16	hi	active	\N	2026-06-23	\N	2026-06-16 17:18:17.093593	50
79	73	72	1 Week	2026-06-16	space	completed	\N	2026-06-23	2026-06-16 17:22:47.679496	2026-06-16 16:55:14.151875	53
81	74	73	1 Week	2026-06-10	to understand each other	completed	{"74": {"bondScore": {"score": 85, "explanation": "You both showed quiet courage and honesty."}, "holdsTogether": {"strengths": ["Deep emotional care", "Willingness to try"], "explanation": "Your foundation remains strong."}, "trulyMissed": {"missed": ["Daily presence", "Quiet moments"], "interpretation": "Absence highlighted your deep bond."}, "unspokenNeeds": {"individual": ["Reassurance"], "shared": ["Emotional safety"], "explanation": "Both of you seek gentle understanding."}, "howYouGrown": {"areas": ["Patience", "Self-awareness"], "examples": "You chose reflection over reaction."}, "patternsNoticed": {"patterns": ["Holding back fears"], "whyItMatters": "Vulnerability brings you closer."}, "quietLove": {"behaviors": ["Showing up daily", "Writing letters"], "summary": "Love was present in the effort."}, "leftUnsaid": {"themes": ["Fear of disconnect"], "summary": "It's safe to share these now."}, "blindSpots": {"opportunities": ["Expressing needs sooner"], "explanation": "Don't wait for the 'perfect' moment."}, "futureWant": {"alignment": ["A peaceful reconnection"], "summary": "You both want the same thing."}, "aiLetter": "Dear Bhagya,\\n\\nThroughout this separation, you have both shown a courage that is quiet but profound. By taking space to look inward, you've created a landscape where understanding can slowly replace reaction.\\n\\nTogether, you have honored this time of distance not as a separation, but as a bridge toward clearer, gentler connection.\\n\\nWith warmth,\\nBonded AI"}}	2026-06-16	2026-06-16 17:27:32.351808	2026-06-16 17:26:45.303976	54
\.


--
-- Data for Name: user_daily_affirmations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_daily_affirmations (id, user_id, affirmation_date, text, created_at) FROM stdin;
1	17	2026-06-11	Pravallika, let hope be the gentle star illuminating your path, guiding you with quiet certainty towards a cherished reunion.	2026-06-11 08:22:34.108793+00
2	22	2026-06-11	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-11 18:42:56.31866+00
4	25	2026-06-12	Our connection is a deep, quiet melody, resonating within the heart and harmonizing all you are.	2026-06-12 05:39:33.813488+00
5	26	2026-06-12	hello, our connection is a deepening wellspring, nourishing the soul with every shared moment and quiet understanding.	2026-06-12 05:48:09.26465+00
6	17	2026-06-12	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-12 06:17:14.161631+00
12	36	2026-06-12	Sofy, today is an invitation to quietly notice and deeply cherish the profound ways your partner enriches your life, allowing gratitude to deepen your beautiful connection.	2026-06-12 10:33:56.771626+00
13	38	2026-06-12	Arjun, let this temporary space strengthen your emotional resilience, knowing that every moment apart draws the heart closer to a cherished reunion.	2026-06-12 18:14:35.17386+00
14	36	2026-06-13	Sofy, though physical distance may exist, the emotional connection and understanding you beautifully cultivate now will seamlessly bridge any temporary space between your hearts.	2026-06-13 06:24:19.367493+00
15	38	2026-06-13	Arjun, let your steadfast heart hold patience, knowing this distance is but a temporary horizon, and that true connection deepens through enduring trust and understanding.	2026-06-13 06:37:08.168462+00
16	38	2026-06-14	Arjun, may your heart fully appreciate the presence of your beloved, allowing gratitude to deepen the beautiful connection you both enrich each day.	2026-06-14 02:24:01.133624+00
17	17	2026-06-14	Pravallika, let your heart gently recognize the unique light your partner brings, nurturing gratitude for the steadfast love that blossoms between you.	2026-06-14 08:15:17.946672+00
18	40	2026-06-14	Sneha, this season of distance is a gentle pause, allowing patience to deepen trust and strengthen the invisible threads connecting your hearts until you meet again.	2026-06-14 08:38:21.187665+00
19	4	2026-06-14	Sofi, by mindfully appreciating the quiet strengths and loving gestures of your partner, your bond grows richer and more profound each day.	2026-06-14 08:49:54.189734+00
20	41	2026-06-14	Bhanu, allow gratitude for your partner's unique essence to illuminate your shared path, fostering an ever-deepening bond of love.	2026-06-14 11:37:14.789099+00
21	43	2026-06-14	Bhagya, allow your heart to fully embrace the radiant love your partner shares, letting gratitude strengthen the beautiful bond you nurture together.	2026-06-14 14:59:55.441139+00
22	44	2026-06-14	Jnana, your love deepens beautifully as you actively recognize and appreciate the unique light your partner brings, weaving your hearts closer in gratitude.	2026-06-14 15:04:34.827046+00
23	44	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 04:24:45.652004+00
24	17	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 04:28:37.094939+00
25	2	2026-06-15	Alex, let their hearts remain softly connected across the miles, trusting that this temporary distance is forging a deeper understanding and resilient love.	2026-06-15 05:53:56.054133+00
26	38	2026-06-15	Arjuu, let your spirit find calm amidst this temporary journey apart, trusting that the unwavering thread of connection between hearts only grows stronger with patience and understanding.	2026-06-15 07:28:22.689428+00
27	46	2026-06-15	Vamsi, may your heart continually find new depths of appreciation for the unique spirit and comforting presence your partner brings, enriching the beautiful tapestry of your shared life.	2026-06-15 07:41:25.198472+00
28	4	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 08:11:44.237003+00
29	47	2026-06-15	Bhagya, may you feel a gentle current of gratitude for your partner, seeing the love reflected in every shared smile and knowing glance.	2026-06-15 08:14:53.55952+00
30	48	2026-06-15	Sri, let gratitude be the quiet language that speaks volumes in your connection, illuminating the unique light your partner brings to your shared journey.	2026-06-15 08:17:52.624504+00
31	40	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 10:57:57.096326+00
32	45	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 12:29:10.915014+00
34	22	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 13:07:37.60876+00
35	54	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 14:06:37.314915+00
36	55	2026-06-15	Tej, allow your heart to recognize the quiet magic in your partner's presence, deepening the wellspring of gratitude that nourishes your shared love.	2026-06-15 15:49:28.537416+00
37	50	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 17:01:34.31324+00
39	58	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 19:42:36.058626+00
40	59	2026-06-15	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-15 20:39:01.706643+00
41	54	2026-06-16	Sofy, may you deeply appreciate the tender connections that enrich your shared journey, allowing gratitude to blossom for your partner's love.	2026-06-16 03:24:08.889684+00
42	50	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 03:25:25.728683+00
43	60	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 03:37:45.144819+00
44	4	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 05:05:17.369642+00
45	61	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 05:12:26.032621+00
46	62	2026-06-16	Bhagya, let your heart gently expand with gratitude, honoring the unique spirit and loving presence your partner brings to your shared life.	2026-06-16 05:21:41.625542+00
47	58	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 05:24:33.007469+00
48	57	2026-06-16	Jan, allow your heart to recognize the quiet strength and unwavering love your partner brings into your world, deepening your shared bond.	2026-06-16 05:30:59.323525+00
50	64	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 06:41:18.970012+00
52	66	2026-06-16	Bhagya, embrace the gentle warmth of appreciation, allowing it to deepen the emotional bond and enrich every shared moment with your beloved partner.	2026-06-16 07:11:08.172915+00
53	67	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 08:28:47.672515+00
55	17	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 12:57:59.803214+00
56	70	2026-06-16	Jnana, know that this season of distance is a temporary canvas, inviting patience and deepening the tender trust that beautifully holds your connection until you are together again.	2026-06-16 14:07:01.248019+00
57	71	2026-06-16	Bhagya, let the quiet strength of your appreciation for your partner's unique light deepen the sacred space of your shared love, fostering an ever-closer bond.	2026-06-16 15:50:55.744964+00
58	73	2026-06-16	Pp, reflect on the wonderful qualities your partner embodies, allowing gratitude to illuminate the profound connection you both nurture.	2026-06-16 16:54:24.96641+00
59	74	2026-06-16	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-16 17:22:08.733304+00
60	73	2026-06-17	Pp, choose today to consciously appreciate the unique light your partner adds to your world, deepening the emotional tapestry woven between you.	2026-06-17 04:23:15.014623+00
61	75	2026-06-17	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-17 05:14:21.468914+00
62	50	2026-06-17	Every quiet step you take toward understanding is a step toward deeper love.	2026-06-17 05:48:16.984248+00
63	46	2026-06-17	Distance measures miles, not the strength of a connection.	2026-06-17 06:28:31.290258+00
\.


--
-- Data for Name: user_daily_comforts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_daily_comforts (id, user_id, comfort_date, text, created_at) FROM stdin;
1	36	2026-06-12	Be gentle with your heart as you navigate this new chapter.	2026-06-12 11:20:41.45377+00
2	38	2026-06-12	You are growing, even in the quiet moments.	2026-06-12 18:14:25.930102+00
3	38	2026-06-13	Distance can create room for understanding.	2026-06-13 06:37:06.345153+00
4	38	2026-06-14	This journey is a return to your own beautiful self.	2026-06-14 05:10:12.559366+00
5	17	2026-06-14	Be gentle with your heart.	2026-06-14 08:21:45.22488+00
6	40	2026-06-14	You're making space for your own beautiful next chapter.	2026-06-14 08:38:14.834102+00
7	4	2026-06-14	Be gentle with yourself; your strength will guide you forward.	2026-06-14 08:49:46.15739+00
8	41	2026-06-14	Nurture your beautiful self through this tender time.	2026-06-14 11:56:05.68122+00
9	43	2026-06-14	Be kind to yourself through this tender time.	2026-06-14 15:06:55.057501+00
10	44	2026-06-14	Be gentle with your heart as you navigate this tender time.	2026-06-14 15:07:10.141367+00
11	44	2026-06-15	Take gentle care of your heart during this tender time.	2026-06-15 04:24:34.818246+00
13	17	2026-06-15	Take this day to nourish your own heart.	2026-06-15 04:28:34.21697+00
14	2	2026-06-15	A step back is sometimes a step forward.	2026-06-15 05:53:18.761023+00
15	38	2026-06-15	Take gentle care of your heart during this time.	2026-06-15 07:28:16.131948+00
16	47	2026-06-15	Be kind to your heart as you heal.	2026-06-15 08:19:20.203417+00
17	48	2026-06-15	**Be gentle with yourself; healing takes time and kindness.**	2026-06-15 08:19:22.171223+00
18	45	2026-06-15	Reflection paves the path to healing.	2026-06-15 12:29:09.498078+00
21	22	2026-06-15	Be gentle with your heart; brighter days are unfolding for you.	2026-06-15 13:50:04.799413+00
22	54	2026-06-15	Reflection paves the path to healing.	2026-06-15 14:13:35.073419+00
23	50	2026-06-15	A step back is sometimes a step forward.	2026-06-15 18:08:29.545396+00
25	58	2026-06-15	This time is a gift of self-discovery.	2026-06-15 19:43:54.258373+00
27	54	2026-06-16	Be gentle with yourself; this journey is a path to new beginnings.	2026-06-16 03:24:04.198889+00
28	50	2026-06-16	Allow yourself grace and time to heal.	2026-06-16 03:25:17.583159+00
29	60	2026-06-16	Take this day to nourish your own heart.	2026-06-16 04:14:43.264642+00
30	4	2026-06-16	Patience is the quietest form of love.	2026-06-16 05:10:33.039868+00
31	61	2026-06-16	Understanding blooms in stillness.	2026-06-16 05:12:40.526763+00
32	58	2026-06-16	Reflection paves the path to healing.	2026-06-16 05:54:22.353218+00
33	57	2026-06-16	Patience is the quietest form of love.	2026-06-16 05:54:28.304672+00
35	64	2026-06-16	True connection deepens even when apart.	2026-06-16 06:45:18.079582+00
38	66	2026-06-16	Allow yourself grace and space to heal.	2026-06-16 07:42:43.46933+00
40	67	2026-06-16	Understanding blooms in stillness.	2026-06-16 08:32:31.291529+00
42	17	2026-06-16	Reflection paves the path to healing.	2026-06-16 13:02:12.00345+00
43	70	2026-06-16	Be gentle with your heart; you are navigating this journey with incredible strength.	2026-06-16 14:06:52.857297+00
45	73	2026-06-16	This time is a gift of self-discovery.	2026-06-16 16:55:20.398075+00
46	74	2026-06-16	Reflection paves the path to healing.	2026-06-16 17:26:51.670256+00
47	50	2026-06-17	This space is creating room for your own beautiful growth.	2026-06-17 05:48:07.499246+00
\.


--
-- Data for Name: user_daily_insights; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_daily_insights (id, user_id, insight_date, text, created_at, is_viewed, viewed_at) FROM stdin;
1	17	2026-06-11	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-11 08:24:26.990319+00	f	\N
2	36	2026-06-12	Your recent moods reveal a consistent experience of peace, particularly when reflecting on a specific person. This indicates that this connection serves as a significant anchor for your emotional well-being, suggesting you find deep calm and stability in your thoughts of them.	2026-06-12 11:00:53.358056+00	f	\N
3	38	2026-06-12	Arjun, your 'Growing' mood, paired with the reflection 'thinking about you,' suggests that your personal evolution is often sparked by focusing on your partner. This highlights a powerful relational pattern where you find significant growth and insight by deeply engaging with your connection rather than solely through internal reflection.	2026-06-12 19:11:04.97828+00	f	\N
4	38	2026-06-13	Arjun, we've noticed an interesting interplay between your 'Growing' mood and the deep 'grief' you experience when separated from your partner. It appears that your current phase of personal growth is profoundly shaped by processing the emotional impact of your connection, particularly how their presence or absence significantly influences your sense of well-being.	2026-06-13 09:29:03.123887+00	t	2026-06-13 12:14:27.596074+00
5	38	2026-06-14	Arjun, your current experience of 'Longing' and 'grief' when reflecting on your partner's absence suggests a profound emotional intertwining. It seems their presence acts as a primary barometer for your daily emotional state, leading to a significant sense of loss and feeling 'low' when they are not near. Recognizing this strong connection could help you anticipate and navigate these emotional shifts.	2026-06-14 02:24:53.174351+00	t	2026-06-14 02:25:15.600938+00
6	41	2026-06-14	Bhanu, your 'Growing' mood, coupled with recalling 'sharing coffee' as your happiest memory with a 'neutral' emotion, reveals a profound appreciation for quiet intimacy and reflective joy. We observe you derive deep contentment from simple, shared presence, processing these moments thoughtfully rather than through overwhelming emotional peaks. This suggests you are on a path of understanding and cultivating happiness in its purest, most introspective forms.	2026-06-14 12:20:58.557821+00	t	2026-06-14 12:58:53.310325+00
7	43	2026-06-14	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-14 15:00:15.44047+00	t	2026-06-14 15:00:26.333199+00
8	44	2026-06-14	You describe a 'happiest memory' as 'neutral,' suggesting a subtle disconnect in recalling its warmth. Gently exploring the joy you *felt* sharing coffee could be insightful.	2026-06-14 15:14:24.462622+00	t	2026-06-14 15:14:43.590028+00
9	44	2026-06-15	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-15 04:27:17.252745+00	t	2026-06-15 04:27:37.123239+00
10	2	2026-06-15	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-15 05:57:04.409408+00	t	2026-06-15 05:57:15.03915+00
11	47	2026-06-15	You're experiencing longing, yet your reflection on happy memories was brief and neutral. Allowing yourself to savor those positive moments can deepen your connection.	2026-06-15 08:23:58.461753+00	t	2026-06-15 08:24:45.899243+00
12	17	2026-06-15	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-15 12:28:06.872542+00	t	2026-06-15 12:28:15.177771+00
14	54	2026-06-15	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-15 14:14:13.488503+00	t	2026-06-15 14:14:45.322509+00
15	55	2026-06-15	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-15 16:37:30.878637+00	t	2026-06-15 16:37:41.229922+00
16	50	2026-06-15	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-15 17:07:11.159838+00	t	2026-06-15 18:07:03.145911+00
17	58	2026-06-15	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-15 19:44:34.959048+00	t	2026-06-15 19:46:22.34958+00
18	50	2026-06-16	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-16 03:29:56.089218+00	t	2026-06-16 03:30:20.047359+00
19	60	2026-06-16	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-16 03:40:14.07391+00	t	2026-06-16 03:44:50.716491+00
20	58	2026-06-16	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-16 05:24:30.94697+00	t	2026-06-16 05:51:30.41412+00
23	4	2026-06-16	Your frequent 'Reflective' and 'Peaceful' moods suggest you often approach situations with thoughtful contemplation. This consistent inner calm is a valuable strength.	2026-06-16 14:18:29.694642+00	t	2026-06-16 14:18:52.569033+00
24	70	2026-06-16	You find profound joy in simple, shared moments, often experiencing them with calm peace rather than outward excitement. Embrace this quiet appreciation.	2026-06-16 14:19:43.781661+00	t	2026-06-16 14:19:53.818512+00
25	17	2026-06-16	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-16 15:41:09.016062+00	t	2026-06-16 15:43:12.996185+00
26	73	2026-06-16	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-16 16:54:48.661638+00	t	2026-06-16 16:54:55.144656+00
27	74	2026-06-16	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-16 17:27:13.950154+00	t	2026-06-16 17:40:18.95764+00
28	73	2026-06-17	You experience a consistent state of peacefulness, yet describe your happiest memory neutrally. Allowing yourself to fully feel the joy in these calm moments will deepen them.	2026-06-17 04:23:04.312211+00	t	2026-06-17 04:23:32.720727+00
29	50	2026-06-17	Your emotional awareness continues to grow as you process your feelings openly. Checking in with yourself daily builds resilience over time.	2026-06-17 05:49:52.188735+00	t	2026-06-17 05:50:13.894229+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, phone_number, country_code, is_active, created_at, user_name, relation_type, partner_name, relationship_date, dob, partner_id, is_partnered, gender, relationship_score, fcm_token, notifications_enabled, last_active_at, has_acknowledged_completion) FROM stdin;
49	7896541235	+91	t	2026-06-15 09:41:35.169556	\N	\N	\N	\N	\N	38	t	\N	0	\N	t	\N	f
5	1234567891	+91	t	2026-05-19 07:53:46.955764	jnana	partner	bhagya	2020-05-14	\N	4	t	female	0	\N	t	\N	f
53	7596561619	+91	t	2026-06-15 13:06:08.274335	\N	\N	\N	\N	\N	\N	f	\N	0	\N	t	\N	f
61	9494705199	+91	t	2026-06-16 05:11:58.168204	Bhagya	Partner	hi	2026-06-02	\N	\N	f	female	0	dykny5NDQViQjXCvCdBvcG:APA91bH-DRwc-s7a_sHwQn_eFWHlL9_CLTenZymlc3oEM_6EN5l7sQQL3dE5vu09OiaLtr4XFMLDQjyNNdFRHDnq2EE8lHoH3W6RIByjBRAHiRY2mSbIQfQ	t	2026-06-16 05:13:31.908178	f
57	9999988888	+91	t	2026-06-15 18:16:01.275382	jan	\N	\N	\N	2026-01-01	\N	f	string	198	eeMxXxn9SniyCXMDcKJMrD:APA91bFNsMfdT0RTMtU9CP6Aw2HAm3Oe0JAFVYcVxcOkdZEf_oYOLf9DnaXkNHftBDQYpJ2uVcK31JX1vZx0HZFiKA85vIdw4gBzzzYYF3WJ5Sv2JhUUAgM	t	2026-06-16 06:26:06.42998	f
46	6303727961	+91	t	2026-06-15 06:06:11.363838	Vamsi	friend	Vip	2021-12-21	\N	\N	f	male	0	fs9bmAl_QAykmPbSKhV8Sz:APA91bHmdjBTqn_7XQxq72Kp4cLraO0d3_OPcWaAB4s9k5VSpq0k05bACNjLcznwJ1sRorUa8NYUE4hDWvrrTa80IGDmkzZJLb1rfcInCINdPy7GPr80_ZE	t	2026-06-17 06:37:51.04691	f
37	7569561618	+91	t	2026-06-12 10:35:15.396149	\N	\N	\N	\N	\N	\N	f	\N	0	\N	t	\N	f
1	9652932349	+91	t	2026-05-19 05:48:12.87033	jnan tej	friends	\N	2019-02-02	2003-02-02	\N	f	male	0	\N	t	\N	f
44	9502954079	+91	t	2026-06-14 15:03:41.386064	Jnan	\N	\N	2026-06-08	\N	\N	t	female	266	c3TG2CwSQW6JaCuwijPqt1:APA91bGd35F1-84yy4f8wV8iUWBTSEKt8DLpZI1zaPcPsZ1ztVor4PYur6iTEJqnki7F5MWWHboCtAJ52RVW3qWw3Au2V9ykQGg1xAMdGw0G1F1jGKmcqok	t	2026-06-15 10:56:53.533406	f
60	9494705712	+91	t	2026-06-16 03:36:44.825598	Bhagya	Partner	pravallika.	2026-06-10	\N	\N	f	female	0	dykny5NDQViQjXCvCdBvcG:APA91bH-DRwc-s7a_sHwQn_eFWHlL9_CLTenZymlc3oEM_6EN5l7sQQL3dE5vu09OiaLtr4XFMLDQjyNNdFRHDnq2EE8lHoH3W6RIByjBRAHiRY2mSbIQfQ	t	2026-06-16 05:04:48.330036	f
55	7569516617	+91	t	2026-06-15 15:48:05.473072	Tej	partner	Pra	2019-06-03	\N	\N	f	male	0	cuPqqXlXQIKIdQSBLL6CE_:APA91bFaCM8VFL8NCIwIGklFUM0bTtQY6VmVkAh2ha3ARJuDeKxbDiHpS81-LCjo3inxV6fnzemmiKRV4JgFSbu-Gj4G_tAmPdvizFy1VUrORhMzeVnHIhs	t	2026-06-15 16:55:03.345239	f
45	9999999999	+91	t	2026-06-15 04:40:11.455329	lilli	\N	\N	\N	2026-01-01	\N	f	string	70	fB6E63uaTp6fj2PyfsNOAQ:APA91bHJmp_CUUm7VFSsR9hhOWcvgKyHpTa4qV8vvW0M7r_5jMuNDrRk6FeaLHhjF2PMRO7ei3O9IG0vTCTl4RB8IEUA8BajaB1TtrLuwYsqjN1kwFa-iME	t	2026-06-15 13:26:06.271295	f
3	1234567890	+91	t	2026-05-19 06:42:42.062365	lucy	\N	\N	\N	\N	\N	f	female	62	\N	t	\N	f
13	9998887777	+91	t	2026-05-22 07:05:37.100242	Priya	Married	Mihail	2023-06-01	1997-04-12	\N	f	female	0	\N	t	\N	f
14	9494705719 	+91	t	2026-05-23 11:12:25.001099	\N	\N	\N	\N	\N	\N	f	\N	0	\N	t	\N	f
15	9794731834	+91	t	2026-05-23 12:09:28.939948	\N	\N	\N	\N	\N	\N	f	\N	0	\N	t	\N	f
16	9494705499	+91	t	2026-06-04 06:15:08.491049	\N	\N	\N	\N	\N	\N	f	\N	0	\N	t	\N	f
25	5687932894	+91	t	2026-06-12 05:38:01.010398	hi	friend	hello	2026-06-12	\N	\N	f	male	0	\N	t	\N	f
43	9431316166	+91	t	2026-06-14 14:59:21.51166	Bhagya	Friend	pravallika	2026-06-08	\N	\N	f	female	229	e0eOUsrITQmoP9z3oNXf6C:APA91bFs0OXFfH3rjjzKZBZvgMCc9eYP3w75dQFbTGIJtalZxHXMYPtPGC71Nr8UCdvqAEc1YyZaydZ1mm1yvNbj9JAPOdvLAuGHDPN2Wa5CR8E3P8Os5QY	t	2026-06-14 15:24:28.481423	f
6	1234567892	+91	t	2026-05-19 07:58:37.1727	jnana illa	partner	bhagya	2020-05-14	\N	\N	f	female	0	\N	t	\N	f
2	9502954078	+91	t	2026-05-19 06:28:00.577903	Alex	Friend	lilli	2026-06-01	\N	\N	f	male	49	eAQAwrx2RQ6ukvXaomCiZU:APA91bGm6UW3t_shIKav8eYEXxgQKcdwkVHFZRMS1kE1s5c1SjLz81ROswHXvna1QIhZOyDYmY2lfWoqcikriaMtQ6vg5zltnt41LUwt3hEKIvRv1Ykcoz0	t	2026-06-15 09:27:49.314408	f
26	9502987456	+91	t	2026-06-12 05:45:16.307013	hello	\N	\N	\N	\N	\N	f	female	0	\N	t	\N	f
38	7569561619	+91	t	2026-06-12 17:37:13.579291	arjuu	\N	\N	\N	2026-06-12	49	t	male	477	\N	t	2026-06-15 09:49:27.723299	f
19	9494705718	+91	t	2026-06-08 14:55:15.438118	teja	couples	pravallika	2026-06-08	2026-06-08	\N	f	male	0	\N	t	\N	f
40	7416805947	+91	t	2026-06-14 06:03:50.83902	sneha	\N	\N	\N	2019-06-03	\N	f	female	218	\N	t	2026-06-15 10:58:26.118014	f
39	7569561615	+91	t	2026-06-13 19:19:04.14145	prava	\N	\N	\N	2019-06-03	\N	f	female	0	\N	t	\N	f
4	9494705719	+91	t	2026-05-19 06:56:14.056901	sofi	Partner	hi	2026-06-10	\N	70	t	female	21	eD8YdHkJTnOsm1ROSIHiOw:APA91bE0WxlrjvDhXWPouOjmzbPmxjPmQqFWaOL7JRHKsdsB-ywVGS-Y6e4H5PnXCOagBy02aFAcah14QLh0PYIaF5HkPa4UdFDAX_slVtaK5j--1pcxIvc	t	2026-06-16 17:20:15.48355	t
41	7569561612	+91	t	2026-06-14 11:35:48.372531	bhanu	partner	soma	2015-06-17	\N	\N	f	female	0	\N	t	2026-06-14 13:10:35.101901	f
42	7416805949	+91	t	2026-06-14 14:42:48.977711	alex	\N	\N	\N	2002-01-11	\N	f	male	0	\N	t	\N	f
48	7416805941	+91	t	2026-06-15 08:17:10.140507	Sri	\N	\N	\N	\N	\N	f	female	0	eAQAwrx2RQ6ukvXaomCiZU:APA91bGm6UW3t_shIKav8eYEXxgQKcdwkVHFZRMS1kE1s5c1SjLz81ROswHXvna1QIhZOyDYmY2lfWoqcikriaMtQ6vg5zltnt41LUwt3hEKIvRv1Ykcoz0	t	2026-06-15 08:23:51.850197	f
21	9502954077	+91	t	2026-06-08 16:03:16.356212	dt	\N	\N	\N	2026-02-02	\N	f	male	0	\N	t	\N	f
36	7569561616	+91	t	2026-06-12 10:33:20.204143	sofy	\N	\N	\N	\N	\N	f	female	41	\N	t	\N	f
23	9652932341	+91	t	2026-06-11 18:41:41.485321	\N	\N	\N	\N	\N	\N	f	\N	0	\N	t	\N	f
47	6300164646	+91	t	2026-06-15 08:13:27.365211	Bhagya	\N	\N	\N	\N	\N	f	female	31	eG09dVvZRVevrG_QMC2i2K:APA91bF1qvqbUD_dy-51iWkeb0w6HaPQzPp95aVBc5wAd0L3bhB1lfkFOrddSCCU7vjrvTRsULpZjFlXrF5ap68DV5lT3f63J9Ae9dY4VvD0n6T-6thJBhw	t	2026-06-15 09:37:38.324943	f
54	6666666666	+91	t	2026-06-15 14:06:00.719588	sofy	Partner	p	2026-06-02	\N	\N	f	female	116	eeMxXxn9SniyCXMDcKJMrD:APA91bFNsMfdT0RTMtU9CP6Aw2HAm3Oe0JAFVYcVxcOkdZEf_oYOLf9DnaXkNHftBDQYpJ2uVcK31JX1vZx0HZFiKA85vIdw4gBzzzYYF3WJ5Sv2JhUUAgM	t	2026-06-16 03:24:43.157942	f
59	7777777777	+91	t	2026-06-15 20:37:06.926592	Ss	partner	Pp	2026-06-11	\N	\N	f	male	0	eeMxXxn9SniyCXMDcKJMrD:APA91bFNsMfdT0RTMtU9CP6Aw2HAm3Oe0JAFVYcVxcOkdZEf_oYOLf9DnaXkNHftBDQYpJ2uVcK31JX1vZx0HZFiKA85vIdw4gBzzzYYF3WJ5Sv2JhUUAgM	t	2026-06-15 20:39:45.756377	f
17	7569561617	+91	t	2026-06-05 08:47:50.886414	pravallika illa	\N	\N	\N	2002-02-02	71	t	female	11	dYNfC6YBSaqiUJ8ZiTKTdr:APA91bFbecLaiIyNZcpZo8buUGwKyrNBDn6l1XRvUjywgiSROcyvh0q4-l1nBbX6mcuwRLZmZwTB-lQeDNmy2SjgH2m5dniPrFdRPtGuvzTEskRKzsrC1vs	t	2026-06-16 16:45:00.793693	t
22	8523010323	+91	t	2026-06-11 18:39:06.234471	sra	\N	\N	\N	\N	\N	f	female	0	\N	t	2026-06-15 14:05:21.181291	f
50	7416805948	+91	t	2026-06-15 10:58:50.798342	Sriiii	partner	Al	2026-06-15	\N	51	t	female	40	doGFvfwxSJa-ZhcYjE7xXI:APA91bGehNJ4q5KgU-PXa_UTufaKGBlnx9SsLza9S9-qSDLDJlDobI-3VVjwA_J0y4Z_EqgRFZbsKJM93DrWIINsXEu_tIFUyrPArBhHnaS9m4RREBF8nys	t	\N	f
62	9494705711	+91	t	2026-06-16 05:21:07.8328	Bhagya	partner	H	2026-06-10	\N	\N	f	male	0	dLt5Li2FQty7Ep4wSq8rvB:APA91bGdoepPxzh-bdJRpLgur7izWtBAwJumkkqzVeEmWIvFBHFi3Fwn0zyaua9pXEJ-RmAfDHs-6PSqAdFEXTWAwcVKr6OtXnFJ4TvRgvQitnTiR2End80	t	2026-06-16 06:40:24.278904	f
66	9494705761	+91	t	2026-06-16 07:10:40.680537	Bhagya	Partner	bhagya	2026-06-08	\N	\N	f	female	128	dLt5Li2FQty7Ep4wSq8rvB:APA91bGdoepPxzh-bdJRpLgur7izWtBAwJumkkqzVeEmWIvFBHFi3Fwn0zyaua9pXEJ-RmAfDHs-6PSqAdFEXTWAwcVKr6OtXnFJ4TvRgvQitnTiR2End80	t	2026-06-16 11:00:05.798431	f
51	8888888888	+91	t	2026-06-15 12:40:31.593919	jan	\N	\N	\N	2026-01-01	50	t	string	3	\N	t	\N	f
58	8888899999	+91	t	2026-06-15 19:40:49.189573	Hii	\N	\N	\N	\N	\N	f	female	0	dbyw5ZmnS1WOoELCXIqJsw:APA91bFBV0V8dWe0ia5krFWeDwzPjmA08zh4GfLIc4Jkr6DzKXTtakvNhSWLYoHca3j2aQvR9HTD-1EHRmH-kTLRdA5wqgb2olqdDPPVdTaM5bRpyJrNvpk	t	2026-06-16 12:30:39.36614	t
71	6318164664	+91	t	2026-06-16 15:50:13.26527	Bhagya	partner	Pravallika	2026-06-09	\N	17	t	female	0	eV4K1JmvSrG2OoMLN5T0bp:APA91bEJdUgg4A0UBaf3E-67tQu5UayepxI0zhcy0IsflJGfmo7I3RKBIZESpH3pFmSvJev4fnPMpjyDJYmQrDnMJwtROJ1GM2HmV3BxwADFmyKRuCTDjFA	t	2026-06-16 17:14:57.405049	f
70	9999666666	+91	t	2026-06-16 14:06:16.673713	Jnana	partner	Bhagya	2026-06-01	\N	4	t	female	21	fdWsVwBnSZGwLVliTK6OYb:APA91bF5IxVQx8JiAdHCHxxpVQmuFgcE_jCPINNTOkEt8CXEjWQ8TC2NNlOD3vOblVZ5AOeJmyRENvqB17Ed7ryYyZ7ZqmFdapCGNvyJL78QUeOg573svTk	t	2026-06-16 15:18:20.801044	f
68	77777777777	+91	t	2026-06-16 09:26:20.387498	JJJ	\N	\N	\N	2022-02-11	\N	f	string	0	\N	t	\N	f
64	6301231616	+91	t	2026-06-16 06:40:46.73208	Bhagyaa	Partner	hii	2026-06-10	\N	\N	f	female	125	dLt5Li2FQty7Ep4wSq8rvB:APA91bGdoepPxzh-bdJRpLgur7izWtBAwJumkkqzVeEmWIvFBHFi3Fwn0zyaua9pXEJ-RmAfDHs-6PSqAdFEXTWAwcVKr6OtXnFJ4TvRgvQitnTiR2End80	t	2026-06-16 06:51:35.100598	t
67	5555555555	+91	t	2026-06-16 08:27:51.546522	Pp	\N	\N	\N	\N	\N	f	male	0	cnUjBybdReuKo60NjWwmHO:APA91bGxB9-MAOssKD3QrDUfOe4JmI0d3X17sXTEJpigs3tOkDFpcfwPqfqRQLbCRq0TlCXWJ4lpIHud9YcEyn2WHlN_e7pdLvrMa7hqJsXhcdAgY_3M9uM	t	2026-06-16 08:41:38.538505	f
73	7777777774	+91	t	2026-06-16 16:53:51.919571	Pp	\N	\N	\N	\N	\N	f	female	0	fMx4inxtSrm6TL2YK4OvL4:APA91bGY7bcbchRPFbMDNadUfe4kghz0ok-HsXo_x01aft8R6nSKa3sz8VYH_qa77FVehOK4CwNttkxXWpMiKhEvDnQAQElR00dCD39N4ShYyy99oSHy-g0	t	\N	t
72	77777777776	+91	t	2026-06-16 16:48:15.735812	s	\N	\N	\N	2012-09-09	\N	f	string	0	\N	t	\N	f
75	9494701313	+91	t	2026-06-17 05:13:49.663211	Bhagya	partner	Pravallika	2026-06-08	\N	\N	f	female	0	cDJgUiUnT_qt_Pflo9ReDA:APA91bGVMsRcKxUSfgcSCQRvfPD_SNVFX-wZcjsPHlVYMHibxQLv0JS03b_CwQ551pc3LCbajP8viyZ5OWk94TCmLqhq2gEN85k7rO_e56QmhRa5eVjfeK0	t	\N	f
74	6310155144	+91	t	2026-06-16 17:20:44.690251	Bhagya	\N	\N	\N	\N	\N	f	female	0	eD8YdHkJTnOsm1ROSIHiOw:APA91bE0WxlrjvDhXWPouOjmzbPmxjPmQqFWaOL7JRHKsdsB-ywVGS-Y6e4H5PnXCOagBy02aFAcah14QLh0PYIaF5HkPa4UdFDAX_slVtaK5j--1pcxIvc	t	\N	f
\.


--
-- Name: invite_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invite_codes_id_seq', 424, true);


--
-- Name: letters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.letters_id_seq', 30, true);


--
-- Name: moods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.moods_id_seq', 248, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 345, true);


--
-- Name: question_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.question_categories_id_seq', 1, false);


--
-- Name: reflection_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reflection_answers_id_seq', 51, true);


--
-- Name: reflection_comparisons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reflection_comparisons_id_seq', 1, true);


--
-- Name: reflection_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reflection_questions_id_seq', 55, true);


--
-- Name: reflection_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reflection_sessions_id_seq', 604, true);


--
-- Name: relationships_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.relationships_id_seq', 54, true);


--
-- Name: separations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.separations_id_seq', 82, true);


--
-- Name: user_daily_affirmations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_daily_affirmations_id_seq', 63, true);


--
-- Name: user_daily_comforts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_daily_comforts_id_seq', 47, true);


--
-- Name: user_daily_insights_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_daily_insights_id_seq', 29, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 75, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: apscheduler_jobs apscheduler_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apscheduler_jobs
    ADD CONSTRAINT apscheduler_jobs_pkey PRIMARY KEY (id);


--
-- Name: invite_codes invite_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invite_codes
    ADD CONSTRAINT invite_codes_pkey PRIMARY KEY (id);


--
-- Name: letters letters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letters
    ADD CONSTRAINT letters_pkey PRIMARY KEY (id);


--
-- Name: moods moods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moods
    ADD CONSTRAINT moods_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: question_categories question_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_categories
    ADD CONSTRAINT question_categories_pkey PRIMARY KEY (id);


--
-- Name: reflection_answers reflection_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_answers
    ADD CONSTRAINT reflection_answers_pkey PRIMARY KEY (id);


--
-- Name: reflection_comparisons reflection_comparisons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_comparisons
    ADD CONSTRAINT reflection_comparisons_pkey PRIMARY KEY (id);


--
-- Name: reflection_questions reflection_questions_day_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_questions
    ADD CONSTRAINT reflection_questions_day_number_key UNIQUE (day_number);


--
-- Name: reflection_questions reflection_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_questions
    ADD CONSTRAINT reflection_questions_pkey PRIMARY KEY (id);


--
-- Name: reflection_sessions reflection_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_sessions
    ADD CONSTRAINT reflection_sessions_pkey PRIMARY KEY (id);


--
-- Name: relationships relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT relationships_pkey PRIMARY KEY (id);


--
-- Name: separations separations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.separations
    ADD CONSTRAINT separations_pkey PRIMARY KEY (id);


--
-- Name: reflection_comparisons uq_sep_day; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_comparisons
    ADD CONSTRAINT uq_sep_day UNIQUE (separation_id, day_number);


--
-- Name: user_daily_affirmations uq_user_daily_affirmation; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_affirmations
    ADD CONSTRAINT uq_user_daily_affirmation UNIQUE (user_id, affirmation_date);


--
-- Name: user_daily_comforts uq_user_daily_comfort; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_comforts
    ADD CONSTRAINT uq_user_daily_comfort UNIQUE (user_id, comfort_date);


--
-- Name: user_daily_insights uq_user_daily_insight; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_insights
    ADD CONSTRAINT uq_user_daily_insight UNIQUE (user_id, insight_date);


--
-- Name: reflection_sessions uq_user_day_sep; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_sessions
    ADD CONSTRAINT uq_user_day_sep UNIQUE (user_id, day_number, separation_id);


--
-- Name: user_daily_affirmations user_daily_affirmations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_affirmations
    ADD CONSTRAINT user_daily_affirmations_pkey PRIMARY KEY (id);


--
-- Name: user_daily_comforts user_daily_comforts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_comforts
    ADD CONSTRAINT user_daily_comforts_pkey PRIMARY KEY (id);


--
-- Name: user_daily_insights user_daily_insights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_insights
    ADD CONSTRAINT user_daily_insights_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_apscheduler_jobs_next_run_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_apscheduler_jobs_next_run_time ON public.apscheduler_jobs USING btree (next_run_time);


--
-- Name: ix_invite_codes_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_invite_codes_code ON public.invite_codes USING btree (code);


--
-- Name: ix_invite_codes_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_invite_codes_id ON public.invite_codes USING btree (id);


--
-- Name: ix_letters_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_letters_id ON public.letters USING btree (id);


--
-- Name: ix_moods_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_moods_id ON public.moods USING btree (id);


--
-- Name: ix_moods_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_moods_user_id ON public.moods USING btree (user_id);


--
-- Name: ix_notifications_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_id ON public.notifications USING btree (id);


--
-- Name: ix_question_categories_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_question_categories_id ON public.question_categories USING btree (id);


--
-- Name: ix_reflection_answers_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reflection_answers_id ON public.reflection_answers USING btree (id);


--
-- Name: ix_reflection_comparisons_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reflection_comparisons_id ON public.reflection_comparisons USING btree (id);


--
-- Name: ix_reflection_questions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reflection_questions_id ON public.reflection_questions USING btree (id);


--
-- Name: ix_reflection_sessions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reflection_sessions_id ON public.reflection_sessions USING btree (id);


--
-- Name: ix_reflection_sessions_separation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reflection_sessions_separation_id ON public.reflection_sessions USING btree (separation_id);


--
-- Name: ix_reflection_sessions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reflection_sessions_user_id ON public.reflection_sessions USING btree (user_id);


--
-- Name: ix_relationships_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_relationships_id ON public.relationships USING btree (id);


--
-- Name: ix_separations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_separations_id ON public.separations USING btree (id);


--
-- Name: ix_user_daily_affirmations_affirmation_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_affirmations_affirmation_date ON public.user_daily_affirmations USING btree (affirmation_date);


--
-- Name: ix_user_daily_affirmations_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_affirmations_id ON public.user_daily_affirmations USING btree (id);


--
-- Name: ix_user_daily_affirmations_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_affirmations_user_id ON public.user_daily_affirmations USING btree (user_id);


--
-- Name: ix_user_daily_comforts_comfort_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_comforts_comfort_date ON public.user_daily_comforts USING btree (comfort_date);


--
-- Name: ix_user_daily_comforts_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_comforts_id ON public.user_daily_comforts USING btree (id);


--
-- Name: ix_user_daily_comforts_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_comforts_user_id ON public.user_daily_comforts USING btree (user_id);


--
-- Name: ix_user_daily_insights_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_insights_id ON public.user_daily_insights USING btree (id);


--
-- Name: ix_user_daily_insights_insight_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_insights_insight_date ON public.user_daily_insights USING btree (insight_date);


--
-- Name: ix_user_daily_insights_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_daily_insights_user_id ON public.user_daily_insights USING btree (user_id);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_phone_number ON public.users USING btree (phone_number);


--
-- Name: invite_codes invite_codes_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invite_codes
    ADD CONSTRAINT invite_codes_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: letters letters_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letters
    ADD CONSTRAINT letters_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: letters letters_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letters
    ADD CONSTRAINT letters_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: letters letters_relationship_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.letters
    ADD CONSTRAINT letters_relationship_id_fkey FOREIGN KEY (relationship_id) REFERENCES public.relationships(id) ON DELETE CASCADE;


--
-- Name: moods moods_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moods
    ADD CONSTRAINT moods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reflection_answers reflection_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_answers
    ADD CONSTRAINT reflection_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.reflection_questions(id);


--
-- Name: reflection_answers reflection_answers_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_answers
    ADD CONSTRAINT reflection_answers_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.reflection_sessions(id) ON DELETE CASCADE;


--
-- Name: reflection_answers reflection_answers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_answers
    ADD CONSTRAINT reflection_answers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: reflection_comparisons reflection_comparisons_separation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_comparisons
    ADD CONSTRAINT reflection_comparisons_separation_id_fkey FOREIGN KEY (separation_id) REFERENCES public.separations(id);


--
-- Name: reflection_comparisons reflection_comparisons_user_a_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_comparisons
    ADD CONSTRAINT reflection_comparisons_user_a_session_id_fkey FOREIGN KEY (user_a_session_id) REFERENCES public.reflection_sessions(id);


--
-- Name: reflection_comparisons reflection_comparisons_user_b_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_comparisons
    ADD CONSTRAINT reflection_comparisons_user_b_session_id_fkey FOREIGN KEY (user_b_session_id) REFERENCES public.reflection_sessions(id);


--
-- Name: reflection_questions reflection_questions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_questions
    ADD CONSTRAINT reflection_questions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.question_categories(id);


--
-- Name: reflection_sessions reflection_sessions_separation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_sessions
    ADD CONSTRAINT reflection_sessions_separation_id_fkey FOREIGN KEY (separation_id) REFERENCES public.separations(id) ON DELETE SET NULL;


--
-- Name: reflection_sessions reflection_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reflection_sessions
    ADD CONSTRAINT reflection_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: relationships relationships_user1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT relationships_user1_id_fkey FOREIGN KEY (user1_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: relationships relationships_user2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relationships
    ADD CONSTRAINT relationships_user2_id_fkey FOREIGN KEY (user2_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: separations separations_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.separations
    ADD CONSTRAINT separations_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: separations separations_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.separations
    ADD CONSTRAINT separations_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: separations separations_relationship_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.separations
    ADD CONSTRAINT separations_relationship_id_fkey FOREIGN KEY (relationship_id) REFERENCES public.relationships(id) ON DELETE CASCADE;


--
-- Name: user_daily_affirmations user_daily_affirmations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_affirmations
    ADD CONSTRAINT user_daily_affirmations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_daily_comforts user_daily_comforts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_comforts
    ADD CONSTRAINT user_daily_comforts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_daily_insights user_daily_insights_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_daily_insights
    ADD CONSTRAINT user_daily_insights_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 1gWFZdEpKC1Z14nKPnH15sUm4zhdnoPN9TPjN7o0A9wSs3B2CerVbVzp8q2XF8Q

