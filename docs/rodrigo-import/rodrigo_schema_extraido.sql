-- Extraído de lemonlog_260715.backup (pg_dump custom 1.16)
-- Extração fiel via length-prefixed strings

SET client_encoding = 'UTF8';

SET standard_conforming_strings = 'on';

SELECT pg_catalog.set_config('search_path', '', false);

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = icu LOCALE = 'en_US.UTF-8' ICU_LOCALE = 'en-US';

DROP DATABASE postgres;

COMMENT;

COMMENT ON DATABASE postgres IS 'default administrative connection database';

GRANT CREATE ON DATABASE postgres TO supabase_etl_admin;
GRANT CREATE ON DATABASE postgres TO supabase_storage_admin;
GRANT ALL ON DATABASE postgres TO dashboard_user;
GRANT CONNECT ON DATABASE postgres TO sandbox_exec;

ALTER DATABASE postgres SET "app.settings.jwt_exp" TO '3600';
ALTER DATABASE postgres SET idle_in_transaction_session_timeout TO '15min';

CREATE SCHEMA auth;

DROP SCHEMA auth;

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;

DROP EXTENSION pg_cron;

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';

GRANT USAGE ON SCHEMA cron TO postgres WITH GRANT OPTION;

CREATE SCHEMA extensions;

DROP SCHEMA extensions;

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;
GRANT USAGE ON SCHEMA extensions TO sandbox_exec;

CREATE SCHEMA graphql;

DROP SCHEMA graphql;

CREATE SCHEMA graphql_public;

DROP SCHEMA graphql_public;

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;
GRANT USAGE ON SCHEMA public TO sandbox_exec;

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA public;

DROP EXTENSION pg_net;

COMMENT ON EXTENSION pg_net IS 'Async HTTP';

GRANT USAGE ON SCHEMA net TO supabase_functions_admin;
GRANT USAGE ON SCHEMA net TO postgres;
GRANT USAGE ON SCHEMA net TO anon;
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;

CREATE SCHEMA pgbouncer;

DROP SCHEMA pgbouncer;

CREATE SCHEMA realtime;

DROP SCHEMA realtime;

GRANT USAGE ON SCHEMA realtime TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;

CREATE SCHEMA storage;

DROP SCHEMA storage;

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA storage TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT USAGE ON SCHEMA storage TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE SCHEMA supabase_migrations;

DROP SCHEMA supabase_migrations;

CREATE SCHEMA vault;

DROP SCHEMA vault;

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;

DROP EXTENSION pg_stat_statements;

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

DROP EXTENSION pg_trgm;

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

DROP EXTENSION pgcrypto;

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;

DROP EXTENSION supabase_vault;

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;

DROP EXTENSION "uuid-ossp";

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);

DROP TYPE auth.aal_level;

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);

DROP TYPE auth.code_challenge_method;

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);

DROP TYPE auth.factor_status;

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);

DROP TYPE auth.factor_type;

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);

DROP TYPE auth.oauth_authorization_status;

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);

DROP TYPE auth.oauth_client_type;

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);

DROP TYPE auth.oauth_registration_type;

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);

DROP TYPE auth.oauth_response_type;

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);

DROP TYPE auth.one_time_token_type;

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'user',
    'produtor',
    'estoque_user'
);

DROP TYPE public.app_role;

CREATE TYPE public.coproducao_frete_destino AS ENUM (
    'empresa_principal',
    'dividir_proporcional',
    'ignorar'
);

DROP TYPE public.coproducao_frete_destino;

CREATE TYPE public.coproducao_modo_operacao AS ENUM (
    'controle_interno',
    'split_real_api',
    'hibrido'
);

DROP TYPE public.coproducao_modo_operacao;

CREATE TYPE public.coproducao_origem AS ENUM (
    'yampi',
    'appmax',
    'manual'
);

DROP TYPE public.coproducao_origem;

CREATE TYPE public.coproducao_status_coprodutor AS ENUM (
    'ativo',
    'inativo'
);

DROP TYPE public.coproducao_status_coprodutor;

CREATE TYPE public.coproducao_status_repasse AS ENUM (
    'pendente',
    'aprovado',
    'pago',
    'cancelado',
    'estornado',
    'chargeback',
    'sem_coprodutor'
);

DROP TYPE public.coproducao_status_repasse;

CREATE TYPE public.coproducao_status_repasse_lote AS ENUM (
    'aberto',
    'conferido',
    'aprovado',
    'pago',
    'cancelado'
);

DROP TYPE public.coproducao_status_repasse_lote;

CREATE TYPE public.coproducao_tipo_base AS ENUM (
    'produtos_sem_frete',
    'produtos_sem_frete_sem_desconto',
    'valor_liquido_produtos'
);

DROP TYPE public.coproducao_tipo_base;

CREATE TYPE public.coproducao_tipo_pessoa AS ENUM (
    'pessoa_fisica',
    'pessoa_juridica'
);

DROP TYPE public.coproducao_tipo_pessoa;

GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO service_role;

CREATE TYPE public.status_logistico_enum AS ENUM (
    'pre_postado',
    'postado',
    'em_transito',
    'saiu_para_entrega',
    'entregue',
    'atraso',
    'problema_na_entrega',
    'devolucao',
    'cancelado',
    'erro'
);

DROP TYPE public.status_logistico_enum;

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);

DROP TYPE realtime.action;

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in',
    'like',
    'ilike',
    'is',
    'match',
    'imatch',
    'isdistinct'
);

DROP TYPE realtime.equality_op;

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text,
	negate boolean
);

DROP TYPE realtime.user_defined_filter;

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);

DROP TYPE realtime.wal_column;

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);

DROP TYPE realtime.wal_rls;

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);

DROP TYPE storage.buckettype;

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;

DROP FUNCTION auth.email();

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;

DROP FUNCTION auth.jwt();

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;

DROP FUNCTION auth.role();

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;

DROP FUNCTION auth.uid();

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;

GRANT ALL ON FUNCTION cron.alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;

GRANT ALL ON FUNCTION cron.job_cache_invalidate() TO postgres WITH GRANT OPTION;

GRANT ALL ON FUNCTION cron.schedule(schedule text, command text) TO postgres WITH GRANT OPTION;

GRANT ALL ON FUNCTION cron.schedule(job_name text, schedule text, command text) TO postgres WITH GRANT OPTION;

GRANT ALL ON FUNCTION cron.schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;

GRANT ALL ON FUNCTION cron.unschedule(job_id bigint) TO postgres WITH GRANT OPTION;

GRANT ALL ON FUNCTION cron.unschedule(job_name text) TO postgres WITH GRANT OPTION;

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO sandbox_exec;

grant_pg_cron_access();

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;

DROP FUNCTION extensions.grant_pg_cron_access();

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;

grant_pg_graphql_access();

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
begin
    if not exists (
        select 1
        from pg_event_trigger_ddl_commands() ev
        join pg_catalog.pg_extension e on ev.objid = e.oid
        where e.extname = 'pg_graphql'
    ) then
        return;
    end if;

    drop function if exists graphql_public.graphql;
    create or replace function graphql_public.graphql(
        "operationName" text default null,
        query text default null,
        variables jsonb default null,
        extensions jsonb default null
    )
        returns jsonb
        language sql
    as $$
        select graphql.resolve(
            query := query,
            variables := coalesce(variables, '{}'),
            "operationName" := "operationName",
            extensions := extensions
        );
    $$;

    -- Attach the wrapper to the extension so DROP EXTENSION cascades to it,
    -- which in turn triggers set_graphql_placeholder to reinstall the "not enabled" stub.
    alter extension pg_graphql add function graphql_public.graphql(text, text, jsonb, jsonb);

    grant usage on schema graphql to postgres, anon, authenticated, service_role;
    grant execute on function graphql.resolve to postgres, anon, authenticated, service_role;
    grant usage on schema graphql to postgres with grant option;
    grant usage on schema graphql_public to postgres with grant option;
end;
$_$;

DROP FUNCTION extensions.grant_pg_graphql_access();

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO sandbox_exec;
RESET SESSION AUTHORIZATION;

grant_pg_net_access();

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;

DROP FUNCTION extensions.grant_pg_net_access();

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO sandbox_exec;

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;

DROP FUNCTION extensions.pgrst_ddl_watch();

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;

DROP FUNCTION extensions.pgrst_drop_watch();

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO sandbox_exec;
RESET SESSION AUTHORIZATION;

set_graphql_placeholder();

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;

DROP FUNCTION extensions.set_graphql_placeholder();

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO sandbox_exec;
RESET SESSION AUTHORIZATION;

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO sandbox_exec;

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO sandbox_exec;

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;

DROP FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb);

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;

GRANT ALL ON FUNCTION pg_catalog.pg_reload_conf() TO postgres WITH GRANT OPTION;

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;

DROP FUNCTION pgbouncer.get_auth(p_usename text);

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;

CREATE FUNCTION public.contagem_pedidos_logistica() RETURNS TABLE(status_logistico text, total bigint)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT COALESCE(p.status_logistico::text, 'sem_status') as status_logistico, COUNT(*)::bigint as total
  FROM public.pedidos p
  WHERE p.produtor_id = public.current_produtor_id()
     OR public.has_role(auth.uid(), 'admin'::public.app_role)
  GROUP BY p.status_logistico
$$;

DROP FUNCTION public.contagem_pedidos_logistica();

GRANT ALL ON FUNCTION public.contagem_pedidos_logistica() TO anon;
GRANT ALL ON FUNCTION public.contagem_pedidos_logistica() TO authenticated;
GRANT ALL ON FUNCTION public.contagem_pedidos_logistica() TO service_role;
GRANT ALL ON FUNCTION public.contagem_pedidos_logistica() TO sandbox_exec;

CREATE FUNCTION public.current_produtor_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT produtor_id FROM public.produtor_usuarios WHERE user_id = auth.uid() LIMIT 1
$$;

DROP FUNCTION public.current_produtor_id();

GRANT ALL ON FUNCTION public.current_produtor_id() TO anon;
GRANT ALL ON FUNCTION public.current_produtor_id() TO authenticated;
GRANT ALL ON FUNCTION public.current_produtor_id() TO service_role;
GRANT ALL ON FUNCTION public.current_produtor_id() TO sandbox_exec;

GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO service_role;

GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO service_role;

GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO service_role;

GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO service_role;

GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO service_role;

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  INSERT INTO public.profiles (user_id, nome)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'nome', NEW.email));
  RETURN NEW;
END;
$$;

DROP FUNCTION public.handle_new_user();

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;
GRANT ALL ON FUNCTION public.handle_new_user() TO sandbox_exec;

CREATE FUNCTION public.has_role(_user_id uuid, _role public.app_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

DROP FUNCTION public.has_role(_user_id uuid, _role public.app_role);

GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO anon;
GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO authenticated;
GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO service_role;
GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO sandbox_exec;

CREATE FUNCTION public.limpar_pedidos_logistica(p_admin boolean, p_produtor_id uuid) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  deletados bigint;
BEGIN
  IF p_admin THEN
    DELETE FROM public.tracking_events;
    DELETE FROM public.pedidos;
    GET DIAGNOSTICS deletados = ROW_COUNT;
  ELSE
    IF p_produtor_id IS NULL THEN
      RAISE EXCEPTION 'produtor_id é obrigatório';
    END IF;
    DELETE FROM public.tracking_events WHERE produtor_id = p_produtor_id;
    DELETE FROM public.pedidos WHERE produtor_id = p_produtor_id;
    GET DIAGNOSTICS deletados = ROW_COUNT;
  END IF;
  RETURN deletados;
END;
$$;

DROP FUNCTION public.limpar_pedidos_logistica(p_admin boolean, p_produtor_id uuid);

REVOKE ALL ON FUNCTION public.limpar_pedidos_logistica(p_admin boolean, p_produtor_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.limpar_pedidos_logistica(p_admin boolean, p_produtor_id uuid) TO anon;
GRANT ALL ON FUNCTION public.limpar_pedidos_logistica(p_admin boolean, p_produtor_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.limpar_pedidos_logistica(p_admin boolean, p_produtor_id uuid) TO service_role;
GRANT ALL ON FUNCTION public.limpar_pedidos_logistica(p_admin boolean, p_produtor_id uuid) TO sandbox_exec;

GRANT ALL ON FUNCTION public.set_limit(real) TO postgres;
GRANT ALL ON FUNCTION public.set_limit(real) TO anon;
GRANT ALL ON FUNCTION public.set_limit(real) TO authenticated;
GRANT ALL ON FUNCTION public.set_limit(real) TO service_role;

GRANT ALL ON FUNCTION public.show_limit() TO postgres;
GRANT ALL ON FUNCTION public.show_limit() TO anon;
GRANT ALL ON FUNCTION public.show_limit() TO authenticated;
GRANT ALL ON FUNCTION public.show_limit() TO service_role;

GRANT ALL ON FUNCTION public.show_trgm(text) TO postgres;
GRANT ALL ON FUNCTION public.show_trgm(text) TO anon;
GRANT ALL ON FUNCTION public.show_trgm(text) TO authenticated;
GRANT ALL ON FUNCTION public.show_trgm(text) TO service_role;

GRANT ALL ON FUNCTION public.similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity(text, text) TO service_role;

GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO service_role;

GRANT ALL ON FUNCTION public.similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO service_role;

GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO service_role;

GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO service_role;

GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO service_role;

GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO service_role;

GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO service_role;

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP FUNCTION public.update_updated_at_column();

GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO sandbox_exec;

GRANT ALL ON FUNCTION public.word_similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO service_role;

GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO service_role;

GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO service_role;

GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO service_role;

GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO service_role;

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    -- Reset the role on every FOR..LOOP batch execution.
                    -- The first batch of 10 rows is pre-fetched using the current connection role (PG internal behaviour)
                    -- then we have to reset it again otherwise it would use the role defined in the `set_config` above
                    -- to fetch the remaining rows when rows>10, which could be a user-defined role that lacks execution grants.
                    -- The flow is:
                    --   1. run batch with conn role
                    --   2. set_config working_role
                    --   3. execute walrus
                    --   4. reset role (revert)
                    --   5. repeat
                    perform set_config('role', null, true);

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;

DROP FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer);

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;

DROP FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text);

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;

DROP FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]);

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;

DROP FUNCTION realtime."cast"(val text, type_ regtype);

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
/*
Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
*/
declare
    op_symbol text = (
        case
            when op = 'eq' then '='
            when op = 'neq' then '!='
            when op = 'lt' then '<'
            when op = 'lte' then '<='
            when op = 'gt' then '>'
            when op = 'gte' then '>='
            when op = 'in' then '= any'
            else 'UNKNOWN OP'
        end
    );
    res boolean;
begin
    execute format(
        'select %L::'|| type_::text || ' ' || op_symbol
        || ' ( %L::'
        || (
            case
                when op = 'in' then type_::text || '[]'
                else type_::text end
        )
        || ')', val_1, val_2) into res;
    return res;
end;
$$;

DROP FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text);

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
declare
    op_symbol text;
    res boolean;
begin
    -- IS DISTINCT FROM / IS NOT DISTINCT FROM: infix, both sides typed literals
    if op = 'isdistinct' then
        execute format(
            'select %L::%s %s %L::%s',
            val_1,
            type_::text,
            case when negate then 'IS NOT DISTINCT FROM' else 'IS DISTINCT FROM' end,
            val_2,
            type_::text
        ) into res;
        return res;
    end if;

    -- IS requires a keyword RHS (NULL, TRUE, FALSE, UNKNOWN), not a typed literal
    if op = 'is' then
        if val_2 not in ('null', 'true', 'false', 'unknown') then
            raise exception 'invalid value for is filter: must be null, true, false, or unknown';
        end if;
        execute format(
            'select %L::%s %s %s',
            val_1,
            type_::text,
            case when negate then 'IS NOT' else 'IS' end,
            upper(val_2)
        ) into res;
        return res;
    end if;

    op_symbol = case
        when op = 'eq'    then '='
        when op = 'neq'   then '!='
        when op = 'lt'    then '<'
        when op = 'lte'   then '<='
        when op = 'gt'    then '>'
        when op = 'gte'   then '>='
        when op = 'in'    then '= any'
        when op = 'like'   then 'LIKE'
        when op = 'ilike'  then 'ILIKE'
        when op = 'match'  then '~'
        when op = 'imatch' then '~*'
        else null
    end;

    if op_symbol is null then
        raise exception 'unsupported equality operator: %', op::text;
    end if;

    execute format(
        'select %L::%s %s (%L::%s)',
        val_1,
        type_::text,
        op_symbol,
        val_2,
        case when op = 'in' then type_::text || '[]' else type_::text end
    ) into res;

    return case when negate then not res else res end;
end;
$$;

DROP FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean);

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) TO service_role;

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select
        filters is null
        or array_length(filters, 1) is null
        or coalesce(
            count(col.name) = count(1)
            and sum(
                realtime.check_equality_op(
                    op:=f.op,
                    type_:=coalesce(col.type_oid::regtype, col.type_name::regtype),
                    val_1:=col.value #>> '{}',
                    val_2:=f.value,
                    negate:=coalesce(f.negate, false)
                )::int
            ) filter (where col.name is not null) = count(col.name),
            false
        )
    from
        unnest(filters) f
        left join unnest(columns) col
            on f.column_name = col.name;
$$;

DROP FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]);

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;

DROP FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer);

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;

DROP FUNCTION realtime.quote_wal2json(entity regclass);

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;

DROP FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean);

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;

DROP FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean);

GRANT ALL ON FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean) TO dashboard_user;

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        elsif filter.op = 'is'::realtime.equality_op then
            -- `is` requires a keyword RHS rather than a typed literal
            if filter.value not in ('null', 'true', 'false', 'unknown') then
                raise exception 'invalid value for is filter: must be null, true, false, or unknown';
            end if;
            -- IS NULL works for any type, but IS TRUE/FALSE/UNKNOWN require a boolean
            -- operand. Reject the non-null keywords on non-boolean columns here so they
            -- don't abort apply_rls at WAL time.
            if filter.value <> 'null' and col_type <> 'boolean'::regtype then
                raise exception 'is % filter requires a boolean column, got %', filter.value, col_type::text;
            end if;
        elsif filter.op in ('like'::realtime.equality_op, 'ilike'::realtime.equality_op) then
            -- like/ilike apply the text pattern operator (~~); reject column types that
            -- have no such operator instead of failing at WAL time
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = '~~' and oprleft = col_type
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
        elsif filter.op in ('match'::realtime.equality_op, 'imatch'::realtime.equality_op) then
            -- match/imatch apply the regex operators ~ / ~*; reject column types that have
            -- no such operator (e.g. integer) instead of failing at WAL time, mirroring the
            -- like/ilike guard above.
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = case when filter.op = 'imatch'::realtime.equality_op then '~*' else '~' end
                  and oprleft = col_type
                  and oprright = col_type
                  and oprresult = 'boolean'::regtype
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
            -- validate the regex eagerly so a bad pattern is rejected here, not inside
            -- apply_rls where it would abort the WAL stream for the entity
            begin
                perform '' ~ filter.value;
            exception when others then
                raise exception 'invalid regular expression for % filter: %', filter.op::text, sqlerrm;
            end;
        else
            -- eq/neq/lt/lte/gt/gte: value must be coercable to the type
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    -- Apply consistent order to filters so the unique constraint can't be tricked by a
    -- different filter order. negate is part of the sort key.
    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value, f.negate),
        '{}'
    ) from unnest(new.filters) f;

    new.selected_columns = (
        select array_agg(c order by c)
        from unnest(new.selected_columns) c
    );

    return new;
end;
$$;

DROP FUNCTION realtime.subscription_check_filters();

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;

DROP FUNCTION realtime.to_regrole(role_name text);

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;

DROP FUNCTION realtime.topic();

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;

DROP FUNCTION realtime.wal2json_escape_identifier(name text);

GRANT ALL ON FUNCTION realtime.wal2json_escape_identifier(name text) TO postgres;
GRANT ALL ON FUNCTION realtime.wal2json_escape_identifier(name text) TO dashboard_user;

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;

DROP FUNCTION storage.allow_any_operation(expected_operations text[]);

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;

DROP FUNCTION storage.allow_only_operation(expected_operation text);

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;

DROP FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb);

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;

DROP FUNCTION storage.enforce_bucket_name_length();

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;

DROP FUNCTION storage.extension(name text);

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;

DROP FUNCTION storage.filename(name text);

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;

DROP FUNCTION storage.foldername(name text);

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;

DROP FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text);

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;

DROP FUNCTION storage.get_size_by_bucket();

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;

DROP FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text);

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;

DROP FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text, sort_order text);

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;

DROP FUNCTION storage.operation();

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;

DROP FUNCTION storage.protect_delete();

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;

DROP FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text);

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;

DROP FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text);

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;

DROP FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text);

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;

DROP FUNCTION storage.update_updated_at_column();

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);

DROP TABLE auth.audit_log_entries;

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_claims_allowlist text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);

DROP TABLE auth.custom_oauth_providers;

GRANT ALL ON TABLE auth.custom_oauth_providers TO postgres;
GRANT ALL ON TABLE auth.custom_oauth_providers TO dashboard_user;

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);

DROP TABLE auth.flow_state;

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.flow_state TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);

DROP TABLE auth.identities;

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.identities TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);

DROP TABLE auth.instances;

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.instances TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);

DROP TABLE auth.mfa_amr_claims;

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);

DROP TABLE auth.mfa_challenges;

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);

DROP TABLE auth.mfa_factors;

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);

DROP TABLE auth.oauth_authorizations;

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);

DROP TABLE auth.oauth_client_states;

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';

GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);

DROP TABLE auth.oauth_clients;

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);

DROP TABLE auth.oauth_consents;

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);

DROP TABLE auth.one_time_tokens;

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);

DROP TABLE auth.refresh_tokens;

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE auth.refresh_tokens_id_seq;

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);

DROP TABLE auth.saml_providers;

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.saml_providers TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);

DROP TABLE auth.saml_relay_states;

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);

DROP TABLE auth.schema_migrations;

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.schema_migrations TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);

DROP TABLE auth.sessions;

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.sessions TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);

DROP TABLE auth.sso_domains;

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.sso_domains TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);

DROP TABLE auth.sso_providers;

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.sso_providers TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);

DROP TABLE auth.users;

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT ON TABLE auth.users TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);

DROP TABLE auth.webauthn_challenges;

GRANT ALL ON TABLE auth.webauthn_challenges TO postgres;
GRANT ALL ON TABLE auth.webauthn_challenges TO dashboard_user;

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);

DROP TABLE auth.webauthn_credentials;

GRANT ALL ON TABLE auth.webauthn_credentials TO postgres;
GRANT ALL ON TABLE auth.webauthn_credentials TO dashboard_user;

GRANT SELECT ON TABLE cron.job TO postgres WITH GRANT OPTION;

GRANT ALL ON TABLE cron.job_run_details TO postgres WITH GRANT OPTION;

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;
GRANT SELECT,INSERT ON TABLE extensions.pg_stat_statements TO sandbox_exec;

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;
GRANT SELECT,INSERT ON TABLE extensions.pg_stat_statements_info TO sandbox_exec;

CREATE TABLE public.api_logs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tipo text NOT NULL,
    acao text NOT NULL,
    status text NOT NULL,
    http_status integer,
    referencia text,
    codigo_rastreio text,
    mensagem text,
    request_payload jsonb,
    response_payload jsonb,
    duracao_ms integer
);

DROP TABLE public.api_logs;

GRANT ALL ON TABLE public.api_logs TO anon;
GRANT ALL ON TABLE public.api_logs TO authenticated;
GRANT ALL ON TABLE public.api_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.api_logs TO sandbox_exec;

CREATE SEQUENCE public.api_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.api_logs_id_seq;

ALTER SEQUENCE public.api_logs_id_seq OWNED BY public.api_logs.id;

GRANT ALL ON SEQUENCE public.api_logs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.api_logs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.api_logs_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.api_logs_id_seq TO sandbox_exec;

CREATE TABLE public.appmax_split_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    environment text DEFAULT 'production'::text NOT NULL,
    client_id text,
    client_secret text,
    logistics_recipient_id text,
    logistics_recipient_name text,
    logistics_recipient_document text,
    recipient_status text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    app_id text,
    redirect_uri text,
    oauth_access_token text,
    oauth_refresh_token text,
    oauth_token_expires_at timestamp with time zone,
    oauth_state text,
    oauth_connected_at timestamp with time zone,
    CONSTRAINT appmax_split_config_environment_check CHECK ((environment = ANY (ARRAY['sandbox'::text, 'production'::text])))
);

DROP TABLE public.appmax_split_config;

