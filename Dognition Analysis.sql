/*Queries that Test Relationships Between Test Completion and Dog Characteristics*/

/*load the sql library and database, and make the Dognition database your default database:*/

%load_ext sql
%sql mysql://studentuser:studentpw@mysqlserver/dognitiondb
%sql USE dognitiondb

/*1. Assess whether Dognition personality dimensions are related to the number of tests completed*/

/*Question 1: To get a feeling for what kind of values exist in the Dognition personality dimension column, write a query that will output all of the distinct values in the dimension column. Use your relational schema or the course materials to determine what table the dimension column is in. Your output should have 11 rows.*/

%%sql
SELECT DISTINCT dimension
FROM dogs;

/*Observations:
There are null values in the dimension column. This has to be kept in mind for future analyses.*/

/*Question 2: Use the equijoin syntax (described in MySQL Exercise 8) to write a query that will output the Dognition personality dimension and total number of tests completed by each unique DogID. This query will be used as an inner subquery in the next question. LIMIT your output to 100 rows for troubleshooting purposes.*/

%%sql
select 
	d.dog_guid AS dogID, 
	d.dimension as dimension, 
	count(c.test_name) AS numtests
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid
group by dogID
Limit 100;


/*Question 3: Re-write the query in Question 2 using traditional join syntax.*/

%%sql
SELECT 
	d.dog_guid AS dogID, 
	d.dimension AS dimension, 
	count(c.created_at) AS
numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
GROUP BY dogID
LIMIT 100;

/*Question 4: To start, write a query that will output the average number of tests completed by unique dogs in each Dognition personality dimension. Choose either the query in Question 2 or 3 to serve as an inner query in your main query. If you have trouble, make sure you use the appropriate aliases in your GROUP BY and SELECT statements.*/

%%sql
select 
	d.dimension, 
	count( c.test_name)/count(distinct c.dog_guid) AS avg_test
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid
group by dimension;



/*Question 5: How many unique DogIDs are summarized in the Dognition dimensions labeled "None" or ""?*/


%%sql
​
select 
	d.dimension, 
	count(distinct c.dog_guid) AS total_dogs
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid AND (dimension IS NULL or dimension = "")
group by dimension;

/*Observations for Q4 and Q5:
There are blanks and nulls in the Dognition personality dimension column. Dognition told us that a Dimension is only assigned after the initial Dog Assessment is completed.  If dogs did not complete the first 20 tests, they would retain a NULL value in the dimension column. The blank dimensions need to be assessed more to understand the reason behind a blank value. */

/*Question 6: To determine whether there are any features that are common to all dogs that have non-NULL empty strings in the dimension column, write a query that outputs the breed, weight, value in the "exclude" column, first or minimum time stamp in the complete_tests table, last or maximum time stamp in the complete_tests table, and total number of tests completed by each unique DogID that has a non-NULL empty string in the dimension column.*/

%%sql
SELECT d.breed, d.weight, d.exclude, MIN(c.created_at) AS first_test,
MAX(c.created_at) AS last_test,count(c.created_at) AS numtests
FROM dogs d JOIN complete_tests c
ON d.dog_guid=c.dog_guid
WHERE d.dimension=""
GROUP BY d.dog_guid;


/*Observations:
Almost all the entries with blank dognition column has 1 in the exclude column, i.e. these entries are meant to be excluded due to factors monitored by the Dognition team.
*/

/*Question 7: Rewrite the query in Question 4 to exclude DogIDs with (1) non-NULL empty strings in the dimension column, (2) NULL values in the dimension column, and (3) values of "1" in the exclude column. NOTES AND HINTS: You cannot use a clause that says d.exclude does not equal 1 to remove rows that have exclude flags, because Dognition clarified that both NULL values and 0 values in the "exclude" column are valid data. A clause that says you should only include values that are not equal to 1 would remove the rows that have NULL values in the exclude column, because NULL values are never included in equals statements (as we learned in the join lessons). In addition, although it should not matter for this query, practice including parentheses with your OR and AND statements that accurately reflect the logic you intend. Your results should return 402 DogIDs in the ace dimension and 626 dogs in the charmer dimension.*/

