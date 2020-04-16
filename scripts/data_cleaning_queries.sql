

update covid19
set country = 'China'
where country = 'Mainland China';


update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where province = covid_lookup.province_state and country = covid_lookup.country_region ;


-- us states 
update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where province = covid_lookup.province_state and country = covid_lookup.country_region and  
covid_lookup.admin2 is NULL;

-- simple countries 
update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = covid_lookup.country_region and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- UK 

update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'UK' and covid_lookup.country_region = 'United Kingdom'and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- South Korea 
update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'South Korea' and covid_lookup.country_region = 'Korea, South' and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- UK 

update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'UK' and covid_lookup.country_region = 'United Kingdom'and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- Czechia
update covid19
set country = 'Czech Republic'
where country = 'Czechia';

-- Taiwan 
-- see https://www.axios.com/johns-hopkins-coronavirus-map-taiwan-china-5c461906-4f1c-42e7-b78e-a4b43f4520ab.html

-- Taiwan Coordinates
update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'Taiwan' and covid_lookup.country_region in ('Taiwan*', 'Taipei and environs') and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- Taiwan Name
update covid19
set country = 'Taiwan'
where country in ('Taiwan*', 'Taipei and environs');

-- Palestine
update covid19
set country = 'Palestine'
where country in ('Palestine', 'occupied Palestinian territory');

-- Vietnam
update covid19
set country = 'Vietnam'
where country in ('Vietnam', 'Viet Nam');

-- Hong Kong, Macau 
update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_, country ='China'
from covid_lookup
where country = 'Macau' and 
province = 'Macau'
and covid_lookup.province_state = 'Macau';

update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_, country ='China'
from covid_lookup
where country = 'Hong Kong' and 
province = 'Hong Kong'
and covid_lookup.province_state = 'Hong Kong';

-- Gambia
update covid19
set country = 'Gambia'
where country like ('%Gambia%');

-- Iran
update covid19
set country = 'Iran'
where country like ('%Iran%');

-- South Korea'
update covid19
set country = 'South Korea'
where country like ('%Korea%');


update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'South Korea' and covid_lookup.country_region in ('Korea, South') and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- Azerbaijan 

update covid19
set country = 'Azerbaijan'
where country like ('%Azerbaijan%');


update covid19 
set latitude  = 40.1431 , longitude =47.5769
where country = ' Azerbaijan';

-- Cote d'Ivoire 
update covid19
set country = 'Ivory Coast'
where country like ('Cote%');

update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'Ivory Coast' and covid_lookup.country_region LIKE 'Cote%' and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- US 

update covid19
set country = 'United States'
where country = 'US';

-- Fix old US province

with clean_province 
as
(
select distinct  
case 
when array_length(regexp_split_to_array(province, ','),1) = 1
then province
when array_length(regexp_split_to_array(province, ','),1) = 2
then (select state_abbreviation.state 
from 
state_abbreviation
where 
trim((regexp_split_to_array(province, ','))[2]) = abbr)
end province,
province as province_old
from covid19 where country = 'United States')
update covid19
set province = clean_province.province
from clean_province
where 
covid19.province = clean_province.province_old;