GRANT ALL ON TABLE public.appmax_split_config TO anon;
GRANT ALL ON TABLE public.appmax_split_config TO authenticated;
GRANT ALL ON TABLE public.appmax_split_config TO service_role;
GRANT SELECT,INSERT ON TABLE public.appmax_split_config TO sandbox_exec;

CREATE TABLE public.appmax_split_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    environment text,
    event_type text,
    appmax_order_id text,
    codigo_venda text,
    valor_total numeric(12,2),
    valor_produto numeric(12,2),
    valor_frete numeric(12,2),
    logistics_recipient_id text,
    split_status text DEFAULT 'pendente'::text NOT NULL,
    divergence_reason text,
    payment_status text,
    payload_raw jsonb,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT appmax_split_logs_split_status_check CHECK ((split_status = ANY (ARRAY['ok'::text, 'divergente'::text, 'sem_frete'::text, 'erro'::text, 'pendente'::text])))
);

DROP TABLE public.appmax_split_logs;

GRANT ALL ON TABLE public.appmax_split_logs TO anon;
GRANT ALL ON TABLE public.appmax_split_logs TO authenticated;
GRANT ALL ON TABLE public.appmax_split_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.appmax_split_logs TO sandbox_exec;

CREATE TABLE public.braip_vendas_xls (
    id bigint NOT NULL,
    chave text,
    produtor text,
    produto text,
    plano text,
    comprador text,
    email text,
    telefone text,
    cep text,
    endereco text,
    numero text,
    complemento text,
    bairro text,
    cidade text,
    estado text,
    documento text,
    parcelamento integer,
    pagamento text,
    status text,
    valor numeric,
    valor_pago numeric,
    comissao numeric,
    data_venda timestamp with time zone,
    data_pagamento timestamp with time zone,
    afiliado text,
    afiliado_email text,
    tipo_frete text,
    valor_frete numeric,
    pagamento_na_entrega text,
    codigo_rastreio text,
    arquivo_origem text,
    ultimo_status text,
    ultimo_status_local text,
    ultimo_status_data timestamp with time zone,
    ultima_consulta timestamp with time zone,
    eventos_rastreio jsonb,
    erro_consulta text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.braip_vendas_xls;

GRANT ALL ON TABLE public.braip_vendas_xls TO anon;
GRANT ALL ON TABLE public.braip_vendas_xls TO authenticated;
GRANT ALL ON TABLE public.braip_vendas_xls TO service_role;
GRANT SELECT,INSERT ON TABLE public.braip_vendas_xls TO sandbox_exec;

CREATE SEQUENCE public.braip_vendas_xls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.braip_vendas_xls_id_seq;

ALTER SEQUENCE public.braip_vendas_xls_id_seq OWNED BY public.braip_vendas_xls.id;

GRANT ALL ON SEQUENCE public.braip_vendas_xls_id_seq TO anon;
GRANT ALL ON SEQUENCE public.braip_vendas_xls_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.braip_vendas_xls_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.braip_vendas_xls_id_seq TO sandbox_exec;

CREATE TABLE public.cep_correcao_logs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    produtor_id uuid,
    venda_id bigint,
    pedido_id uuid,
    destino text,
    cep_original text,
    cep_corrigido text NOT NULL,
    fonte text,
    endereco_original jsonb,
    endereco_corrigido jsonb,
    enviado_sislog boolean DEFAULT false NOT NULL,
    observacao text
);

DROP TABLE public.cep_correcao_logs;

GRANT ALL ON TABLE public.cep_correcao_logs TO anon;
GRANT ALL ON TABLE public.cep_correcao_logs TO authenticated;
GRANT ALL ON TABLE public.cep_correcao_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.cep_correcao_logs TO sandbox_exec;

CREATE SEQUENCE public.cep_correcao_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.cep_correcao_logs_id_seq;

ALTER SEQUENCE public.cep_correcao_logs_id_seq OWNED BY public.cep_correcao_logs.id;

GRANT ALL ON SEQUENCE public.cep_correcao_logs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.cep_correcao_logs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.cep_correcao_logs_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.cep_correcao_logs_id_seq TO sandbox_exec;

CREATE TABLE public.clientes_envio (
    id bigint NOT NULL,
    nome text NOT NULL,
    cpf text,
    codigo_rastreio text,
    cep text,
    endereco_completo text,
    nome_plano text,
    telefone text,
    csv_nome text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.clientes_envio;

GRANT ALL ON TABLE public.clientes_envio TO anon;
GRANT ALL ON TABLE public.clientes_envio TO authenticated;
GRANT ALL ON TABLE public.clientes_envio TO service_role;
GRANT SELECT,INSERT ON TABLE public.clientes_envio TO sandbox_exec;

CREATE SEQUENCE public.clientes_envio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.clientes_envio_id_seq;

ALTER SEQUENCE public.clientes_envio_id_seq OWNED BY public.clientes_envio.id;

GRANT ALL ON SEQUENCE public.clientes_envio_id_seq TO anon;
GRANT ALL ON SEQUENCE public.clientes_envio_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.clientes_envio_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.clientes_envio_id_seq TO sandbox_exec;

CREATE TABLE public.conferencias_postagem (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    produtor_id uuid,
    planilha_nome text,
    pdf_nome text,
    total_planilha integer DEFAULT 0 NOT NULL,
    total_postados integer DEFAULT 0 NOT NULL,
    total_nao_encontrados integer DEFAULT 0 NOT NULL,
    total_possiveis integer DEFAULT 0 NOT NULL,
    resultado jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    paginas_resumo jsonb DEFAULT '[]'::jsonb NOT NULL
);

DROP TABLE public.conferencias_postagem;

GRANT ALL ON TABLE public.conferencias_postagem TO anon;
GRANT ALL ON TABLE public.conferencias_postagem TO authenticated;
GRANT ALL ON TABLE public.conferencias_postagem TO service_role;
GRANT SELECT,INSERT ON TABLE public.conferencias_postagem TO sandbox_exec;

CREATE TABLE public.contratos_logisticos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    nome text NOT NULL,
    transportadora text DEFAULT 'correios'::text NOT NULL,
    agf_nome text,
    cidade text,
    uf text,
    codigo_contrato text,
    cartao_postagem text,
    codigo_administrativo text,
    codigo_diretoria integer,
    numero_dr integer,
    correios_api_token text,
    observacao text,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.contratos_logisticos;

GRANT ALL ON TABLE public.contratos_logisticos TO anon;
GRANT ALL ON TABLE public.contratos_logisticos TO authenticated;
GRANT ALL ON TABLE public.contratos_logisticos TO service_role;
GRANT SELECT,INSERT ON TABLE public.contratos_logisticos TO sandbox_exec;

CREATE TABLE public.coproducao_auditoria (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid,
    acao text NOT NULL,
    entidade text,
    entidade_id text,
    dados_anteriores jsonb,
    dados_novos jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.coproducao_auditoria;

GRANT ALL ON TABLE public.coproducao_auditoria TO anon;
GRANT ALL ON TABLE public.coproducao_auditoria TO authenticated;
GRANT ALL ON TABLE public.coproducao_auditoria TO service_role;
GRANT SELECT,INSERT ON TABLE public.coproducao_auditoria TO sandbox_exec;

CREATE TABLE public.coproducao_configuracoes (
    id integer DEFAULT 1 NOT NULL,
    ativar_modulo boolean DEFAULT true NOT NULL,
    modo_operacao public.coproducao_modo_operacao DEFAULT 'controle_interno'::public.coproducao_modo_operacao NOT NULL,
    base_calculo_padrao public.coproducao_tipo_base DEFAULT 'produtos_sem_frete'::public.coproducao_tipo_base NOT NULL,
    frete_padrao public.coproducao_frete_destino DEFAULT 'empresa_principal'::public.coproducao_frete_destino NOT NULL,
    permitir_comissao_sobre_frete boolean DEFAULT false NOT NULL,
    bloquear_comissao_sobre_total_com_frete boolean DEFAULT true NOT NULL,
    gerar_conta_pagar_automaticamente boolean DEFAULT false NOT NULL,
    sistema_conta_pagar text DEFAULT 'manual'::text NOT NULL,
    status_minimo_para_gerar_comissao text DEFAULT 'pago'::text NOT NULL,
    prazo_liberacao_repasse_dias integer DEFAULT 7 NOT NULL,
    considerar_chargeback boolean DEFAULT true NOT NULL,
    considerar_estorno boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT coproducao_configuracoes_id_check CHECK ((id = 1))
);

DROP TABLE public.coproducao_configuracoes;

GRANT ALL ON TABLE public.coproducao_configuracoes TO anon;
GRANT ALL ON TABLE public.coproducao_configuracoes TO authenticated;
GRANT ALL ON TABLE public.coproducao_configuracoes TO service_role;
GRANT SELECT,INSERT ON TABLE public.coproducao_configuracoes TO sandbox_exec;

CREATE TABLE public.coproducao_regras (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    coprodutor_id uuid NOT NULL,
    nome_regra text NOT NULL,
    produto_id text,
    produto_nome text,
    sku text,
    codigo_produto_yampi text,
    codigo_produto_appmax text,
    cupom text,
    utm_source text,
    utm_campaign text,
    metadata_coprodutor text,
    percentual_comissao numeric(5,2) NOT NULL,
    tipo_base_calculo public.coproducao_tipo_base DEFAULT 'produtos_sem_frete'::public.coproducao_tipo_base NOT NULL,
    frete_para public.coproducao_frete_destino DEFAULT 'empresa_principal'::public.coproducao_frete_destino NOT NULL,
    status public.coproducao_status_coprodutor DEFAULT 'ativo'::public.coproducao_status_coprodutor NOT NULL,
    prioridade integer DEFAULT 100 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT coproducao_regras_percentual_comissao_check CHECK (((percentual_comissao >= (0)::numeric) AND (percentual_comissao <= (100)::numeric)))
);

DROP TABLE public.coproducao_regras;

GRANT ALL ON TABLE public.coproducao_regras TO anon;
GRANT ALL ON TABLE public.coproducao_regras TO authenticated;
GRANT ALL ON TABLE public.coproducao_regras TO service_role;
GRANT SELECT,INSERT ON TABLE public.coproducao_regras TO sandbox_exec;

CREATE TABLE public.coproducao_repasse_itens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    repasse_id uuid NOT NULL,
    venda_id uuid NOT NULL,
    valor_comissao numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.coproducao_repasse_itens;

GRANT ALL ON TABLE public.coproducao_repasse_itens TO anon;
GRANT ALL ON TABLE public.coproducao_repasse_itens TO authenticated;
GRANT ALL ON TABLE public.coproducao_repasse_itens TO service_role;
GRANT SELECT,INSERT ON TABLE public.coproducao_repasse_itens TO sandbox_exec;

CREATE TABLE public.coproducao_repasses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    coprodutor_id uuid NOT NULL,
    periodo_inicio date NOT NULL,
    periodo_fim date NOT NULL,
    total_vendas integer DEFAULT 0 NOT NULL,
    total_produtos numeric(12,2) DEFAULT 0 NOT NULL,
    total_frete numeric(12,2) DEFAULT 0 NOT NULL,
    total_comissao numeric(12,2) DEFAULT 0 NOT NULL,
    total_estornos numeric(12,2) DEFAULT 0 NOT NULL,
    total_chargebacks numeric(12,2) DEFAULT 0 NOT NULL,
    total_liquido_repassar numeric(12,2) DEFAULT 0 NOT NULL,
    status public.coproducao_status_repasse_lote DEFAULT 'aberto'::public.coproducao_status_repasse_lote NOT NULL,
    data_aprovacao timestamp with time zone,
    data_pagamento timestamp with time zone,
    forma_pagamento text,
    comprovante_url text,
    observacoes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.coproducao_repasses;

GRANT ALL ON TABLE public.coproducao_repasses TO anon;
GRANT ALL ON TABLE public.coproducao_repasses TO authenticated;
GRANT ALL ON TABLE public.coproducao_repasses TO service_role;
GRANT SELECT,INSERT ON TABLE public.coproducao_repasses TO sandbox_exec;

CREATE TABLE public.coproducao_vendas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    origem public.coproducao_origem NOT NULL,
    pedido_yampi_id text,
    pedido_appmax_id text,
    transacao_appmax_id text,
    codigo_venda text,
    cliente_nome text,
    cliente_email text,
    cliente_documento text,
    produto_nome text,
    sku text,
    quantidade integer DEFAULT 1 NOT NULL,
    valor_produtos numeric(12,2) DEFAULT 0 NOT NULL,
    valor_frete numeric(12,2) DEFAULT 0 NOT NULL,
    valor_desconto numeric(12,2) DEFAULT 0 NOT NULL,
    valor_total numeric(12,2) DEFAULT 0 NOT NULL,
    valor_pago numeric(12,2) DEFAULT 0 NOT NULL,
    forma_pagamento text,
    status_pagamento text,
    coprodutor_id uuid,
    regra_comissao_id uuid,
    percentual_comissao numeric(5,2),
    base_comissao numeric(12,2),
    valor_comissao numeric(12,2),
    valor_empresa numeric(12,2),
    frete_destinado_empresa numeric(12,2),
    status_repasse public.coproducao_status_repasse DEFAULT 'pendente'::public.coproducao_status_repasse NOT NULL,
    data_venda timestamp with time zone,
    data_pagamento timestamp with time zone,
    data_repasse timestamp with time zone,
    payload_original jsonb,
    observacoes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.coproducao_vendas;

GRANT ALL ON TABLE public.coproducao_vendas TO anon;
GRANT ALL ON TABLE public.coproducao_vendas TO authenticated;
GRANT ALL ON TABLE public.coproducao_vendas TO service_role;
GRANT SELECT,INSERT ON TABLE public.coproducao_vendas TO sandbox_exec;

CREATE TABLE public.coproducao_webhook_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    origem public.coproducao_origem NOT NULL,
    evento text,
    pedido_id text,
    transacao_id text,
    status text DEFAULT 'recebido'::text NOT NULL,
    payload jsonb,
    processado boolean DEFAULT false NOT NULL,
    erro text,
    tentativas integer DEFAULT 0 NOT NULL,
    venda_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.coproducao_webhook_logs;

GRANT ALL ON TABLE public.coproducao_webhook_logs TO anon;
GRANT ALL ON TABLE public.coproducao_webhook_logs TO authenticated;
GRANT ALL ON TABLE public.coproducao_webhook_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.coproducao_webhook_logs TO sandbox_exec;

CREATE TABLE public.coprodutores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    tipo_pessoa public.coproducao_tipo_pessoa DEFAULT 'pessoa_fisica'::public.coproducao_tipo_pessoa NOT NULL,
    cpf_cnpj text,
    email text,
    telefone text,
    chave_pix text,
    banco text,
    agencia text,
    conta text,
    tipo_conta text,
    percentual_padrao numeric(5,2) DEFAULT 0 NOT NULL,
    status public.coproducao_status_coprodutor DEFAULT 'ativo'::public.coproducao_status_coprodutor NOT NULL,
    observacoes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT coprodutores_percentual_padrao_check CHECK (((percentual_padrao >= (0)::numeric) AND (percentual_padrao <= (100)::numeric)))
);

DROP TABLE public.coprodutores;

GRANT ALL ON TABLE public.coprodutores TO anon;
GRANT ALL ON TABLE public.coprodutores TO authenticated;
GRANT ALL ON TABLE public.coprodutores TO service_role;
GRANT SELECT,INSERT ON TABLE public.coprodutores TO sandbox_exec;

CREATE TABLE public.correios_api_logs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    prefixo text NOT NULL,
    acao text NOT NULL,
    status text NOT NULL,
    http_status integer,
    codigo_rastreio text,
    mensagem text,
    request_payload jsonb,
    response_payload jsonb,
    duracao_ms integer
);

DROP TABLE public.correios_api_logs;

GRANT ALL ON TABLE public.correios_api_logs TO anon;
GRANT ALL ON TABLE public.correios_api_logs TO authenticated;
GRANT ALL ON TABLE public.correios_api_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.correios_api_logs TO sandbox_exec;

CREATE SEQUENCE public.correios_api_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.correios_api_logs_id_seq;

ALTER SEQUENCE public.correios_api_logs_id_seq OWNED BY public.correios_api_logs.id;

GRANT ALL ON SEQUENCE public.correios_api_logs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.correios_api_logs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.correios_api_logs_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.correios_api_logs_id_seq TO sandbox_exec;

