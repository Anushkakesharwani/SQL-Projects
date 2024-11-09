/* Create Tables */
CREATE TABLE Goals (
    GOAL_ID VARCHAR PRIMARY KEY,
    MATCH_ID VARCHAR,
    PID VARCHAR,
    DURATION INTEGER,
    ASSIST VARCHAR,
    GOAL_DESC TEXT
);

CREATE TABLE Matches (
    MATCH_ID VARCHAR PRIMARY KEY,
    SEASON VARCHAR,
    DATE DATE,
    HOME_TEAM VARCHAR,
    AWAY_TEAM VARCHAR,
    STADIUM VARCHAR,
    HOME_TEAM_SCORE INTEGER,
    AWAY_TEAM_SCORE INTEGER,
    PENALTY_SHOOT_OUT INTEGER,
    ATTENDANCE INTEGER
);

CREATE TABLE Players (
    PLAYER_ID VARCHAR PRIMARY KEY,
    FIRST_NAME VARCHAR,
    LAST_NAME VARCHAR,
    NATIONALITY VARCHAR,
    DOB DATE,
    TEAM VARCHAR,
    JERSEY_NUMBER FLOAT,
    POSITION VARCHAR,
    HEIGHT FLOAT,
    WEIGHT FLOAT,
    FOOT CHAR(1)
);

CREATE TABLE Teams (
    TEAM_NAME VARCHAR ,
    COUNTRY VARCHAR,
    HOME_STADIUM VARCHAR
);

CREATE TABLE Stadium (
    Name VARCHAR ,
    City VARCHAR,
    Country VARCHAR,
    Capacity INTEGER
);

/* Import CSV Files */
COPY Goals FROM 'E:\Data Science Course\SQL-Assignment\goals.csv' delimiter ',' csv header ;
SELECT * FROM Goals;

SET datestyle = 'DMY';
COPY Matches FROM 'E:\Data Science Course\SQL-Assignment\Matches.csv' delimiter ',' csv header;
SELECT * FROM Matches;

COPY Players FROM 'E:\Data Science Course\SQL-Assignment\Players.csv' delimiter ',' csv header;
SELECT * FROM Players;

COPY Teams FROM 'E:\Data Science Course\SQL-Assignment\Teams.csv' delimiter ',' csv header;
SELECT * FROM Teams;

COPY Stadium FROM 'E:\Data Science Course\SQL-Assignment\Stadiums.csv' delimiter ',' csv header;
SELECT * FROM Stadium;

/* Queries */

--1)Count the Total Number of Teams
SELECT COUNT(*) AS total_teams FROM Teams;--74

--2)Find the Number of Teams per Country
SELECT COUNTRY, COUNT(*) AS no_of_teams FROM Teams GROUP BY COUNTRY;

--3)Calculate the Average Team Name Length
SELECT AVG(length(TEAM_NAME)) AS Avg_Team_name_length FROM Teams;--12.35

--4)Calculate the Average Stadium Capacity in Each Country round it off and sort by the total stadiums in the country.
SELECT Country,ROUND(AVG(Capacity)) AS Avg_capcity,
	COUNT(*) AS total_Stadium FROM Stadium GROUP BY Country ORDER BY total_Stadium DESC;

--5)Calculate the Total Goals Scored.
SELECT count(*) AS total_goal_scored FROM Goals;--2279

--6)Find the total teams that have city in their names
SELECT COUNT(*) AS total_teams_with_city
FROM Teams
WHERE TEAM_NAME LIKE '%City%';--2

--7) Use Text Functions to Concatenate the Team's Name and Country
SELECT TEAM_NAME||','||COUNTRY AS address FROM Teams;

--8) What is the highest attendance recorded in the dataset, and which match (including home and away teams, and date) does it correspond to?
SELECT DATE, HOME_TEAM, AWAY_TEAM,ATTENDANCE
FROM Matches WHERE ATTENDANCE= (SELECT MAX(ATTENDANCE)
FROM Matches);

SELECT MATCH_ID, HOME_TEAM, AWAY_TEAM, DATE, ATTENDANCE
FROM Matches ORDER BY ATTENDANCE DESC LIMIT 1;

--9)What is the lowest attendance recorded in the dataset, and which match (including home and away teams, and date) does it correspond to set the criteria as greater than 1 as some matches had 0 attendance because of covid.
SELECT DATE, HOME_TEAM, AWAY_TEAM,ATTENDANCE
FROM Matches WHERE ATTENDANCE= (SELECT MIN(ATTENDANCE)
FROM Matches WHERE ATTENDANCE>1);

