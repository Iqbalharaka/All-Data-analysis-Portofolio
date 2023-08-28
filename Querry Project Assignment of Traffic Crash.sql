Dataset: City bike lane data
--Source: Refocus Data Analytics Bootcamps Course
--Queried using: PGadmin4

select * from crash


--Data_cleansing
alter table crash add column local_time timestamp ;
update crash set local_time =
(
case
when state_name in ('Alaska') then timestamp_of_crash at time zone 'akst'
when state_name in ('Alabama','Arkansas','Illinois','Iowa','Louisiana','Minnesota','Mississippi','Missouri','Oklahoma','Wisconsin','Kansas','Nebraska','North Dakota','South Dakota','Texas')
then timestamp_of_crash at time zone 'cst'
when state_name in ('Connecticut','Delaware','Georgia','Maine','Maryland','Massachusetts','New Hampshire','New Jersey','New York','North Carolina','Ohio','Pennsylvania','Rhode Island','South Carolina','Vermont','Virginia',
'West Virginia', 'District of Columbia','Florida','Indiana','Kentucky','Michigan','Tennessee')
then timestamp_of_crash at time zone 'est'
when state_name in ('Hawaii') then timestamp_of_crash at time zone 'hst'
when state_name in ('Arizona','Colorado','Montana','New Mexico','Utah','Wyoming','Idaho')
then timestamp_of_crash at time zone 'mst'
when state_name in ('California','Washington','Nevada','Oregon') then timestamp_of_crash at time zone 'pst'
end
)
from crash


update crash
set city_name = 'Others'
where city_name in ('Unknown','Other','Not Reported','NOT APPLICABLE')

update crash 
set land_use_name = 'Others'
where land_use_name   in ('Unknown','Not Reported','Trafficway Not in State Inventory')

update crash
set functional_system_name = 'Others'
where functional_system_name in ('Unknown','Not Reported')

update crash
set manner_of_collision_name = 'Others'
where manner_of_collision_name in ()'Reported as Unknown','Not Reported','Other','Rear-to-Rear', 'Rear-to-Side')

update crash
set manner_of_collision_name = 'Sideswipe'
where manner_of_collision_name in ('Sideswipe - Same Direction', 'Sideswipe - Opposite Direction')

update crash
set type_of_intersection_name = 'Others'
where type_of_intersection_name in ('Reported as Unknown','Not Reported')

update crash
set light_condition_name = 'Others'
where light_condition_name in ('Reported as Unknown','Not Reported','Other','Unknown Lighting')

update crash
set atmospheric_conditions_1_name = 'Others'
where atmospheric_conditions_1_name in ('Reported as Unknown','Other','Not Reported')




--number of accidents by region
select 
		state_name, count(consecutive_number) Accidents  
		from crash
		where local_time >= '2021-01-01' and local_time <= '2021-12-31'
		group by state_name
		order by count(consecutive_number) desc
		limit 10	
		
--AVG of accidents per hour
select hours, count(*)/avg(totalday) as Accidents
from
	(select to_char(local_time,'hh24') as hours,
		extract(day from max(local_time)over ()-min(local_time) over()) +1 as totalday 
		from crash
	 where local_time >= '2021-01-01' and local_time <= '2021-12-31') as x
group by 1
order by hours 
		
		
--SUM of accidents per day

select distinct 
		extract(DAY from(local_time))DAYS ,count(consecutive_number) as Accident 
		from crash
		where local_time >= '2021-01-01' and local_time <= '2021-12-31'
		group by extract(DAY from(local_time))
		order by  extract(DAY from(local_time))

--SUM of accidents per month
select distinct
	extract (MONTH from(local_time)) MONTHS, count(consecutive_number) as Accident
	from crash
	where local_time >= '2021-01-01' and local_time <= '2021-12-31'
	group by extract (MONTH from(local_time))
	order by extract (MONTH from(local_time))
	
	
--SUM_accident_weekday
SELECT to_char(local_time, 'Day') Hari , COUNT(consecutive_number) total_kecelakaan
FROM crash
where local_time >= '2021-01-01' and local_time <= '2021-12-31'
GROUP BY to_char(local_time, 'Day')
ORDER BY  COUNT(consecutive_number) DESC

--Percentage crash urban vs rural
select 
		land_use_name, count(consecutive_number) Accidents  
		from crash
		where land_use_name in ('Rural','Urban') and  local_time >= '2021-01-01' and local_time <= '2021-12-31'
		group by land_use_name
		
--Percentage number_drunk_drivers
select 
		number_of_drunk_drivers, count(consecutive_number) Accidents 
		from crash 
		where local_time >= '2021-01-01' and local_time <= '2021-12-31'
		group by  number_of_drunk_drivers
		order by number_of_drunk_drivers
		
--Road Accident in AMERICA In 2021
select 
		extract(MONTH from(local_time)) Months ,count(consecutive_number) as Accident,
		sum(number_of_vehicle_forms_submitted_all) Vehicle ,
		sum(number_of_forms_submitted_for_persons_not_in_motor_vehicles) as Pedestrian, 
		sum(number_of_fatalities) No_of_Fatalities
		from crash
		where local_time >= '2021-01-01' and local_time <= '2021-12-31'  
		group by  extract(MONTH from(local_time))
		order by  extract(MONTH from(local_time))

-- External Issues Crash Distribution 
select distinct
		atmospheric_conditions_1_name As Weather_condition ,light_condition_name as Light_condition, manner_of_collision_name,
		Count(consecutive_number) Accidents
		from crash
		where atmospheric_conditions_1_name not in ('Others') and light_condition_name not in ('Others') and manner_of_collision_name not in ('Others')
		and local_time >= '2021-01-01' and local_time <= '2021-12-31'
		group by atmospheric_conditions_1_name, light_condition_name, manner_of_collision_name
		order by Count(consecutive_number) desc