CREATE TABLE public.correios_token_cache (
    id integer NOT NULL,
    tipo text NOT NULL,
    numero_cartao text,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.correios_token_cache;

GRANT ALL ON TABLE public.correios_token_cache TO anon;
GRANT ALL ON TABLE public.correios_token_cache TO authenticated;
GRANT ALL ON TABLE public.correios_token_cache TO service_role;
GRANT SELECT,INSERT ON TABLE public.correios_token_cache TO sandbox_exec;

CREATE TABLE public.email_envios_log (
    id bigint NOT NULL,
    pedido_id uuid,
    codigo_rastreio text,
    email text NOT NULL,
    nome text,
    status text DEFAULT 'queued'::text NOT NULL,
    erro text,
    sendgrid_message_id text,
    assunto text,
    template_hash text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    venda_id bigint
);

DROP TABLE public.email_envios_log;

GRANT ALL ON TABLE public.email_envios_log TO anon;
GRANT ALL ON TABLE public.email_envios_log TO authenticated;
GRANT ALL ON TABLE public.email_envios_log TO service_role;
GRANT SELECT,INSERT ON TABLE public.email_envios_log TO sandbox_exec;

CREATE SEQUENCE public.email_envios_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.email_envios_log_id_seq;

ALTER SEQUENCE public.email_envios_log_id_seq OWNED BY public.email_envios_log.id;

GRANT ALL ON SEQUENCE public.email_envios_log_id_seq TO anon;
GRANT ALL ON SEQUENCE public.email_envios_log_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.email_envios_log_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.email_envios_log_id_seq TO sandbox_exec;

CREATE TABLE public.email_template_rastreio (
    id integer DEFAULT 1 NOT NULL,
    assunto text DEFAULT 'Seu código de rastreio - Pedido {{codigo}}'::text NOT NULL,
    html text DEFAULT '<div style="font-family:Arial,sans-serif;max-width:560px;margin:0 auto;padding:20px;color:#222"><h2 style="margin:0 0 16px">Olá, {{nome}}!</h2><p>Seu pedido foi postado nos Correios. Veja abaixo o código de rastreio:</p><p style="font-size:18px;font-weight:bold;background:#f4f4f4;padding:12px;border-radius:6px;text-align:center;letter-spacing:1px">{{codigo}}</p><p>Você pode acompanhar a entrega clicando no link abaixo:</p><p style="text-align:center;margin:24px 0"><a href="{{link_rastreio}}" style="background:#0066cc;color:#fff;padding:12px 24px;text-decoration:none;border-radius:6px;display:inline-block">Rastrear pedido</a></p></div>'::text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT email_template_rastreio_singleton CHECK ((id = 1))
);

DROP TABLE public.email_template_rastreio;

GRANT ALL ON TABLE public.email_template_rastreio TO anon;
GRANT ALL ON TABLE public.email_template_rastreio TO authenticated;
GRANT ALL ON TABLE public.email_template_rastreio TO service_role;
GRANT SELECT,INSERT ON TABLE public.email_template_rastreio TO sandbox_exec;

CREATE TABLE public.envios (
    id bigint NOT NULL,
    data_envio text,
    nome text NOT NULL,
    cep text,
    uf text,
    peso text,
    formato text,
    codigo_interno text,
    codigo_rastreio text,
    valor_declarado numeric(12,2),
    valor_pago numeric(12,2),
    pdf_nome text,
    linha_bruta text,
    ultimo_status text,
    ultimo_status_detalhe text,
    ultimo_status_local text,
    ultimo_status_data timestamp with time zone,
    ultima_consulta timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.envios;

GRANT ALL ON TABLE public.envios TO anon;
GRANT ALL ON TABLE public.envios TO authenticated;
GRANT ALL ON TABLE public.envios TO service_role;
GRANT SELECT,INSERT ON TABLE public.envios TO sandbox_exec;

CREATE SEQUENCE public.envios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.envios_id_seq;

ALTER SEQUENCE public.envios_id_seq OWNED BY public.envios.id;

GRANT ALL ON SEQUENCE public.envios_id_seq TO anon;
GRANT ALL ON SEQUENCE public.envios_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.envios_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.envios_id_seq TO sandbox_exec;

CREATE TABLE public.estoque_baixa_config (
    produtor_id uuid NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    local_id uuid,
    observacao text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.estoque_baixa_config;

GRANT ALL ON TABLE public.estoque_baixa_config TO anon;
GRANT ALL ON TABLE public.estoque_baixa_config TO authenticated;
GRANT ALL ON TABLE public.estoque_baixa_config TO service_role;
GRANT SELECT,INSERT ON TABLE public.estoque_baixa_config TO sandbox_exec;

CREATE TABLE public.estoque_locais (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    nome text NOT NULL,
    descricao text,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.estoque_locais;

GRANT ALL ON TABLE public.estoque_locais TO anon;
GRANT ALL ON TABLE public.estoque_locais TO authenticated;
GRANT ALL ON TABLE public.estoque_locais TO service_role;
GRANT SELECT,INSERT ON TABLE public.estoque_locais TO sandbox_exec;

CREATE TABLE public.estoque_movimentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    produto_id uuid NOT NULL,
    local_id uuid,
    local_destino_id uuid,
    tipo text NOT NULL,
    quantidade numeric(14,3) NOT NULL,
    valor_unitario numeric(14,2),
    observacao text,
    identificacao text,
    user_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT estoque_movimentos_quantidade_check CHECK ((quantidade > (0)::numeric)),
    CONSTRAINT estoque_movimentos_tipo_check CHECK ((tipo = ANY (ARRAY['entrada'::text, 'saida'::text, 'ajuste'::text, 'transferencia'::text])))
);

DROP TABLE public.estoque_movimentos;

GRANT ALL ON TABLE public.estoque_movimentos TO anon;
GRANT ALL ON TABLE public.estoque_movimentos TO authenticated;
GRANT ALL ON TABLE public.estoque_movimentos TO service_role;
GRANT SELECT,INSERT ON TABLE public.estoque_movimentos TO sandbox_exec;

CREATE TABLE public.estoque_produtos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    nome text NOT NULL,
    codigo text,
    unidade text DEFAULT 'UN'::text NOT NULL,
    categoria text,
    estoque_minimo numeric(14,3) DEFAULT 0 NOT NULL,
    valor_custo numeric(14,2),
    observacao text,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.estoque_produtos;

GRANT ALL ON TABLE public.estoque_produtos TO anon;
GRANT ALL ON TABLE public.estoque_produtos TO authenticated;
GRANT ALL ON TABLE public.estoque_produtos TO service_role;
GRANT SELECT,INSERT ON TABLE public.estoque_produtos TO sandbox_exec;

CREATE VIEW public.estoque_saldos WITH (security_invoker='on') AS
 SELECT p.produtor_id,
    p.id AS produto_id,
    p.nome AS produto_nome,
    p.codigo AS produto_codigo,
    p.unidade,
    p.estoque_minimo,
    l.id AS local_id,
    l.nome AS local_nome,
    (COALESCE(sum(
        CASE
            WHEN ((m.tipo = ANY (ARRAY['entrada'::text, 'ajuste'::text])) AND (m.local_id = l.id)) THEN m.quantidade
            WHEN ((m.tipo = 'transferencia'::text) AND (m.local_destino_id = l.id)) THEN m.quantidade
            WHEN ((m.tipo = ANY (ARRAY['saida'::text, 'transferencia'::text])) AND (m.local_id = l.id)) THEN (- m.quantidade)
            ELSE (0)::numeric
        END), (0)::numeric))::numeric(14,3) AS saldo
   FROM ((public.estoque_produtos p
     CROSS JOIN public.estoque_locais l)
     LEFT JOIN public.estoque_movimentos m ON (((m.produto_id = p.id) AND ((m.local_id = l.id) OR (m.local_destino_id = l.id)))))
  WHERE (p.produtor_id = l.produtor_id)
  GROUP BY p.produtor_id, p.id, p.nome, p.codigo, p.unidade, p.estoque_minimo, l.id, l.nome;

DROP VIEW public.estoque_saldos;

GRANT ALL ON TABLE public.estoque_saldos TO anon;
GRANT ALL ON TABLE public.estoque_saldos TO authenticated;
GRANT ALL ON TABLE public.estoque_saldos TO service_role;
GRANT SELECT,INSERT ON TABLE public.estoque_saldos TO sandbox_exec;

CREATE TABLE public.ml_tokens (
    id integer DEFAULT 1 NOT NULL,
    access_token text,
    refresh_token text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ml_tokens_single_row CHECK ((id = 1))
);

DROP TABLE public.ml_tokens;

GRANT ALL ON TABLE public.ml_tokens TO anon;
GRANT ALL ON TABLE public.ml_tokens TO authenticated;
GRANT ALL ON TABLE public.ml_tokens TO service_role;
GRANT SELECT,INSERT ON TABLE public.ml_tokens TO sandbox_exec;

CREATE TABLE public.monetizze_vendas (
    id bigint NOT NULL,
    codigo_venda text,
    codigo_transacao text,
    status text,
    tipo_evento text,
    produto_codigo text,
    produto_nome text,
    plano_codigo text,
    plano_nome text,
    comprador_nome text,
    comprador_email text,
    comprador_telefone text,
    comprador_cpf text,
    comprador_cep text,
    comprador_endereco text,
    comprador_numero text,
    comprador_complemento text,
    comprador_bairro text,
    comprador_cidade text,
    comprador_estado text,
    valor numeric,
    valor_comissao numeric,
    forma_pagamento text,
    parcelas integer,
    data_inicio timestamp with time zone,
    data_finalizada timestamp with time zone,
    assinatura_codigo text,
    assinatura_status text,
    codigo_rastreio text,
    payload_completo jsonb NOT NULL,
    ip_origem text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    produtor_id uuid,
    transacao_invalida boolean DEFAULT false NOT NULL,
    notazz_document_id text,
    plataforma text DEFAULT 'monetizze'::text NOT NULL,
    origem_webhook boolean DEFAULT false NOT NULL
);

ALTER TABLE ONLY public.monetizze_vendas REPLICA IDENTITY FULL;

DROP TABLE public.monetizze_vendas;

GRANT ALL ON TABLE public.monetizze_vendas TO anon;
GRANT ALL ON TABLE public.monetizze_vendas TO authenticated;
GRANT ALL ON TABLE public.monetizze_vendas TO service_role;
GRANT SELECT,INSERT ON TABLE public.monetizze_vendas TO sandbox_exec;

CREATE SEQUENCE public.monetizze_vendas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.monetizze_vendas_id_seq;

ALTER SEQUENCE public.monetizze_vendas_id_seq OWNED BY public.monetizze_vendas.id;

GRANT ALL ON SEQUENCE public.monetizze_vendas_id_seq TO anon;
GRANT ALL ON SEQUENCE public.monetizze_vendas_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.monetizze_vendas_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.monetizze_vendas_id_seq TO sandbox_exec;

CREATE TABLE public.nfe_baixa_estoque_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    produto_codigo text DEFAULT ''::text NOT NULL,
    id_produto_vhsys text NOT NULL,
    id_local_estoque text,
    produto_descricao text,
    local_descricao text,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    match_nome text,
    vincular_produto boolean DEFAULT true NOT NULL
);

DROP TABLE public.nfe_baixa_estoque_config;

GRANT ALL ON TABLE public.nfe_baixa_estoque_config TO anon;
GRANT ALL ON TABLE public.nfe_baixa_estoque_config TO authenticated;
GRANT ALL ON TABLE public.nfe_baixa_estoque_config TO service_role;
GRANT SELECT,INSERT ON TABLE public.nfe_baixa_estoque_config TO sandbox_exec;

CREATE TABLE public.nfe_emissoes (
    id bigint NOT NULL,
    venda_id bigint,
    produtor_id uuid,
    status text DEFAULT 'pendente'::text NOT NULL,
    vhsys_nfe_id text,
    chave text,
    protocolo text,
    ambiente text,
    danfe_url text,
    xml_url text,
    valor numeric,
    produto_codigo text,
    produto_nome text,
    plano_codigo text,
    plano_nome text,
    erro text,
    tentativas integer DEFAULT 0 NOT NULL,
    payload_request jsonb,
    payload_response jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    emitida_at timestamp with time zone
);

DROP TABLE public.nfe_emissoes;

GRANT ALL ON TABLE public.nfe_emissoes TO anon;
GRANT ALL ON TABLE public.nfe_emissoes TO authenticated;
GRANT ALL ON TABLE public.nfe_emissoes TO service_role;
GRANT SELECT,INSERT ON TABLE public.nfe_emissoes TO sandbox_exec;

CREATE SEQUENCE public.nfe_emissoes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.nfe_emissoes_id_seq;

ALTER SEQUENCE public.nfe_emissoes_id_seq OWNED BY public.nfe_emissoes.id;

GRANT ALL ON SEQUENCE public.nfe_emissoes_id_seq TO anon;
GRANT ALL ON SEQUENCE public.nfe_emissoes_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.nfe_emissoes_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.nfe_emissoes_id_seq TO sandbox_exec;

CREATE TABLE public.notificacoes_carteiro_ausente (
    id bigint NOT NULL,
    codigo_objeto text NOT NULL,
    evento_descricao text,
    evento_data timestamp with time zone,
    evento_local text,
    telefone text,
    nome text,
    status text DEFAULT 'enviado'::text NOT NULL,
    erro text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.notificacoes_carteiro_ausente;

GRANT ALL ON TABLE public.notificacoes_carteiro_ausente TO anon;
GRANT ALL ON TABLE public.notificacoes_carteiro_ausente TO authenticated;
GRANT ALL ON TABLE public.notificacoes_carteiro_ausente TO service_role;
GRANT SELECT,INSERT ON TABLE public.notificacoes_carteiro_ausente TO sandbox_exec;

CREATE SEQUENCE public.notificacoes_carteiro_ausente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.notificacoes_carteiro_ausente_id_seq;

ALTER SEQUENCE public.notificacoes_carteiro_ausente_id_seq OWNED BY public.notificacoes_carteiro_ausente.id;

GRANT ALL ON SEQUENCE public.notificacoes_carteiro_ausente_id_seq TO anon;
GRANT ALL ON SEQUENCE public.notificacoes_carteiro_ausente_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.notificacoes_carteiro_ausente_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.notificacoes_carteiro_ausente_id_seq TO sandbox_exec;

CREATE TABLE public.pedido_regra_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid,
    pedido_id uuid,
    regra_logistica_id uuid,
    contrato_logistico_id uuid,
    origem text NOT NULL,
    payload_avaliacao jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.pedido_regra_logs;

GRANT ALL ON TABLE public.pedido_regra_logs TO anon;
GRANT ALL ON TABLE public.pedido_regra_logs TO authenticated;
GRANT ALL ON TABLE public.pedido_regra_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.pedido_regra_logs TO sandbox_exec;

CREATE TABLE public.pedidos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid,
    cliente_nome text,
    cliente_documento text,
    produto_nome text,
    codigo_rastreio text,
    id_prepostagem text,
    status_logistico public.status_logistico_enum DEFAULT 'pre_postado'::public.status_logistico_enum NOT NULL,
    data_prepostagem timestamp with time zone,
    data_postagem timestamp with time zone,
    data_em_transito timestamp with time zone,
    data_saiu_para_entrega timestamp with time zone,
    data_entrega timestamp with time zone,
    data_ultima_atualizacao timestamp with time zone,
    previsao_entrega timestamp with time zone,
    cidade_destino text,
    uf_destino text,
    servico_correios text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    venda_id bigint,
    plataforma text,
    cliente_email text,
    cliente_telefone text,
    valor_venda numeric,
    codigo_venda text,
    plano_nome text,
    data_venda timestamp with time zone,
    contrato_logistico_id uuid,
    regra_logistica_id uuid,
    origem_regra_logistica text,
    nome_contrato_logistico text,
    agf_origem text,
    transportadora_aplicada text,
    transportadora_externa text,
    transportadora_externa_id text,
    transportadora_externa_status text,
    transportadora_externa_erro text,
    transportadora_externa_enviado_em timestamp with time zone,
    transportadora_externa_payload jsonb,
    transportadora_externa_resposta jsonb
);

ALTER TABLE ONLY public.pedidos REPLICA IDENTITY FULL;

DROP TABLE public.pedidos;

GRANT ALL ON TABLE public.pedidos TO anon;
GRANT ALL ON TABLE public.pedidos TO authenticated;
GRANT ALL ON TABLE public.pedidos TO service_role;
GRANT SELECT,INSERT ON TABLE public.pedidos TO sandbox_exec;

CREATE TABLE public.pedidos_importados (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    data_envio date,
    nome text NOT NULL,
    cep text,
    uf text,
    peso numeric,
    codigo_rastreio text,
    valor numeric,
    servico text,
    arquivo_origem text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    email text
);

DROP TABLE public.pedidos_importados;

GRANT ALL ON TABLE public.pedidos_importados TO anon;
GRANT ALL ON TABLE public.pedidos_importados TO authenticated;
GRANT ALL ON TABLE public.pedidos_importados TO service_role;
GRANT SELECT,INSERT ON TABLE public.pedidos_importados TO sandbox_exec;

CREATE TABLE public.pedidos_xls (
    id bigint NOT NULL,
    id_nf_e text,
    id_logistica text,
    id_redespacho text,
    integracao text,
    data_criacao text,
    cliente text,
    valor_frete numeric,
    valor_nota numeric,
    rastreio text,
    novo_rastreio text,
    etiqueta text,
    protocolo text,
    status text,
    logistica text,
    venda text,
    motivo_status text,
    arquivo_origem text,
    ultimo_status text,
    ultimo_status_detalhe text,
    ultimo_status_local text,
    ultimo_status_data timestamp with time zone,
    ultima_consulta timestamp with time zone,
    eventos_rastreio jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    regra_id bigint
);

DROP TABLE public.pedidos_xls;

GRANT ALL ON TABLE public.pedidos_xls TO anon;
GRANT ALL ON TABLE public.pedidos_xls TO authenticated;
GRANT ALL ON TABLE public.pedidos_xls TO service_role;
GRANT SELECT,INSERT ON TABLE public.pedidos_xls TO sandbox_exec;

CREATE SEQUENCE public.pedidos_xls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.pedidos_xls_id_seq;

ALTER SEQUENCE public.pedidos_xls_id_seq OWNED BY public.pedidos_xls.id;

GRANT ALL ON SEQUENCE public.pedidos_xls_id_seq TO anon;
GRANT ALL ON SEQUENCE public.pedidos_xls_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.pedidos_xls_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.pedidos_xls_id_seq TO sandbox_exec;

CREATE TABLE public.prep_massa_logs (
    id bigint NOT NULL,
    run_id uuid NOT NULL,
    produtor_id uuid,
    user_id uuid,
    venda_id bigint,
    codigo_venda text,
    comprador_nome text,
    servico_codigo text,
    servico_nome text,
    quantidade integer,
    valor_declarado numeric,
    peso_g numeric,
    altura_cm numeric,
    largura_cm numeric,
    comprimento_cm numeric,
    status text NOT NULL,
    mensagem text,
    detalhes jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.prep_massa_logs;

GRANT ALL ON TABLE public.prep_massa_logs TO anon;
GRANT ALL ON TABLE public.prep_massa_logs TO authenticated;
GRANT ALL ON TABLE public.prep_massa_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.prep_massa_logs TO sandbox_exec;

CREATE SEQUENCE public.prep_massa_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.prep_massa_logs_id_seq;

ALTER SEQUENCE public.prep_massa_logs_id_seq OWNED BY public.prep_massa_logs.id;

GRANT ALL ON SEQUENCE public.prep_massa_logs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.prep_massa_logs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.prep_massa_logs_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.prep_massa_logs_id_seq TO sandbox_exec;

CREATE TABLE public.prepostagem_auto_logs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    produtor_id uuid,
    venda_id bigint,
    plataforma text,
    plano_codigo text,
    plano_id uuid,
    etapa text NOT NULL,
    status text NOT NULL,
    mensagem text,
    prepostagem_id bigint,
    codigo_objeto text,
    payload jsonb
);

DROP TABLE public.prepostagem_auto_logs;

GRANT ALL ON TABLE public.prepostagem_auto_logs TO anon;
GRANT ALL ON TABLE public.prepostagem_auto_logs TO authenticated;
GRANT ALL ON TABLE public.prepostagem_auto_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.prepostagem_auto_logs TO sandbox_exec;

CREATE SEQUENCE public.prepostagem_auto_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.prepostagem_auto_logs_id_seq;

ALTER SEQUENCE public.prepostagem_auto_logs_id_seq OWNED BY public.prepostagem_auto_logs.id;

GRANT ALL ON SEQUENCE public.prepostagem_auto_logs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.prepostagem_auto_logs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.prepostagem_auto_logs_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.prepostagem_auto_logs_id_seq TO sandbox_exec;

CREATE TABLE public.prepostagens (
    id bigint NOT NULL,
    venda_id bigint,
    regra_id bigint,
    quantidade integer DEFAULT 1 NOT NULL,
    servico_codigo text NOT NULL,
    servico_nome text,
    peso_g numeric NOT NULL,
    altura_cm numeric NOT NULL,
    largura_cm numeric NOT NULL,
    comprimento_cm numeric NOT NULL,
    valor_declarado numeric,
    destinatario_nome text,
    destinatario_cep text,
    destinatario_endereco text,
    destinatario_cidade text,
    destinatario_estado text,
    codigo_objeto text,
    id_prepostagem text,
    etiqueta_pdf_base64 text,
    status text DEFAULT 'pendente'::text NOT NULL,
    erro text,
    payload_request jsonb,
    payload_response jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ultimo_status text,
    ultimo_status_data timestamp with time zone,
    ultimo_status_local text,
    ultima_consulta timestamp with time zone,
    eventos_rastreio jsonb
);

ALTER TABLE ONLY public.prepostagens REPLICA IDENTITY FULL;

DROP TABLE public.prepostagens;

GRANT ALL ON TABLE public.prepostagens TO anon;
GRANT ALL ON TABLE public.prepostagens TO authenticated;
GRANT ALL ON TABLE public.prepostagens TO service_role;
GRANT SELECT,INSERT ON TABLE public.prepostagens TO sandbox_exec;

CREATE SEQUENCE public.prepostagens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.prepostagens_id_seq;

ALTER SEQUENCE public.prepostagens_id_seq OWNED BY public.prepostagens.id;

GRANT ALL ON SEQUENCE public.prepostagens_id_seq TO anon;
GRANT ALL ON SEQUENCE public.prepostagens_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.prepostagens_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.prepostagens_id_seq TO sandbox_exec;

CREATE TABLE public.prepostagens_ppn (
    id bigint NOT NULL,
    id_prepostagem text NOT NULL,
    codigo_objeto text,
    destinatario_nome text,
    data_postagem timestamp with time zone,
    data_criacao timestamp with time zone,
    data_expiracao timestamp with time zone,
    status text NOT NULL,
    servico_codigo text,
    servico_nome text,
    destinatario_cidade text,
    destinatario_estado text,
    destinatario_cep text,
    valor_total numeric,
    payload_completo jsonb,
    ultima_sincronizacao timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ultimo_status text,
    ultimo_status_data timestamp with time zone,
    ultimo_status_local text,
    ultima_consulta_sro timestamp with time zone,
    eventos_rastreio jsonb
);

ALTER TABLE ONLY public.prepostagens_ppn REPLICA IDENTITY FULL;

DROP TABLE public.prepostagens_ppn;

GRANT ALL ON TABLE public.prepostagens_ppn TO anon;
GRANT ALL ON TABLE public.prepostagens_ppn TO authenticated;
GRANT ALL ON TABLE public.prepostagens_ppn TO service_role;
GRANT SELECT,INSERT ON TABLE public.prepostagens_ppn TO sandbox_exec;

CREATE SEQUENCE public.prepostagens_ppn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.prepostagens_ppn_id_seq;

ALTER SEQUENCE public.prepostagens_ppn_id_seq OWNED BY public.prepostagens_ppn.id;

GRANT ALL ON SEQUENCE public.prepostagens_ppn_id_seq TO anon;
GRANT ALL ON SEQUENCE public.prepostagens_ppn_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.prepostagens_ppn_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.prepostagens_ppn_id_seq TO sandbox_exec;

CREATE TABLE public.produto_precos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    produto_nome text NOT NULL,
    quantidade_min integer DEFAULT 1 NOT NULL,
    quantidade_max integer DEFAULT 1 NOT NULL,
    preco_unitario numeric NOT NULL,
    link_asaas text,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.produto_precos;

GRANT ALL ON TABLE public.produto_precos TO anon;
GRANT ALL ON TABLE public.produto_precos TO authenticated;
GRANT ALL ON TABLE public.produto_precos TO service_role;
GRANT SELECT,INSERT ON TABLE public.produto_precos TO sandbox_exec;

CREATE TABLE public.produto_regras (
    id bigint NOT NULL,
    nome text NOT NULL,
    palavras_chave text[] DEFAULT '{}'::text[] NOT NULL,
    peso_unitario_g numeric DEFAULT 0 NOT NULL,
    altura_cm numeric DEFAULT 2 NOT NULL,
    largura_cm numeric DEFAULT 11 NOT NULL,
    comprimento_cm numeric DEFAULT 16 NOT NULL,
    valor_declarado_padrao numeric,
    faixas jsonb DEFAULT '[]'::jsonb NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    is_fallback boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    itens_planos jsonb DEFAULT '[]'::jsonb NOT NULL,
    enviar_sislogica boolean DEFAULT true NOT NULL
);

DROP TABLE public.produto_regras;

COMMENT ON COLUMN public.produto_regras.enviar_sislogica IS 'Quando false, produtos que casarem com esta regra não serão enviados para a SisLogica (automático e manual).';

GRANT ALL ON TABLE public.produto_regras TO anon;
GRANT ALL ON TABLE public.produto_regras TO authenticated;
GRANT ALL ON TABLE public.produto_regras TO service_role;
GRANT SELECT,INSERT ON TABLE public.produto_regras TO sandbox_exec;

CREATE SEQUENCE public.produto_regras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.produto_regras_id_seq;

ALTER SEQUENCE public.produto_regras_id_seq OWNED BY public.produto_regras.id;

GRANT ALL ON SEQUENCE public.produto_regras_id_seq TO anon;
GRANT ALL ON SEQUENCE public.produto_regras_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.produto_regras_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.produto_regras_id_seq TO sandbox_exec;

CREATE TABLE public.produtor_api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    user_id uuid NOT NULL,
    nome text NOT NULL,
    key_prefix text NOT NULL,
    key_hash text NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    last_used_at timestamp with time zone,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    escopos text[] DEFAULT ARRAY['vendas:read'::text, 'pedidos:read'::text] NOT NULL
);

DROP TABLE public.produtor_api_keys;

GRANT ALL ON TABLE public.produtor_api_keys TO anon;
GRANT ALL ON TABLE public.produtor_api_keys TO authenticated;
GRANT ALL ON TABLE public.produtor_api_keys TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_api_keys TO sandbox_exec;

CREATE TABLE public.produtor_frete_faixas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    qtd_min integer NOT NULL,
    qtd_max integer NOT NULL,
    valor numeric(10,2) NOT NULL,
    observacao text,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT produtor_frete_faixas_check CHECK ((qtd_max >= qtd_min)),
    CONSTRAINT produtor_frete_faixas_qtd_min_check CHECK ((qtd_min >= 1)),
    CONSTRAINT produtor_frete_faixas_valor_check CHECK ((valor >= (0)::numeric))
);

DROP TABLE public.produtor_frete_faixas;

GRANT ALL ON TABLE public.produtor_frete_faixas TO anon;
GRANT ALL ON TABLE public.produtor_frete_faixas TO authenticated;
GRANT ALL ON TABLE public.produtor_frete_faixas TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_frete_faixas TO sandbox_exec;

CREATE TABLE public.produtor_peso_faixas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    qtd_min integer NOT NULL,
    qtd_max integer NOT NULL,
    peso_total numeric(10,3) NOT NULL,
    observacao text,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT produtor_peso_faixas_check CHECK ((qtd_max >= qtd_min)),
    CONSTRAINT produtor_peso_faixas_peso_total_check CHECK ((peso_total >= (0)::numeric)),
    CONSTRAINT produtor_peso_faixas_qtd_max_check CHECK ((qtd_max >= 1)),
    CONSTRAINT produtor_peso_faixas_qtd_min_check CHECK ((qtd_min >= 1))
);

DROP TABLE public.produtor_peso_faixas;

GRANT ALL ON TABLE public.produtor_peso_faixas TO anon;
GRANT ALL ON TABLE public.produtor_peso_faixas TO authenticated;
GRANT ALL ON TABLE public.produtor_peso_faixas TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_peso_faixas TO sandbox_exec;

CREATE TABLE public.produtor_planos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    plano_codigo text NOT NULL,
    plano_nome_amigavel text,
    regra_id bigint,
    gerar_prepostagem_auto boolean DEFAULT false NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    plataforma text DEFAULT 'monetizze'::text NOT NULL,
    atualizar_rastreio_auto boolean DEFAULT false NOT NULL,
    contrato_logistico_padrao_id uuid,
    unidades integer DEFAULT 1 NOT NULL
);

DROP TABLE public.produtor_planos;

COMMENT ON COLUMN public.produtor_planos.unidades IS 'Quantos frascos/itens este plano representa. Usado para somar quantidades de upsells/order bumps em uma mesma venda.';

GRANT ALL ON TABLE public.produtor_planos TO anon;
GRANT ALL ON TABLE public.produtor_planos TO authenticated;
GRANT ALL ON TABLE public.produtor_planos TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_planos TO sandbox_exec;

CREATE TABLE public.produtor_produto_precos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    produto_codigo text NOT NULL,
    produto_nome text,
    valor_unitario numeric NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.produtor_produto_precos;

GRANT ALL ON TABLE public.produtor_produto_precos TO anon;
GRANT ALL ON TABLE public.produtor_produto_precos TO authenticated;
GRANT ALL ON TABLE public.produtor_produto_precos TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_produto_precos TO sandbox_exec;

CREATE TABLE public.produtor_usuarios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    produtor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.produtor_usuarios;

GRANT ALL ON TABLE public.produtor_usuarios TO anon;
GRANT ALL ON TABLE public.produtor_usuarios TO authenticated;
GRANT ALL ON TABLE public.produtor_usuarios TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_usuarios TO sandbox_exec;

CREATE TABLE public.produtor_webhook_entregas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    webhook_id uuid NOT NULL,
    evento text NOT NULL,
    payload jsonb NOT NULL,
    status_http integer,
    resposta text,
    erro text,
    duracao_ms integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.produtor_webhook_entregas;

GRANT ALL ON TABLE public.produtor_webhook_entregas TO anon;
GRANT ALL ON TABLE public.produtor_webhook_entregas TO authenticated;
GRANT ALL ON TABLE public.produtor_webhook_entregas TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_webhook_entregas TO sandbox_exec;

CREATE TABLE public.produtor_webhooks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    produtor_id uuid,
    nome text NOT NULL,
    url text NOT NULL,
    eventos text[] DEFAULT ARRAY['venda.criada'::text] NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.produtor_webhooks;

GRANT ALL ON TABLE public.produtor_webhooks TO anon;
GRANT ALL ON TABLE public.produtor_webhooks TO authenticated;
GRANT ALL ON TABLE public.produtor_webhooks TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtor_webhooks TO sandbox_exec;

CREATE TABLE public.produtores_integracao (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    plataforma text DEFAULT 'monetizze'::text NOT NULL,
    webhook_token text NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    consumer_key text DEFAULT (gen_random_uuid())::text NOT NULL,
    monetizze_api_key text,
    monetizze_logistica_key text,
    vhsys_cliente_id text,
    cnpj text,
    razao_social text,
    inscricao_estadual text,
    endereco text,
    endereco_numero text,
    endereco_complemento text,
    endereco_bairro text,
    endereco_cidade text,
    endereco_estado text,
    endereco_cep text,
    email_fiscal text,
    telefone_fiscal text,
    emissao_nfe_ativa boolean DEFAULT false NOT NULL,
    armazem_nome text,
    armazem_cnpj text,
    armazem_inscricao_est text,
    armazem_endereco text,
    armazem_endereco_numero text,
    armazem_endereco_complemento text,
    armazem_endereco_bairro text,
    armazem_endereco_cidade text,
    armazem_endereco_estado text,
    armazem_endereco_cep text,
    valor_frete numeric DEFAULT 0 NOT NULL,
    vhsys_id_almoxarifado integer,
    vhsys_produtos jsonb DEFAULT '[]'::jsonb NOT NULL,
    vhsys_id_local_estoque integer,
    peso_produto numeric DEFAULT 0 NOT NULL,
    correios_webhook_secret text DEFAULT (gen_random_uuid())::text,
    braip_api_token text,
    braip_webhook_secret text DEFAULT (gen_random_uuid())::text,
    braip_ativa boolean DEFAULT false NOT NULL,
    monetizze_ativa boolean DEFAULT true NOT NULL,
    aceitar_vendas_sem_plano boolean DEFAULT false NOT NULL,
    sislog_ativa boolean DEFAULT false NOT NULL,
    sislog_cnpj_embarcador text,
    sislog_ufs text[] DEFAULT '{}'::text[] NOT NULL,
    nfe_obs_complementar text,
    nfe_natureza_operacao text,
    nfe_cfop text,
    nfe_frete_por_conta smallint,
    nfe_chave_referenciada text
);