%%sql
select d.dimension, count(c.test_name) As total_test, count(distinct c.dog_guid) AS total_dogs,
count( c.test_name)/count(distinct c.dog_guid) AS avg_test
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid AND d.dimension != "" AND d.dimension IS NOT NULL AND (d.exclude = 0 OR d.exclude IS NULL)
group by dimension;

/*Observations:
The results indicate there are not significant differences in the number of tests completed by dogs with different Dognition personality dimensions. These results suggest focusing on Dognition personality dimensions will not likely lead to significant insights about how to improve Dognition completion rates.*/

/*2. Assess whether dog breeds are related to the number of tests completed.*/

/*Questions 8: Write a query that will output all of the distinct values in the breed_group field.*/

%%sql
select distinct breed_group
from dogs;

/*Observation:
There are null values in the breed group. Let's analyse the reasons behind this.*/


/*Question 9: Write a query that outputs the breed, weight, value in the "exclude" column, first or minimum time stamp in the complete_tests table, last or maximum time stamp in the complete_tests table, and total number of tests completed by each unique DogID that has a NULL value in the breed_group column.*/

%%sql
select c.dog_guid,d.breed, d.weight, d.exclude, MIN(c.created_at) AS first_test,
MAX(c.created_at) AS last_test, 
count(c.test_name) AS numtests
from dogs d, complete_tests c
where d.dog_guid=c.dog_guid AND d.breed_group IS NULL
group by c.dog_guid;

/*Observation:
There is no feature that is common to these entries. We are not sure if we should exclude them or not.
*/

/*Question 10: Adapt the query in Question 7 to examine the relationship between breed_group and number of tests completed. Exclude DogIDs with values of "1" in the exclude column. Your results should return 1774 DogIDs in the Herding breed group.*/

%%sql
select d.breed_group, count(c.test_name) As total_test, count(distinct c.dog_guid) AS total_dogs,
count( c.test_name)/count(distinct c.dog_guid) AS avg_test
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid AND (d.exclude = 0 OR d.exclude IS NULL)
group by breed_group;

/*The results show there are blank entries in breed_group column.
 Herding and Sporting breed_groups complete the most tests, while Toy breed groups complete the least tests. 
 This leads a possibility that target marketing on certain types of Dognition tests to dog owners with dogs in the Herding and Sporting breed_groups might lead to an increase in the number of tests completed by users.*/
 
 
/*Question 11: Adapt the query in Question 10 to only report results for Sporting, Hound, Herding, and Working breed_groups using an IN clause.*/

%%sql
select d.breed_group, count(c.test_name) As total_test, count(distinct c.dog_guid) AS total_dogs,
count( c.test_name)/count(distinct c.dog_guid) AS avg_test
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid 
AND (d.exclude = 0 OR d.exclude IS NULL) 
AND breed_group IN('Sporting', 'Hound', 'Herding', 'Working')
group by breed_group;


/*Examining the relationship between breed_type and number of completed tests.*/

/*Questions 12: Begin by writing a query that will output all of the distinct values in the breed_type field.*/

%%sql
select distinct breed_type from dogs
%%sql
select distinct breed_type from dogs;

/*Question 13: Adapt the query in Question 7 to examine the relationship between breed_type and number of tests completed. Exclude DogIDs with values of "1" in the exclude column. Your results should return 8865 DogIDs in the Pure Breed group.*/

%%sql
select d.breed_type, count(c.test_name) As total_test, count(distinct c.dog_guid) AS total_dogs,
count( c.test_name)/count(distinct c.dog_guid) AS avg_test
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid AND (d.exclude = 0 OR d.exclude IS NULL)
group by breed_type;

/*Observation:
Average tests completed for different dog breeds are almost same. There does not appear to be a significant difference between number of tests completed by dogs of different breed types.
*/
/*
3. Assess whether dog breeds and neutering are related to the number of tests completed*/

/*Question 14: For each unique DogID, output its dog_guid, breed_type, number of completed tests, and use a CASE statement to include an extra column with a string that reads "Pure_Breed" whenever breed_type equals 'Pure Breed" and "Not_Pure_Breed" whenever breed_type equals anything else. LIMIT your output to 50 rows for troubleshooting.*/

