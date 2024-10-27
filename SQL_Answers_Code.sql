-- create database Pinnacle_Realty_Group;

use pinnacle_realty_group;

/*
Preliminary Analysis:
1. How many of each property type does Pinnacle have 
2. What are the locations that Pinnacle have properties? How many of each property type do they have in each of the cities?
*/

select * from properties;
select distinct property_type from properties order by 1; -- Office, Retail, Industrial and Residential
select distinct location from properties order by 1; -- All the locations where Pinnacle have properties
select count(distinct location) from properties; -- Pinnacle has properties in 491 locations

select
	*,
    round(count_of_properties/sum(count_of_properties) over(),2) as proportional_of_count
from (
	select 
		property_type, 
		count(*) as count_of_properties 
	from properties 
	group by property_type 
	order by 2 desc
    ) as sub; -- Around 56% of the portfolio is made up of Industrial and Residential Properties
    
/*
QUESTION 1: 
The leasing department wants to track rent growth for each property over time. Calculate
the cumulative rent amount for each property, ordered by lease start date.
 */    
 
 /*
 select * from leases;
 select count(distinct property_id) from leases; -- 492 properties returned
 select count(distinct property_id) from properties; -- 500 properties returned. This probably means 8 properties did not lease.
 */
 
 create view properties_leases_table as (
	 select
		p.property_id as property_id,
        p.property_name as property_name,
        p.property_type as property_type,
        p.size_sqft as size_sqft,
        p.location as location,
        l.lease_id as lease_id,
        l.tenant_name as tenant_name,
        l.lease_start as lease_start,
        l.lease_end as lease_end,
        l.rent_amount as rent_amount
	 from properties as p
	 left join leases as l
	 using(property_id)
     ); -- This view joins properties and leases table for lease info (like rent) and property info (like property name)

select 
	property_name,
    lease_start,
    rent_amount,
    sum(rent_amount) over(partition by property_name order by lease_start) as cumulative_rent
from properties_leases_table
where lease_id is not null; 

/*
QUESTION 2:
Management is interested in knowing the properties generating the most revenue. Rank
properties by their total rent revenue generated, grouped by property type.
*/

select 
	property_type,
    property_name,
    sum(rent_amount) as total_rental_revenue,
    dense_rank() over(partition by property_type order by sum(rent_amount) desc) as rental_revenue_ranking
from properties_leases_table
where lease_id is not null
group by property_type, property_name;

/* 
QUESTION 3:
Pinnacle Realty Group's CEO wants a report on the top-performing properties based on
transactions. Find the top 5 most profitable properties in terms of total transactions and
rank them.
*/

create view properties_transactions_table as (
	select
		property_name,
		property_type,
		size_sqft,
		location,
		transaction_type,
		transaction_date, 
		amount as transaction_amount
	from properties as p
	inner join transactions as t
	using(property_id)
    );
    
select 
	property_name,
    transaction_type,
    transaction_date,
    transaction_amount
from properties_transactions_table
order by property_name, transaction_date;
    
/*
QUESTION 4:
Leasing managers need insight into rent trends to adjust lease pricing. For each property,
determine the rolling average rent amount over the last 3 leases
*/

select 
	property_name,
    tenant_name,
    rent_amount,
    lease_start,
    round(avg(rent_amount) over( partition by property_name order by lease_start rows between 2 preceding and current row))
    as _3leases_rolling_average
from properties_leases_table
where lease_id is not null;

/*
QUESTION 5:
Maintenance costs are rising, and management wants to identify high-cost properties.
Calculate the percentage of total maintenance costs per property and rank properties by
this percentage.
*/

create view properties_maintenance_table as (
	select 
		property_name,
		property_type,
		size_sqft,
		location,
		maintenance_type,
		maintenance_date,
		cost as maintenance_cost
	from properties as p
	left join maintenance_logs as ml
	using(property_id)
    ); -- Joining properties and maintenance tables to get property names and maintenance cost

-- This CTE finds the percentage cost of every property relative to the overall cost of maintenance
with maintable as (
	select
		property_name,
		maintenance_cost_per_property,
		maintenance_cost_per_property/sum(maintenance_cost_per_property) over() as pct_cost
	from (
		select 
			property_name,
			sum(maintenance_cost) as maintenance_cost_per_property
		from properties_maintenance_table
		group by property_name
		) as sub
        )
