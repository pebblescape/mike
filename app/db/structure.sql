--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_keys (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    user_id integer,
    created_by_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_keys_id_seq OWNED BY api_keys.id;


--
-- Name: google_user_infos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE google_user_infos (
    id integer NOT NULL,
    user_id integer NOT NULL,
    google_user_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: google_user_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE google_user_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: google_user_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE google_user_infos_id_seq OWNED BY google_user_infos.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: site_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE site_settings (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    data_type integer NOT NULL,
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: site_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE site_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE site_settings_id_seq OWNED BY site_settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    username_lower character varying(255) NOT NULL,
    name character varying(255),
    email character varying(255),
    password_hash character varying(255),
    salt character varying(255),
    auth_token character varying(255),
    admin boolean DEFAULT false NOT NULL,
    last_seen_at timestamp without time zone,
    previous_visit_at timestamp without time zone,
    ip_address inet,
    locale character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys ALTER COLUMN id SET DEFAULT nextval('api_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY google_user_infos ALTER COLUMN id SET DEFAULT nextval('google_user_infos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY site_settings ALTER COLUMN id SET DEFAULT nextval('site_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: google_user_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY google_user_infos
    ADD CONSTRAINT google_user_infos_pkey PRIMARY KEY (id);


--
-- Name: site_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY site_settings
    ADD CONSTRAINT site_settings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_api_keys_on_key ON api_keys USING btree (key);


--
-- Name: index_api_keys_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_api_keys_on_user_id ON api_keys USING btree (user_id);


--
-- Name: index_google_user_infos_on_google_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_google_user_infos_on_google_user_id ON google_user_infos USING btree (google_user_id);


--
-- Name: index_google_user_infos_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_google_user_infos_on_user_id ON google_user_infos USING btree (user_id);


--
-- Name: index_users_on_auth_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_auth_token ON users USING btree (auth_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_users_on_username_lower; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username_lower ON users USING btree (username_lower);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140424120944');

INSERT INTO schema_migrations (version) VALUES ('20140424121601');

INSERT INTO schema_migrations (version) VALUES ('20140424125010');

INSERT INTO schema_migrations (version) VALUES ('20140426142927');