%%sql
select c.dog_guid AS dogID, d.breed_type, count(c.test_name) As total_test,
(CASE breed_type
WHEN 'Pure Breed' THEN 'Pure_Breed'
ELSE 'Not_Pure_Breed'
END) AS pure_breed
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid
group by c.dog_guid
limit 50;

/*
Question 15: Adapt your queries from Questions 7 and 14 to examine the relationship between breed_type and number of tests completed by Pure_Breed dogs and non_Pure_Breed dogs. Your results should return 8336 DogIDs in the Not_Pure_Breed group.*/

%%sql
select
(CASE breed_type
WHEN 'Pure Breed' THEN 'Pure_Breed'
ELSE 'Not_Pure_Breed'
END) AS pure_breed, count(distinct c.dog_guid) AS total_dogs,
count( c.test_name)/count(distinct c.dog_guid) AS avg_test
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid AND (d.exclude = 0 OR d.exclude IS NULL)
group by pure_breed;
2 rows affected.


/*Question 16: Adapt your query from Question 15 to examine the relationship between breed_type, whether or not a dog was neutered (indicated in the dog_fixed field), and number of tests completed by Pure_Breed dogs and non_Pure_Breed dogs. There are DogIDs with null values in the dog_fixed column, so your results should have 6 rows, and the average number of tests completed by non-pure-breeds who are neutered is 10.5681.*/

%%sql
select
(CASE breed_type
WHEN 'Pure Breed' THEN 'Pure_Breed'
ELSE 'Not_Pure_Breed'
END) AS pure_breed,d.dog_fixed, count(distinct c.dog_guid) AS total_dogs,
count( c.test_name)/count(distinct c.dog_guid) AS avg_test
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid AND (d.exclude = 0 OR d.exclude IS NULL)
group by pure_breed,dog_fixed;

/*Observation:
We observed that Neutered dogs finish more tests than non-neutered dogs. 
To further analyse the reasons behind this, we can look into -
1. Is this observation consistent across different segments of dogs broken up according to other variables. 
2. If the effects are consistent,does neutered dogs finish more tests due to traits that arise when a dog is neutered, or instead, whether owners who are more likely to neuter their dogs have traits that make it more likely they will want to complete more tests.
*/

/*Question 17: Adapt your query from Question 7 to include a column with the standard deviation for the number of tests completed by each Dognition personality dimension.*/

%%sql
select d.dimension, count(c.test_name) As total_test, count(distinct c.dog_guid) AS total_dogs,
count(c.test_name)/count(distinct c.dog_guid) AS avg_test,
STDEV(c.test_name) OVER(PARTITION BY c.dog_guid) AS std_dev
from dogs d, complete_tests c
where d.dog_guid = c.dog_guid AND d.dimension != "" AND d.dimension IS NOT NULL AND (d.exclude = 0 OR d.exclude IS NULL)
group by dimension;

/*Observation:
The standard deviation for the number of tests completed by each Dognition personality dimension is not tremendously different across the personality dimensions, so the average values are likely fairly trustworthy.
*/

/*Question 18: Write a query that calculates the average amount of time it took each dog breed_type to complete all of the tests in the exam_answers table. Exclude negative durations from the calculation, and include a column that calculates the standard deviation of durations for each breed_type group:*/

%%sql
SELECT d.breed_type AS breed_type,
AVG(TIMESTAMPDIFF(minute,e.start_time,e.end_time)) AS AvgDuration,
STDDEV(TIMESTAMPDIFF(minute,e.start_time,e.end_time)) AS StdDevDuration
FROM dogs d JOIN exam_answers e
ON d.dog_guid=e.dog_guid
WHERE TIMESTAMPDIFF(minute,e.start_time,e.end_time)>0
GROUP BY breed_type;

/*Observation:
Many of the standard deviations have larger magnitudes than the average duration values. This suggests there are outliers in the data that are significantly impacting the reported average values, so the average values are not likely trustworthy. We should use another program for a sophisticated analysis.
*/

------------------------------------------------------------------------------------------------------------------------------------------------------

/*Queries that Test Relationships Between Test Completion and Testing Circumstances*/

/*1. During which weekdays do Dognition users complete the most tests?*/

