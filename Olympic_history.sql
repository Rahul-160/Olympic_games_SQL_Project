select * from athlete_events
select * from athletes

--1 which team has won the maximum gold medals over the years.

select top 1 a.team, count(*)
from athlete_events ae
join athletes a
on ae.athlete_id = a.id
where ae.medal = 'gold'
group by a.team
order by count(*) desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
with cte as(
select a.team as team, ae.year as year, count(*) as total_silver_medals,
       rank() over(partition by team order by count(*) desc) as rn
from athlete_events ae
join athletes a on ae.athlete_id = a.id
where ae.medal = 'silver'
group by a.team, ae.year)

select max(case when rn=1 then year end) as year_of_max_silver,sum(total_silver_medals) as total_silver_medals, team
from cte
group by team
order by total_silver_medals desc

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

select top 1 a.name , count(*) as no_of_gold--a.team as team, ae.year as year, count(*) as total_silver_medals
from athlete_events ae
join athletes a
on ae.athlete_id = a.id
where name not in (select distinct a.name from  athlete_events ae
                   join athletes a
                   on ae.athlete_id = a.id where ae.medal in ('Silver','Bronze'))
and ae.medal='Gold'
group by a.name
order by count(*) desc

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte as(
select a.name, ae.year, rank() over(partition by year order by count(ae.medal) desc) as rn, count(*) as no_of_golds_won
from athlete_events ae
join athletes a
on ae.athlete_id = a.id
where ae.medal not in ('silver','bronze','na') 
group by a.name, ae.year)

select year, string_agg(name,'|'), sum(no_of_golds_won) as no_of_golds_won
from cte
where rn = 1
group by year,no_of_golds_won
order by year


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

with cte as(
select *   --,  max(case when medal = 'gold' then year end) as year1 --, sport
from athlete_events ae
join athletes a
on ae.athlete_id = a.id
where a.team = 'india' and ae.medal != 'na'
),

cte2 as(
select *, rank() over(partition by medal order by year) as rn
from cte)

select distinct year, medal,sport
from cte2
where rn = 1

--6 find players who won gold medal in summer and winter olympics both.

select a.name   --,  max(case when medal = 'gold' then year end) as year1 --, sport
from athlete_events ae
join athletes a
on ae.athlete_id = a.id
where medal = 'gold'
group by a.name
having count(distinct season) = 2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select a.name , year  
from athlete_events ae
join athletes a
on ae.athlete_id = a.id
where medal != 'na'
group by year,a.name
having count(distinct medal) = 3


--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

--method 1

with cte as(
select a.name as name,year, rank() over(partition by a.name order by ae.year) as rn --,string_agg(year,','), count(*)
from athlete_events ae
join athletes a
on ae.athlete_id = a.id
where medal = 'gold' and season = 'summer' and  year >= 2000
),

cte2 as(
select *, row_number() over(order by name) -rn as diff
from cte)

select name, string_agg(year,',')
from cte2
group by name,diff
having count(*) = 3

--method 2

with cte as (
select name,year,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)

select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4













