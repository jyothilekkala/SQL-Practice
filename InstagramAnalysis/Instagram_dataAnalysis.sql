use [ig_clone]
GO

select count(*) from [dbo].[comments]

select count(*) from [dbo].[follows]

select count(*) from [dbo].[photo_tags]

select count(*) from [dbo].[likes]

select count(*) from [dbo].users

select count(*) from [dbo].[photos]

/*1. We want to reward our users who have been around the longest. Find the 5 oldest users.*/

SELECT TOP(5) id
,username 
FROM users 
order by created_at


/*2. What day of the week do most users register on? 
	We need to figure out when to schedule an ad campgain*/

SELECT TOP(10) created_at 
FROM users;

SELECT  TOP(1) WITH TIES DATENAME(WEEKDAY, created_at) as day_name
, COUNT(DATENAME(WEEKDAY, created_at)) AS weeks_count
FROM users
GROUP BY DATENAME(WEEKDAY, created_at)
ORDER BY weeks_count DESC;


/*We want to target our inactive users with an email campaign. Find the users who have never posted a photo*/

SELECT u.id
, u.username 
FROM users u 
LEFT JOIN photos p
ON u.id = p.user_id
WHERE p.id IS NULL;


/*We're running a new contest to see who can get the most likes on a single photo. WHO WON??!!*/

SELECT TOP(1) WITH TIES username
, p.user_id as userid
, count(photo_id) as photo_likes_count
FROM photos p 
INNER JOIN likes l
ON p.id = l.photo_id
INNER JOIN users u
ON p.user_id = u.id
GROUP BY p.user_id, photo_id, username
ORDER BY photo_likes_count DESC;



/*Our Investors want to know...avg no.of times a user posts on our app/website*/

SELECT ROUND((SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users), 2) as avg_posting


/*User ranking by postings higher to lower*/

WITH CTE as(
SELECT user_id,
COUNT(user_id) OVER(PARTITION BY user_id) as posts_count
FROM photos)
SELECT DISTINCT username, posts_count
, DENSE_RANK() OVER(ORDER BY posts_count DESC) as user_ranks
FROM CTE INNER JOIN users u 
ON CTE.user_id = u.id
ORDER BY user_ranks



/*Total Posts by users (longer version of SELECT COUNT(*)FROM photos) */

SELECT COUNT(*) 
FROM photos  --257

--Advanced version of count(*)
SELECT SUM(posts_count) FROM 
	(SELECT user_id
	,COUNT(id) as posts_count 
	FROM photos
	GROUP BY user_id) as post_count
--257	



/*Total numbers of users who have posted at least one time */

SELECT COUNT(DISTINCT u.id)
FROM users u
INNER JOIN photos p
ON u.id = p.user_id

--74


/*A brand wants to know which hashtags to use in a post. What are the top 5 most commonly used hashtags?*/

SELECT TOP(5) WITH TIES tag_name
, COUNT(tag_name) as tags_count
FROM tags t
INNER JOIN photo_tags pt
ON t.id = pt.tag_id
GROUP BY tag_name
ORDER BY tags_count DESC;


/*We have a small problem with bots on our site... Find users who have liked every single photo on the site*/


WITH liked_cte AS(
SELECT user_id, photo_id, COUNT(user_id) as liked_count
FROM likes
GROUP BY user_id, photo_id)
SELECT lc.user_id, u.username, SUM(liked_count) as total_likes_by_user
FROM liked_cte lc
INNER JOIN users u
ON lc.user_id = u.id
GROUP BY user_id, username
HAVING SUM(liked_count) = (SELECT COUNT(id) FROM photos)



/*We also have a problem with celebrities. Find users who have never commented on a photo*/

SELECT id, username
FROM users
WHERE id NOT IN (SELECT user_id FROM comments)
ORDER BY username


/*Mega Challenges
Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/

<<<<<<< HEAD
WITH no_comments AS(
SELECT id, COUNT(id) as users_count_no_comments 
FROM users
WHERE id NOT IN (SELECT user_id FROM comments)
),
commented_total_count AS (
SELECT id, COUNT(*) as count_comment_everything
FROM (SELECT u.id, COUNT(u.id) As total_comments_by_user
		FROM users u
		INNER JOIN comments c ON u.id = c.user_id
		GROUP BY u.id
		HAVING COUNT(u.id) = (SELECT COUNT(*) FROM photos)) as all_comments
)
SELECT (users_count_no_comments/(SELECT COUNT(id) FROM users)) * 100 as Not_commented_per,
(count_comment_everything/(SELECT COUNT(id) FROM users))*100 as commented_everything_per



=======
>>>>>>> 3d7e821635c155c564a735776832cf6e43bfec64

/*Find users who have ever commented on a photo*/

SELECT COUNT(DISTINCT user_id) users_commented_count
FROM comments;