/*Question 1: Using the function you found in the websites above, write a query that will output one column with the original created_at time stamp from each row in the completed_tests table, and another column with a number that represents the day of the week associated with each of those time stamps. Limit your output to 200 rows starting at row 50.*/

%%sql
Select created_at, DAYOFWEEK(created_at)
from complete_tests
limit 49,200;

/*Question 2: Include a CASE statement in the query you wrote in Question 1 to output a third column that provides the weekday name (or an appropriate abbreviation) associated with each created_at time stamp.*/

%%sql
SELECT created_at, DAYOFWEEK(created_at),
(CASE
WHEN DAYOFWEEK(created_at)=1 THEN "Su"
WHEN DAYOFWEEK(created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(created_at)=4 THEN "We"
WHEN DAYOFWEEK(created_at)=5 THEN "Th"
WHEN DAYOFWEEK(created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(created_at)=7 THEN "Sa"
END) AS daylabel
FROM complete_tests
LIMIT 49,200;

/*Question 3: Adapt the query you wrote in Question 2 to report the total number of tests completed on each weekday. Sort the results by the total number of tests completed in descending order. You should get a total of 33,190 tests in the Sunday row of your output.*/

%%sql
SELECT 
(CASE
WHEN DAYOFWEEK(created_at)=1 THEN "Su"
WHEN DAYOFWEEK(created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(created_at)=4 THEN "We"
WHEN DAYOFWEEK(created_at)=5 THEN "Th"
WHEN DAYOFWEEK(created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(created_at)=7 THEN "Sa"
END) AS daylabel, count(test_name) AS numtests
FROM complete_tests
group by daylabel
order by numtests DESC;

/*Observation:
Users complete maximum number of tests on Sunday and the least number of tests on Friday.*/

/*Question 4: Rewrite the query in Question 3 to exclude the dog_guids that have a value of "1" in the exclude column (Hint: this query will require a join.) This time you should get a total of 31,092 tests in the Sunday row of your output.
*/

%%sql
SELECT 
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel, count(test_name) AS numtests
FROM complete_tests c, dogs d
Where c.dog_guid=d.dog_guid and (d.exclude IS NULL OR d.exclude=0)
group by daylabel
order by numtests DESC;

/*Observation:
After removing the flagged dog_guids and user_guids from the analysis, we can still see that Users complete maximum number of tests on Sunday and the least number of tests on Friday.*/

/*Question 5: Write a query to retrieve all the dog_guids for users common to the dogs and users table using the traditional inner join syntax (your output will have 950,331 rows).*/

%%sql
select d.dog_guid
from users u JOIN dogs d
ON u.user_guid = d.user_guid;
%%sql
select d.dog_guid
from users u JOIN dogs d
ON u.user_guid = d.user_guid;

/*Question 6: Write a query to retrieve all the distinct dog_guids common to the dogs and users table using the traditional inner join syntax (your output will have 35,048 rows).*/

%%sql
select distinct d.dog_guid
from users u JOIN dogs d
ON u.user_guid = d.user_guid;
%%sql
select distinct d.dog_guid
from users u JOIN dogs d
ON u.user_guid = d.user_guid;

/*Question 7: Start by writing a query that retrieves distinct dog_guids common to the dogs and users table, excuding dog_guids and user_guids with a "1" in their respective exclude columns (your output will have 34,121 rows).*/

%%sql
SELECT DISTINCT dog_guid
FROM dogs d JOIN users u
ON d.user_guid=u.user_guid
WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0);

/*Question 8: Now adapt your query from Question 4 so that it inner joins on the result of the subquery you wrote in Question 7 instead of the dogs table. This will give you a count of the number of tests completed on each day of the week, excluding all of the dog_guids and user_guids that the Dognition team flagged in the exclude columns.*/

%%sql
SELECT 
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel, count(test_name) AS numtests
FROM complete_tests c JOIN (SELECT DISTINCT dog_guid
                            FROM dogs d JOIN users u
                            ON d.user_guid=u.user_guid
                            WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0)) AS du
ON c.dog_guid=du.dog_guid
group by daylabel
order by numtests DESC;

/*Observation:
After removing the duplicate entries from the users table, the result with respect you tests completed on a specific weekday remains the same.
However, our first query suggested that more tests were completed on Tuesday than Saturday; our current query suggests that slightly more tests are completed on Saturday than Tuesday, now that flagged dog_guids and user_guids are excluded.*/

/*Question 9: Adapt your query from Question 8 to provide a count of the number of tests completed on each weekday of each year in the Dognition data set. Exclude all dog_guids and user_guids with a value of "1" in their exclude columns. Sort the output by year in ascending order, and then by the total number of tests completed in descending order. HINT: you will need a function described in one of these references to retrieve the year of each time stamp in the created_at field:

http://dev.mysql.com/doc/refman/5.7/en/func-op-summary-ref.html
http://www.w3resource.com/mysql/mysql-functions-and-operators.php*/

%%sql
SELECT YEAR(c.created_at) AS yearlabel,
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel, count(test_name) AS numtests
FROM complete_tests c JOIN (SELECT DISTINCT dog_guid
                            FROM dogs d JOIN users u
                            ON d.user_guid=u.user_guid
                            WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0)) AS du
ON c.dog_guid=du.dog_guid
group by yearlabel,daylabel
order by yearlabel ASC, numtests DESC;

/*Observation:
Th results suggest that for all the years, Sunday has the maximum test completion rate and Friday has the least.However there is another issue in our analysis,all timestamps are in UTC time convention.The same UTC time can correspond with local times in different countries that are as much as 24 hours apart. This might lead to a change in tests completed for a specific day.*/

/*Question 10: First, adapt your query from Question 9 so that you only examine customers located in the United States, with Hawaii and Alaska residents excluded. HINTS: In this data set, the abbreviation for the United States is "US", the abbreviation for Hawaii is "HI" and the abbreviation for Alaska is "AK". You should have 5,860 tests completed on Sunday of 2013.*/

%%sql
SELECT YEAR(c.created_at) AS yearlabel,
(CASE
WHEN DAYOFWEEK(c.created_at)=1 THEN "Su"
WHEN DAYOFWEEK(c.created_at)=2 THEN "Mo"
WHEN DAYOFWEEK(c.created_at)=3 THEN "Tu"
WHEN DAYOFWEEK(c.created_at)=4 THEN "We"
WHEN DAYOFWEEK(c.created_at)=5 THEN "Th"
WHEN DAYOFWEEK(c.created_at)=6 THEN "Fr"
WHEN DAYOFWEEK(c.created_at)=7 THEN "Sa"
END) AS daylabel, count(test_name) AS numtests
FROM complete_tests c JOIN (SELECT DISTINCT dog_guid
                            FROM dogs d JOIN users u
                            ON d.user_guid=u.user_guid
                            WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0) 
                            AND u.country ='US'AND (u.state!="HI" AND u.state!="AK")) AS du
