

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



-- Taiwan 
update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'Taiwan' and covid_lookup.country_region = 'Taiwan*' and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

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


-- Azer 


update covid19 
set latitude  = 40.1431 , longitude =47.5769
where country = ' Azerbaijan';

-- Cote d'Ivoire 

update covid19 
set latitude  = covid_lookup.lat , longitude = covid_lookup.long_ 
from covid_lookup
where country = 'Ivory Coast' and covid_lookup.country_region LIKE 'Cote%' and  
covid_lookup.admin2 is NULL AND  covid_lookup.province_state iS NULL;

-- US 

update covid19
set country = 'United States'
where country = 'US';