DROP TABLE public.produtores_integracao;

GRANT ALL ON TABLE public.produtores_integracao TO anon;
GRANT ALL ON TABLE public.produtores_integracao TO authenticated;
GRANT ALL ON TABLE public.produtores_integracao TO service_role;
GRANT SELECT,INSERT ON TABLE public.produtores_integracao TO sandbox_exec;

CREATE TABLE public.profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    nome text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.profiles;

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;
GRANT SELECT,INSERT ON TABLE public.profiles TO sandbox_exec;

CREATE TABLE public.reenvio_pagamentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    reenvio_id bigint,
    venda_id bigint,
    comprador_nome text,
    comprador_email text,
    quantidade integer NOT NULL,
    preco_total numeric NOT NULL,
    link_asaas text,
    status text DEFAULT 'pendente'::text NOT NULL,
    email_enviado boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.reenvio_pagamentos;

GRANT ALL ON TABLE public.reenvio_pagamentos TO anon;
GRANT ALL ON TABLE public.reenvio_pagamentos TO authenticated;
GRANT ALL ON TABLE public.reenvio_pagamentos TO service_role;
GRANT SELECT,INSERT ON TABLE public.reenvio_pagamentos TO sandbox_exec;

CREATE TABLE public.reenvios (
    id bigint NOT NULL,
    produtor_id uuid NOT NULL,
    venda_id bigint,
    prepostagem_id bigint,
    codigo_objeto_original text,
    codigo_objeto_novo text,
    motivo text,
    status text DEFAULT 'pendente'::text NOT NULL,
    observacao text,
    comprador_nome text,
    produto_nome text,
    destino_cidade text,
    destino_uf text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    quantidade integer
);

DROP TABLE public.reenvios;

GRANT ALL ON TABLE public.reenvios TO anon;
GRANT ALL ON TABLE public.reenvios TO authenticated;
GRANT ALL ON TABLE public.reenvios TO service_role;
GRANT SELECT,INSERT ON TABLE public.reenvios TO sandbox_exec;

CREATE SEQUENCE public.reenvios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.reenvios_id_seq;

ALTER SEQUENCE public.reenvios_id_seq OWNED BY public.reenvios.id;

GRANT ALL ON SEQUENCE public.reenvios_id_seq TO anon;
GRANT ALL ON SEQUENCE public.reenvios_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.reenvios_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.reenvios_id_seq TO sandbox_exec;

CREATE TABLE public.registro_estoque (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    codigo_rastreio text,
    cliente_nome text,
    produto_nome text,
    quantidade integer,
    foto_etiqueta_url text,
    foto_declaracao_url text,
    pedido_id uuid,
    payload_ia jsonb,
    observacao text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.registro_estoque;

GRANT ALL ON TABLE public.registro_estoque TO anon;
GRANT ALL ON TABLE public.registro_estoque TO authenticated;
GRANT ALL ON TABLE public.registro_estoque TO service_role;
GRANT SELECT,INSERT ON TABLE public.registro_estoque TO sandbox_exec;

CREATE TABLE public.regras_logisticas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    nome text NOT NULL,
    plano_id uuid,
    produto_nome text,
    transportadora text,
    contrato_logistico_id uuid NOT NULL,
    uf text,
    cidade text,
    cep_inicial text,
    cep_final text,
    prioridade integer DEFAULT 100 NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    enviar_sislogica boolean DEFAULT true NOT NULL
);

DROP TABLE public.regras_logisticas;

COMMENT ON COLUMN public.regras_logisticas.enviar_sislogica IS 'Quando false, vendas que casarem com esta regra NÃO são despachadas para a SisLogica (nem aparecem na aba SisLogica).';

GRANT ALL ON TABLE public.regras_logisticas TO anon;
GRANT ALL ON TABLE public.regras_logisticas TO authenticated;
GRANT ALL ON TABLE public.regras_logisticas TO service_role;
GRANT SELECT,INSERT ON TABLE public.regras_logisticas TO sandbox_exec;

CREATE TABLE public.remetente_config (
    id integer DEFAULT 1 NOT NULL,
    nome text,
    documento text,
    email text,
    telefone text,
    cep text,
    endereco text,
    numero text,
    complemento text,
    bairro text,
    cidade text,
    estado text,
    numero_contrato text,
    numero_cartao_postagem text,
    numero_dr integer,
    codigo_diretoria integer,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT remetente_config_id_check CHECK ((id = 1))
);

DROP TABLE public.remetente_config;

GRANT ALL ON TABLE public.remetente_config TO anon;
GRANT ALL ON TABLE public.remetente_config TO authenticated;
GRANT ALL ON TABLE public.remetente_config TO service_role;
GRANT SELECT,INSERT ON TABLE public.remetente_config TO sandbox_exec;

CREATE TABLE public.sislog_remetentes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    produtor_id uuid NOT NULL,
    nome text NOT NULL,
    cnpj text,
    inscricao_estadual text,
    razao_social text,
    cep text,
    logradouro text,
    numero text,
    complemento text,
    bairro text,
    cidade text,
    estado text,
    telefone text,
    email text,
    ufs_atendidas text[] DEFAULT '{}'::text[] NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.sislog_remetentes;

GRANT ALL ON TABLE public.sislog_remetentes TO anon;
GRANT ALL ON TABLE public.sislog_remetentes TO authenticated;
GRANT ALL ON TABLE public.sislog_remetentes TO service_role;
GRANT SELECT,INSERT ON TABLE public.sislog_remetentes TO sandbox_exec;

CREATE TABLE public.sislogica_envios_log (
    id bigint NOT NULL,
    pedido_id uuid,
    produtor_id uuid,
    id_solicitacao_interno text,
    id_solicitacao_gerada text,
    codigo_rastreio text,
    status text NOT NULL,
    http_status integer,
    erro text,
    request_payload jsonb,
    response_payload jsonb,
    duracao_ms integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    venda_id bigint
);

DROP TABLE public.sislogica_envios_log;

GRANT ALL ON TABLE public.sislogica_envios_log TO anon;
GRANT ALL ON TABLE public.sislogica_envios_log TO authenticated;
GRANT ALL ON TABLE public.sislogica_envios_log TO service_role;
GRANT SELECT,INSERT ON TABLE public.sislogica_envios_log TO sandbox_exec;

CREATE SEQUENCE public.sislogica_envios_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.sislogica_envios_log_id_seq;

ALTER SEQUENCE public.sislogica_envios_log_id_seq OWNED BY public.sislogica_envios_log.id;

GRANT ALL ON SEQUENCE public.sislogica_envios_log_id_seq TO anon;
GRANT ALL ON SEQUENCE public.sislogica_envios_log_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.sislogica_envios_log_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.sislogica_envios_log_id_seq TO sandbox_exec;

CREATE TABLE public.sislogica_webhook_recebidos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    id_solicitacao text,
    id_solicitacao_interno text,
    codigo_rastreio text,
    status_recebido text,
    processado boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.sislogica_webhook_recebidos;

GRANT ALL ON TABLE public.sislogica_webhook_recebidos TO anon;
GRANT ALL ON TABLE public.sislogica_webhook_recebidos TO authenticated;
GRANT ALL ON TABLE public.sislogica_webhook_recebidos TO service_role;
GRANT SELECT,INSERT ON TABLE public.sislogica_webhook_recebidos TO sandbox_exec;

CREATE TABLE public.sislogica_webhook_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    token text NOT NULL,
    descricao text,
    criado_por uuid,
    revogado boolean DEFAULT false NOT NULL,
    ultimo_uso_em timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.sislogica_webhook_tokens;

GRANT ALL ON TABLE public.sislogica_webhook_tokens TO anon;
GRANT ALL ON TABLE public.sislogica_webhook_tokens TO authenticated;
GRANT ALL ON TABLE public.sislogica_webhook_tokens TO service_role;
GRANT SELECT,INSERT ON TABLE public.sislogica_webhook_tokens TO sandbox_exec;

CREATE TABLE public.tracking_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pedido_id uuid,
    produtor_id uuid,
    codigo_rastreio text,
    status text,
    descricao_evento text,
    data_evento timestamp with time zone,
    local_evento text,
    cidade_evento text,
    uf_evento text,
    payload_original jsonb,
    origem text DEFAULT 'webhook'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.tracking_events REPLICA IDENTITY FULL;

DROP TABLE public.tracking_events;

GRANT ALL ON TABLE public.tracking_events TO anon;
GRANT ALL ON TABLE public.tracking_events TO authenticated;
GRANT ALL ON TABLE public.tracking_events TO service_role;
GRANT SELECT,INSERT ON TABLE public.tracking_events TO sandbox_exec;

CREATE TABLE public.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role public.app_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.user_roles;

GRANT ALL ON TABLE public.user_roles TO anon;
GRANT ALL ON TABLE public.user_roles TO authenticated;
GRANT ALL ON TABLE public.user_roles TO service_role;
GRANT SELECT,INSERT ON TABLE public.user_roles TO sandbox_exec;

CREATE TABLE public.vendas_ml (
    id bigint NOT NULL,
    ml_order_id bigint NOT NULL,
    status text,
    total numeric,
    comprador text,
    itens jsonb,
    pago_em timestamp with time zone,
    raw jsonb,
    criado_em timestamp with time zone DEFAULT now() NOT NULL,
    nome_completo text,
    email text,
    telefone text,
    cpf_cnpj text,
    endereco jsonb,
    shipping_id bigint,
    shipping_raw jsonb,
    billing_raw jsonb
);

DROP TABLE public.vendas_ml;

GRANT ALL ON TABLE public.vendas_ml TO anon;
GRANT ALL ON TABLE public.vendas_ml TO authenticated;
GRANT ALL ON TABLE public.vendas_ml TO service_role;
GRANT SELECT,INSERT ON TABLE public.vendas_ml TO sandbox_exec;

CREATE SEQUENCE public.vendas_ml_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.vendas_ml_id_seq;

ALTER SEQUENCE public.vendas_ml_id_seq OWNED BY public.vendas_ml.id;

GRANT ALL ON SEQUENCE public.vendas_ml_id_seq TO anon;
GRANT ALL ON SEQUENCE public.vendas_ml_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.vendas_ml_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.vendas_ml_id_seq TO sandbox_exec;

CREATE TABLE public.vhsys_estoque_movimentos (
    id bigint NOT NULL,
    produto_vhsys_id bigint NOT NULL,
    produto_nome text,
    tipo text NOT NULL,
    quantidade numeric NOT NULL,
    valor_unitario numeric,
    observacao text,
    identificacao text,
    produtor_id uuid,
    user_id uuid,
    vhsys_id_estoque bigint,
    status text DEFAULT 'pendente'::text NOT NULL,
    erro text,
    payload_request jsonb,
    payload_response jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT vhsys_estoque_movimentos_tipo_check CHECK ((tipo = ANY (ARRAY['Entrada'::text, 'Saida'::text])))
);

DROP TABLE public.vhsys_estoque_movimentos;

GRANT ALL ON TABLE public.vhsys_estoque_movimentos TO anon;
GRANT ALL ON TABLE public.vhsys_estoque_movimentos TO authenticated;
GRANT ALL ON TABLE public.vhsys_estoque_movimentos TO service_role;
GRANT SELECT,INSERT ON TABLE public.vhsys_estoque_movimentos TO sandbox_exec;

CREATE SEQUENCE public.vhsys_estoque_movimentos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.vhsys_estoque_movimentos_id_seq;

ALTER SEQUENCE public.vhsys_estoque_movimentos_id_seq OWNED BY public.vhsys_estoque_movimentos.id;

GRANT ALL ON SEQUENCE public.vhsys_estoque_movimentos_id_seq TO anon;
GRANT ALL ON SEQUENCE public.vhsys_estoque_movimentos_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.vhsys_estoque_movimentos_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.vhsys_estoque_movimentos_id_seq TO sandbox_exec;

CREATE TABLE public.vhsys_estoque_saldos (
    produto_vhsys_id bigint NOT NULL,
    produto_nome text,
    produto_codigo text,
    saldo_atual numeric DEFAULT 0 NOT NULL,
    estoque_minimo numeric DEFAULT 0 NOT NULL,
    ultima_consulta timestamp with time zone,
    payload jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tipo_item text DEFAULT 'produto'::text NOT NULL,
    CONSTRAINT vhsys_estoque_saldos_tipo_item_check CHECK ((tipo_item = ANY (ARRAY['produto'::text, 'insumo'::text])))
);

DROP TABLE public.vhsys_estoque_saldos;

GRANT ALL ON TABLE public.vhsys_estoque_saldos TO anon;
GRANT ALL ON TABLE public.vhsys_estoque_saldos TO authenticated;
GRANT ALL ON TABLE public.vhsys_estoque_saldos TO service_role;
GRANT SELECT,INSERT ON TABLE public.vhsys_estoque_saldos TO sandbox_exec;

CREATE TABLE public.vhsys_locais_estoque (
    id_local_estoque bigint NOT NULL,
    nome text NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    observacao text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.vhsys_locais_estoque;

GRANT ALL ON TABLE public.vhsys_locais_estoque TO anon;
GRANT ALL ON TABLE public.vhsys_locais_estoque TO authenticated;
GRANT ALL ON TABLE public.vhsys_locais_estoque TO service_role;
GRANT SELECT,INSERT ON TABLE public.vhsys_locais_estoque TO sandbox_exec;

CREATE TABLE public.webhook_logs (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    produtor_id uuid,
    token_prefix text,
    status text NOT NULL,
    motivo text,
    plano_codigo text,
    produto_codigo text,
    comprador_nome text,
    valor numeric,
    venda_id bigint,
    ip_origem text,
    payload jsonb,
    codigo_venda text
);

DROP TABLE public.webhook_logs;

GRANT ALL ON TABLE public.webhook_logs TO anon;
GRANT ALL ON TABLE public.webhook_logs TO authenticated;
GRANT ALL ON TABLE public.webhook_logs TO service_role;
GRANT SELECT,INSERT ON TABLE public.webhook_logs TO sandbox_exec;

CREATE SEQUENCE public.webhook_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.webhook_logs_id_seq;

ALTER SEQUENCE public.webhook_logs_id_seq OWNED BY public.webhook_logs.id;

GRANT ALL ON SEQUENCE public.webhook_logs_id_seq TO anon;
GRANT ALL ON SEQUENCE public.webhook_logs_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.webhook_logs_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.webhook_logs_id_seq TO sandbox_exec;

CREATE TABLE public.whatsapp_envios_log (
    id bigint NOT NULL,
    cliente_id bigint,
    telefone text NOT NULL,
    nome text,
    mensagem text NOT NULL,
    status text DEFAULT 'pendente'::text NOT NULL,
    erro text,
    enviado_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE public.whatsapp_envios_log;

GRANT ALL ON TABLE public.whatsapp_envios_log TO anon;
GRANT ALL ON TABLE public.whatsapp_envios_log TO authenticated;
GRANT ALL ON TABLE public.whatsapp_envios_log TO service_role;
GRANT SELECT,INSERT ON TABLE public.whatsapp_envios_log TO sandbox_exec;

CREATE SEQUENCE public.whatsapp_envios_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

DROP SEQUENCE public.whatsapp_envios_log_id_seq;

ALTER SEQUENCE public.whatsapp_envios_log_id_seq OWNED BY public.whatsapp_envios_log.id;

GRANT ALL ON SEQUENCE public.whatsapp_envios_log_id_seq TO anon;
GRANT ALL ON SEQUENCE public.whatsapp_envios_log_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.whatsapp_envios_log_id_seq TO service_role;
GRANT SELECT,USAGE ON SEQUENCE public.whatsapp_envios_log_id_seq TO sandbox_exec;

CREATE TABLE public.whatsapp_template (
    id integer DEFAULT 1 NOT NULL,
    mensagem text DEFAULT 'Olá {nome}! 📦

Seu pedido do plano *{plano}* foi enviado pelos Correios.

🔎 Código de rastreio: *{codigo_rastreio}*

Acompanhe em:
https://rastreamento.correios.com.br/app/index.php

Qualquer dúvida estamos à disposição!'::text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT single_row CHECK ((id = 1))
);

DROP TABLE public.whatsapp_template;

GRANT ALL ON TABLE public.whatsapp_template TO anon;
GRANT ALL ON TABLE public.whatsapp_template TO authenticated;
GRANT ALL ON TABLE public.whatsapp_template TO service_role;
GRANT SELECT,INSERT ON TABLE public.whatsapp_template TO sandbox_exec;

CREATE TABLE public.whatsapp_template_carteiro (
    id integer DEFAULT 1 NOT NULL,
    mensagem text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT single_row_carteiro CHECK ((id = 1))
);

DROP TABLE public.whatsapp_template_carteiro;

GRANT ALL ON TABLE public.whatsapp_template_carteiro TO anon;
GRANT ALL ON TABLE public.whatsapp_template_carteiro TO authenticated;
GRANT ALL ON TABLE public.whatsapp_template_carteiro TO service_role;
GRANT SELECT,INSERT ON TABLE public.whatsapp_template_carteiro TO sandbox_exec;

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea
)
PARTITION BY RANGE (inserted_at);

DROP TABLE realtime.messages;

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;

CREATE TABLE realtime.messages_2026_07_12 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);

DROP TABLE realtime.messages_2026_07_12;

GRANT ALL ON TABLE realtime.messages_2026_07_12 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_07_12 TO dashboard_user;

CREATE TABLE realtime.messages_2026_07_13 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);

DROP TABLE realtime.messages_2026_07_13;

GRANT ALL ON TABLE realtime.messages_2026_07_13 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_07_13 TO dashboard_user;

CREATE TABLE realtime.messages_2026_07_14 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);

DROP TABLE realtime.messages_2026_07_14;

GRANT ALL ON TABLE realtime.messages_2026_07_14 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_07_14 TO dashboard_user;

CREATE TABLE realtime.messages_2026_07_15 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);

DROP TABLE realtime.messages_2026_07_15;

GRANT ALL ON TABLE realtime.messages_2026_07_15 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_07_15 TO dashboard_user;

CREATE TABLE realtime.messages_2026_07_16 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);

DROP TABLE realtime.messages_2026_07_16;

GRANT ALL ON TABLE realtime.messages_2026_07_16 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_07_16 TO dashboard_user;

CREATE TABLE realtime.messages_2026_07_17 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);

DROP TABLE realtime.messages_2026_07_17;

GRANT ALL ON TABLE realtime.messages_2026_07_17 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_07_17 TO dashboard_user;

CREATE TABLE realtime.messages_2026_07_18 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea,
    CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL)))
);

DROP TABLE realtime.messages_2026_07_18;

GRANT ALL ON TABLE realtime.messages_2026_07_18 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_07_18 TO dashboard_user;

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);

DROP TABLE realtime.schema_migrations;

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);

DROP TABLE realtime.subscription;

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);

DROP TABLE storage.buckets;

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';

REVOKE ALL ON TABLE storage.buckets FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.buckets TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT,INSERT ON TABLE storage.buckets TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);

DROP TABLE storage.buckets_analytics;

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE storage.buckets_vectors;

GRANT SELECT ON TABLE storage.buckets_vectors TO service_role;
GRANT SELECT ON TABLE storage.buckets_vectors TO authenticated;
GRANT SELECT ON TABLE storage.buckets_vectors TO anon;

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE storage.migrations;

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);

DROP TABLE storage.objects;

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';

REVOKE ALL ON TABLE storage.objects FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.objects TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;
SET SESSION AUTHORIZATION postgres;
GRANT SELECT,INSERT ON TABLE storage.objects TO sandbox_exec;
RESET SESSION AUTHORIZATION;

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);

DROP TABLE storage.s3_multipart_uploads;

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE storage.s3_multipart_uploads_parts;

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

DROP TABLE storage.vector_indexes;

GRANT SELECT ON TABLE storage.vector_indexes TO service_role;
GRANT SELECT ON TABLE storage.vector_indexes TO authenticated;
GRANT SELECT ON TABLE storage.vector_indexes TO anon;

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text,
    created_by text,
    idempotency_key text,
    rollback text[]
);

DROP TABLE supabase_migrations.schema_migrations;

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_07_12 FOR VALUES FROM ('2026-07-12 00:00:00') TO ('2026-07-13 00:00:00');

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_07_13 FOR VALUES FROM ('2026-07-13 00:00:00') TO ('2026-07-14 00:00:00');

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_07_14 FOR VALUES FROM ('2026-07-14 00:00:00') TO ('2026-07-15 00:00:00');

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_07_15 FOR VALUES FROM ('2026-07-15 00:00:00') TO ('2026-07-16 00:00:00');

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_07_16 FOR VALUES FROM ('2026-07-16 00:00:00') TO ('2026-07-17 00:00:00');

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_07_17 FOR VALUES FROM ('2026-07-17 00:00:00') TO ('2026-07-18 00:00:00');

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_07_18 FOR VALUES FROM ('2026-07-18 00:00:00') TO ('2026-07-19 00:00:00');

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);

ALTER TABLE auth.refresh_tokens ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.api_logs ALTER COLUMN id SET DEFAULT nextval('public.api_logs_id_seq'::regclass);

ALTER TABLE public.api_logs ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.braip_vendas_xls ALTER COLUMN id SET DEFAULT nextval('public.braip_vendas_xls_id_seq'::regclass);

ALTER TABLE public.braip_vendas_xls ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.cep_correcao_logs ALTER COLUMN id SET DEFAULT nextval('public.cep_correcao_logs_id_seq'::regclass);

ALTER TABLE public.cep_correcao_logs ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.clientes_envio ALTER COLUMN id SET DEFAULT nextval('public.clientes_envio_id_seq'::regclass);

ALTER TABLE public.clientes_envio ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.correios_api_logs ALTER COLUMN id SET DEFAULT nextval('public.correios_api_logs_id_seq'::regclass);

ALTER TABLE public.correios_api_logs ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.email_envios_log ALTER COLUMN id SET DEFAULT nextval('public.email_envios_log_id_seq'::regclass);

ALTER TABLE public.email_envios_log ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.envios ALTER COLUMN id SET DEFAULT nextval('public.envios_id_seq'::regclass);

ALTER TABLE public.envios ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.monetizze_vendas ALTER COLUMN id SET DEFAULT nextval('public.monetizze_vendas_id_seq'::regclass);

ALTER TABLE public.monetizze_vendas ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.nfe_emissoes ALTER COLUMN id SET DEFAULT nextval('public.nfe_emissoes_id_seq'::regclass);

ALTER TABLE public.nfe_emissoes ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.notificacoes_carteiro_ausente ALTER COLUMN id SET DEFAULT nextval('public.notificacoes_carteiro_ausente_id_seq'::regclass);

ALTER TABLE public.notificacoes_carteiro_ausente ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.pedidos_xls ALTER COLUMN id SET DEFAULT nextval('public.pedidos_xls_id_seq'::regclass);

ALTER TABLE public.pedidos_xls ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.prep_massa_logs ALTER COLUMN id SET DEFAULT nextval('public.prep_massa_logs_id_seq'::regclass);

ALTER TABLE public.prep_massa_logs ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.prepostagem_auto_logs ALTER COLUMN id SET DEFAULT nextval('public.prepostagem_auto_logs_id_seq'::regclass);

ALTER TABLE public.prepostagem_auto_logs ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.prepostagens ALTER COLUMN id SET DEFAULT nextval('public.prepostagens_id_seq'::regclass);

ALTER TABLE public.prepostagens ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.prepostagens_ppn ALTER COLUMN id SET DEFAULT nextval('public.prepostagens_ppn_id_seq'::regclass);

ALTER TABLE public.prepostagens_ppn ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.produto_regras ALTER COLUMN id SET DEFAULT nextval('public.produto_regras_id_seq'::regclass);

ALTER TABLE public.produto_regras ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.reenvios ALTER COLUMN id SET DEFAULT nextval('public.reenvios_id_seq'::regclass);

ALTER TABLE public.reenvios ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.sislogica_envios_log ALTER COLUMN id SET DEFAULT nextval('public.sislogica_envios_log_id_seq'::regclass);

ALTER TABLE public.sislogica_envios_log ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.vendas_ml ALTER COLUMN id SET DEFAULT nextval('public.vendas_ml_id_seq'::regclass);

ALTER TABLE public.vendas_ml ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.vhsys_estoque_movimentos ALTER COLUMN id SET DEFAULT nextval('public.vhsys_estoque_movimentos_id_seq'::regclass);

ALTER TABLE public.vhsys_estoque_movimentos ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.webhook_logs ALTER COLUMN id SET DEFAULT nextval('public.webhook_logs_id_seq'::regclass);

