---duplicados x titulo
select * from [dbo].[Netflix]
where concat(title,type) in 
(
select concat(title,type) 
from  [dbo].[Netflix] 
group by title,type
having count(*) > 1)
order by title 


with cte as (
select ROW_NUMBER() over (partition by title, type order by show_id) as rn,*
from [dbo].[Netflix])
select * from cte
where rn = 1;

--nueva tabla normalizada para director, cast, country, listed in

select show_id, trim(value) as genre
into netflix_genre
from [dbo].[Netflix]
cross apply string_split(listed_in,',');

--- Cambiar el formato de 'date_added' a date

with cte as (
select ROW_NUMBER() over (partition by title, type order by show_id) as rn,*
from [dbo].[Netflix])
select show_id, title, cast(date_added as date) as date_added, release_year,
rating, duration, description
from cte
where rn = 1;

-- Reemplazar valores nulos en director, duration
insert into [dbo].[netflix_country]
select show_id, m.country
from [dbo].[Netflix] as n
inner join (
select d.director, c.country
from [dbo].[netflix_country] as c
inner join [dbo].[netflix_director] as d on c.show_id = d.show_id
group by d.director, c.country
) as m on m.director = n.director
where n.country is null

select * from [dbo].[Netflix]
where duration is null

with cte as (
select ROW_NUMBER() over (partition by title, type order by show_id) as rn,*
from [dbo].[Netflix])
select show_id,type, title, cast(date_added as date) as date_added, release_year,
rating, case when duration is null then rating else duration end as duration , description
into netflix_stg
from cte
where rn = 1;

select * from netflix_stg

