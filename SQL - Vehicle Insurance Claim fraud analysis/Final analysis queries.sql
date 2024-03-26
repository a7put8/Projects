############ Question 1 
############# What are the customer demographics in terms of gender and number of cars owned. Is there a relationship between them? #############
## Summary statistics of Customer Demographics ##
select distinct 
	Sex, 
    MaritalStatus,
	concat(round(count(Sex)*100/(select count(*) from customer),2),"%") as Counts
from 
	customer c1
group by
	Sex, MaritalStatus
order by
	 Sex, Counts desc, MaritalStatus;

## Relative customer percentages by Marital Status ##  
  
select distinct
	Sex,
    MaritalStatus,
	count(CustomerID) over () TotalCount,
    count(CustomerID) over (partition by Sex) GenderCounts,
    concat(round(count(CustomerID) over (partition by Sex) * 100 / count(CustomerID) over (),2),"%") GenderRatio,
    concat(round(count(CustomerID) over (partition by Sex, MaritalStatus) * 100 / count(CustomerID) over (partition by Sex),2),"%") Gender_Relative_Relationship_per
from
	customer
order by
	GenderRatio,Gender_Relative_Relationship_per desc;

## Is there a relationship between gender and Number of Cars? No ##

with CustVehicle as (
select 
	*,
    count(CustomerID) over (partition by Sex,NumberOfCars) * 100 / count(CustomerID) over (partition by Sex) Counts
from
	customer 
    inner join policy using(CustomerID)
    inner join policytypes using(PolicyTypeID)
)
select distinct 
    Sex,
    NumberOfCars,
    Counts
from 
	CustVehicle
 order by
	Sex,
    NumberOfCars, 
    Counts desc;

############################################################################################
############ Question 2
########### What are the attributes of customers whose claims were found to be fraudulent? ####

## Attributes of customers whose claims were found to be fraudulent ##

with fraud as (
select 
	*,
    concat(round (sum(FraudFound) over (partition by Sex) * 100 / count(CustomerID) over (partition by Sex),2), "%") pecent_fraud_gender
from 
	customer
    inner join policy using(CustomerID)
    inner join claim using(PolicyNumber)
)
select distinct
	sex,
    pecent_fraud_gender
from fraud;

## no gender bias in frauds commited ##

select distinct
	case when 
		FraudFound = 0 then "No Fraud"
        else "Fraud" 
        end as Was_Claim_Fraud,
	MaritalStatus,
	Sex,
	concat(round (sum(FraudFound) over (partition by FraudFound, MaritalStatus, Sex order by FraudFound) * 100 / count(CustomerID) over (partition by FraudFound, MaritalStatus),2), "%") pecent_fraud_gender
from 
	customer
    inner join policy using(CustomerID)
    inner join claim using(PolicyNumber);

## Male customers in general commit more fraud than females, but this trend is reversed in case of divorced females

with fraud1 as(
select 
	*,
    count(CustomerID) over (partition by Sex, MaritalStatus) Counts
from 
	customer 
    inner join policy using(CustomerID)
    inner join claim using(PolicyNumber)
    inner join policytypes using(PolicyTypeID)
where
	FraudFound = 1
)
select distinct
	Sex,
    MaritalStatus,
    first_value(NumberOfCars) over (order by Counts desc) Number_of_Vehicles
from
	fraud1
order by
	Sex, MaritalStatus;
## All categories of customers committing fraud own 1 car only. Hence, some extra caution would be needed for single car owner claims ###

#################################################################################################################

### Question 3
## Which are the top 5 most popular car makes and models enrolled with our firm for an insurance? #################

with temp as (
select 
	Make, count(PolicyNumber) count1
from 
	policy 
    inner join vehicle using(VehicleID)
group by 
	Make
order by 
	count1 desc
limit 5
),
temp2 as (
select 
	Make, 
    VehicleCategory, 
    count(*) count, 
    row_number() over (partition by Make order by count(*) desc) ranks
from 
	policy policy 
    inner join vehicle using(VehicleID)
group by
	Make, VehicleCategory
)
select
	temp2.Make,
    VehicleCategory,
    count,
    ranks
from 
	temp 
	inner join temp2 using(Make)
where 
	ranks = 1;

##############################################################################################

### Question 4
#### Are cars in certain price ranges more represented in our database than the others, i.e are expensive cars more likely to be insured with our than low range ones? Does this vary by car maker?

## Counts by price ranges ##
select
	VehiclePrice,
	count(PolicyNumber) counts
from
	policy 
    inner join vehicle using(VehicleID)
group by
	VehiclePrice
order by
	counts desc;

## Top make for each price range ##
with temp as(
select 
	VehiclePrice,
    Make,
    count(*) counts,
    row_number() over (partition by VehiclePrice order by count(*) desc) ranks
from 
	policy 
    inner join vehicle using(VehicleID)
group by
	VehiclePrice, Make
)
select 	
	*
from
	temp 
where 
	ranks = 1;
    
### Top price category for each make
with temp as(
select 
	VehiclePrice,
    Make,
    count(*) counts,
    row_number() over (partition by Make order by count(*) desc) ranks
from 
	policy 
    inner join vehicle using(VehicleID)
group by
	Make, VehiclePrice
)
select 	
	*
from
	temp 
where 
	ranks = 1;

####################################################################################################
## Question 5
## Does marital status determine the type of car and insurance owned?

