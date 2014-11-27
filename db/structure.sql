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


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_keys (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    key character varying(64) NOT NULL,
    user_id uuid,
    created_by_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apps (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    owner_id uuid,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: ssh_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ssh_keys (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid,
    key text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    fingerprint character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    email character varying(255) NOT NULL,
    password_hash character varying(64),
    salt character varying(32),
    auth_token character varying(32),
    admin boolean DEFAULT false NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: ssh_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ssh_keys
    ADD CONSTRAINT ssh_keys_pkey PRIMARY KEY (id);


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
-- Name: index_apps_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apps_on_name ON apps USING btree (name);


--
-- Name: index_ssh_keys_on_fingerprint; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ssh_keys_on_fingerprint ON ssh_keys USING btree (fingerprint);


--
-- Name: index_ssh_keys_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ssh_keys_on_key ON ssh_keys USING btree (key);


--
-- Name: index_users_on_auth_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_auth_token ON users USING btree (auth_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('20140807103256');

INSERT INTO schema_migrations (version) VALUES ('20140807104650');

INSERT INTO schema_migrations (version) VALUES ('20140911094402');

INSERT INTO schema_migrations (version) VALUES ('20140911102130');

INSERT INTO schema_migrations (version) VALUES ('20141126134134');

