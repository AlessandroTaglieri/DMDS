

#DATABASE is UPDATED UP TO 2011



1)
#highSchool name and count of players gives by each highSchool
select highSchool, count(1)	
from players
where highSchool is not null
group by highSchool 
order by count(1) desc

2)
#name,lastname,id and total points scored by the best 10 players (who scored most)
select firstname,lastName,a.playerid, sum(a.points)
from players_teams a
inner join players b on a.playerid = b.playerid
group by a.playerid
order by sum(a.points) desc
limit 10;


4)
#the best 10 players who scored the most but never played in all star match
select b.firstname,b.lastName,sum(a.points) total_points
from Basketball.players_teams a
inner join Basketball.players b on a.playerid = b.playerid
where a.playerid not in( 
					select distinct playerid
                    from Basketball.player_allstar
                    )
group by a.playerid  
order by total_points desc
limit 10


6)
#the player who won the most awards for each category, in case of draw between PLAYERS, select the younger one


with count_awards as(
select a.playerid,b.firstname,b.lastName,a.award,b.birthdate,count(1) awards_amount,ROW_NUMBER() OVER(PARTITION BY award ORDER BY count(1) desc,birthdate desc) row_num
from awards_players a
inner join players b on a.playerid = b.playerid
group by a.playerid,a.award
 )
 select firstname,lastName,award,awards_amount
 from count_awards
 where row_num = 1
 order by firstname asc


7) #for each year we found the ranking of coaches from the one with the best Win/rate to the worst with at least more than 10 games. 
# We want to know if the best coaches have also won an award for the same year  and only for NBA league.
with ranking  as(
select coachId,year_coach,1-(lost/won), won,lost, ROW_NUMBER() OVER(PARTITION BY year_coach ORDER BY 1-(lost/won) desc) row_num
from Basketball.coaches
where 1-(lost/won) is not null and lost+won>10
)
select ran.year_coach, ran.coachid best_WR_coach, 
case when ran.coachid  = awa.coachid then 'Yes' ELSE 'No' END Awarded
from ranking ran
inner join Basketball.awards_coaches awa on ran.year_coach = awa.year_award and ran.row_num=1
where lgID = 'NBA'






9)#top 10 players that won more MVP awards. For every player we show numebr of total MVP awards taht he won. We show also with which team he won them and number of MVP for every team.

create or replace view first10players  as
select p.firstName as name, p.lastName as surname, p.playerID as id_player, year_awards_palyer as year_award, count(*) as MVP_total
from awards_players as ap join players as p on ap.playerID = p.playerID
where ap.award="Most Valuable Player"
group by p.playerID
order by MVP_total desc
limit 10;

create or replace view first10playersWithYear  as
select fp.name, fp.surname, fp.id_player, fp.MVP_total, ap.year_awards_palyer
from first10players as fp join awards_players as ap on fp.id_player = ap.playerID
where ap.award="Most Valuable Player";


create or replace view fp_teams  as
select fp.*, pt.tmID, pt.year_pt, pt.points
from first10playersWithYear as fp join players_teams as pt on fp.id_player = pt.playerID and fp.year_awards_palyer = pt.year_pt;


select fp_teams.name, fp_teams.surname,fp_teams.MVP_total, sum(fp_teams.points) as points, t.name_team, count(*) as MVP_awards_fro_each_team
from fp_teams join teams as t on fp_teams.tmID = t.tmID and fp_teams.year_pt = t.year_teams
group by fp_teams.id_player,t.name_team;



########### 4 QUERIES THAT WE'LL OPTIMIZATE ######################



3)
#firstname,lastName,height,weight,birthcountry of players born not in USA that played ONLY in 1 team in career(in the USA leagues)

select firstname,lastName,height,weight,birthcountry
from players 
where exists(
			select playerid,tmid
			from (
				select playerid,tmid
				from players_teams
				group by playerid,tmid
			) a
			where a.playerid=players.playerid
			group by playerid
			having count(1) =1)
AND birthcountry not in ('USA')


5) #Michael Jordan's team mates


select distinct p1.firstName, p1.lastName
from players as p1, players_teams as pt1
where p1.playerID = pt1.playerID and p1.firstName != 'Michael' and p1.lastName != 'Jordan'
and pt1.year_pt in (select pt.year_pt
				from players as p, players_teams as pt
				where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID) 