ON c.dog_guid=du.dog_guid
group by yearlabel,daylabel
order by yearlabel ASC, numtests DESC;


/*Question 11: Write a query that extracts the original created_at time stamps for rows in the complete_tests table in one column, and the created_at time stamps with 6 hours subtracted in another column. Limit your output to 100 rows.*/

%%sql
SELECT created_at, DATE_SUB(c.created_at, interval 6 hour) AS corrected_time
FROM complete_tests
LIMIT 100;

/*Question 12: Use your query from Question 11 to adapt your query from Question 10 in order to provide a count of the number of tests completed on each day of the week, with approximate time zones taken into account, in each year in the Dognition data set. Exclude all dog_guids and user_guids with a value of "1" in their exclude columns. Sort the output by year in ascending order, and then by the total number of tests completed in descending order. HINT: Don't forget to adjust for the time zone in your DAYOFWEEK statement and your CASE statement.*/

%%sql
SELECT YEAR(c.created_at) AS yearlabel,
(CASE
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=1 THEN "Su"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=2 THEN "Mo"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=3 THEN "Tu"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=4 THEN "We"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=5 THEN "Th"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=6 THEN "Fr"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=7 THEN "Sa"
END) AS daylabel, count(test_name) AS numtests
FROM complete_tests c JOIN (SELECT DISTINCT dog_guid
                            FROM dogs d JOIN users u
                            ON d.user_guid=u.user_guid
                            WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0) 
                            AND u.country ='US'AND (u.state!="HI" AND u.state!="AK")) AS du