-- This code ranks properties based on their pct_cost
select
	property_name,
    pct_cost,
    maintenance_cost_per_property,
    dense_rank() over(order by pct_cost desc) as cost_ranking_per_property
from maintable;

/*
QUESTION 6:
 To manage tenant satisfaction, leasing agents need to understand rent adjustments.
Identify properties with rent increases over consecutive leases using window functions.
*/

with table1 as (
	select
		property_name,
		lease_start,
		rent_amount as rent_curr_lease,
		lag(rent_amount) over(partition by property_name order by lease_start) as rent_prev_lease
	from (
		select 
			property_name,
			property_type,
			tenant_name,
			lease_start,
			lease_end,
			timestampdiff(month, lease_start, lease_end) as lease_term,
			rent_amount
		from properties_leases_table
		where lease_id is not null
		order by property_name, property_type,lease_start
		) as sub
        ),
        
    table2 as (    
	select
		*,
		ifnull(rent_curr_lease - rent_prev_lease, 'N/A') as rent_increase_from_prev_lease
	from table1
    )

select distinct property_name
from table2
where rent_increase_from_prev_lease > 0;

/*
QUESTION 7: * The order of transaction is ambiguous
Investment advisors need to evaluate the latest transactions for properties. For each
property, determine the three most recent transactions and calculate the average
transaction amount.
*/

select
	*
from (
	select 
		property_name,
		transaction_type,
		transaction_date,
		transaction_amount,
		rank() over(partition by property_name order by transaction_date desc) as transaction_recency
	from properties_transactions_table
    ) as sub
where transaction_recency < 4;

/*
QUESTION 8:
Maintenance staff needs to know which properties require more frequent servicing.
Determine the properties with the highest average maintenance cost over the last year.
*/

select
	property_name,
    round(avg(maintenance_cost)) as avg_maintenance_cost
from (
	select 
		property_name,
		maintenance_date,
		maintenance_cost
	from properties_maintenance_table
	where maintenance_date between date_sub(curdate(), interval 12 month) and curdate()
	order by maintenance_date
    ) as sub
group by property_name
order by avg_maintenance_cost desc;

/*
QUESTION 9:
The leasing team wants to understand tenant loyalty by analyzing lease durations.
Calculate the tenure of each tenant and find the average tenure for each property type
*/

-- This code returns the tenure of each tenant in months and years
select 
	tenant_name,
    sum(timestampdiff(month, lease_start, lease_end)) as lease_tenure_months,
    sum(timestampdiff(year, lease_start, lease_end)) as lease_tenure_years
from properties_leases_table
group by tenant_name
order by lease_tenure_months desc;

-- This query returns the average tenure for each property type in months and years
select
	property_type,
    round(avg(timestampdiff(month, lease_start, lease_end)),1) as avg_tenure_months,
    round(avg(timestampdiff(year, lease_start, lease_end)),1) as avg_tenure_years
from properties_leases_table
group by property_Type
order by avg_tenure_months desc;

/*
QUESTION 10: *
. Investment managers need to see cash flow trends from transactions. Calculate the
moving sum of transactions over the last 12 months for each property.
*/

/*
QUESTION 11: 
To optimize resources, managers want to know the most frequently leased properties.
Rank properties based on the number of leases and identify the top 10 most leased
properties.
*/

select
	*
from (
	select 
		property_name,
		count(*) as lease_count,
		dense_rank() over(order by count(*) desc) as lease_count_ranking
	from properties_leases_table
	where lease_id is not null
	group by property_name
    ) as sub
where lease_count_ranking < 11;

/*
QUESTION 12: 
Property managers are being evaluated on maintenance efficiency. For each property
manager, calculate the average maintenance cost across their assigned properties.
*/

create view properties_managers_table as (
	select
		p.property_id as property_id,
		property_name,
		property_type,
		manager_name,
		maintenance_type,
		maintenance_date,
		cost as maintenance_cost
	from properties as p
	inner join managers as m
	on p.property_id = m.assigned_property
	inner join maintenance_logs as ml
	on p.property_id = ml.property_id
    );

select 
	manager_name,
    round(avg(maintenance_cost),2) as avg_maintenance_cost
from properties_managers_table
group by manager_name
order by avg_maintenance_cost desc;

/*
QUESTION 13: 
The finance team wants to assess lease stability by duration. Identify the properties with
the longest active leases by calculating the difference between lease start and end dates.
*/