select 
    c.MaritalStatus, 
    v.VehicleCategory, 
    p.PolicyType, 
    count(*) * 100 / total.count as relative_percentage,
	rank() over (partition by MaritalStatus order by count(*) * 100 / total.count desc) Ranks
from 
    customer c
	inner join 
    policy on c.CustomerID = policy.CustomerID
	inner join 
    policytypes p on policy.PolicyTypeID = p.PolicyTypeID
	inner join 
    vehicle v on policy.VehicleID = v.VehicleID
	inner join 
    (select 
         MaritalStatus, 
         count(*) as count 
     from 
		customer 
     group by 
		MaritalStatus) total on c.MaritalStatus = total.MaritalStatus
group by 
    c.MaritalStatus, 
    v.VehicleCategory, 
    p.policytype, 
    total.count
order by
	MaritalStatus, relative_percentage desc;

## Divorced customers more likely to own Sports cars
## Married, singles and widowed customers mostly own Sedans
## MArital status does determine type of car owned and Policy type
    
##################################################################################
## Question 6
#### Who are our top 2 and bottom 2 performing agents in terms of the number of policies sold?
(select
	AgentID,
	rank() over (order by count(CustomerID) desc) Ranks,
    count(CustomerID) count_of_policies_sold
from 
	agent
	inner join policy using(AgentID)
group by
	AgentID
order by
	count_of_policies_sold desc
limit 2 )
union all
(select
	AgentID,
	rank() over (order by count(CustomerID) desc) Ranks,
    count(CustomerID) count_of_policies_sold
from 
	agent
	inner join policy using(AgentID)
group by
	AgentID
order by
	count_of_policies_sold asc
limit 2);

## Top 2 - Agents 7-E and 9-E
## Bottom 2 - Agents 3-I and 16-I

#############################################################################

## Question 7
### Is there any seasonality in accidents? Are there certain months when more accidents occur? What is the YoY change in accident-related claims?

with temp as(
select
	year(Date) Yr,
	month(Date) Mon,
    count(AccidentID) counts
from
	accident
group by
	year(Date),month(Date)
order by
	Yr,Mon
), temp2 as(
select
	t1.Yr prev_yr,
    t1.Mon prev_yr_mon,
    t1.counts acc_last_yr,
    t2.Yr current_yr,
    t2.Mon current_yr_mon,
    t2.counts acc_current_yr
from
	temp t1
    inner join temp t2 on t1.Yr + 1 = t2.Yr and t1.Mon = t2.Mon
)
select 
	prev_yr,
    current_yr,
	current_yr_mon,
    case when
		acc_current_yr > acc_last_yr then "Increase"
        else "Same or less"
        end Acc_count_status,
		concat(round((acc_current_yr - acc_last_yr) * 100/acc_last_yr,2),"%") YoY_percent_change
	from
		temp2;
## YoY trend in accident claims declining ##

select
	month(Date) Mon,
    monthname(Date) MonthName,
	year(Date) as Year,
    count(AccidentID) Accident_counts
from
	accident
group by
	year(Date),month(Date),monthname(Date)
order by
	Year, Mon;
## No particular seasonality observed in accident claims ##

###############################################################################################

## Question 8
## Are sports cars more likely to be involved in accidents? Where do most of these accidents occur

select distinct
	VehicleCategory,
    count(AccidentID) over (partition by VehicleCategory)
from
	vehicle
    inner join policy using(VehicleID)
	inner join claim using(PolicyNumber);
    
## We have more sedans involved in accidents compared to the other vehicle categories ##

with temp as(
select
	AccidentID,
    VehicleCategory,
    FraudFound,
    ClaimID,
    PolicyNumber,
    AccidentArea
from
	vehicle
    inner join policy using(vehicleID)
    inner join claim using(PolicyNumber)
    inner join accident using(AccidentID)
)
select distinct
	VehicleCategory,
    AccidentArea,
	count(AccidentID) over (partition by VehicleCategory, AccidentArea) * 100 / count(AccidentID) over () Percent_Accident
from
	temp;
## Ursurprisingly Uban accidents are more common than rural with sedans being involved in more accidents than othe categories ##

###################################################################################################

## Question 9
## Is a claim more likely to be a fraudulent in the absence of a witness and if police report wasn’t filed?

with temp as(
select 
	ClaimID,
    AccidentID,
    InvestigationID,
    PoliceReportFiled,
    WitnessPresent,
    FraudFound
from
	claim 
    inner join accident using(AccidentID)
    inner join investigation using(InvestigationID)
)
select distinct
	PoliceReportFiled,
    WitnessPresent,
    sum(FraudFound) over (partition by PoliceReportFiled, WitnessPresent) *100/ sum(FraudFound) over () percent_fraud
from 
	temp;

## A claim is highly likely to be fraudulent if there was not witness and if no police report was filed

############################################################################################

### Question 10
### Which are the top 3 policy types and their area of accident

with temp as(
select 
    PolicyType,
    AccidentArea,
    count(*) Acc_counts,
    rank() over (partition by AccidentArea order by count(*) desc) ranks
from
	policytypes inner join policy using(PolicyTypeID)
    inner join claim using(PolicyNumber)
    inner join accident using(AccidentID)
    inner join investigation using(InvestigationID)
group by
	 PolicyType, AccidentArea
)
 
select distinct
	PolicyType,
    AccidentArea,
    ranks	
from
	temp
where ranks <=3;

## Sedan collision are most frequently involved in accidents in both rural and urban areas
    