and pt1.tmID in (select pt.tmID
				from players as p, players_teams as pt
				where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID);


8) #top 50 players with higher average point/minutes rate that have won at least 1MVP or have been inserted in All NBA Fisr Team of the year. 
# For every player we show points/minutes rate, number of MVP won, how many times every players has been inserted in 'ALL NBA - First Team of the year" 
# and number of times that every player has played in allstart games

#view8 is a view that allows to calculate number of MVP and number of times that a player is inserted in 'All NBA - First Team'
create or replace view view8 as
((select team, d1.playerID, d2.mvp
from (
select count(*) as team, ap.playerID
from awards_players as ap
where ap.award="All-NBA First Team"
group by ap.playerID
) as d1 left join (
select count(*) as mvp, ap.playerID
from awards_players as ap
where ap.award="Most Valuable Player"
group by ap.playerID
) as d2 on d1.playerID = d2.playerID)
union 
(select team,d2.playerID, d2.mvp
from (
select count(*) as team, ap.playerID
from awards_players as ap
where ap.award="All-NBA First Team"
group by ap.playerID
) as d1 right join (
select count(*) as mvp, ap.playerID
from awards_players as ap
where ap.award="Most Valuable Player"
group by ap.playerID
) as d2 on d1.playerID = d2.playerID
));



select  t4.*, count(*) as won
from player_allstar join (
select t3.*, players.firstName, players.lastName
from players join (
select view8.playerID, view8.mvp, view8.team, t2.ave
from view8
join (
select (punti/m) as ave, v1.playerID, v3.games_played
from (
(
select (sum(points)) as punti, playerID
				from players_teams
                where year_pt>1980 and year_pt<2010 and lgID = "NBA"
                group by playerID
) as v1
 join (
select (sum(minutes)) as m, playerID
				from players_teams
                where year_pt>1980 and year_pt<2010 and lgID = "NBA"
                group by playerID
 ) as v2
 on v1.playerID = v2.playerID) join (
 select sum(GP) as games_played, playerID
					from players_teams
					where lgID = "NBA" 
					group by playerID
 ) as v3
 on v1.playerID = v3.playerID
where v3.games_played >500
) as t2 on view8.playerID = t2.playerID
group by t2.playerID
order by t2.ave DESC
) as t3 on players.playerID = t3.playerID
) as t4 on player_allstar.playerID = t4.playerID
group by t4.ave
order by t4.ave DESC
limit 50;



10) 
#Top player for different ranking (games played, minutes played, best scorer, best assistman, best carcher, best stealer, best blocker, 
#best free throws, best sniper from 2, best sniper from 3)

SELECT c NAME,'GAMES PLAYED' as CATEGORY,MAX(A) TOTAL FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(GP) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by b.playerid,concat(p.firstName,' ',p.lastname)
order by sum(GP) desc limit 1) x
UNION
SELECT c NAME,'MINUTES PLAYED',MAX(A) FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(MINUTES) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(MINUTES) desc limit 1) x
UNION
SELECT c NAME,'BEST SCORER' as CATEGORY,MAX(A) FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(points) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(points) desc limit 1) x
UNION
SELECT c NAME,'BEST ASSISTMAN',MAX(A)  FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(assists)a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(assists) desc limit 1) x
UNION
SELECT c NAME,'BEST CATCHER',MAX(A)  FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(rebounds) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(rebounds) desc limit 1) x
UNION
SELECT c NAME,'BEST STEALER',MAX(A)  FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(STEALS) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(STEALS) desc limit 1) x
UNION
SELECT c NAME,'BEST BLOCKER',MAX(A)  FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(BLOCKS) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(BLOCKS) desc limit 1) x
UNION
SELECT c NAME,'BEST FREE THROWS',MAX(A)  FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(FTMADE) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(FTMADE) desc limit 1) x
UNION
SELECT c NAME,'BEST SNIPER FROM 2',MAX(A)  FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(FGMADE) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(FGMADE) desc limit 1) x
UNION
SELECT c NAME,'BEST SNIPER FROM 3',MAX(A)  FROM (
select b.playerid,concat(p.firstName,' ',p.lastname) c,sum(THREEMADE) a
from players_teams b
INNER JOIN PLAYERS p  ON b.playerID=p.playerid
group by playerid,concat(p.firstName,' ',p.lastname)
order by sum(THREEMADE) desc limit 1) x;