ALTER TABLE public.webhook_logs ALTER COLUMN id DROP DEFAULT;

ALTER TABLE ONLY public.whatsapp_envios_log ALTER COLUMN id SET DEFAULT nextval('public.whatsapp_envios_log_id_seq'::regclass);

ALTER TABLE public.whatsapp_envios_log ALTER COLUMN id DROP DEFAULT;

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 2189, true);

SELECT pg_catalog.setval('cron.jobid_seq', 17, true);

SELECT pg_catalog.setval('cron.runid_seq', 83269, true);

SELECT pg_catalog.setval('public.api_logs_id_seq', 98096, true);

SELECT pg_catalog.setval('public.braip_vendas_xls_id_seq', 564, true);

SELECT pg_catalog.setval('public.cep_correcao_logs_id_seq', 8, true);

SELECT pg_catalog.setval('public.clientes_envio_id_seq', 510, true);

SELECT pg_catalog.setval('public.correios_api_logs_id_seq', 47, true);

SELECT pg_catalog.setval('public.email_envios_log_id_seq', 3220, true);

SELECT pg_catalog.setval('public.envios_id_seq', 2563, true);

SELECT pg_catalog.setval('public.monetizze_vendas_id_seq', 7825, true);

SELECT pg_catalog.setval('public.nfe_emissoes_id_seq', 1818, true);

SELECT pg_catalog.setval('public.notificacoes_carteiro_ausente_id_seq', 1, false);

SELECT pg_catalog.setval('public.pedidos_xls_id_seq', 5428, true);

SELECT pg_catalog.setval('public.prep_massa_logs_id_seq', 90, true);

SELECT pg_catalog.setval('public.prepostagem_auto_logs_id_seq', 2150, true);

SELECT pg_catalog.setval('public.prepostagens_id_seq', 1234, true);

SELECT pg_catalog.setval('public.prepostagens_ppn_id_seq', 233552, true);

SELECT pg_catalog.setval('public.produto_regras_id_seq', 21, true);

SELECT pg_catalog.setval('public.reenvios_id_seq', 3, true);

SELECT pg_catalog.setval('public.sislogica_envios_log_id_seq', 2947, true);

SELECT pg_catalog.setval('public.vendas_ml_id_seq', 38, true);

SELECT pg_catalog.setval('public.vhsys_estoque_movimentos_id_seq', 33, true);

SELECT pg_catalog.setval('public.webhook_logs_id_seq', 22133, true);

SELECT pg_catalog.setval('public.whatsapp_envios_log_id_seq', 104, true);

SELECT pg_catalog.setval('realtime.subscription_id_seq', 26017, true);

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);

ALTER TABLE ONLY auth.mfa_amr_claims DROP CONSTRAINT amr_id_pk;

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.audit_log_entries DROP CONSTRAINT audit_log_entries_pkey;

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);

ALTER TABLE ONLY auth.custom_oauth_providers DROP CONSTRAINT custom_oauth_providers_identifier_key;

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.custom_oauth_providers DROP CONSTRAINT custom_oauth_providers_pkey;

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.flow_state DROP CONSTRAINT flow_state_pkey;

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.identities DROP CONSTRAINT identities_pkey;

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);

ALTER TABLE ONLY auth.identities DROP CONSTRAINT identities_provider_id_provider_unique;

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.instances DROP CONSTRAINT instances_pkey;

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);

ALTER TABLE ONLY auth.mfa_amr_claims DROP CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey;

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.mfa_challenges DROP CONSTRAINT mfa_challenges_pkey;

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);

ALTER TABLE ONLY auth.mfa_factors DROP CONSTRAINT mfa_factors_last_challenged_at_key;

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.mfa_factors DROP CONSTRAINT mfa_factors_pkey;

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);

ALTER TABLE ONLY auth.oauth_authorizations DROP CONSTRAINT oauth_authorizations_authorization_code_key;

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);

ALTER TABLE ONLY auth.oauth_authorizations DROP CONSTRAINT oauth_authorizations_authorization_id_key;

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.oauth_authorizations DROP CONSTRAINT oauth_authorizations_pkey;

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.oauth_client_states DROP CONSTRAINT oauth_client_states_pkey;

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.oauth_clients DROP CONSTRAINT oauth_clients_pkey;

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.oauth_consents DROP CONSTRAINT oauth_consents_pkey;

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);

ALTER TABLE ONLY auth.oauth_consents DROP CONSTRAINT oauth_consents_user_client_unique;

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.one_time_tokens DROP CONSTRAINT one_time_tokens_pkey;

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.refresh_tokens DROP CONSTRAINT refresh_tokens_pkey;

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);

ALTER TABLE ONLY auth.refresh_tokens DROP CONSTRAINT refresh_tokens_token_unique;

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);

ALTER TABLE ONLY auth.saml_providers DROP CONSTRAINT saml_providers_entity_id_key;

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.saml_providers DROP CONSTRAINT saml_providers_pkey;

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.saml_relay_states DROP CONSTRAINT saml_relay_states_pkey;

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

ALTER TABLE ONLY auth.schema_migrations DROP CONSTRAINT schema_migrations_pkey;

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.sessions DROP CONSTRAINT sessions_pkey;

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.sso_domains DROP CONSTRAINT sso_domains_pkey;

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.sso_providers DROP CONSTRAINT sso_providers_pkey;

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);

ALTER TABLE ONLY auth.users DROP CONSTRAINT users_phone_key;

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.users DROP CONSTRAINT users_pkey;

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.webauthn_challenges DROP CONSTRAINT webauthn_challenges_pkey;

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.webauthn_credentials DROP CONSTRAINT webauthn_credentials_pkey;

ALTER TABLE ONLY public.api_logs
    ADD CONSTRAINT api_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.api_logs DROP CONSTRAINT api_logs_pkey;

ALTER TABLE ONLY public.appmax_split_config
    ADD CONSTRAINT appmax_split_config_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.appmax_split_config DROP CONSTRAINT appmax_split_config_pkey;

ALTER TABLE ONLY public.appmax_split_logs
    ADD CONSTRAINT appmax_split_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.appmax_split_logs DROP CONSTRAINT appmax_split_logs_pkey;

ALTER TABLE ONLY public.braip_vendas_xls
    ADD CONSTRAINT braip_vendas_xls_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.braip_vendas_xls DROP CONSTRAINT braip_vendas_xls_pkey;

ALTER TABLE ONLY public.cep_correcao_logs
    ADD CONSTRAINT cep_correcao_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.cep_correcao_logs DROP CONSTRAINT cep_correcao_logs_pkey;

ALTER TABLE ONLY public.clientes_envio
    ADD CONSTRAINT clientes_envio_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.clientes_envio DROP CONSTRAINT clientes_envio_pkey;

ALTER TABLE ONLY public.conferencias_postagem
    ADD CONSTRAINT conferencias_postagem_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.conferencias_postagem DROP CONSTRAINT conferencias_postagem_pkey;

ALTER TABLE ONLY public.contratos_logisticos
    ADD CONSTRAINT contratos_logisticos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.contratos_logisticos DROP CONSTRAINT contratos_logisticos_pkey;

ALTER TABLE ONLY public.coproducao_auditoria
    ADD CONSTRAINT coproducao_auditoria_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coproducao_auditoria DROP CONSTRAINT coproducao_auditoria_pkey;

ALTER TABLE ONLY public.coproducao_configuracoes
    ADD CONSTRAINT coproducao_configuracoes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coproducao_configuracoes DROP CONSTRAINT coproducao_configuracoes_pkey;

ALTER TABLE ONLY public.coproducao_regras
    ADD CONSTRAINT coproducao_regras_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coproducao_regras DROP CONSTRAINT coproducao_regras_pkey;

ALTER TABLE ONLY public.coproducao_repasse_itens
    ADD CONSTRAINT coproducao_repasse_itens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coproducao_repasse_itens DROP CONSTRAINT coproducao_repasse_itens_pkey;

ALTER TABLE ONLY public.coproducao_repasse_itens
    ADD CONSTRAINT coproducao_repasse_itens_repasse_id_venda_id_key UNIQUE (repasse_id, venda_id);

ALTER TABLE ONLY public.coproducao_repasse_itens DROP CONSTRAINT coproducao_repasse_itens_repasse_id_venda_id_key;

ALTER TABLE ONLY public.coproducao_repasses
    ADD CONSTRAINT coproducao_repasses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coproducao_repasses DROP CONSTRAINT coproducao_repasses_pkey;

ALTER TABLE ONLY public.coproducao_vendas
    ADD CONSTRAINT coproducao_vendas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coproducao_vendas DROP CONSTRAINT coproducao_vendas_pkey;

ALTER TABLE ONLY public.coproducao_webhook_logs
    ADD CONSTRAINT coproducao_webhook_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coproducao_webhook_logs DROP CONSTRAINT coproducao_webhook_logs_pkey;

ALTER TABLE ONLY public.coprodutores
    ADD CONSTRAINT coprodutores_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.coprodutores DROP CONSTRAINT coprodutores_pkey;

ALTER TABLE ONLY public.correios_api_logs
    ADD CONSTRAINT correios_api_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.correios_api_logs DROP CONSTRAINT correios_api_logs_pkey;

ALTER TABLE ONLY public.correios_token_cache
    ADD CONSTRAINT correios_token_cache_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.correios_token_cache DROP CONSTRAINT correios_token_cache_pkey;

ALTER TABLE ONLY public.email_envios_log
    ADD CONSTRAINT email_envios_log_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.email_envios_log DROP CONSTRAINT email_envios_log_pkey;

ALTER TABLE ONLY public.email_template_rastreio
    ADD CONSTRAINT email_template_rastreio_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.email_template_rastreio DROP CONSTRAINT email_template_rastreio_pkey;

ALTER TABLE ONLY public.envios
    ADD CONSTRAINT envios_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.envios DROP CONSTRAINT envios_pkey;

ALTER TABLE ONLY public.estoque_baixa_config
    ADD CONSTRAINT estoque_baixa_config_pkey PRIMARY KEY (produtor_id);

ALTER TABLE ONLY public.estoque_baixa_config DROP CONSTRAINT estoque_baixa_config_pkey;

ALTER TABLE ONLY public.estoque_locais
    ADD CONSTRAINT estoque_locais_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.estoque_locais DROP CONSTRAINT estoque_locais_pkey;

ALTER TABLE ONLY public.estoque_locais
    ADD CONSTRAINT estoque_locais_produtor_id_nome_key UNIQUE (produtor_id, nome);

ALTER TABLE ONLY public.estoque_locais DROP CONSTRAINT estoque_locais_produtor_id_nome_key;

ALTER TABLE ONLY public.estoque_movimentos
    ADD CONSTRAINT estoque_movimentos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.estoque_movimentos DROP CONSTRAINT estoque_movimentos_pkey;

ALTER TABLE ONLY public.estoque_produtos
    ADD CONSTRAINT estoque_produtos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.estoque_produtos DROP CONSTRAINT estoque_produtos_pkey;

ALTER TABLE ONLY public.estoque_produtos
    ADD CONSTRAINT estoque_produtos_produtor_id_codigo_key UNIQUE (produtor_id, codigo);

ALTER TABLE ONLY public.estoque_produtos DROP CONSTRAINT estoque_produtos_produtor_id_codigo_key;

ALTER TABLE ONLY public.ml_tokens
    ADD CONSTRAINT ml_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.ml_tokens DROP CONSTRAINT ml_tokens_pkey;

ALTER TABLE ONLY public.monetizze_vendas
    ADD CONSTRAINT monetizze_vendas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.monetizze_vendas DROP CONSTRAINT monetizze_vendas_pkey;

ALTER TABLE ONLY public.nfe_baixa_estoque_config
    ADD CONSTRAINT nfe_baixa_estoque_config_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.nfe_baixa_estoque_config DROP CONSTRAINT nfe_baixa_estoque_config_pkey;

ALTER TABLE ONLY public.nfe_baixa_estoque_config
    ADD CONSTRAINT nfe_baixa_estoque_config_produtor_id_produto_codigo_key UNIQUE (produtor_id, produto_codigo);

ALTER TABLE ONLY public.nfe_baixa_estoque_config DROP CONSTRAINT nfe_baixa_estoque_config_produtor_id_produto_codigo_key;

ALTER TABLE ONLY public.nfe_emissoes
    ADD CONSTRAINT nfe_emissoes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.nfe_emissoes DROP CONSTRAINT nfe_emissoes_pkey;

ALTER TABLE ONLY public.notificacoes_carteiro_ausente
    ADD CONSTRAINT notificacoes_carteiro_ausente_codigo_objeto_evento_data_key UNIQUE (codigo_objeto, evento_data);

ALTER TABLE ONLY public.notificacoes_carteiro_ausente DROP CONSTRAINT notificacoes_carteiro_ausente_codigo_objeto_evento_data_key;

ALTER TABLE ONLY public.notificacoes_carteiro_ausente
    ADD CONSTRAINT notificacoes_carteiro_ausente_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.notificacoes_carteiro_ausente DROP CONSTRAINT notificacoes_carteiro_ausente_pkey;

ALTER TABLE ONLY public.pedido_regra_logs
    ADD CONSTRAINT pedido_regra_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.pedido_regra_logs DROP CONSTRAINT pedido_regra_logs_pkey;

ALTER TABLE ONLY public.pedidos_importados
    ADD CONSTRAINT pedidos_importados_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.pedidos_importados DROP CONSTRAINT pedidos_importados_pkey;

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.pedidos DROP CONSTRAINT pedidos_pkey;

ALTER TABLE ONLY public.pedidos_xls
    ADD CONSTRAINT pedidos_xls_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.pedidos_xls DROP CONSTRAINT pedidos_xls_pkey;

ALTER TABLE ONLY public.prep_massa_logs
    ADD CONSTRAINT prep_massa_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.prep_massa_logs DROP CONSTRAINT prep_massa_logs_pkey;

ALTER TABLE ONLY public.prepostagem_auto_logs
    ADD CONSTRAINT prepostagem_auto_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.prepostagem_auto_logs DROP CONSTRAINT prepostagem_auto_logs_pkey;

ALTER TABLE ONLY public.prepostagens
    ADD CONSTRAINT prepostagens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.prepostagens DROP CONSTRAINT prepostagens_pkey;

ALTER TABLE ONLY public.prepostagens_ppn
    ADD CONSTRAINT prepostagens_ppn_id_prepostagem_key UNIQUE (id_prepostagem);

ALTER TABLE ONLY public.prepostagens_ppn DROP CONSTRAINT prepostagens_ppn_id_prepostagem_key;

ALTER TABLE ONLY public.prepostagens_ppn
    ADD CONSTRAINT prepostagens_ppn_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.prepostagens_ppn DROP CONSTRAINT prepostagens_ppn_pkey;

ALTER TABLE ONLY public.produto_precos
    ADD CONSTRAINT produto_precos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produto_precos DROP CONSTRAINT produto_precos_pkey;

ALTER TABLE ONLY public.produto_regras
    ADD CONSTRAINT produto_regras_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produto_regras DROP CONSTRAINT produto_regras_pkey;

ALTER TABLE ONLY public.produtor_api_keys
    ADD CONSTRAINT produtor_api_keys_key_hash_key UNIQUE (key_hash);

ALTER TABLE ONLY public.produtor_api_keys DROP CONSTRAINT produtor_api_keys_key_hash_key;

ALTER TABLE ONLY public.produtor_api_keys
    ADD CONSTRAINT produtor_api_keys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_api_keys DROP CONSTRAINT produtor_api_keys_pkey;

ALTER TABLE ONLY public.produtor_frete_faixas
    ADD CONSTRAINT produtor_frete_faixas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_frete_faixas DROP CONSTRAINT produtor_frete_faixas_pkey;

ALTER TABLE ONLY public.produtor_peso_faixas
    ADD CONSTRAINT produtor_peso_faixas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_peso_faixas DROP CONSTRAINT produtor_peso_faixas_pkey;

ALTER TABLE ONLY public.produtor_planos
    ADD CONSTRAINT produtor_planos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_planos DROP CONSTRAINT produtor_planos_pkey;

ALTER TABLE ONLY public.produtor_produto_precos
    ADD CONSTRAINT produtor_produto_precos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_produto_precos DROP CONSTRAINT produtor_produto_precos_pkey;

ALTER TABLE ONLY public.produtor_produto_precos
    ADD CONSTRAINT produtor_produto_precos_produtor_id_produto_codigo_key UNIQUE (produtor_id, produto_codigo);

ALTER TABLE ONLY public.produtor_produto_precos DROP CONSTRAINT produtor_produto_precos_produtor_id_produto_codigo_key;

ALTER TABLE ONLY public.produtor_usuarios
    ADD CONSTRAINT produtor_usuarios_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_usuarios DROP CONSTRAINT produtor_usuarios_pkey;

ALTER TABLE ONLY public.produtor_usuarios
    ADD CONSTRAINT produtor_usuarios_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.produtor_usuarios DROP CONSTRAINT produtor_usuarios_user_id_key;

ALTER TABLE ONLY public.produtor_webhook_entregas
    ADD CONSTRAINT produtor_webhook_entregas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_webhook_entregas DROP CONSTRAINT produtor_webhook_entregas_pkey;

ALTER TABLE ONLY public.produtor_webhooks
    ADD CONSTRAINT produtor_webhooks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtor_webhooks DROP CONSTRAINT produtor_webhooks_pkey;

ALTER TABLE ONLY public.produtores_integracao
    ADD CONSTRAINT produtores_integracao_correios_webhook_token_key UNIQUE (correios_webhook_secret);

ALTER TABLE ONLY public.produtores_integracao DROP CONSTRAINT produtores_integracao_correios_webhook_token_key;

ALTER TABLE ONLY public.produtores_integracao
    ADD CONSTRAINT produtores_integracao_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.produtores_integracao DROP CONSTRAINT produtores_integracao_pkey;

ALTER TABLE ONLY public.produtores_integracao
    ADD CONSTRAINT produtores_integracao_webhook_token_key UNIQUE (webhook_token);

ALTER TABLE ONLY public.produtores_integracao DROP CONSTRAINT produtores_integracao_webhook_token_key;

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_pkey;

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_user_id_key;

ALTER TABLE ONLY public.reenvio_pagamentos
    ADD CONSTRAINT reenvio_pagamentos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.reenvio_pagamentos DROP CONSTRAINT reenvio_pagamentos_pkey;

ALTER TABLE ONLY public.reenvios
    ADD CONSTRAINT reenvios_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.reenvios DROP CONSTRAINT reenvios_pkey;

ALTER TABLE ONLY public.registro_estoque
    ADD CONSTRAINT registro_estoque_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.registro_estoque DROP CONSTRAINT registro_estoque_pkey;

ALTER TABLE ONLY public.regras_logisticas
    ADD CONSTRAINT regras_logisticas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.regras_logisticas DROP CONSTRAINT regras_logisticas_pkey;

ALTER TABLE ONLY public.remetente_config
    ADD CONSTRAINT remetente_config_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.remetente_config DROP CONSTRAINT remetente_config_pkey;

ALTER TABLE ONLY public.sislog_remetentes
    ADD CONSTRAINT sislog_remetentes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sislog_remetentes DROP CONSTRAINT sislog_remetentes_pkey;

ALTER TABLE ONLY public.sislogica_envios_log
    ADD CONSTRAINT sislogica_envios_log_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sislogica_envios_log DROP CONSTRAINT sislogica_envios_log_pkey;

ALTER TABLE ONLY public.sislogica_webhook_recebidos
    ADD CONSTRAINT sislogica_webhook_recebidos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sislogica_webhook_recebidos DROP CONSTRAINT sislogica_webhook_recebidos_pkey;

ALTER TABLE ONLY public.sislogica_webhook_tokens
    ADD CONSTRAINT sislogica_webhook_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sislogica_webhook_tokens DROP CONSTRAINT sislogica_webhook_tokens_pkey;

ALTER TABLE ONLY public.sislogica_webhook_tokens
    ADD CONSTRAINT sislogica_webhook_tokens_token_key UNIQUE (token);

ALTER TABLE ONLY public.sislogica_webhook_tokens DROP CONSTRAINT sislogica_webhook_tokens_token_key;

ALTER TABLE ONLY public.tracking_events
    ADD CONSTRAINT tracking_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.tracking_events DROP CONSTRAINT tracking_events_pkey;

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_pkey;

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);

ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_user_id_role_key;

ALTER TABLE ONLY public.vendas_ml
    ADD CONSTRAINT vendas_ml_ml_order_id_key UNIQUE (ml_order_id);

ALTER TABLE ONLY public.vendas_ml DROP CONSTRAINT vendas_ml_ml_order_id_key;

ALTER TABLE ONLY public.vendas_ml
    ADD CONSTRAINT vendas_ml_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.vendas_ml DROP CONSTRAINT vendas_ml_pkey;

ALTER TABLE ONLY public.vhsys_estoque_movimentos
    ADD CONSTRAINT vhsys_estoque_movimentos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.vhsys_estoque_movimentos DROP CONSTRAINT vhsys_estoque_movimentos_pkey;

ALTER TABLE ONLY public.vhsys_estoque_saldos
    ADD CONSTRAINT vhsys_estoque_saldos_pkey PRIMARY KEY (produto_vhsys_id);

ALTER TABLE ONLY public.vhsys_estoque_saldos DROP CONSTRAINT vhsys_estoque_saldos_pkey;

ALTER TABLE ONLY public.vhsys_locais_estoque
    ADD CONSTRAINT vhsys_locais_estoque_pkey PRIMARY KEY (id_local_estoque);

ALTER TABLE ONLY public.vhsys_locais_estoque DROP CONSTRAINT vhsys_locais_estoque_pkey;

ALTER TABLE ONLY public.webhook_logs
    ADD CONSTRAINT webhook_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.webhook_logs DROP CONSTRAINT webhook_logs_pkey;

ALTER TABLE ONLY public.whatsapp_envios_log
    ADD CONSTRAINT whatsapp_envios_log_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.whatsapp_envios_log DROP CONSTRAINT whatsapp_envios_log_pkey;

ALTER TABLE ONLY public.whatsapp_template_carteiro
    ADD CONSTRAINT whatsapp_template_carteiro_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.whatsapp_template_carteiro DROP CONSTRAINT whatsapp_template_carteiro_pkey;

ALTER TABLE ONLY public.whatsapp_template
    ADD CONSTRAINT whatsapp_template_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.whatsapp_template DROP CONSTRAINT whatsapp_template_pkey;

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages DROP CONSTRAINT messages_pkey;

ALTER TABLE ONLY realtime.messages_2026_07_12
    ADD CONSTRAINT messages_2026_07_12_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages_2026_07_12 DROP CONSTRAINT messages_2026_07_12_pkey;

ALTER TABLE ONLY realtime.messages_2026_07_13
    ADD CONSTRAINT messages_2026_07_13_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages_2026_07_13 DROP CONSTRAINT messages_2026_07_13_pkey;

ALTER TABLE ONLY realtime.messages_2026_07_14
    ADD CONSTRAINT messages_2026_07_14_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages_2026_07_14 DROP CONSTRAINT messages_2026_07_14_pkey;

ALTER TABLE ONLY realtime.messages_2026_07_15
    ADD CONSTRAINT messages_2026_07_15_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages_2026_07_15 DROP CONSTRAINT messages_2026_07_15_pkey;

ALTER TABLE ONLY realtime.messages_2026_07_16
    ADD CONSTRAINT messages_2026_07_16_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages_2026_07_16 DROP CONSTRAINT messages_2026_07_16_pkey;

ALTER TABLE ONLY realtime.messages_2026_07_17
    ADD CONSTRAINT messages_2026_07_17_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages_2026_07_17 DROP CONSTRAINT messages_2026_07_17_pkey;

ALTER TABLE ONLY realtime.messages_2026_07_18
    ADD CONSTRAINT messages_2026_07_18_pkey PRIMARY KEY (id, inserted_at);

ALTER TABLE ONLY realtime.messages_2026_07_18 DROP CONSTRAINT messages_2026_07_18_pkey;

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;

ALTER TABLE realtime.messages DROP CONSTRAINT messages_payload_exclusive;

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);

ALTER TABLE ONLY realtime.subscription DROP CONSTRAINT pk_subscription;

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

ALTER TABLE ONLY realtime.schema_migrations DROP CONSTRAINT schema_migrations_pkey;

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.buckets_analytics DROP CONSTRAINT buckets_analytics_pkey;

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.buckets DROP CONSTRAINT buckets_pkey;

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.buckets_vectors DROP CONSTRAINT buckets_vectors_pkey;

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);

ALTER TABLE ONLY storage.migrations DROP CONSTRAINT migrations_name_key;

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.migrations DROP CONSTRAINT migrations_pkey;

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.objects DROP CONSTRAINT objects_pkey;

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT s3_multipart_uploads_parts_pkey;

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.s3_multipart_uploads DROP CONSTRAINT s3_multipart_uploads_pkey;

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY storage.vector_indexes DROP CONSTRAINT vector_indexes_pkey;

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_idempotency_key_key UNIQUE (idempotency_key);