select
	property_name,
    timestampdiff(month, lease_start, lease_end) as lease_length_months,
    timestampdiff(year, lease_start, lease_end) as lease_length_years
from properties_leases_table
where lease_id is not null
order by lease_length_months desc;

/*
QUESTION 14: ** 
The board wants an annual summary of leasing activity for strategic planning.
Determine the cumulative number of leases for each property by year, ordered by lease
start date.
*/

select
	property_name, 
    lease_start,
    lease_start_year,
    count(*) over(partition by property_name order by lease_start) as cumulative_lease_count
from (
	select
		property_name,
		lease_start,
		year(lease_start) as lease_start_year
	from properties_leases_table
	where lease_id is not null
    ) as sub;
    
/*
QUESTION 15: *
Investment advisors are interested in high-value properties within each category.
Calculate the 90th percentile of transaction amounts for each property type.
*/

/*
QUESTION 16:
Maintenance planners need to identify properties with recurring issues. Identify
properties with consecutive maintenance activities of the same type (e.g., consecutive
plumbing issues).
*/

select distinct
	property_name
from (
	select 
		property_name,
		maintenance_date,
		maintenance_type as curr_issue,
		lag(maintenance_type) over(partition by property_name order by maintenance_date) as prev_issue
	from properties_maintenance_table
    ) as sub
where curr_issue = prev_issue;

/*
QUESTION 17:
To analyze revenue distribution, finance needs property type revenue percentages. Find
the total rent revenue for each property, then calculate the percentage of total revenue for
each property type.
*/

select
	property_name,
    property_type,
    property_rent_revenue,
    round(property_rent_revenue/sum(property_rent_revenue) over() * 100,2) as rent_rev_as_percent_of_total,
    round(property_rent_revenue/sum(property_rent_revenue) over(partition by property_type) * 100,2) as rent_rev_as_percent_of_propType_total
from (
	select 
		property_name,
		property_type,
		sum(rent_amount) as property_rent_revenue
	from properties_leases_table
	where lease_id is not null
	group by property_name, property_type
    ) as sub;

/*
QUESTION 18:
Leasing agents need to track rent changes over time to understand market trends.
Calculate the difference in rent between consecutive leases for each property, and flag
increases or decreases.
*/

with maintable as (
	select
		property_name,
		lease_start,
		ifnull(curr_lease_rent - prev_lease_rent, 'N/A') as rent_change_from_prev_lease
	from (
		select 
			property_name,
			lease_start,
			rent_amount as curr_lease_rent,
			lag(rent_amount) over(partition by property_name order by lease_start) as prev_lease_rent
		from properties_leases_table
		) as sub
        )

select
	*,
    case
		when rent_change_from_prev_lease < 0 then 'rent decreased'
        when rent_change_from_prev_lease > 0 then 'rent_increased'
        else 'No previous month record'
	end as rent_change
from maintable;

/*
QUESTION 19:
Management wants to know which property managers bring in the most revenue. Rank
property managers by the total revenue generated from properties they manage.
*/

-- Joining two views: properties_managers_table and properties_leases_table to get information about both managers and revenue
with maintable as (
    select 
		manager_name,
		sum(rent_amount) as total_revenue_generated
	from properties_managers_table as pm
	inner join properties_leases_table as pl
	using(property_id)
	group by manager_name
    )

select
	manager_name,
    total_revenue_generated,
    dense_rank() over(order by total_revenue_generated desc) as manager_ranking_by_revenue
from maintable;

/*
QUESTION 20:
Leasing agents want to analyze recent rent prices to set competitive rates. For each
property, calculate the average rent for the top 3 most recent leases.
*/

-- First, partition the by property_name, find the top three most recent leases then calculate the average rent

-- This SELECT statement averages the 3 most recent leases per property
select
	property_name,
    round(avg(rent_amount)) as avg_3latest_leases
from (
    select 
		property_name,
		lease_start,
		rent_amount,
		rank() over(partition by property_name order by lease_start desc) as rank_by_latest_to_oldest_lease
	from properties_leases_table
	where lease_id is not null
    ) as sub -- This subquery ranks leases from latest to oldest per property
where rank_by_latest_to_oldest_lease < 4 -- Fetches only top 3 most recent leases per property from the subquery
group by property_name 