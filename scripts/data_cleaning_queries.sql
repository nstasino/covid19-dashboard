
UPDATE covid19
SET country = 'China'
WHERE country = 'Mainland China';


UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE province = covid_lookup.province_state
  AND country = covid_lookup.country_region ;

 -- us states

UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE province = covid_lookup.province_state
  AND country = covid_lookup.country_region
  AND covid_lookup.admin2 IS NULL;

 -- simple countries

UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE country = covid_lookup.country_region
  AND covid_lookup.admin2 IS NULL
  AND covid_lookup.province_state IS NULL;

 -- UK

UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE country = 'UK'
  AND covid_lookup.country_region = 'United Kingdom'
  AND covid_lookup.admin2 IS NULL
  AND covid_lookup.province_state IS NULL;

 -- South Korea

UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE country = 'South Korea'
  AND covid_lookup.country_region = 'Korea, South'
  AND covid_lookup.admin2 IS NULL
  AND covid_lookup.province_state IS NULL;

 -- UK

UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE country = 'UK'
  AND covid_lookup.country_region = 'United Kingdom'
  AND covid_lookup.admin2 IS NULL
  AND covid_lookup.province_state IS NULL;

 -- Czechia

UPDATE covid19
SET country = 'Czech Republic'
WHERE country = 'Czechia';

 -- Taiwan
-- see https://www.axios.com/johns-hopkins-coronavirus-map-taiwan-china-5c461906-4f1c-42e7-b78e-a4b43f4520ab.html
 -- Taiwan Coordinates

UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE country = 'Taiwan'
  AND covid_lookup.country_region IN ('Taiwan*',
                                      'Taipei and environs')
  AND covid_lookup.admin2 IS NULL
  AND covid_lookup.province_state IS NULL;

 -- Taiwan Name

UPDATE covid19
SET country = 'Taiwan'
WHERE country IN ('Taiwan*',
                  'Taipei and environs');

 -- Palestine

UPDATE covid19
SET country = 'Palestine'
WHERE country IN ('Palestine',
                  'occupied Palestinian territory');

 -- Vietnam

UPDATE covid19
SET country = 'Vietnam'
WHERE country IN ('Vietnam',
                  'Viet Nam');

 -- Hong Kong, Macau

UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_,
    country ='China'
FROM covid_lookup
WHERE country = 'Macau'
  AND province = 'Macau'
  AND covid_lookup.province_state = 'Macau';


UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_,
    country ='China'
FROM covid_lookup
WHERE country = 'Hong Kong'
  AND province = 'Hong Kong'
  AND covid_lookup.province_state = 'Hong Kong';

 -- Gambia

UPDATE covid19
SET country = 'Gambia'
WHERE country LIKE ('%Gambia%');

 -- Iran

UPDATE covid19
SET country = 'Iran'
WHERE country LIKE ('%Iran%');

 -- South Korea'

UPDATE covid19
SET country = 'South Korea'
WHERE country LIKE ('%Korea%');


UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE country = 'South Korea'
  AND covid_lookup.country_region IN ('Korea, South')
  AND covid_lookup.admin2 IS NULL
  AND covid_lookup.province_state IS NULL;

 -- Azerbaijan

UPDATE covid19
SET country = 'Azerbaijan'
WHERE country LIKE ('%Azerbaijan%');


UPDATE covid19
SET latitude = 40.1431 , longitude =47.5769
WHERE country = ' Azerbaijan';

 -- Cote d'Ivoire

UPDATE covid19
SET country = 'Ivory Coast'
WHERE country LIKE ('Cote%');


UPDATE covid19
SET latitude = covid_lookup.lat ,
    longitude = covid_lookup.long_
FROM covid_lookup
WHERE country = 'Ivory Coast'
  AND covid_lookup.country_region LIKE 'Cote%'
  AND covid_lookup.admin2 IS NULL
  AND covid_lookup.province_state IS NULL;

 -- US

UPDATE covid19
SET country = 'United States'
WHERE country = 'US';

 -- Fix old US province
 WITH clean_province AS
  (SELECT DISTINCT CASE
                       WHEN array_length(regexp_split_to_array(province, ','),1) = 1 THEN province
                       WHEN array_length(regexp_split_to_array(province, ','),1) = 2 THEN
                              (SELECT state_abbreviation.state
                               FROM state_abbreviation
                               WHERE trim((regexp_split_to_array(province, ','))[2]) = abbr)
                   END province,
                       province AS province_old
   FROM covid19
   WHERE country = 'United States')
UPDATE covid19
SET province = clean_province.province
FROM clean_province
WHERE covid19.province = clean_province.province_old;