ALTER TABLE ONLY supabase_migrations.schema_migrations DROP CONSTRAINT schema_migrations_idempotency_key_key;

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

ALTER TABLE ONLY supabase_migrations.schema_migrations DROP CONSTRAINT schema_migrations_pkey;

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);

DROP INDEX auth.audit_logs_instance_id_idx;

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);

DROP INDEX auth.confirmation_token_idx;

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);

DROP INDEX auth.custom_oauth_providers_created_at_idx;

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);

DROP INDEX auth.custom_oauth_providers_enabled_idx;

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);

DROP INDEX auth.custom_oauth_providers_identifier_idx;

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);

DROP INDEX auth.custom_oauth_providers_provider_type_idx;

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);

DROP INDEX auth.email_change_token_current_idx;

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);

DROP INDEX auth.email_change_token_new_idx;

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);

DROP INDEX auth.factor_id_created_at_idx;

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);

DROP INDEX auth.flow_state_created_at_idx;

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);

DROP INDEX auth.identities_email_idx;

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);

DROP INDEX auth.identities_user_id_idx;

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);

DROP INDEX auth.idx_auth_code;

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);

DROP INDEX auth.idx_oauth_client_states_created_at;

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);

DROP INDEX auth.idx_user_id_auth_method;

CREATE INDEX idx_users_created_at_desc ON auth.users USING btree (created_at DESC);

DROP INDEX auth.idx_users_created_at_desc;

CREATE INDEX idx_users_email ON auth.users USING btree (email);

DROP INDEX auth.idx_users_email;

CREATE INDEX idx_users_last_sign_in_at_desc ON auth.users USING btree (last_sign_in_at DESC);

DROP INDEX auth.idx_users_last_sign_in_at_desc;

CREATE INDEX idx_users_name ON auth.users USING btree (((raw_user_meta_data ->> 'name'::text))) WHERE ((raw_user_meta_data ->> 'name'::text) IS NOT NULL);

DROP INDEX auth.idx_users_name;

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);

DROP INDEX auth.mfa_challenge_created_at_idx;

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);

DROP INDEX auth.mfa_factors_user_friendly_name_unique;

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);

DROP INDEX auth.mfa_factors_user_id_idx;

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);

DROP INDEX auth.oauth_auth_pending_exp_idx;

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);

DROP INDEX auth.oauth_clients_deleted_at_idx;

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);

DROP INDEX auth.oauth_consents_active_client_idx;

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);

DROP INDEX auth.oauth_consents_active_user_client_idx;

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);

DROP INDEX auth.oauth_consents_user_order_idx;

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);

DROP INDEX auth.one_time_tokens_relates_to_hash_idx;

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);

DROP INDEX auth.one_time_tokens_token_hash_hash_idx;

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);

DROP INDEX auth.one_time_tokens_user_id_token_type_key;

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);

DROP INDEX auth.reauthentication_token_idx;

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);

DROP INDEX auth.recovery_token_idx;

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);

DROP INDEX auth.refresh_tokens_instance_id_idx;

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);

DROP INDEX auth.refresh_tokens_instance_id_user_id_idx;

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);

DROP INDEX auth.refresh_tokens_parent_idx;

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);

DROP INDEX auth.refresh_tokens_session_id_revoked_idx;

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);

DROP INDEX auth.refresh_tokens_updated_at_idx;

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);

DROP INDEX auth.saml_providers_sso_provider_id_idx;

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);

DROP INDEX auth.saml_relay_states_created_at_idx;

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);

DROP INDEX auth.saml_relay_states_for_email_idx;

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);

DROP INDEX auth.saml_relay_states_sso_provider_id_idx;

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);

DROP INDEX auth.sessions_not_after_idx;

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);

DROP INDEX auth.sessions_oauth_client_id_idx;

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);

DROP INDEX auth.sessions_user_id_idx;

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));

DROP INDEX auth.sso_domains_domain_idx;

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);

DROP INDEX auth.sso_domains_sso_provider_id_idx;

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));

DROP INDEX auth.sso_providers_resource_id_idx;

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);

DROP INDEX auth.sso_providers_resource_id_pattern_idx;

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);

DROP INDEX auth.unique_phone_factor_per_user;

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);

DROP INDEX auth.user_id_created_at_idx;

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);

DROP INDEX auth.users_email_partial_key;

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));

DROP INDEX auth.users_instance_id_email_idx;

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);

DROP INDEX auth.users_instance_id_idx;

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);

DROP INDEX auth.users_is_anonymous_idx;

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);

DROP INDEX auth.webauthn_challenges_expires_at_idx;

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);

DROP INDEX auth.webauthn_challenges_user_id_idx;

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);

DROP INDEX auth.webauthn_credentials_credential_id_key;

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);

DROP INDEX auth.webauthn_credentials_user_id_idx;

CREATE INDEX email_envios_log_venda_id_idx ON public.email_envios_log USING btree (venda_id);

DROP INDEX public.email_envios_log_venda_id_idx;

CREATE INDEX idx_api_logs_created_at ON public.api_logs USING btree (created_at DESC);

DROP INDEX public.idx_api_logs_created_at;

CREATE INDEX idx_api_logs_tipo ON public.api_logs USING btree (tipo);

DROP INDEX public.idx_api_logs_tipo;

CREATE INDEX idx_appmax_split_logs_codigo_venda ON public.appmax_split_logs USING btree (codigo_venda);

DROP INDEX public.idx_appmax_split_logs_codigo_venda;

CREATE INDEX idx_appmax_split_logs_created_at ON public.appmax_split_logs USING btree (created_at DESC);

DROP INDEX public.idx_appmax_split_logs_created_at;

CREATE INDEX idx_appmax_split_logs_order_id ON public.appmax_split_logs USING btree (appmax_order_id);

DROP INDEX public.idx_appmax_split_logs_order_id;

CREATE INDEX idx_appmax_split_logs_status ON public.appmax_split_logs USING btree (split_status, created_at DESC);

DROP INDEX public.idx_appmax_split_logs_status;

CREATE INDEX idx_audit_entidade ON public.coproducao_auditoria USING btree (entidade, entidade_id);

DROP INDEX public.idx_audit_entidade;

CREATE INDEX idx_braip_vendas_xls_arquivo ON public.braip_vendas_xls USING btree (arquivo_origem);

DROP INDEX public.idx_braip_vendas_xls_arquivo;

CREATE UNIQUE INDEX idx_braip_vendas_xls_chave ON public.braip_vendas_xls USING btree (chave) WHERE (chave IS NOT NULL);

DROP INDEX public.idx_braip_vendas_xls_chave;

CREATE INDEX idx_braip_vendas_xls_rastreio ON public.braip_vendas_xls USING btree (codigo_rastreio);

DROP INDEX public.idx_braip_vendas_xls_rastreio;

CREATE INDEX idx_cep_correcao_logs_created_at ON public.cep_correcao_logs USING btree (created_at DESC);

DROP INDEX public.idx_cep_correcao_logs_created_at;

CREATE INDEX idx_cep_correcao_logs_produtor ON public.cep_correcao_logs USING btree (produtor_id);

DROP INDEX public.idx_cep_correcao_logs_produtor;

CREATE INDEX idx_clientes_envio_nome_trgm ON public.clientes_envio USING gin (nome public.gin_trgm_ops);

DROP INDEX public.idx_clientes_envio_nome_trgm;

CREATE INDEX idx_clientes_envio_rastreio ON public.clientes_envio USING btree (codigo_rastreio);

DROP INDEX public.idx_clientes_envio_rastreio;

CREATE INDEX idx_clientes_envio_telefone ON public.clientes_envio USING btree (telefone);

DROP INDEX public.idx_clientes_envio_telefone;

CREATE INDEX idx_conferencias_postagem_user ON public.conferencias_postagem USING btree (user_id, created_at DESC);

DROP INDEX public.idx_conferencias_postagem_user;

CREATE INDEX idx_contratos_logisticos_produtor ON public.contratos_logisticos USING btree (produtor_id, ativo);

DROP INDEX public.idx_contratos_logisticos_produtor;

CREATE INDEX idx_correios_api_logs_created ON public.correios_api_logs USING btree (created_at DESC);

DROP INDEX public.idx_correios_api_logs_created;

CREATE INDEX idx_email_envios_log_codigo ON public.email_envios_log USING btree (codigo_rastreio);

DROP INDEX public.idx_email_envios_log_codigo;

CREATE INDEX idx_email_envios_log_created ON public.email_envios_log USING btree (created_at DESC);

DROP INDEX public.idx_email_envios_log_created;

CREATE INDEX idx_email_envios_log_email ON public.email_envios_log USING btree (email);

DROP INDEX public.idx_email_envios_log_email;

CREATE INDEX idx_envios_cep ON public.envios USING btree (cep);

DROP INDEX public.idx_envios_cep;

CREATE INDEX idx_envios_codigo_rastreio ON public.envios USING btree (codigo_rastreio);

DROP INDEX public.idx_envios_codigo_rastreio;

CREATE INDEX idx_envios_created_at ON public.envios USING btree (created_at DESC);

DROP INDEX public.idx_envios_created_at;

CREATE INDEX idx_envios_nome_lower ON public.envios USING btree (lower(nome));

DROP INDEX public.idx_envios_nome_lower;

CREATE INDEX idx_envios_nome_trgm ON public.envios USING gin (nome public.gin_trgm_ops);

DROP INDEX public.idx_envios_nome_trgm;

CREATE INDEX idx_envios_pdf_nome ON public.envios USING btree (pdf_nome);

DROP INDEX public.idx_envios_pdf_nome;

CREATE INDEX idx_estoque_locais_produtor ON public.estoque_locais USING btree (produtor_id);

DROP INDEX public.idx_estoque_locais_produtor;

CREATE INDEX idx_estoque_mov_created ON public.estoque_movimentos USING btree (created_at DESC);

DROP INDEX public.idx_estoque_mov_created;

CREATE INDEX idx_estoque_mov_local ON public.estoque_movimentos USING btree (local_id);

DROP INDEX public.idx_estoque_mov_local;

CREATE INDEX idx_estoque_mov_produto ON public.estoque_movimentos USING btree (produto_id);

DROP INDEX public.idx_estoque_mov_produto;

CREATE INDEX idx_estoque_mov_produtor ON public.estoque_movimentos USING btree (produtor_id);

DROP INDEX public.idx_estoque_mov_produtor;

CREATE INDEX idx_estoque_produtos_nome ON public.estoque_produtos USING gin (nome public.gin_trgm_ops);

DROP INDEX public.idx_estoque_produtos_nome;

CREATE INDEX idx_estoque_produtos_produtor ON public.estoque_produtos USING btree (produtor_id);

DROP INDEX public.idx_estoque_produtos_produtor;

CREATE INDEX idx_monetizze_codigo_venda ON public.monetizze_vendas USING btree (codigo_venda);

DROP INDEX public.idx_monetizze_codigo_venda;

CREATE INDEX idx_monetizze_created ON public.monetizze_vendas USING btree (created_at DESC);

DROP INDEX public.idx_monetizze_created;

CREATE INDEX idx_monetizze_email ON public.monetizze_vendas USING btree (comprador_email);

DROP INDEX public.idx_monetizze_email;

CREATE INDEX idx_monetizze_status ON public.monetizze_vendas USING btree (status);

DROP INDEX public.idx_monetizze_status;

CREATE INDEX idx_monetizze_vendas_origem_webhook ON public.monetizze_vendas USING btree (origem_webhook);

DROP INDEX public.idx_monetizze_vendas_origem_webhook;

CREATE INDEX idx_monetizze_vendas_plataforma_codigo ON public.monetizze_vendas USING btree (plataforma, codigo_venda);

DROP INDEX public.idx_monetizze_vendas_plataforma_codigo;

CREATE INDEX idx_monetizze_vendas_plataforma_created ON public.monetizze_vendas USING btree (plataforma, created_at DESC);

DROP INDEX public.idx_monetizze_vendas_plataforma_created;

CREATE INDEX idx_monetizze_vendas_produtor ON public.monetizze_vendas USING btree (produtor_id);

DROP INDEX public.idx_monetizze_vendas_produtor;

CREATE INDEX idx_monetizze_vendas_produtor_codigo ON public.monetizze_vendas USING btree (produtor_id, codigo_venda);

DROP INDEX public.idx_monetizze_vendas_produtor_codigo;

CREATE INDEX idx_monetizze_vendas_produtor_cpf ON public.monetizze_vendas USING btree (produtor_id, comprador_cpf);

DROP INDEX public.idx_monetizze_vendas_produtor_cpf;

CREATE INDEX idx_monetizze_vendas_produtor_email ON public.monetizze_vendas USING btree (produtor_id, comprador_email);

DROP INDEX public.idx_monetizze_vendas_produtor_email;

CREATE INDEX idx_monetizze_vendas_produtor_plataforma_created ON public.monetizze_vendas USING btree (produtor_id, plataforma, created_at DESC);

DROP INDEX public.idx_monetizze_vendas_produtor_plataforma_created;

CREATE INDEX idx_monetizze_vendas_produtor_status_created ON public.monetizze_vendas USING btree (produtor_id, status, created_at DESC);

DROP INDEX public.idx_monetizze_vendas_produtor_status_created;

CREATE INDEX idx_nfe_baixa_config_match_nome ON public.nfe_baixa_estoque_config USING btree (produtor_id, match_nome) WHERE (match_nome IS NOT NULL);

DROP INDEX public.idx_nfe_baixa_config_match_nome;

CREATE INDEX idx_pedido_regra_logs_pedido ON public.pedido_regra_logs USING btree (pedido_id);

DROP INDEX public.idx_pedido_regra_logs_pedido;

CREATE INDEX idx_pedidos_importados_nome_cep ON public.pedidos_importados USING btree (lower(nome), cep);

DROP INDEX public.idx_pedidos_importados_nome_cep;

CREATE INDEX idx_pedidos_importados_rastreio ON public.pedidos_importados USING btree (codigo_rastreio);

DROP INDEX public.idx_pedidos_importados_rastreio;

CREATE INDEX idx_pedidos_prepostagem ON public.pedidos USING btree (id_prepostagem);

DROP INDEX public.idx_pedidos_prepostagem;

CREATE INDEX idx_pedidos_produtor ON public.pedidos USING btree (produtor_id);

DROP INDEX public.idx_pedidos_produtor;

CREATE INDEX idx_pedidos_produtor_created ON public.pedidos USING btree (produtor_id, created_at DESC);

DROP INDEX public.idx_pedidos_produtor_created;

CREATE INDEX idx_pedidos_produtor_status_created ON public.pedidos USING btree (produtor_id, status_logistico, created_at DESC);

DROP INDEX public.idx_pedidos_produtor_status_created;

CREATE INDEX idx_pedidos_rastreio ON public.pedidos USING btree (codigo_rastreio);

DROP INDEX public.idx_pedidos_rastreio;

CREATE INDEX idx_pedidos_status ON public.pedidos USING btree (status_logistico);

DROP INDEX public.idx_pedidos_status;

CREATE INDEX idx_pedidos_status_logistico ON public.pedidos USING btree (status_logistico);

DROP INDEX public.idx_pedidos_status_logistico;

CREATE INDEX idx_pedidos_transp_ext_status ON public.pedidos USING btree (transportadora_externa, transportadora_externa_status);

DROP INDEX public.idx_pedidos_transp_ext_status;

CREATE INDEX idx_pedidos_xls_cliente ON public.pedidos_xls USING btree (cliente);

DROP INDEX public.idx_pedidos_xls_cliente;

CREATE INDEX idx_pedidos_xls_rastreio ON public.pedidos_xls USING btree (rastreio);

DROP INDEX public.idx_pedidos_xls_rastreio;

CREATE INDEX idx_pedidos_xls_regra_id ON public.pedidos_xls USING btree (regra_id);

DROP INDEX public.idx_pedidos_xls_regra_id;

CREATE INDEX idx_peso_faixas_produtor ON public.produtor_peso_faixas USING btree (produtor_id, ativo, qtd_min);

DROP INDEX public.idx_peso_faixas_produtor;

CREATE INDEX idx_prepostagem_auto_logs_produtor ON public.prepostagem_auto_logs USING btree (produtor_id, created_at DESC);

DROP INDEX public.idx_prepostagem_auto_logs_produtor;

CREATE INDEX idx_prepostagem_auto_logs_status ON public.prepostagem_auto_logs USING btree (status, created_at DESC);

DROP INDEX public.idx_prepostagem_auto_logs_status;

CREATE INDEX idx_prepostagem_auto_logs_venda ON public.prepostagem_auto_logs USING btree (venda_id);

DROP INDEX public.idx_prepostagem_auto_logs_venda;

CREATE INDEX idx_prepostagens_created_at ON public.prepostagens USING btree (created_at DESC);

DROP INDEX public.idx_prepostagens_created_at;

CREATE INDEX idx_prepostagens_ppn_codigo ON public.prepostagens_ppn USING btree (codigo_objeto);

DROP INDEX public.idx_prepostagens_ppn_codigo;

CREATE INDEX idx_prepostagens_ppn_data_postagem ON public.prepostagens_ppn USING btree (data_postagem DESC);

DROP INDEX public.idx_prepostagens_ppn_data_postagem;

CREATE INDEX idx_prepostagens_ppn_data_postagem_desc ON public.prepostagens_ppn USING btree (data_postagem DESC);

DROP INDEX public.idx_prepostagens_ppn_data_postagem_desc;

CREATE INDEX idx_prepostagens_ppn_status ON public.prepostagens_ppn USING btree (status);

DROP INDEX public.idx_prepostagens_ppn_status;

CREATE INDEX idx_prepostagens_status ON public.prepostagens USING btree (status);

DROP INDEX public.idx_prepostagens_status;

CREATE INDEX idx_prepostagens_venda ON public.prepostagens USING btree (venda_id);

DROP INDEX public.idx_prepostagens_venda;

CREATE INDEX idx_produto_precos_produto ON public.produto_precos USING btree (produto_nome);

DROP INDEX public.idx_produto_precos_produto;

CREATE INDEX idx_produto_precos_produtor ON public.produto_precos USING btree (produtor_id);

DROP INDEX public.idx_produto_precos_produtor;

CREATE INDEX idx_produtor_api_keys_hash ON public.produtor_api_keys USING btree (key_hash) WHERE (ativo = true);

DROP INDEX public.idx_produtor_api_keys_hash;

CREATE INDEX idx_produtor_api_keys_produtor ON public.produtor_api_keys USING btree (produtor_id);

DROP INDEX public.idx_produtor_api_keys_produtor;

CREATE INDEX idx_produtor_frete_faixas_produtor ON public.produtor_frete_faixas USING btree (produtor_id);

DROP INDEX public.idx_produtor_frete_faixas_produtor;

CREATE INDEX idx_produtor_planos_auto_rastreio ON public.produtor_planos USING btree (produtor_id, plano_codigo) WHERE (atualizar_rastreio_auto = true);

DROP INDEX public.idx_produtor_planos_auto_rastreio;

CREATE INDEX idx_produtor_planos_codigo ON public.produtor_planos USING btree (plano_codigo);

DROP INDEX public.idx_produtor_planos_codigo;

CREATE INDEX idx_produtor_planos_plataforma ON public.produtor_planos USING btree (produtor_id, plataforma, plano_codigo);

DROP INDEX public.idx_produtor_planos_plataforma;

CREATE INDEX idx_produtor_planos_produtor ON public.produtor_planos USING btree (produtor_id);

DROP INDEX public.idx_produtor_planos_produtor;

CREATE INDEX idx_produtor_produto_precos_pid ON public.produtor_produto_precos USING btree (produtor_id);

DROP INDEX public.idx_produtor_produto_precos_pid;

CREATE INDEX idx_produtor_webhooks_produtor ON public.produtor_webhooks USING btree (produtor_id) WHERE ativo;

DROP INDEX public.idx_produtor_webhooks_produtor;

CREATE INDEX idx_reenvio_pagamentos_produtor ON public.reenvio_pagamentos USING btree (produtor_id);

DROP INDEX public.idx_reenvio_pagamentos_produtor;

CREATE INDEX idx_reenvio_pagamentos_reenvio ON public.reenvio_pagamentos USING btree (reenvio_id);

DROP INDEX public.idx_reenvio_pagamentos_reenvio;

CREATE INDEX idx_reenvios_codigo_original ON public.reenvios USING btree (codigo_objeto_original);

DROP INDEX public.idx_reenvios_codigo_original;

CREATE INDEX idx_reenvios_produtor ON public.reenvios USING btree (produtor_id);

DROP INDEX public.idx_reenvios_produtor;

CREATE INDEX idx_reenvios_venda ON public.reenvios USING btree (venda_id);

DROP INDEX public.idx_reenvios_venda;

CREATE INDEX idx_registro_estoque_codigo ON public.registro_estoque USING btree (codigo_rastreio);

DROP INDEX public.idx_registro_estoque_codigo;

CREATE INDEX idx_registro_estoque_produtor ON public.registro_estoque USING btree (produtor_id, created_at DESC);

DROP INDEX public.idx_registro_estoque_produtor;

CREATE INDEX idx_regras_coprodutor ON public.coproducao_regras USING btree (coprodutor_id);

DROP INDEX public.idx_regras_coprodutor;

CREATE INDEX idx_regras_logisticas_lookup ON public.regras_logisticas USING btree (produtor_id, ativo, prioridade);

DROP INDEX public.idx_regras_logisticas_lookup;

CREATE INDEX idx_regras_logisticas_plano ON public.regras_logisticas USING btree (plano_id);

DROP INDEX public.idx_regras_logisticas_plano;

CREATE INDEX idx_regras_prioridade ON public.coproducao_regras USING btree (prioridade, status);

DROP INDEX public.idx_regras_prioridade;

CREATE INDEX idx_repasses_coprodutor ON public.coproducao_repasses USING btree (coprodutor_id);

DROP INDEX public.idx_repasses_coprodutor;

CREATE INDEX idx_sislog_remetentes_produtor ON public.sislog_remetentes USING btree (produtor_id);

DROP INDEX public.idx_sislog_remetentes_produtor;

CREATE INDEX idx_sislogica_log_created ON public.sislogica_envios_log USING btree (created_at DESC);

DROP INDEX public.idx_sislogica_log_created;

CREATE INDEX idx_sislogica_log_pedido ON public.sislogica_envios_log USING btree (pedido_id);

DROP INDEX public.idx_sislogica_log_pedido;

CREATE INDEX idx_sislogica_log_venda ON public.sislogica_envios_log USING btree (venda_id);

DROP INDEX public.idx_sislogica_log_venda;

CREATE INDEX idx_tracking_events_produtor_rastreio_data ON public.tracking_events USING btree (produtor_id, codigo_rastreio, data_evento DESC);

DROP INDEX public.idx_tracking_events_produtor_rastreio_data;

CREATE INDEX idx_tracking_pedido ON public.tracking_events USING btree (pedido_id, data_evento DESC);

DROP INDEX public.idx_tracking_pedido;

CREATE INDEX idx_tracking_produtor ON public.tracking_events USING btree (produtor_id);

DROP INDEX public.idx_tracking_produtor;

CREATE INDEX idx_tracking_rastreio ON public.tracking_events USING btree (codigo_rastreio);

DROP INDEX public.idx_tracking_rastreio;

CREATE INDEX idx_vendas_codigo ON public.coproducao_vendas USING btree (codigo_venda);

DROP INDEX public.idx_vendas_codigo;

CREATE INDEX idx_vendas_coprodutor ON public.coproducao_vendas USING btree (coprodutor_id);

DROP INDEX public.idx_vendas_coprodutor;

CREATE INDEX idx_vendas_data_pag ON public.coproducao_vendas USING btree (data_pagamento);

DROP INDEX public.idx_vendas_data_pag;

CREATE INDEX idx_vendas_status ON public.coproducao_vendas USING btree (status_repasse);

DROP INDEX public.idx_vendas_status;

CREATE INDEX idx_vhsys_estoque_movimentos_created ON public.vhsys_estoque_movimentos USING btree (created_at DESC);

DROP INDEX public.idx_vhsys_estoque_movimentos_created;

CREATE INDEX idx_vhsys_estoque_movimentos_produto ON public.vhsys_estoque_movimentos USING btree (produto_vhsys_id);

DROP INDEX public.idx_vhsys_estoque_movimentos_produto;

CREATE INDEX idx_vhsys_estoque_movimentos_produtor ON public.vhsys_estoque_movimentos USING btree (produtor_id);

DROP INDEX public.idx_vhsys_estoque_movimentos_produtor;