SELECT MATCH_ID, HOME_TEAM, AWAY_TEAM, DATE, ATTENDANCE
FROM Matches WHERE ATTENDANCE > 1 ORDER BY ATTENDANCE ASC LIMIT 1;

--10) Identify the match with the highest total score (sum of home and away team scores) in the dataset. Include the match ID, home and away teams, and the total score.
SELECT MATCH_ID, HOME_TEAM, AWAY_TEAM, (HOME_TEAM_SCORE + AWAY_TEAM_SCORE) AS total_score
FROM Matches ORDER BY total_score DESC LIMIT 1;

--11)Find the total goals scored by each team, distinguishing between home and away goals. Use a CASE WHEN statement to differentiate home and away goals within the subquery
SELECT team_name,
    SUM(CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END) AS home_goals,
    SUM(CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END) AS away_goals
FROM teams as t LEFT JOIN matches as m 
ON m.home_team = t.team_name OR m.away_team = t.team_name
GROUP BY team_name;

-- using subquery
SELECT team_name,home_goals,away_goals FROM
(SELECT team_name,
    SUM(CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END) AS home_goals,
    SUM(CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END) AS away_goals
FROM teams as t LEFT JOIN matches as m 
ON m.home_team = t.team_name OR m.away_team = t.team_name GROUP BY team_name);
	
--12) windows function - Rank teams based on their total scored goals (home and away combined) using a window function.In the stadium Old Trafford.
SELECT team_name,SUM((CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END)+
	(CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END)) AS total_goals,
	RANK() OVER (ORDER BY SUM((CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END)+
	(CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END))DESC) AS goal_rank
FROM teams as t LEFT JOIN matches as m 
ON m.home_team = t.team_name OR m.away_team = t.team_name 
	WHERE m.stadium = 'Old Trafford' GROUP BY team_name;

-- using subquery
SELECT team_name,total_goals,RANK() OVER (ORDER BY total_goals DESC) AS goal_rank
FROM (SELECT team_name,SUM((CASE WHEN m.home_team = t.team_name THEN m.home_team_score ELSE 0 END) + 
       (CASE WHEN m.away_team = t.team_name THEN m.away_team_score ELSE 0 END)) AS total_goals
    FROM teams t LEFT JOIN matches m 
	ON t.team_name = m.home_team OR t.team_name = m.away_team
    WHERE m.stadium = 'Old Trafford' GROUP BY t.team_name) AS team_goals;


--13) TOP 5 l players who scored the most goals in Old Trafford, ensuring null values are not included in the result (especially pertinent for cases where a player might not have scored any goals).
SELECT p.player_id,p.first_name,p.last_name,COUNT(g.goal_id) AS total_goals
FROM Players p JOIN Goals g ON p.player_id = g.pid
JOIN Matches m ON g.match_id = m.match_id
WHERE m.stadium = 'Old Trafford'
GROUP BY p.player_id, p.first_name, p.last_name HAVING COUNT(g.goal_id) > 0
ORDER BY total_goals DESC LIMIT 5;

--14)Write a query to list all players along with the total number of goals they have scored. Order the results by the number of goals scored in descending order to easily identify the top 6 scorers.
SELECT p.player_id,p.first_name,p.last_name,COUNT(g.goal_id) AS total_goals
FROM Players p LEFT JOIN Goals g ON p.player_id = g.pid
GROUP BY p.player_id, p.first_name, p.last_name 
ORDER BY total_goals DESC LIMIT 6;

--16)Find the Total Number of Goals Scored in the Latest Season - Calculate the total number of goals scored in the latest season available in the dataset. This question involves using a subquery to first identify the latest season from the Matches table, then summing the goals from the Goals table that occurred in matches from that season

SELECT COUNT(g.goal_id)AS total_goals FROM Goals g LEFT JOIN Matches m ON g.match_id = m.match_id
Where m.season= (SELECT MAX(season) FROM Matches );

--17)Find Matches with Above Average Attendance - Retrieve a list of matches that had an attendance higher than the average attendance across all matches. This question requires a subquery to calculate the average attendance first, then use it to filter matches.
SELECT MATCH_ID, DATE, HOME_TEAM, AWAY_TEAM, ATTENDANCE
FROM Matches WHERE ATTENDANCE>(SELECT AVG(ATTENDANCE) FROM Matches )

--18)Find the Number of Matches Played Each Month - Count how many matches were played in each month across all seasons. This question requires extracting the month from the match dates and grouping the results by this value. as January Feb march	
SELECT TO_CHAR(DATE, 'Month') AS month_name,COUNT(*) AS matches_played
FROM Matches GROUP BY month_name ORDER BY month_name;