ON c.dog_guid=du.dog_guid
group by yearlabel,daylabel
order by yearlabel ASC, numtests DESC;

/*Observation:
Most United States states (excluding Hawaii and Alaska) have a time zone of UTC time -5 hours (in the eastern-most regions) to -8 hours (in the western-most regions). To get a general idea for how much our weekday analysis is likely to change based on time zone, we will subtract 6 hours from every time stamp in the complete_tests table. Although this means our time stamps can be inaccurate by 1 or 2 hours, people are not likely to be playing Dognition games at midnight, so 1-2 hours should not affect the weekdays extracted from each time stamp too much.*/

/*Question 13: Adapt your query from Question 12 so that the results are sorted by year in ascending order, and then by the day of the week in the following order: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.*/

%%sql
SELECT YEAR(c.created_at) AS yearlabel,
(CASE
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=1 THEN "Su"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=2 THEN "Mo"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=3 THEN "Tu"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=4 THEN "We"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=5 THEN "Th"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=6 THEN "Fr"
WHEN DAYOFWEEK(DATE_SUB(c.created_at, interval 6 hour))=7 THEN "Sa"
END) AS daylabel, count(test_name) AS numtests
FROM complete_tests c JOIN (SELECT DISTINCT dog_guid
                            FROM dogs d JOIN users u
                            ON d.user_guid=u.user_guid
                            WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0) 
                            AND u.country ='US'AND (u.state!="HI" AND u.state!="AK")) AS du
ON c.dog_guid=du.dog_guid
group by yearlabel,daylabel
order by yearlabel ASC, FIELD(daylabel, 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su');

/*Observation:
All of these analyses suggest that customers are most likely to complete tests around Sunday and Monday, and least likely to complete tests around the end of the work week, on Thursday and Friday.*/

/*2. Which states and countries have the most Dognition users?*/

/*Question 14: Which 5 states within the United States have the most Dognition customers, once all dog_guids and user_guids with a value of "1" in their exclude columns are removed? Try using the following general strategy: count how many unique user_guids are associated with dogs in the complete_tests table, break up the counts according to state, sort the results by counts of unique user_guids in descending order, and then limit your output to 5 rows. California ("CA") and New York ("NY") should be at the top of your list.*/

%%sql
SELECT du.state, count(distinct du.user_guid) AS numuser
FROM complete_tests c JOIN (SELECT DISTINCT dog_guid, u.user_guid, u.state
                            FROM dogs d JOIN users u
                            ON d.user_guid=u.user_guid
                            WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0) 
                            AND u.country ='US') AS du
ON c.dog_guid=du.dog_guid
group by du.state
order by numuser DESC
LIMIT 5;

/*Observation:
The number of Dognition users in California is very high as compared to any other state.
Useful follow-up questions would be: were special promotions run in California that weren't run in other states? Did Dognition use advertising channels that are particularly effective in California? If not, what traits differentiate California users from other users? Can these traits be taken advantage of in future marketing efforts or product developments?*/

/*Question 15: Which 10 countries have the most Dognition customers, once all dog_guids and user_guids with a value of "1" in their exclude columns are removed? HINT: don't forget to remove the u.country="US" statement from your WHERE clause.*/

%%sql
SELECT du.country, count(distinct du.user_guid) AS numuser
FROM complete_tests c JOIN (SELECT DISTINCT dog_guid, u.user_guid, u.country
                            FROM dogs d JOIN users u
                            ON d.user_guid=u.user_guid
                            WHERE (u.exclude IS NULL OR u.exclude=0) AND (d.exclude IS NULL OR d.exclude=0)) AS du
ON c.dog_guid=du.dog_guid
group by du.country
order by numuser DESC
LIMIT 10;

/*Observation:
The United States, Canada, Australia, and Great Britain are the countries with the most Dognition users.  After Great Britain, the number of Dognition users drops quite a lot. This analysis suggests that Dognition is most likely to be used by English-speaking countries. One question Dognition might want to consider is whether there are any countries whose participation would dramatically increase if a translated website were available.
*/


