CREATE INDEX idx_webhook_entregas_webhook ON public.produtor_webhook_entregas USING btree (webhook_id, created_at DESC);

DROP INDEX public.idx_webhook_entregas_webhook;

CREATE INDEX idx_webhook_logs_codigo_venda ON public.webhook_logs USING btree (codigo_venda);

DROP INDEX public.idx_webhook_logs_codigo_venda;

CREATE INDEX idx_webhook_logs_created_at ON public.webhook_logs USING btree (created_at DESC);

DROP INDEX public.idx_webhook_logs_created_at;

CREATE INDEX idx_webhook_logs_venda_id ON public.webhook_logs USING btree (venda_id);

DROP INDEX public.idx_webhook_logs_venda_id;

CREATE INDEX idx_wh_logs_origem ON public.coproducao_webhook_logs USING btree (origem, created_at DESC);

DROP INDEX public.idx_wh_logs_origem;

CREATE INDEX idx_wh_logs_pedido ON public.coproducao_webhook_logs USING btree (pedido_id);

DROP INDEX public.idx_wh_logs_pedido;

CREATE INDEX idx_wh_logs_transacao ON public.coproducao_webhook_logs USING btree (transacao_id);

DROP INDEX public.idx_wh_logs_transacao;

CREATE INDEX idx_whatsapp_log_cliente ON public.whatsapp_envios_log USING btree (cliente_id);

DROP INDEX public.idx_whatsapp_log_cliente;

CREATE INDEX idx_whatsapp_log_status ON public.whatsapp_envios_log USING btree (status);

DROP INDEX public.idx_whatsapp_log_status;

CREATE INDEX nfe_emissoes_produtor_idx ON public.nfe_emissoes USING btree (produtor_id);

DROP INDEX public.nfe_emissoes_produtor_idx;

CREATE INDEX nfe_emissoes_status_idx ON public.nfe_emissoes USING btree (status);

DROP INDEX public.nfe_emissoes_status_idx;

CREATE UNIQUE INDEX nfe_emissoes_venda_id_uniq ON public.nfe_emissoes USING btree (venda_id) WHERE (venda_id IS NOT NULL);

DROP INDEX public.nfe_emissoes_venda_id_uniq;

CREATE UNIQUE INDEX pedidos_codigo_rastreio_produtor_key ON public.pedidos USING btree (codigo_rastreio, produtor_id);

DROP INDEX public.pedidos_codigo_rastreio_produtor_key;

CREATE UNIQUE INDEX pedidos_produtor_venda_uidx ON public.pedidos USING btree (produtor_id, venda_id) WHERE (venda_id IS NOT NULL);

DROP INDEX public.pedidos_produtor_venda_uidx;

CREATE INDEX pedidos_venda_id_idx ON public.pedidos USING btree (venda_id);

DROP INDEX public.pedidos_venda_id_idx;

CREATE INDEX prep_massa_logs_created_idx ON public.prep_massa_logs USING btree (created_at DESC);

DROP INDEX public.prep_massa_logs_created_idx;

CREATE INDEX prep_massa_logs_produtor_idx ON public.prep_massa_logs USING btree (produtor_id, created_at DESC);

DROP INDEX public.prep_massa_logs_produtor_idx;

CREATE INDEX prep_massa_logs_run_idx ON public.prep_massa_logs USING btree (run_id);

DROP INDEX public.prep_massa_logs_run_idx;

CREATE UNIQUE INDEX produtor_planos_produtor_plataforma_codigo_key ON public.produtor_planos USING btree (produtor_id, plataforma, plano_codigo);

DROP INDEX public.produtor_planos_produtor_plataforma_codigo_key;

CREATE UNIQUE INDEX produtores_integracao_braip_webhook_secret_key ON public.produtores_integracao USING btree (braip_webhook_secret);

DROP INDEX public.produtores_integracao_braip_webhook_secret_key;

CREATE UNIQUE INDEX uniq_monetizze_vendas_produtor_plataforma_codigo ON public.monetizze_vendas USING btree (produtor_id, plataforma, codigo_venda) WHERE ((codigo_venda IS NOT NULL) AND (produtor_id IS NOT NULL));

DROP INDEX public.uniq_monetizze_vendas_produtor_plataforma_codigo;

CREATE UNIQUE INDEX uq_tracking_evento_por_pedido ON public.tracking_events USING btree (pedido_id, codigo_rastreio, data_evento, status);

DROP INDEX public.uq_tracking_evento_por_pedido;

CREATE UNIQUE INDEX ux_vendas_pedido_appmax ON public.coproducao_vendas USING btree (pedido_appmax_id) WHERE ((pedido_appmax_id IS NOT NULL) AND (transacao_appmax_id IS NULL));

DROP INDEX public.ux_vendas_pedido_appmax;

CREATE UNIQUE INDEX ux_vendas_pedido_yampi ON public.coproducao_vendas USING btree (pedido_yampi_id) WHERE ((pedido_yampi_id IS NOT NULL) AND (pedido_appmax_id IS NULL) AND (transacao_appmax_id IS NULL));

DROP INDEX public.ux_vendas_pedido_yampi;

CREATE UNIQUE INDEX ux_vendas_transacao_appmax ON public.coproducao_vendas USING btree (transacao_appmax_id) WHERE (transacao_appmax_id IS NOT NULL);

DROP INDEX public.ux_vendas_transacao_appmax;

CREATE INDEX vendas_ml_criado_em_idx ON public.vendas_ml USING btree (criado_em DESC);

DROP INDEX public.vendas_ml_criado_em_idx;

CREATE INDEX vendas_ml_status_idx ON public.vendas_ml USING btree (status);

DROP INDEX public.vendas_ml_status_idx;

CREATE INDEX vhsys_estoque_saldos_tipo_item_idx ON public.vhsys_estoque_saldos USING btree (tipo_item);

DROP INDEX public.vhsys_estoque_saldos_tipo_item_idx;

CREATE INDEX webhook_logs_created_idx ON public.webhook_logs USING btree (created_at DESC);

DROP INDEX public.webhook_logs_created_idx;

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);

DROP INDEX realtime.ix_realtime_subscription_entity;

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

DROP INDEX realtime.messages_inserted_at_topic_index;

CREATE INDEX messages_2026_07_12_inserted_at_topic_idx ON realtime.messages_2026_07_12 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

CREATE INDEX messages_2026_07_13_inserted_at_topic_idx ON realtime.messages_2026_07_13 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

CREATE INDEX messages_2026_07_14_inserted_at_topic_idx ON realtime.messages_2026_07_14 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

CREATE INDEX messages_2026_07_15_inserted_at_topic_idx ON realtime.messages_2026_07_15 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

CREATE INDEX messages_2026_07_16_inserted_at_topic_idx ON realtime.messages_2026_07_16 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

CREATE INDEX messages_2026_07_17_inserted_at_topic_idx ON realtime.messages_2026_07_17 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

CREATE INDEX messages_2026_07_18_inserted_at_topic_idx ON realtime.messages_2026_07_18 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_selec ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter, COALESCE(selected_columns, '{}'::text[]));

DROP INDEX realtime.subscription_subscription_id_entity_filters_action_filter_selec;

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);

DROP INDEX storage.bname;

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);

DROP INDEX storage.bucketid_objname;

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);

DROP INDEX storage.buckets_analytics_unique_name_idx;

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);

DROP INDEX storage.idx_multipart_uploads_list;

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");

DROP INDEX storage.idx_objects_bucket_id_name;

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");

DROP INDEX storage.idx_objects_bucket_id_name_lower;

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);

DROP INDEX storage.name_prefix_search;

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);

DROP INDEX storage.vector_indexes_name_bucket_id_idx;

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_07_12_inserted_at_topic_idx;

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_07_12_pkey;

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_07_13_inserted_at_topic_idx;

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_07_13_pkey;

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_07_14_inserted_at_topic_idx;

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_07_14_pkey;

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_07_15_inserted_at_topic_idx;

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_07_15_pkey;

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_07_16_inserted_at_topic_idx;

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_07_16_pkey;

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_07_17_inserted_at_topic_idx;

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_07_17_pkey;

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_07_18_inserted_at_topic_idx;

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_07_18_pkey;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER on_auth_user_created ON auth.users;

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER profiles_updated_at ON public.profiles;

CREATE TRIGGER set_updated_at_produtor_frete_faixas BEFORE UPDATE ON public.produtor_frete_faixas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER set_updated_at_produtor_frete_faixas ON public.produtor_frete_faixas;

CREATE TRIGGER tg_estoque_locais_updated BEFORE UPDATE ON public.estoque_locais FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER tg_estoque_locais_updated ON public.estoque_locais;

CREATE TRIGGER tg_estoque_produtos_updated BEFORE UPDATE ON public.estoque_produtos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER tg_estoque_produtos_updated ON public.estoque_produtos;

CREATE TRIGGER trg_appmax_split_config_updated_at BEFORE UPDATE ON public.appmax_split_config FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_appmax_split_config_updated_at ON public.appmax_split_config;

CREATE TRIGGER trg_appmax_split_logs_updated_at BEFORE UPDATE ON public.appmax_split_logs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_appmax_split_logs_updated_at ON public.appmax_split_logs;

CREATE TRIGGER trg_braip_vendas_xls_updated BEFORE UPDATE ON public.braip_vendas_xls FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_braip_vendas_xls_updated ON public.braip_vendas_xls;

CREATE TRIGGER trg_config_updated BEFORE UPDATE ON public.coproducao_configuracoes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_config_updated ON public.coproducao_configuracoes;

CREATE TRIGGER trg_contratos_logisticos_updated_at BEFORE UPDATE ON public.contratos_logisticos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_contratos_logisticos_updated_at ON public.contratos_logisticos;

CREATE TRIGGER trg_coprodutores_updated BEFORE UPDATE ON public.coprodutores FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_coprodutores_updated ON public.coprodutores;

CREATE TRIGGER trg_estoque_baixa_config_updated_at BEFORE UPDATE ON public.estoque_baixa_config FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_estoque_baixa_config_updated_at ON public.estoque_baixa_config;

CREATE TRIGGER trg_nfe_baixa_cfg_updated_at BEFORE UPDATE ON public.nfe_baixa_estoque_config FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_nfe_baixa_cfg_updated_at ON public.nfe_baixa_estoque_config;

CREATE TRIGGER trg_nfe_emissoes_updated_at BEFORE UPDATE ON public.nfe_emissoes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_nfe_emissoes_updated_at ON public.nfe_emissoes;

CREATE TRIGGER trg_pedidos_updated BEFORE UPDATE ON public.pedidos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_pedidos_updated ON public.pedidos;

CREATE TRIGGER trg_pedidos_xls_updated BEFORE UPDATE ON public.pedidos_xls FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_pedidos_xls_updated ON public.pedidos_xls;

CREATE TRIGGER trg_peso_faixas_updated_at BEFORE UPDATE ON public.produtor_peso_faixas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_peso_faixas_updated_at ON public.produtor_peso_faixas;

CREATE TRIGGER trg_produtor_produto_precos_updated BEFORE UPDATE ON public.produtor_produto_precos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_produtor_produto_precos_updated ON public.produtor_produto_precos;

CREATE TRIGGER trg_produtor_webhooks_updated BEFORE UPDATE ON public.produtor_webhooks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_produtor_webhooks_updated ON public.produtor_webhooks;

CREATE TRIGGER trg_registro_estoque_updated_at BEFORE UPDATE ON public.registro_estoque FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_registro_estoque_updated_at ON public.registro_estoque;

CREATE TRIGGER trg_regras_logisticas_updated_at BEFORE UPDATE ON public.regras_logisticas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_regras_logisticas_updated_at ON public.regras_logisticas;

CREATE TRIGGER trg_regras_updated BEFORE UPDATE ON public.coproducao_regras FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_regras_updated ON public.coproducao_regras;

CREATE TRIGGER trg_repasses_updated BEFORE UPDATE ON public.coproducao_repasses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_repasses_updated ON public.coproducao_repasses;

CREATE TRIGGER trg_vendas_updated BEFORE UPDATE ON public.coproducao_vendas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_vendas_updated ON public.coproducao_vendas;

CREATE TRIGGER trg_vhsys_estoque_saldos_updated_at BEFORE UPDATE ON public.vhsys_estoque_saldos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_vhsys_estoque_saldos_updated_at ON public.vhsys_estoque_saldos;

CREATE TRIGGER trg_vhsys_locais_estoque_updated_at BEFORE UPDATE ON public.vhsys_locais_estoque FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_vhsys_locais_estoque_updated_at ON public.vhsys_locais_estoque;

CREATE TRIGGER trg_wh_logs_updated BEFORE UPDATE ON public.coproducao_webhook_logs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER trg_wh_logs_updated ON public.coproducao_webhook_logs;

CREATE TRIGGER update_pedidos_importados_updated_at BEFORE UPDATE ON public.pedidos_importados FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER update_pedidos_importados_updated_at ON public.pedidos_importados;

CREATE TRIGGER update_prepostagens_ppn_updated_at BEFORE UPDATE ON public.prepostagens_ppn FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER update_prepostagens_ppn_updated_at ON public.prepostagens_ppn;

CREATE TRIGGER update_produtor_api_keys_updated_at BEFORE UPDATE ON public.produtor_api_keys FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER update_produtor_api_keys_updated_at ON public.produtor_api_keys;

CREATE TRIGGER update_produtor_planos_updated_at BEFORE UPDATE ON public.produtor_planos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER update_produtor_planos_updated_at ON public.produtor_planos;

CREATE TRIGGER update_produtores_integracao_updated_at BEFORE UPDATE ON public.produtores_integracao FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER update_produtores_integracao_updated_at ON public.produtores_integracao;

CREATE TRIGGER update_reenvios_updated_at BEFORE UPDATE ON public.reenvios FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER update_reenvios_updated_at ON public.reenvios;

CREATE TRIGGER update_sislog_remetentes_updated_at BEFORE UPDATE ON public.sislog_remetentes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER update_sislog_remetentes_updated_at ON public.sislog_remetentes;

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();

DROP TRIGGER tr_check_filters ON realtime.subscription;

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();

DROP TRIGGER enforce_bucket_name_length_trigger ON storage.buckets;

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();

DROP TRIGGER protect_buckets_delete ON storage.buckets;

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();

DROP TRIGGER protect_objects_delete ON storage.objects;

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();

DROP TRIGGER update_objects_updated_at ON storage.objects;

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.identities DROP CONSTRAINT identities_user_id_fkey;

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.mfa_amr_claims DROP CONSTRAINT mfa_amr_claims_session_id_fkey;

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.mfa_challenges DROP CONSTRAINT mfa_challenges_auth_factor_id_fkey;

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.mfa_factors DROP CONSTRAINT mfa_factors_user_id_fkey;

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.oauth_authorizations DROP CONSTRAINT oauth_authorizations_client_id_fkey;

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.oauth_authorizations DROP CONSTRAINT oauth_authorizations_user_id_fkey;

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.oauth_consents DROP CONSTRAINT oauth_consents_client_id_fkey;

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.oauth_consents DROP CONSTRAINT oauth_consents_user_id_fkey;

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.one_time_tokens DROP CONSTRAINT one_time_tokens_user_id_fkey;

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.refresh_tokens DROP CONSTRAINT refresh_tokens_session_id_fkey;

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.saml_providers DROP CONSTRAINT saml_providers_sso_provider_id_fkey;

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.saml_relay_states DROP CONSTRAINT saml_relay_states_flow_state_id_fkey;

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.saml_relay_states DROP CONSTRAINT saml_relay_states_sso_provider_id_fkey;

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.sessions DROP CONSTRAINT sessions_oauth_client_id_fkey;

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.sessions DROP CONSTRAINT sessions_user_id_fkey;

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.sso_domains DROP CONSTRAINT sso_domains_sso_provider_id_fkey;

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.webauthn_challenges DROP CONSTRAINT webauthn_challenges_user_id_fkey;

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY auth.webauthn_credentials DROP CONSTRAINT webauthn_credentials_user_id_fkey;

ALTER TABLE ONLY public.coproducao_auditoria
    ADD CONSTRAINT coproducao_auditoria_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES auth.users(id);

ALTER TABLE ONLY public.coproducao_auditoria DROP CONSTRAINT coproducao_auditoria_usuario_id_fkey;

