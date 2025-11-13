--Analisis de datos

--para cada director que haya hecho, tanto peliculas como tv shows
--contar el numero de peliculas y tv shows creadas en columnas separadas
select nd.director,
count(distinct case when np.type = 'Movie' then np.show_id end) as cant_peliculas,
count(distinct case when np.type = 'TV Show' then np.show_id end) as cant_tvvshows
from netflix_stg as np
inner join [dbo].[netflix_director] as nd 
on np.show_id = nd.show_id
group by nd.director
having count(distinct np.type) > 1

--que pais tiene la mayor cantidad de peliculas del genero 'comedia'

select top 1 nc.country, count(distinct np.show_id) as numero_peliculas
from netflix_stg as np
inner join [dbo].[netflix_genre] as ng on np.show_id =ng.show_id
inner join [dbo].[netflix_country] as nc on np.show_id = nc.show_id
where ng.genre = 'Comedies' and np.type = 'Movie'
group by nc.country
order by numero_peliculas desc

---- por cada año (según la fecha de incorporación a Netflix), 
----¿qué director tiene el mayor número de películas estrenadas?
with cte as (
select year(n.date_added) as fecha_año, nd.director, count(n.show_id) as num_peliculas
from [dbo].[netflix_stg] as n
inner join [dbo].[netflix_director] as nd on n.show_id = nd.show_id
where n.type = 'Movie'
group by nd.director, year(n.date_added)
)
, cte2 as(
select *, 
ROW_NUMBER() over(partition by fecha_año order by num_peliculas desc, director) as rn
from cte 
)
select * from cte2
where rn=1



---Cual es el promedio de duracion de las peliculas en cada genero
select  ng.genre, avg(cast(replace(n.duration,' min', '') as int)) as avg_duration
from [dbo].[netflix_stg] as n
inner join [dbo].[netflix_genre] as ng on n.show_id = ng.show_id
where n.type = 'Movie'
group by ng.genre
order by avg_duration desc


--encontrar la lista de directores que han creado tanto películas de terror como de comedia.
-- mostrar los nombres de los directores junto con el número de películas de comedia y de terror 
--dirigidas por ellos.

select nd.director, count(n.show_id) as num_peliculas,
count(distinct case when ng.genre = 'Comedies' then n.show_id end ) as peliculas_comedia,
count(distinct case when ng.genre = 'Horror Movies' then n.show_id end ) as peliculas_terror
from [dbo].[netflix_stg] as n
inner join [dbo].[netflix_director] as nd on n.show_id = nd.show_id
inner join [dbo].[netflix_genre] as ng on n.show_id = ng.show_id
where n.type = 'Movie' and ng.genre in ('Comedies','Horror Movies')
group by nd.director
having count(distinct ng.genre) = 2
order by num_peliculas desc


