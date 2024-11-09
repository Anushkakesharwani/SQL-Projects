Create Table student_scores (
id INT PRIMARY KEY,
first_name VARCHAR,
last_name  VARCHAR,
email VARCHAR,	
gender VARCHAR,
part_time_job VARCHAR,	
absence_days INT,		
extracurricular_activities	VARCHAR,
weekly_self_study_hours	INT,	
career_aspiration VARCHAR,	
math_score INT,
history_score INT,	
physics_score INT,
chemistry_score	INT,
biology_score INT,	
english_score INT,	
geography_score INT
);

/* Import CSV Files */
COPY student_scores FROM 'E:\Data Science Course\Final Evaluation\Anushka_CuvetteDS\Anushka Kesharwani SQL\student-scores.csv' delimiter ',' csv header ;
SELECT * FROM student_scores;

--1)Calculate the average math_score for each career_aspiration. Order the results by the average score in descending order.
SELECT career_aspiration, AVG(math_score) AS AVG_MATH_SCORE FROM student_scores 
	GROUP BY career_aspiration ORDER BY AVG(math_score) DESC;

--2)Find the career_aspirations that have an average english_score greater than 75. Display the career aspiration and the average score.
SELECT career_aspiration, AVG(english_score) AS AVG_ENGLISH_SCORE FROM student_scores 
	GROUP BY career_aspiration Having AVG(english_score)>75 ORDER BY AVG(english_score) DESC; 

--3)Identify students who have a math_score higher than the school's average math score. List their first_name, last_name, and math_score.
SELECT first_name, last_name, math_score FROM student_scores
 WHERE  math_score > (SELECT AVG(math_score) FROM student_scores);

--4)Rank students within each career_aspiration category by their physics_score in descending order. Display the first_name, last_name, career_aspiration, physics_score, and the rank.
SELECT first_name, last_name, career_aspiration, physics_score,
Rank() OVER(PARTITION BY career_aspiration ORDER BY physics_score DESC ) AS rank_students
FROM student_scores;

--5) For each student, create a new column full_name by concatenating first_name and last_name with a space in between. Show the full_name and email columns where the email contains the string "academy".
SELECT first_name||' '||last_name AS full_name,email FROM student_scores 
WHERE email LIKE '%academy%';

--6)Calculate the lowest (FLOOR), highest (CEIL), and average (ROUND to two decimal places) chemistry_score for each career aspirant. Display the career aspirants, lowest score, highest score, and average score.
SELECT career_aspiration, FLOOR (MIN(chemistry_score)) AS lowest_score, 
CEIL(MAX(chemistry_score)) AS highest_score, ROUND(AVG(chemistry_score),2) AS average_score
FROM student_scores GROUP BY career_aspiration;

--7)Find career aspirations where the average history_score is above 85 and at least 5 students aspire to that career. List the career_aspiration and the average score.
SELECT career_aspiration,AVG(history_score) AS AVG_HISTORY_SCORE , COUNT(*) AS num_students FROM  student_scores 
	GROUP BY career_aspiration Having AVG(history_score)>85 AND COUNT(*) >= 5;

--8)Identify students who score above average in both biology and chemistry, compared to the school's average for those subjects. Display their id, first_name, last_name, biology_score, and chemistry_score.
SELECT id, first_name, last_name, biology_score,chemistry_score FROM  student_scores
 WHERE  biology_score > (SELECT AVG(biology_score) FROM student_scores) AND
 chemistry_score > (SELECT AVG(chemistry_score)FROM student_scores);

--9)Calculate the percentage of absence days for each student relative to the total absence days recorded for all students. Display the id, first_name, last_name, and the calculated percentage, rounded to two decimal places. Order the results by the percentage in descending order.
SELECT id, first_name,last_name, ROUND((absence_days / total_absence_days) * 100, 2) AS absence_percentage
FROM student_scores, (SELECT SUM(absence_days) AS total_absence_days FROM student_scores) AS total
ORDER BY absence_percentage DESC;


--10)Identify students who have scores above 80 in at least three out of the six subjects: math, history, physics, chemistry, biology, and English. Display their id, first_name, last_name, and the count of subjects where they scored above 80.
SELECT * FROM (SELECT id, first_name, last_name , 
	((CASE WHEN math_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN history_score>80 THEN 1 ELSE 0 END ) +
	(CASE WHEN physics_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN chemistry_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN biology_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN english_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN geography_score>80 THEN 1 ELSE 0 END )) AS subjects_above_80 FROM student_scores)
WHERE subjects_above_80 >= 3;

--other way
SELECT id, first_name, last_name , ((CASE WHEN math_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN history_score>80 THEN 1 ELSE 0 END ) +
	(CASE WHEN physics_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN chemistry_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN biology_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN english_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN geography_score>80 THEN 1 ELSE 0 END )) AS subjects_above_80
 FROM student_scores
 WHERE ((CASE WHEN math_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN history_score>80 THEN 1 ELSE 0 END ) +
	(CASE WHEN physics_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN chemistry_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN biology_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN english_score>80 THEN 1 ELSE 0 END ) + 
	(CASE WHEN geography_score>80 THEN 1 ELSE 0 END )) >=3;