ALTER TABLE ONLY public.coproducao_regras
    ADD CONSTRAINT coproducao_regras_coprodutor_id_fkey FOREIGN KEY (coprodutor_id) REFERENCES public.coprodutores(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.coproducao_regras DROP CONSTRAINT coproducao_regras_coprodutor_id_fkey;

ALTER TABLE ONLY public.coproducao_repasse_itens
    ADD CONSTRAINT coproducao_repasse_itens_repasse_id_fkey FOREIGN KEY (repasse_id) REFERENCES public.coproducao_repasses(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.coproducao_repasse_itens DROP CONSTRAINT coproducao_repasse_itens_repasse_id_fkey;

ALTER TABLE ONLY public.coproducao_repasse_itens
    ADD CONSTRAINT coproducao_repasse_itens_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.coproducao_vendas(id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.coproducao_repasse_itens DROP CONSTRAINT coproducao_repasse_itens_venda_id_fkey;

ALTER TABLE ONLY public.coproducao_repasses
    ADD CONSTRAINT coproducao_repasses_coprodutor_id_fkey FOREIGN KEY (coprodutor_id) REFERENCES public.coprodutores(id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.coproducao_repasses DROP CONSTRAINT coproducao_repasses_coprodutor_id_fkey;

ALTER TABLE ONLY public.coproducao_repasses
    ADD CONSTRAINT coproducao_repasses_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);

ALTER TABLE ONLY public.coproducao_repasses DROP CONSTRAINT coproducao_repasses_created_by_fkey;

ALTER TABLE ONLY public.coproducao_vendas
    ADD CONSTRAINT coproducao_vendas_coprodutor_id_fkey FOREIGN KEY (coprodutor_id) REFERENCES public.coprodutores(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.coproducao_vendas DROP CONSTRAINT coproducao_vendas_coprodutor_id_fkey;

ALTER TABLE ONLY public.coproducao_vendas
    ADD CONSTRAINT coproducao_vendas_regra_comissao_id_fkey FOREIGN KEY (regra_comissao_id) REFERENCES public.coproducao_regras(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.coproducao_vendas DROP CONSTRAINT coproducao_vendas_regra_comissao_id_fkey;

ALTER TABLE ONLY public.coproducao_webhook_logs
    ADD CONSTRAINT coproducao_webhook_logs_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.coproducao_vendas(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.coproducao_webhook_logs DROP CONSTRAINT coproducao_webhook_logs_venda_id_fkey;

ALTER TABLE ONLY public.estoque_movimentos
    ADD CONSTRAINT estoque_movimentos_local_destino_id_fkey FOREIGN KEY (local_destino_id) REFERENCES public.estoque_locais(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.estoque_movimentos DROP CONSTRAINT estoque_movimentos_local_destino_id_fkey;

ALTER TABLE ONLY public.estoque_movimentos
    ADD CONSTRAINT estoque_movimentos_local_id_fkey FOREIGN KEY (local_id) REFERENCES public.estoque_locais(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.estoque_movimentos DROP CONSTRAINT estoque_movimentos_local_id_fkey;

ALTER TABLE ONLY public.estoque_movimentos
    ADD CONSTRAINT estoque_movimentos_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.estoque_produtos(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.estoque_movimentos DROP CONSTRAINT estoque_movimentos_produto_id_fkey;

ALTER TABLE ONLY public.monetizze_vendas
    ADD CONSTRAINT monetizze_vendas_produtor_id_fkey FOREIGN KEY (produtor_id) REFERENCES public.produtores_integracao(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.monetizze_vendas DROP CONSTRAINT monetizze_vendas_produtor_id_fkey;

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_contrato_logistico_id_fkey FOREIGN KEY (contrato_logistico_id) REFERENCES public.contratos_logisticos(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.pedidos DROP CONSTRAINT pedidos_contrato_logistico_id_fkey;

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_regra_logistica_id_fkey FOREIGN KEY (regra_logistica_id) REFERENCES public.regras_logisticas(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.pedidos DROP CONSTRAINT pedidos_regra_logistica_id_fkey;

ALTER TABLE ONLY public.pedidos_xls
    ADD CONSTRAINT pedidos_xls_regra_id_fkey FOREIGN KEY (regra_id) REFERENCES public.produto_regras(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.pedidos_xls DROP CONSTRAINT pedidos_xls_regra_id_fkey;

ALTER TABLE ONLY public.prepostagens
    ADD CONSTRAINT prepostagens_regra_id_fkey FOREIGN KEY (regra_id) REFERENCES public.produto_regras(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.prepostagens DROP CONSTRAINT prepostagens_regra_id_fkey;

ALTER TABLE ONLY public.prepostagens
    ADD CONSTRAINT prepostagens_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.monetizze_vendas(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.prepostagens DROP CONSTRAINT prepostagens_venda_id_fkey;

ALTER TABLE ONLY public.produtor_planos
    ADD CONSTRAINT produtor_planos_contrato_logistico_padrao_id_fkey FOREIGN KEY (contrato_logistico_padrao_id) REFERENCES public.contratos_logisticos(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.produtor_planos DROP CONSTRAINT produtor_planos_contrato_logistico_padrao_id_fkey;

ALTER TABLE ONLY public.produtor_planos
    ADD CONSTRAINT produtor_planos_produtor_id_fkey FOREIGN KEY (produtor_id) REFERENCES public.produtores_integracao(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.produtor_planos DROP CONSTRAINT produtor_planos_produtor_id_fkey;

ALTER TABLE ONLY public.produtor_planos
    ADD CONSTRAINT produtor_planos_regra_id_fkey FOREIGN KEY (regra_id) REFERENCES public.produto_regras(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.produtor_planos DROP CONSTRAINT produtor_planos_regra_id_fkey;

ALTER TABLE ONLY public.produtor_webhook_entregas
    ADD CONSTRAINT produtor_webhook_entregas_webhook_id_fkey FOREIGN KEY (webhook_id) REFERENCES public.produtor_webhooks(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.produtor_webhook_entregas DROP CONSTRAINT produtor_webhook_entregas_webhook_id_fkey;

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.profiles DROP CONSTRAINT profiles_user_id_fkey;

ALTER TABLE ONLY public.regras_logisticas
    ADD CONSTRAINT regras_logisticas_contrato_logistico_id_fkey FOREIGN KEY (contrato_logistico_id) REFERENCES public.contratos_logisticos(id) ON DELETE RESTRICT;

ALTER TABLE ONLY public.regras_logisticas DROP CONSTRAINT regras_logisticas_contrato_logistico_id_fkey;

ALTER TABLE ONLY public.regras_logisticas
    ADD CONSTRAINT regras_logisticas_plano_id_fkey FOREIGN KEY (plano_id) REFERENCES public.produtor_planos(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.regras_logisticas DROP CONSTRAINT regras_logisticas_plano_id_fkey;

ALTER TABLE ONLY public.sislog_remetentes
    ADD CONSTRAINT sislog_remetentes_produtor_id_fkey FOREIGN KEY (produtor_id) REFERENCES public.produtores_integracao(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.sislog_remetentes DROP CONSTRAINT sislog_remetentes_produtor_id_fkey;

ALTER TABLE ONLY public.sislogica_envios_log
    ADD CONSTRAINT sislogica_envios_log_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.sislogica_envios_log DROP CONSTRAINT sislogica_envios_log_pedido_id_fkey;

ALTER TABLE ONLY public.sislogica_webhook_tokens
    ADD CONSTRAINT sislogica_webhook_tokens_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.sislogica_webhook_tokens DROP CONSTRAINT sislogica_webhook_tokens_criado_por_fkey;

ALTER TABLE ONLY public.tracking_events
    ADD CONSTRAINT tracking_events_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.tracking_events DROP CONSTRAINT tracking_events_pedido_id_fkey;

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_user_id_fkey;

ALTER TABLE ONLY public.whatsapp_envios_log
    ADD CONSTRAINT whatsapp_envios_log_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes_envio(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.whatsapp_envios_log DROP CONSTRAINT whatsapp_envios_log_cliente_id_fkey;

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);

ALTER TABLE ONLY storage.objects DROP CONSTRAINT "objects_bucketId_fkey";

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);

ALTER TABLE ONLY storage.s3_multipart_uploads DROP CONSTRAINT s3_multipart_uploads_bucket_id_fkey;

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);

ALTER TABLE ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey;

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;

ALTER TABLE ONLY storage.s3_multipart_uploads_parts DROP CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey;

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);

ALTER TABLE ONLY storage.vector_indexes DROP CONSTRAINT vector_indexes_bucket_id_fkey;

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin gerencia peso faixas" ON public.produtor_peso_faixas TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "Admin gerencia peso faixas" ON public.produtor_peso_faixas;

CREATE POLICY "Admin manage ml_tokens" ON public.ml_tokens TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "Admin manage ml_tokens" ON public.ml_tokens;

CREATE POLICY "Admin manage vendas_ml" ON public.vendas_ml TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "Admin manage vendas_ml" ON public.vendas_ml;

CREATE POLICY "admin all" ON public.api_logs TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.api_logs;

CREATE POLICY "admin all" ON public.clientes_envio TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.clientes_envio;

CREATE POLICY "admin all" ON public.correios_api_logs TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.correios_api_logs;

CREATE POLICY "admin all" ON public.email_envios_log TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.email_envios_log;

CREATE POLICY "admin all" ON public.email_template_rastreio TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.email_template_rastreio;

CREATE POLICY "admin all" ON public.envios TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.envios;

CREATE POLICY "admin all" ON public.notificacoes_carteiro_ausente TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.notificacoes_carteiro_ausente;

CREATE POLICY "admin all" ON public.pedidos_importados TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.pedidos_importados;

CREATE POLICY "admin all" ON public.pedidos_xls TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.pedidos_xls;

CREATE POLICY "admin all" ON public.prepostagens TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.prepostagens;

CREATE POLICY "admin all" ON public.prepostagens_ppn TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.prepostagens_ppn;

CREATE POLICY "admin all" ON public.produto_regras TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.produto_regras;

CREATE POLICY "admin all" ON public.remetente_config TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.remetente_config;

CREATE POLICY "admin all" ON public.whatsapp_envios_log TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.whatsapp_envios_log;

CREATE POLICY "admin all" ON public.whatsapp_template TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.whatsapp_template;

CREATE POLICY "admin all" ON public.whatsapp_template_carteiro TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all" ON public.whatsapp_template_carteiro;

CREATE POLICY "admin all braip_vendas_xls" ON public.braip_vendas_xls TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all braip_vendas_xls" ON public.braip_vendas_xls;

CREATE POLICY "admin all sislogica logs" ON public.sislogica_envios_log TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all sislogica logs" ON public.sislogica_envios_log;

CREATE POLICY "admin all vhsys_estoque_movimentos" ON public.vhsys_estoque_movimentos TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all vhsys_estoque_movimentos" ON public.vhsys_estoque_movimentos;

CREATE POLICY "admin all vhsys_estoque_saldos" ON public.vhsys_estoque_saldos TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all vhsys_estoque_saldos" ON public.vhsys_estoque_saldos;

CREATE POLICY "admin all vhsys_locais_estoque" ON public.vhsys_locais_estoque TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin all vhsys_locais_estoque" ON public.vhsys_locais_estoque;

CREATE POLICY "admin delete webhook_logs" ON public.webhook_logs FOR DELETE TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin delete webhook_logs" ON public.webhook_logs;

CREATE POLICY "admin manage nfe" ON public.nfe_emissoes TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin manage nfe" ON public.nfe_emissoes;

CREATE POLICY "admin manage planos" ON public.produtor_planos TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin manage planos" ON public.produtor_planos;

CREATE POLICY "admin manage precos nfe" ON public.produtor_produto_precos TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin manage precos nfe" ON public.produtor_produto_precos;

CREATE POLICY "admin manage produtores" ON public.produtores_integracao TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin manage produtores" ON public.produtores_integracao;

CREATE POLICY "admin manage sislog webhook tokens" ON public.sislogica_webhook_tokens TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admin manage sislog webhook tokens" ON public.sislogica_webhook_tokens;

CREATE POLICY "admins manage appmax_split_config" ON public.appmax_split_config TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admins manage appmax_split_config" ON public.appmax_split_config;

CREATE POLICY "admins manage appmax_split_logs" ON public.appmax_split_logs TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admins manage appmax_split_logs" ON public.appmax_split_logs;

CREATE POLICY "admins manage produtor_usuarios" ON public.produtor_usuarios TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admins manage produtor_usuarios" ON public.produtor_usuarios;

CREATE POLICY "admins manage roles" ON public.user_roles TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admins manage roles" ON public.user_roles;

CREATE POLICY "admins view appmax_split_logs" ON public.appmax_split_logs FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "admins view appmax_split_logs" ON public.appmax_split_logs;

ALTER TABLE public.api_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.appmax_split_config ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.appmax_split_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY audit_admin_read ON public.coproducao_auditoria FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY audit_admin_read ON public.coproducao_auditoria;

CREATE POLICY audit_authenticated_insert ON public.coproducao_auditoria FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY audit_authenticated_insert ON public.coproducao_auditoria;

CREATE POLICY "auth delete monetizze_vendas" ON public.monetizze_vendas FOR DELETE TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "auth delete monetizze_vendas" ON public.monetizze_vendas;

CREATE POLICY "auth delete prepostagem_auto_logs" ON public.prepostagem_auto_logs FOR DELETE TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "auth delete prepostagem_auto_logs" ON public.prepostagem_auto_logs;

CREATE POLICY "auth insert monetizze_vendas" ON public.monetizze_vendas FOR INSERT TO authenticated WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY "auth insert monetizze_vendas" ON public.monetizze_vendas;

CREATE POLICY "auth update monetizze_vendas" ON public.monetizze_vendas FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "auth update monetizze_vendas" ON public.monetizze_vendas;

CREATE POLICY "auth view monetizze_vendas" ON public.monetizze_vendas FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "auth view monetizze_vendas" ON public.monetizze_vendas;

CREATE POLICY "auth view prepostagem_auto_logs" ON public.prepostagem_auto_logs FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "auth view prepostagem_auto_logs" ON public.prepostagem_auto_logs;

CREATE POLICY "baixa_config: produtor select" ON public.estoque_baixa_config FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "baixa_config: produtor select" ON public.estoque_baixa_config;

CREATE POLICY "baixa_config: produtor update" ON public.estoque_baixa_config FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role))) WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "baixa_config: produtor update" ON public.estoque_baixa_config;

CREATE POLICY "baixa_config: produtor upsert" ON public.estoque_baixa_config FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "baixa_config: produtor upsert" ON public.estoque_baixa_config;

ALTER TABLE public.braip_vendas_xls ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.cep_correcao_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.clientes_envio ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.conferencias_postagem ENABLE ROW LEVEL SECURITY;

CREATE POLICY config_admin_all ON public.coproducao_configuracoes TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY config_admin_all ON public.coproducao_configuracoes;

CREATE POLICY config_auth_read ON public.coproducao_configuracoes FOR SELECT TO authenticated USING (true);

DROP POLICY config_auth_read ON public.coproducao_configuracoes;

ALTER TABLE public.contratos_logisticos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coproducao_auditoria ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coproducao_configuracoes ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coproducao_regras ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coproducao_repasse_itens ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coproducao_repasses ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coproducao_vendas ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coproducao_webhook_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.coprodutores ENABLE ROW LEVEL SECURITY;

CREATE POLICY coprodutores_admin_all ON public.coprodutores TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY coprodutores_admin_all ON public.coprodutores;

CREATE POLICY coprodutores_auth_read ON public.coprodutores FOR SELECT TO authenticated USING (true);

DROP POLICY coprodutores_auth_read ON public.coprodutores;

ALTER TABLE public.correios_api_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.correios_token_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "delete contratos" ON public.contratos_logisticos FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "delete contratos" ON public.contratos_logisticos;

CREATE POLICY "delete regras" ON public.regras_logisticas FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "delete regras" ON public.regras_logisticas;

CREATE POLICY "deny all client access" ON public.correios_token_cache USING (false) WITH CHECK (false);

DROP POLICY "deny all client access" ON public.correios_token_cache;

ALTER TABLE public.email_envios_log ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.email_template_rastreio ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.envios ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.estoque_baixa_config ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.estoque_locais ENABLE ROW LEVEL SECURITY;

CREATE POLICY "estoque_locais: produtor atualiza" ON public.estoque_locais FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_locais: produtor atualiza" ON public.estoque_locais;

CREATE POLICY "estoque_locais: produtor deleta" ON public.estoque_locais FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_locais: produtor deleta" ON public.estoque_locais;

CREATE POLICY "estoque_locais: produtor insere" ON public.estoque_locais FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_locais: produtor insere" ON public.estoque_locais;

CREATE POLICY "estoque_locais: produtor vê seus" ON public.estoque_locais FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_locais: produtor vê seus" ON public.estoque_locais;

CREATE POLICY "estoque_mov: produtor atualiza" ON public.estoque_movimentos FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_mov: produtor atualiza" ON public.estoque_movimentos;

CREATE POLICY "estoque_mov: produtor deleta" ON public.estoque_movimentos FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_mov: produtor deleta" ON public.estoque_movimentos;

CREATE POLICY "estoque_mov: produtor insere" ON public.estoque_movimentos FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_mov: produtor insere" ON public.estoque_movimentos;

CREATE POLICY "estoque_mov: produtor vê seus" ON public.estoque_movimentos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_mov: produtor vê seus" ON public.estoque_movimentos;

ALTER TABLE public.estoque_movimentos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.estoque_produtos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "estoque_produtos: produtor atualiza" ON public.estoque_produtos FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_produtos: produtor atualiza" ON public.estoque_produtos;

CREATE POLICY "estoque_produtos: produtor deleta" ON public.estoque_produtos FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_produtos: produtor deleta" ON public.estoque_produtos;

CREATE POLICY "estoque_produtos: produtor insere" ON public.estoque_produtos FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_produtos: produtor insere" ON public.estoque_produtos;

CREATE POLICY "estoque_produtos: produtor vê seus" ON public.estoque_produtos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "estoque_produtos: produtor vê seus" ON public.estoque_produtos;

CREATE POLICY "insert contratos" ON public.contratos_logisticos FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "insert contratos" ON public.contratos_logisticos;

CREATE POLICY "insert regras" ON public.regras_logisticas FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "insert regras" ON public.regras_logisticas;

ALTER TABLE public.ml_tokens ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.monetizze_vendas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nfe_baixa_cfg produtor delete" ON public.nfe_baixa_estoque_config FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "nfe_baixa_cfg produtor delete" ON public.nfe_baixa_estoque_config;

CREATE POLICY "nfe_baixa_cfg produtor insert" ON public.nfe_baixa_estoque_config FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "nfe_baixa_cfg produtor insert" ON public.nfe_baixa_estoque_config;

CREATE POLICY "nfe_baixa_cfg produtor select" ON public.nfe_baixa_estoque_config FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "nfe_baixa_cfg produtor select" ON public.nfe_baixa_estoque_config;

CREATE POLICY "nfe_baixa_cfg produtor update" ON public.nfe_baixa_estoque_config FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role))) WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "nfe_baixa_cfg produtor update" ON public.nfe_baixa_estoque_config;

ALTER TABLE public.nfe_baixa_estoque_config ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.nfe_emissoes ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.notificacoes_carteiro_ausente ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.pedido_regra_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.pedidos_importados ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.pedidos_xls ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.prep_massa_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY prep_massa_logs_insert_own_or_admin ON public.prep_massa_logs FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY prep_massa_logs_insert_own_or_admin ON public.prep_massa_logs;

CREATE POLICY prep_massa_logs_select_own_or_admin ON public.prep_massa_logs FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY prep_massa_logs_select_own_or_admin ON public.prep_massa_logs;

ALTER TABLE public.prepostagem_auto_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.prepostagens ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.prepostagens_ppn ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produto_precos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produto_regras ENABLE ROW LEVEL SECURITY;

CREATE POLICY "produtor delete frete faixas" ON public.produtor_frete_faixas FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor delete frete faixas" ON public.produtor_frete_faixas;

CREATE POLICY "produtor delete own api keys" ON public.produtor_api_keys FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor delete own api keys" ON public.produtor_api_keys;

CREATE POLICY "produtor delete reenvios" ON public.reenvios FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor delete reenvios" ON public.reenvios;

CREATE POLICY "produtor delete registro_estoque" ON public.registro_estoque FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor delete registro_estoque" ON public.registro_estoque;

CREATE POLICY "produtor delete sislog_remetentes" ON public.sislog_remetentes FOR DELETE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor delete sislog_remetentes" ON public.sislog_remetentes;

CREATE POLICY "produtor insert frete faixas" ON public.produtor_frete_faixas FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor insert frete faixas" ON public.produtor_frete_faixas;

CREATE POLICY "produtor insert own api keys" ON public.produtor_api_keys FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor insert own api keys" ON public.produtor_api_keys;

CREATE POLICY "produtor insert pagamentos" ON public.reenvio_pagamentos FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor insert pagamentos" ON public.reenvio_pagamentos;

CREATE POLICY "produtor insert pedidos" ON public.pedidos FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor insert pedidos" ON public.pedidos;

CREATE POLICY "produtor insert reenvios" ON public.reenvios FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor insert reenvios" ON public.reenvios;

CREATE POLICY "produtor insert registro_estoque" ON public.registro_estoque FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor insert registro_estoque" ON public.registro_estoque;

CREATE POLICY "produtor insert sislog_remetentes" ON public.sislog_remetentes FOR INSERT TO authenticated WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor insert sislog_remetentes" ON public.sislog_remetentes;

CREATE POLICY "produtor manage precos" ON public.produto_precos TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role))) WITH CHECK (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor manage precos" ON public.produto_precos;

CREATE POLICY "produtor select registro_estoque" ON public.registro_estoque FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor select registro_estoque" ON public.registro_estoque;

CREATE POLICY "produtor update frete faixas" ON public.produtor_frete_faixas FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor update frete faixas" ON public.produtor_frete_faixas;

CREATE POLICY "produtor update own api keys" ON public.produtor_api_keys FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor update own api keys" ON public.produtor_api_keys;

CREATE POLICY "produtor update pedidos" ON public.pedidos FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor update pedidos" ON public.pedidos;

CREATE POLICY "produtor update reenvios" ON public.reenvios FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor update reenvios" ON public.reenvios;

CREATE POLICY "produtor update registro_estoque" ON public.registro_estoque FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor update registro_estoque" ON public.registro_estoque;

CREATE POLICY "produtor update sislog_remetentes" ON public.sislog_remetentes FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor update sislog_remetentes" ON public.sislog_remetentes;

CREATE POLICY "produtor view frete faixas" ON public.produtor_frete_faixas FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view frete faixas" ON public.produtor_frete_faixas;

CREATE POLICY "produtor view own api keys" ON public.produtor_api_keys FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view own api keys" ON public.produtor_api_keys;

CREATE POLICY "produtor view pagamentos" ON public.reenvio_pagamentos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view pagamentos" ON public.reenvio_pagamentos;

CREATE POLICY "produtor view pedidos" ON public.pedidos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view pedidos" ON public.pedidos;

CREATE POLICY "produtor view precos" ON public.produto_precos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view precos" ON public.produto_precos;

CREATE POLICY "produtor view precos nfe" ON public.produtor_produto_precos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view precos nfe" ON public.produtor_produto_precos;

CREATE POLICY "produtor view reenvios" ON public.reenvios FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view reenvios" ON public.reenvios;

CREATE POLICY "produtor view sislog_remetentes" ON public.sislog_remetentes FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view sislog_remetentes" ON public.sislog_remetentes;

CREATE POLICY "produtor view tracking" ON public.tracking_events FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view tracking" ON public.tracking_events;

CREATE POLICY "produtor view webhook_logs" ON public.webhook_logs FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "produtor view webhook_logs" ON public.webhook_logs;

ALTER TABLE public.produtor_api_keys ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtor_frete_faixas ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtor_peso_faixas ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtor_planos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtor_produto_precos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtor_usuarios ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtor_webhook_entregas ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtor_webhooks ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.produtores_integracao ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.reenvio_pagamentos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.reenvios ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.registro_estoque ENABLE ROW LEVEL SECURITY;

CREATE POLICY regras_admin_all ON public.coproducao_regras TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY regras_admin_all ON public.coproducao_regras;

CREATE POLICY regras_auth_read ON public.coproducao_regras FOR SELECT TO authenticated USING (true);

DROP POLICY regras_auth_read ON public.coproducao_regras;

ALTER TABLE public.regras_logisticas ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.remetente_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY repasse_itens_admin_all ON public.coproducao_repasse_itens TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY repasse_itens_admin_all ON public.coproducao_repasse_itens;

CREATE POLICY repasse_itens_auth_read ON public.coproducao_repasse_itens FOR SELECT TO authenticated USING (true);

DROP POLICY repasse_itens_auth_read ON public.coproducao_repasse_itens;

CREATE POLICY repasses_admin_all ON public.coproducao_repasses TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY repasses_admin_all ON public.coproducao_repasses;

CREATE POLICY repasses_auth_read ON public.coproducao_repasses FOR SELECT TO authenticated USING (true);

DROP POLICY repasses_auth_read ON public.coproducao_repasses;

CREATE POLICY "service_role full access" ON public.sislogica_webhook_recebidos TO service_role USING (true) WITH CHECK (true);

DROP POLICY "service_role full access" ON public.sislogica_webhook_recebidos;

ALTER TABLE public.sislog_remetentes ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.sislogica_envios_log ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.sislogica_webhook_recebidos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.sislogica_webhook_tokens ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.tracking_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "update contratos" ON public.contratos_logisticos FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "update contratos" ON public.contratos_logisticos;

CREATE POLICY "update regras" ON public.regras_logisticas FOR UPDATE TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "update regras" ON public.regras_logisticas;

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users delete own conferencias" ON public.conferencias_postagem FOR DELETE TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users delete own conferencias" ON public.conferencias_postagem;

CREATE POLICY "users delete own webhook entregas" ON public.produtor_webhook_entregas FOR DELETE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.produtor_webhooks w
  WHERE ((w.id = produtor_webhook_entregas.webhook_id) AND (w.user_id = auth.uid())))));

DROP POLICY "users delete own webhook entregas" ON public.produtor_webhook_entregas;

CREATE POLICY "users delete own webhooks" ON public.produtor_webhooks FOR DELETE TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users delete own webhooks" ON public.produtor_webhooks;

CREATE POLICY "users insert own conferencias" ON public.conferencias_postagem FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));

DROP POLICY "users insert own conferencias" ON public.conferencias_postagem;

CREATE POLICY "users insert own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));

DROP POLICY "users insert own profile" ON public.profiles;

CREATE POLICY "users insert own webhooks" ON public.produtor_webhooks FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));

DROP POLICY "users insert own webhooks" ON public.produtor_webhooks;

CREATE POLICY "users update own conferencias" ON public.conferencias_postagem FOR UPDATE TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users update own conferencias" ON public.conferencias_postagem;

CREATE POLICY "users update own profile" ON public.profiles FOR UPDATE TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users update own profile" ON public.profiles;

CREATE POLICY "users update own webhooks" ON public.produtor_webhooks FOR UPDATE TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users update own webhooks" ON public.produtor_webhooks;

CREATE POLICY "users view own conferencias" ON public.conferencias_postagem FOR SELECT TO authenticated USING (((auth.uid() = user_id) OR (produtor_id = public.current_produtor_id())));

DROP POLICY "users view own conferencias" ON public.conferencias_postagem;

CREATE POLICY "users view own produtor link" ON public.produtor_usuarios FOR SELECT TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users view own produtor link" ON public.produtor_usuarios;

CREATE POLICY "users view own profile" ON public.profiles FOR SELECT TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users view own profile" ON public.profiles;

CREATE POLICY "users view own roles" ON public.user_roles FOR SELECT TO authenticated USING ((auth.uid() = user_id));

DROP POLICY "users view own roles" ON public.user_roles;

CREATE POLICY "users view own webhook entregas" ON public.produtor_webhook_entregas FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.produtor_webhooks w
  WHERE ((w.id = produtor_webhook_entregas.webhook_id) AND ((w.user_id = auth.uid()) OR (w.produtor_id = public.current_produtor_id()))))));

DROP POLICY "users view own webhook entregas" ON public.produtor_webhook_entregas;

CREATE POLICY "users view own webhooks" ON public.produtor_webhooks FOR SELECT TO authenticated USING (((auth.uid() = user_id) OR (produtor_id = public.current_produtor_id())));

DROP POLICY "users view own webhooks" ON public.produtor_webhooks;

CREATE POLICY vendas_admin_all ON public.coproducao_vendas TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY vendas_admin_all ON public.coproducao_vendas;

CREATE POLICY vendas_auth_read ON public.coproducao_vendas FOR SELECT TO authenticated USING (true);

DROP POLICY vendas_auth_read ON public.coproducao_vendas;

ALTER TABLE public.vendas_ml ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.vhsys_estoque_movimentos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.vhsys_estoque_saldos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.vhsys_locais_estoque ENABLE ROW LEVEL SECURITY;

CREATE POLICY "view cep correcao logs" ON public.cep_correcao_logs FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "view cep correcao logs" ON public.cep_correcao_logs;

CREATE POLICY "view contratos" ON public.contratos_logisticos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "view contratos" ON public.contratos_logisticos;

CREATE POLICY "view own nfe" ON public.nfe_emissoes FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "view own nfe" ON public.nfe_emissoes;

CREATE POLICY "view own planos" ON public.produtor_planos FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "view own planos" ON public.produtor_planos;

CREATE POLICY "view own produtor" ON public.produtores_integracao FOR SELECT TO authenticated USING (((id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "view own produtor" ON public.produtores_integracao;

CREATE POLICY "view pedido regra logs" ON public.pedido_regra_logs FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "view pedido regra logs" ON public.pedido_regra_logs;

CREATE POLICY "view regras" ON public.regras_logisticas FOR SELECT TO authenticated USING (((produtor_id = public.current_produtor_id()) OR public.has_role(auth.uid(), 'admin'::public.app_role)));

DROP POLICY "view regras" ON public.regras_logisticas;

ALTER TABLE public.webhook_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY wh_logs_admin_all ON public.coproducao_webhook_logs TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role)) WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));

DROP POLICY wh_logs_admin_all ON public.coproducao_webhook_logs;

CREATE POLICY wh_logs_auth_read ON public.coproducao_webhook_logs FOR SELECT TO authenticated USING (true);

DROP POLICY wh_logs_auth_read ON public.coproducao_webhook_logs;

ALTER TABLE public.whatsapp_envios_log ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.whatsapp_template ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.whatsapp_template_carteiro ENABLE ROW LEVEL SECURITY;

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "registro_estoque delete own" ON storage.objects FOR DELETE TO authenticated USING (((bucket_id = 'registro-estoque'::text) AND (public.has_role(auth.uid(), 'admin'::public.app_role) OR ((storage.foldername(name))[1] = (public.current_produtor_id())::text))));

DROP POLICY "registro_estoque delete own" ON storage.objects;

CREATE POLICY "registro_estoque insert own" ON storage.objects FOR INSERT TO authenticated WITH CHECK (((bucket_id = 'registro-estoque'::text) AND (public.has_role(auth.uid(), 'admin'::public.app_role) OR ((storage.foldername(name))[1] = (public.current_produtor_id())::text))));

DROP POLICY "registro_estoque insert own" ON storage.objects;

CREATE POLICY "registro_estoque select own" ON storage.objects FOR SELECT TO authenticated USING (((bucket_id = 'registro-estoque'::text) AND (public.has_role(auth.uid(), 'admin'::public.app_role) OR ((storage.foldername(name))[1] = (public.current_produtor_id())::text))));

DROP POLICY "registro_estoque select own" ON storage.objects;

CREATE POLICY "registro_estoque update own" ON storage.objects FOR UPDATE TO authenticated USING (((bucket_id = 'registro-estoque'::text) AND (public.has_role(auth.uid(), 'admin'::public.app_role) OR ((storage.foldername(name))[1] = (public.current_produtor_id())::text))));

DROP POLICY "registro_estoque update own" ON storage.objects;

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');

DROP PUBLICATION supabase_realtime;

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');

DROP PUBLICATION supabase_realtime_messages_publication;

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.monetizze_vendas;

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.pedidos;

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.prepostagens;

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.prepostagens_ppn;

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.tracking_events;

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA auth GRANT SELECT,USAGE ON SEQUENCES TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA auth GRANT ALL ON FUNCTIONS TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA auth GRANT SELECT,INSERT ON TABLES TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA extensions GRANT SELECT,USAGE ON SEQUENCES TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA extensions GRANT SELECT,INSERT ON TABLES TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT ON TABLES TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,USAGE ON SEQUENCES TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO sandbox_exec;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT ON TABLES TO sandbox_exec;

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();

DROP EVENT TRIGGER issue_graphql_placeholder;

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();

DROP EVENT TRIGGER issue_pg_cron_access;

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();

DROP EVENT TRIGGER issue_pg_graphql_access;

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();

DROP EVENT TRIGGER issue_pg_net_access;

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();

DROP EVENT TRIGGER pgrst_ddl_watch;

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();

DROP EVENT TRIGGER pgrst_drop_watch;

