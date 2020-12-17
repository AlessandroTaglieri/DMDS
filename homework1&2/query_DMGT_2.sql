
SELECT @@SESSION.sql_mode;
SET session sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

#firstname,lastName,height,weight,birthcountry of players born not in USA that played ONLY in 1 team in career(in the USA leagues)

#time = 2.500 sec circa
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
AND birthcountry not in ('USA');


#riformulazione query
#time = 0.790 sec
select firstname,lastName,height,weight,birthcountry
from players 
where  birthcountry not in ('USA') and exists(
			select playerid,tmid
			from (
				select playerid,tmid
				from players_teams
				group by playerid,tmid
			) a
			where a.playerid=players.playerid
			group by playerid
			having count(1) =1
);

# EXECUTE INITIAL QUERY WITH INDEX

#add index to birthCountry
create index index_birthCountry on players (birthCountry);
# time = 0.740 sec
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
AND birthcountry not in ('USA');
#drop index
drop index index_birthCountry on players;



#################################################


#Michael Jordan's team mates

#execution time without pk and fk on b basketball_bis db
#time=0.550 sec
select distinct p1.firstName, p1.lastName
from players as p1, players_teams as pt1
where p1.playerID = pt1.playerID and p1.firstName != 'Michael' and p1.lastName != 'Jordan'
and pt1.year_pt in (select pt.year_pt
				from players as p, players_teams as pt
				where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID) 
and pt1.tmID in (select pt.tmID
				from players as p, players_teams as pt
				where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID);


#execution with pk and fk  on b basketball db
#time = 0.0095 sec
select distinct p1.firstName, p1.lastName
from players as p1, players_teams as pt1
where p1.playerID = pt1.playerID and p1.firstName != 'Michael' and p1.lastName != 'Jordan'
and pt1.year_pt in (select pt.year_pt
				from players as p, players_teams as pt
				where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID) 
and pt1.tmID in (select pt.tmID
				from players as p, players_teams as pt
				where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID);

#riformulazione query with view and with pk and fk
#time = 0.0065 sec

create or replace view view1 (year_pt) as
select distinct pt.year_pt
from players as p, players_teams as pt
where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID;

create or replace view view2 (teamID) as
select distinct pt.tmID
from players as p, players_teams as pt
where p.firstName = 'Michael' and p.lastName = 'Jordan' and p.playerID = pt.playerID;
            


select distinct p1.firstName, p1.lastName
from players as p1, players_teams as pt1, view1, view2
where p1.playerID = pt1.playerID and p1.firstName != 'Michael' and p1.lastName != 'Jordan' and pt1.year_pt = view1.year_pt and pt1.tmID = view2.teamID;



######################################################################



#top 50 players with higher average point/minutes rate that have won at least 1MVP or have been inserted in All NBA First Team of the year. 
# For every player we show points/minutes rate, number of MVP won, how many times every players has been inserted in 'ALL NBA - First Team of the year" 


#query without pk and fk on basketball_bis
#time = 0.940 sec
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

#query with pk and fk on basketball db
#time = 0.330 sec
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


select  t4.*
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


#riformulazione query con view ed altre clausole
#time = 0.100
create or replace view v1 as
select (sum(points)) as punti, playerID
				from players_teams
                where year_pt>1980 and year_pt<2010 and lgID = "NBA"
                group by playerID;
create or replace view v2 as
select (sum(minutes)) as m, playerID
				from players_teams
                where year_pt>1980 and year_pt<2010 and lgID = "NBA"
                group by playerID;
create or replace view v3 as
select sum(GP) as games_played, playerID
					from players_teams
					where lgID = "NBA" 
					group by playerID;
                    
select tab.playerID, tab.MVP_awards, tab.First_Team, tab.ave, tab.firstName, tab.lastName
from (
select  t4.*, count(*) as won
from player_allstar join (
select t3.*, players.firstName, players.lastName
from players join (
select count(case when award = "All-NBA First Team" then 1 end) as First_Team, count(case when award = "Most Valuable Player" then 1 end) as MVP_awards,  t2.*
from awards_players as ap join (
select (punti/m) as ave, v1.playerID, v3.games_played
from (
v1 join v2 on v1.playerID = v2.playerID) join v3 on v1.playerID = v3.playerID
where v3.games_played >500
) as t2 on ap.playerID = t2.playerID
group by t2.playerID
order by t2.ave DESC
) as t3 on players.playerID = t3.playerID
) as t4 on player_allstar.playerID = t4.playerID
where player_allstar.league_id="NBA"
group by t4.ave
order by t4.ave DESC
) as tab
where tab.MVP_awards != 0 or tab.First_Team !=0
limit 50;



###############################################
#Top player for different ranking (games played, minutes played, best scorer, best assistman, best carcher, best stealer, best blocker, 
#best free throws, best sniper from 2, best sniper from 3)

#execution without pk and fk on basketball_bis
#execution time = 0.750 sec
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


#execution with pk and fk
#execution time = 0.540 sec
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



#riformulazione query with temp table
#execution time = 0.200 sec
drop table if exists app;
create table app as
select concat(firstName,' ',lastname) NAME,sum(GP) gp,sum(minutes) minutes,sum(points) points,sum(assists) assists,sum(rebounds) rebounds,sum(STEALS) STEALS,sum(BLOCKS) BLOCKS,sum(FTMADE) FTMADE,sum(FGMADE) FGMADE,sum(THREEMADE) THREEMADE
from players_teams pt
INNER JOIN players p ON  pt.playerID=p.playerid
group by pt.playerid;

drop table  if exists max;
CREATE TABLE MAX AS
select max(a.GP) GP,MAX(a.minutes) minutes,max(a.points) points, max(a.assists) assists,max(a.rebounds) rebounds,max(a.STEALS) STEALS,max(a.BLOCKS) BLOCKS,max(a.FTMADE) FTMADE,max(a.FGMADE) FGMADE,max(a.THREEMADE) THREEMADE
from app A;

select name, 'GAMES PLAYED', app.GP from app inner join max on max.gp = app.gp 
UNION
select name, 'MINUTES PLAYED', app.minutes from app inner join max on max.minutes = app.minutes
UNION
select name, 'BEST SCORER', app.points from app inner join max on max.points = app.points 
UNION
select name, 'BEST ASSISTMAN', app.assists from app inner join max on max.assists = app.assists 
UNION
select name, 'BEST CATCHER', app.rebounds from app inner join max on max.rebounds = app.rebounds 
UNION
select name, 'BEST STEALER', app.STEALS from app inner join max on max.STEALS = app.STEALS 
UNION
select name, 'BEST BLOCKER', app.BLOCKS from app inner join max on max.BLOCKS = app.BLOCKS 
UNION
select name, 'BEST FREE THROWS', app.FTMADE from app inner join max on max.FTMADE = app.FTMADE 
UNION
select name, 'BEST SNIPER FROM 2', app.FGMADE from app inner join max on max.FGMADE = app.FGMADE 
UNION
select name, 'BEST SNIPER FROM 3', app.THREEMADE from app inner join max on max.THREEMADE = app.THREEMADE;





