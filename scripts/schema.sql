-- Covid 19 Schema

-- Table: public.covid19

DROP TABLE public.covid19 CASCADE;

CREATE TABLE IF NOT EXISTS public.covid19
(
    fips character varying(20) COLLATE pg_catalog."default",
    admin2 character varying(60) COLLATE pg_catalog."default",
    province character varying(60) COLLATE pg_catalog."default",
    country character varying(60) COLLATE pg_catalog."default",
    latitude double precision,
    longitude double precision,
    confirmed integer,
    deaths integer,
    recovered integer,
    active integer,
    combined_key character varying(120) COLLATE pg_catalog."default",
    last_update timestamp without time zone,
    file_date date DEFAULT '2020-04-07'::date,
    "Incidence_Rate" double precision,
    "Case-Fatality_Ratio" double precision 
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.covid19
    OWNER to superset;


-- Table: public.covid_lookup

DROP TABLE public.covid_lookup CASCADE;

CREATE TABLE IF NOT EXISTS  public.covid_lookup
(
    uid integer,
    iso2 character varying(2) COLLATE pg_catalog."default",
    iso3 character varying(3) COLLATE pg_catalog."default",
    code3 integer,
    fips integer,
    admin2 character varying(60) COLLATE pg_catalog."default",
    province_state character varying(60) COLLATE pg_catalog."default",
    country_region character varying(60) COLLATE pg_catalog."default",
    lat double precision,
    long_ double precision,
    combined_key character varying(60) COLLATE pg_catalog."default",
    population bigint
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.covid_lookup
    OWNER to superset;

-- Table: public.state_abbreviation

DROP TABLE public.state_abbreviation CASCADE;

CREATE TABLE IF NOT EXISTS public.state_abbreviation
(
    state character varying(100) COLLATE pg_catalog."default",
    abbr character(2) COLLATE pg_catalog."default"
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.state_abbreviation
    OWNER to superset;



-- View: public.sunkey

DROP VIEW public.sunkey;

CREATE OR REPLACE VIEW public.sunkey AS
 WITH totals AS (
         SELECT covid19.country,file_date,
            sum(covid19.confirmed) AS confirmed,
            sum(covid19.deaths) AS deaths,
            sum(covid19.recovered) AS recovered
           FROM covid19
          GROUP BY covid19.country,file_date
        )
 SELECT totals.country,
    'deaths'::text AS target,
    totals.deaths AS value_final,
    file_date
   FROM totals
UNION
 SELECT totals.country,
    'recovered'::text AS target,
    totals.recovered AS value_final,
    file_date
   FROM totals
UNION
 SELECT totals.country,
    'under treatment'::text AS target,
    totals.confirmed - totals.deaths - totals.recovered AS value_final,
    file_date
   FROM totals;



-- View: public.by_state

DROP VIEW public.by_state;

CREATE OR REPLACE VIEW public.by_state AS
 SELECT concat('US-', abbrvs.abbr) AS code,
    abbrvs.state,
    covid_lookup.iso2,
    covid_lookup.iso3,
    covid19.deaths,
    covid19.confirmed,
    covid19.recovered,
    covid19.country,
    covid19.province,
    covid19.admin2,
    covid19.latitude,
    covid19.longitude,
    covid_lookup.population,
    covid19.file_date
   FROM covid_lookup,
    covid19,
    state_abbreviation abbrvs
  WHERE covid_lookup.province_state::text = covid19.province::text AND covid_lookup.country_region::text = 'US'::text AND covid19.country::text = 'United States'::text AND abbrvs.state::text = covid19.province::text;

ALTER TABLE public.by_state
    OWNER TO superset;


-- View: public.covid_pdf

DROP VIEW public.covid_pdf;

CREATE OR REPLACE VIEW public.covid_pdf AS
 SELECT sum(covid19.deaths) AS sum,
    covid19.file_date,
    covid19.country,
    sum(covid19.confirmed) - lag(sum(covid19.confirmed), 1) OVER (PARTITION BY covid19.country ORDER BY covid19.file_date) AS confirmed,
    sum(covid19.deaths) - lag(sum(covid19.deaths), 1) OVER (PARTITION BY covid19.country ORDER BY covid19.file_date) AS deaths,
    sum(covid19.recovered) - lag(sum(covid19.recovered), 1) OVER (PARTITION BY covid19.country ORDER BY covid19.file_date) AS recovered
   FROM covid19
  GROUP BY covid19.country, covid19.file_date
  ORDER BY covid19.country, covid19.file_date;

ALTER TABLE public.covid_pdf
    OWNER TO superset;


