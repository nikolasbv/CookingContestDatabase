---QUERY 3.1
--1: Μέσος Όρος Αξιολογήσεων (σκορ) ανά μάγειρα και Εθνική κουζίνα: 

WITH CookRatings AS (
    SELECT cec.cook_id, (cec.rating_1 + cec.rating_2 + cec.rating_3) AS total_rating
    FROM Cook_Episode_Contestants cec
),
CookAverage AS (
    SELECT cr.cook_id, AVG(cr.total_rating) AS average_rating
    FROM CookRatings cr
    GROUP BY cr.cook_id
),
NationalityRatings AS (
    SELECT r.nationality_id, cr.total_rating
    FROM CookRatings cr
    JOIN Recipe r ON cr.cook_id = r.recipe_id
),
NationalityAverage AS (
    SELECT nr.nationality_id, AVG(nr.total_rating) AS average_nationality_rating
    FROM NationalityRatings nr
    GROUP BY nr.nationality_id
)
SELECT 
    'Cook' AS Type, ca.cook_id AS ID,CONCAT(c.first_name,' ', c.last_name) AS Name, ca.average_rating AS Average_Rating
FROM CookAverage ca
JOIN Cook c ON c.cook_id=ca.cook_id

UNION ALL

SELECT 'Nationality' AS Type, na.nationality_id AS ID, n.name AS Name, na.average_nationality_rating AS Average_Rating
FROM NationalityAverage na
JOIN Nationality n ON n.nationality_id=na.nationality_id
ORDER BY Type, ID;

---QUERY 3.2
--2: Για δεδομένη Εθνική κουζίνα και έτος, 
--ποιοι μάγειρες ανήκουν σε αυτήν και ποιοι μάγειρες συμμετείχαν σε επεισόδια:

SET @NationalityID = 103; 
SET @Season = 4;

WITH CooksByNationality AS (
    SELECT nc.cook_id
    FROM Nationality_Cook nc
    WHERE nc.nationality_id = @NationalityID
), CooksInEpisodes AS (
    SELECT DISTINCT cec.cook_id
    FROM Cook_Episode_Contestants cec
    JOIN Episode e ON cec.episode_id = e.episode_id
    JOIN Recipe r ON cec.recipe_id = r.recipe_id
    WHERE e.season = @Season AND r.nationality_id = @NationalityID
)

SELECT * FROM (
    SELECT 'Nationality Linked Cook' AS Type, c.cook_id, c.first_name, c.last_name
    FROM CooksByNationality cbn
    JOIN Cook c ON cbn.cook_id = c.cook_id

    UNION

    SELECT 'Episode Participating Cook' AS Type, c.cook_id, c.first_name, c.last_name
    FROM CooksInEpisodes cie
    JOIN Cook c ON cie.cook_id = c.cook_id
) AS results
ORDER BY Type, cook_id;

---QUERY 3.3
--3.Βρείτε τους νέους μάγειρες (ηλικία < 30 ετών) που έχουν τις περισσότερες συνταγές:

--IF WE ARE REFFERING TO RECIPE_COOK (EVERY RECIPE HE CAN MAKE)
SELECT Cook.cook_id, Cook.first_name, Cook.last_name, COUNT(*) AS recipe_count, TIMESTAMPDIFF(YEAR, Cook.date_of_birth, CURDATE()) AS age
FROM Cook 
INNER JOIN Recipe_Cook ON Cook.cook_id = Recipe_Cook.cook_id
WHERE TIMESTAMPDIFF(YEAR, Cook.date_of_birth, CURDATE()) < 30
GROUP BY Cook.cook_id, Cook.first_name, Cook.last_name
ORDER BY COUNT(*) DESC;


--IF WE ARE REFFERING TO COOK_EPISODE_CONTESTANTS (RECIPE_ID ATTRIBUTE) (RECIPES HE WAS ASSIGNED IN EPISODES)
SELECT Cook.cook_id, Cook.first_name, Cook.last_name, COUNT(DISTINCT cec.recipe_id) AS recipe_count, TIMESTAMPDIFF(YEAR, Cook.date_of_birth, CURDATE()) AS age
FROM Cook
INNER JOIN Cook_Episode_Contestants cec ON Cook.cook_id = cec.cook_id
WHERE TIMESTAMPDIFF(YEAR, Cook.date_of_birth, CURDATE()) < 30
GROUP BY Cook.cook_id, Cook.first_name, Cook.last_name
ORDER BY recipe_count DESC;


---QUERY 3.4 
--4.Βρείτε τους μάγειρες που δεν έχουν συμμετάσχει ποτέ σε ως κριτές σε κάποιο επεισόδιο: 

SELECT Cook.cook_id, Cook.first_name, Cook.last_name
FROM Cook
WHERE Cook.cook_id NOT IN (SELECT cook_id FROM Cook_Episode_Judge); 

---QUERY 3.5
--5.Ποιοι κριτές έχουν συμμετάσχει στον ίδιο αριθμό επεισοδίων 
--σε διάστημα ενός έτους με περισσότερες από 3 εμφανίσεις: 

--ONLY FROM THE SAME SEASON
WITH JudgeAppearances AS (
    SELECT cej.cook_id,e.season,COUNT(*) AS appearances
    FROM Cook_Episode_Judge cej
    JOIN Episode e ON cej.episode_id = e.episode_id
    GROUP BY cej.cook_id, e.season
    HAVING COUNT(*) > 3
)

SELECT j1.cook_id,j1.season,j1.appearances
FROM JudgeAppearances j1
JOIN JudgeAppearances j2 ON j1.season = j2.season AND j1.appearances = j2.appearances AND j1.cook_id <> j2.cook_id
GROUP BY j1.cook_id, j1.season, j1.appearances
ORDER BY j1.season, j1.appearances;


--FROM ALL THE SEASONS SEASON
WITH JudgeAppearances AS (
    SELECT cej.cook_id,e.season,COUNT(*) AS appearances
    FROM Cook_Episode_Judge cej
    JOIN Episode e ON cej.episode_id = e.episode_id
    GROUP BY cej.cook_id, e.season
    HAVING COUNT(*) > 3
)

SELECT j1.cook_id,j1.season,j1.appearances
FROM JudgeAppearances j1
JOIN JudgeAppearances j2 ON j1.appearances = j2.appearances AND j1.cook_id <> j2.cook_id
GROUP BY j1.cook_id, j1.season, j1.appearances
ORDER BY j1.appearances DESC, j1.season;

---QUERY 3.6 
--6.Πολλές συνταγές καλύπτουν περισσότερες από μια ετικέτες.    
--Ανάμεσα σε ζεύγη πεδίων (π.χ. brunch και κρύο πιάτο) που είναι κοινά στις συνταγές,
--βρείτε τα 3 κορυφαία (top-3) ζεύγη που εμφανίστηκαν σε επεισόδια. 

SELECT tag1, tag2, COUNT(DISTINCT cec.episode_id) AS appearances       
FROM (
    SELECT 
        r.recipe_id,
        LEAST(t1.name, t2.name) AS tag1,
        GREATEST(t1.name, t2.name) AS tag2
    FROM 
        Recipe_Tag rt1       
    INNER JOIN Recipe_Tag rt2 ON rt1.recipe_id = rt2.recipe_id AND rt1.tag_id < rt2.tag_id
    INNER JOIN Tag t1 ON rt1.tag_id = t1.tag_id
    INNER JOIN Tag t2 ON rt2.tag_id = t2.tag_id
    INNER JOIN Recipe r ON rt1.recipe_id = r.recipe_id
    GROUP BY 
        r.recipe_id, tag1, tag2
) AS pairs
INNER JOIN Cook_Episode_Contestants cec ON pairs.recipe_id = cec.recipe_id
GROUP BY 
    tag1, tag2
ORDER BY 
    appearances DESC
LIMIT 3;

--Force Indexing
SELECT tag1, tag2, COUNT(DISTINCT cec.episode_id) AS appearances
FROM (
    SELECT
        r.recipe_id,
        LEAST(t1.name, t2.name) AS tag1,
        GREATEST(t1.name, t2.name) AS tag2
    FROM Recipe_Tag rt1 FORCE INDEX (idx_recipe_tag_on_recipe_id_tag_id)
    INNER JOIN Recipe_Tag rt2
        FORCE INDEX (idx_recipe_tag_on_recipe_id_tag_id)
        ON rt1.recipe_id = rt2.recipe_id AND rt1.tag_id < rt2.tag_id
    INNER JOIN Tag t1 ON rt1.tag_id = t1.tag_id
    INNER JOIN Tag t2 ON rt2.tag_id = t2.tag_id
    INNER JOIN Recipe r FORCE INDEX (idx_recipe_on_recipe_id_difficulty)
        ON rt1.recipe_id = r.recipe_id
    GROUP BY r.recipe_id, tag1, tag2 
) AS pairs
INNER JOIN Cook_Episode_Contestants cec ON pairs.recipe_id = cec.recipe_id
GROUP BY
    tag1, tag2
ORDER BY
    appearances DESC
LIMIT 3;



---QUERY 3.7
--7.Βρείτε όλους τους μάγειρες που συμμετείχαν τουλάχιστον 5 λιγότερες φορές 
--από τον μάγειρα με τις περισσότερες συμμετοχές σε επεισόδια:

--ONLY CONTESTANTS
WITH CookParticipations AS (
    SELECT ce.cook_id, c.first_name, c.last_name, COUNT(*) AS appearances
    FROM Cook_Episode_Contestants ce
    JOIN Cook c ON ce.cook_id = c.cook_id
    GROUP BY ce.cook_id, c.first_name, c.last_name
), MaxParticipation AS (
    SELECT MAX(appearances) AS max_appearances
    FROM CookParticipations
)

SELECT 'Maximum Appearances' AS Description, cp.cook_id, cp.first_name, cp.last_name, cp.appearances AS Appearances
FROM CookParticipations cp
WHERE cp.appearances = (SELECT max_appearances FROM MaxParticipation)

UNION ALL

SELECT 'At least 5 fewer appearances' AS Description, cp.cook_id, cp.first_name, cp.last_name, cp.appearances AS Appearances
FROM CookParticipations cp
JOIN MaxParticipation mp ON cp.appearances <= (mp.max_appearances - 5) AND cp.appearances < mp.max_appearances
ORDER BY Appearances DESC;


--BOTH CONTESTANTS AND JUDGES (MAX IS FOR TOTAL APPEARANCES)
WITH ContestantCounts AS (
    SELECT ce.cook_id, COUNT(*) AS contestant_appearances
    FROM Cook_Episode_Contestants ce
    GROUP BY ce.cook_id
),
JudgeCounts AS (
    SELECT cej.cook_id, COUNT(*) AS judge_appearances
    FROM Cook_Episode_Judge cej
    GROUP BY cej.cook_id
),
CombinedCounts AS (
    SELECT 
        c.cook_id,
        c.first_name,
        c.last_name,
        COALESCE(cc.contestant_appearances, 0) AS contestant_appearances,
        COALESCE(jc.judge_appearances, 0) AS judge_appearances,
        (COALESCE(cc.contestant_appearances, 0) + COALESCE(jc.judge_appearances, 0)) AS total_appearances
    FROM Cook c
    LEFT JOIN ContestantCounts cc ON c.cook_id = cc.cook_id
    LEFT JOIN JudgeCounts jc ON c.cook_id = jc.cook_id
),
MaxParticipation AS (
    SELECT MAX(total_appearances) AS max_appearances
    FROM CombinedCounts
)

SELECT CASE WHEN cp.total_appearances = mp.max_appearances THEN 'Maximum Appearances' 
            ELSE 'At least 5 fewer appearances' END AS Description, 
       cp.cook_id, 
       cp.first_name, 
       cp.last_name, 
       cp.contestant_appearances, 
       cp.judge_appearances, 
       cp.total_appearances
FROM CombinedCounts cp
CROSS JOIN MaxParticipation mp
WHERE cp.total_appearances = mp.max_appearances OR cp.total_appearances <= (mp.max_appearances - 5)
ORDER BY (cp.total_appearances = mp.max_appearances) DESC, total_appearances DESC;


---QUERY 3.8 
--8.Σε ποιο επεισόδιο χρησιμοποιήθηκαν τα περισσότερα εξαρτήματα (εξοπλισμός): 

--ONLY UNIQUE EQUIPMENT
WITH EpisodeEquipmentCounts AS (
    SELECT e.episode_id, e.name AS episode_name, e.season, COUNT(DISTINCT re.equipment_id) AS total_unique_equipment
    FROM Episode e
    JOIN Cook_Episode_Contestants cec ON e.episode_id = cec.episode_id
    JOIN Recipe_Equipment re ON cec.recipe_id = re.recipe_id
    GROUP BY e.episode_id, e.name, e.season
)

SELECT eec.episode_id, eec.episode_name AS episode, eec.season, eec.total_unique_equipment
FROM EpisodeEquipmentCounts eec
WHERE eec.total_unique_equipment = (
    SELECT MAX(total_unique_equipment) FROM EpisodeEquipmentCounts
)
ORDER BY eec.total_unique_equipment DESC;


--TOTAL EQUIPMENT (NOT UNIQUE)
EXPLAIN
WITH EpisodeEquipmentCounts AS (
    SELECT e.episode_id, e.name AS episode_name, e.season, COUNT(re.equipment_id) AS total_equipment
    FROM Episode e
    JOIN Cook_Episode_Contestants cec ON e.episode_id = cec.episode_id
    JOIN Recipe_Equipment re ON cec.recipe_id = re.recipe_id
    GROUP BY e.episode_id, e.name, e.season
)

SELECT eec.episode_id, eec.episode_name AS episode, eec.season, eec.total_equipment
FROM EpisodeEquipmentCounts eec
WHERE eec.total_equipment = (
    SELECT MAX(total_equipment) FROM EpisodeEquipmentCounts
)
ORDER BY eec.total_equipment DESC;

--Force Indexing
CREATE INDEX idx_episode_grouping ON Episode(episode_id, name, season);

WITH EpisodeEquipmentCounts AS (
    SELECT e.episode_id, e.name AS episode_name, e.season, COUNT(re.equipment_id) AS total_equipment
    FROM Episode e
    FORCE INDEX (idx_episode_grouping)
    JOIN Cook_Episode_Contestants cec FORCE INDEX (idx_cec_on_episode_id_recipe_id) ON e.episode_id = cec.episode_id
    JOIN Recipe_Equipment re FORCE INDEX (idx_re_on_recipe_id_equipment_id) ON cec.recipe_id = re.recipe_id
    GROUP BY e.episode_id, e.name, e.season
)

SELECT eec.episode_id, eec.episode_name AS episode, eec.season, eec.total_equipment
FROM EpisodeEquipmentCounts eec
WHERE eec.total_equipment = (
    SELECT MAX(total_equipment) FROM EpisodeEquipmentCounts
)
ORDER BY eec.total_equipment DESC;


---QUERY 3.9 
--9.Λίστα με μέσο όρο αριθμού γραμμάριων υδατανθράκων στο διαγωνισμό ανά έτος: 

SELECT season,
   AVG(Recipe.curbs_grams_per_portion) AS avg_carbs_per_portion  
FROM Episode 
JOIN Cook_Episode_Contestants ON Episode.episode_id = Cook_Episode_Contestants.episode_id
JOIN Recipe ON Cook_Episode_Contestants.recipe_id = Recipe.recipe_id
GROUP BY season;



---QUERY 3.10
--10.Ποιες Εθνικές κουζίνες έχουν τον ίδιο αριθμό συμμετοχών σε διαγωνισμούς, 
--σε διάστημα δύο συνεχόμενων ετών, με τουλάχιστον 3 συμμετοχές ετησίως:

WITH NationalityAppearances AS (
    SELECT ne.nationality_id, e.season, COUNT(*) AS appearances
    FROM Nationality_Episode ne
    JOIN Episode e ON ne.episode_id = e.episode_id
    GROUP BY ne.nationality_id, e.season
    HAVING COUNT(*) >= 3
), ConsecutiveSeasons AS (
    SELECT n1.nationality_id, n1.season AS season1, n2.season AS season2, n1.appearances + n2.appearances AS total_appearances
    FROM NationalityAppearances n1
    JOIN NationalityAppearances n2 ON n1.nationality_id = n2.nationality_id AND n2.season = n1.season + 1
), FilteredNationalities AS (
    SELECT cs1.nationality_id, cs1.season1, cs1.season2, cs1.total_appearances
    FROM ConsecutiveSeasons cs1
    JOIN ConsecutiveSeasons cs2 ON cs1.total_appearances = cs2.total_appearances AND cs1.nationality_id <> cs2.nationality_id
)

SELECT DISTINCT fn.nationality_id AS Nationality_id, n.name AS Name, fn.season1, fn.season2, fn.total_appearances
FROM FilteredNationalities fn
JOIN Nationality n ON n.nationality_id=fn.nationality_id
ORDER BY fn.total_appearances DESC, fn.season1;

---QUERY 3.11 
--11.Βρείτε τους top-5 κριτές που έχουν δώσει συνολικά την υψηλότερη βαθμολόγηση σε ένα μάγειρα.
--(όνομα κριτή, όνομα μάγειρα και συνολικό σκορ βαθμολόγησης) : 
WITH JudgeRatings AS (
    SELECT 
        cec.cook_id AS contestant_cook_id,
        cec.episode_id,
        cec.rating_1, 
        cec.rating_2, 
        cec.rating_3
    FROM Cook_Episode_Contestants cec
),
Judges AS (
    SELECT 
        cej.cook_id AS judge_cook_id, 
        cej.episode_id,
        cej.judge_number
    FROM Cook_Episode_Judge cej
),
JudgeContestantRatings AS (
    SELECT 
        j.judge_cook_id,
        jr.contestant_cook_id,
        CASE 
            WHEN j.judge_number = 1 THEN jr.rating_1
            WHEN j.judge_number = 2 THEN jr.rating_2
            WHEN j.judge_number = 3 THEN jr.rating_3
        END AS rating
    FROM Judges j
    JOIN JudgeRatings jr ON j.episode_id = jr.episode_id
),
TotalRatings AS (
    SELECT 
        j.judge_cook_id,
        j.contestant_cook_id,
        SUM(j.rating) AS total_rating
    FROM JudgeContestantRatings j
    GROUP BY j.judge_cook_id, j.contestant_cook_id
),
JudgeNames AS (
    SELECT 
        c.cook_id,
        c.first_name AS judge_first_name,
        c.last_name AS judge_last_name
    FROM Cook c
),
ContestantNames AS (
    SELECT 
        c.cook_id,
        c.first_name AS contestant_first_name,
        c.last_name AS contestant_last_name
    FROM Cook c
)
SELECT 
    jn.cook_id AS judge_cook_id,
    jn.judge_first_name,
    jn.judge_last_name,
    cn.cook_id AS contestant_cook_id,
    cn.contestant_first_name,
    cn.contestant_last_name,
    tr.total_rating
FROM TotalRatings tr
JOIN JudgeNames jn ON tr.judge_cook_id = jn.cook_id
JOIN ContestantNames cn ON tr.contestant_cook_id = cn.cook_id
ORDER BY tr.total_rating DESC
LIMIT 5;



---QUERY 3.12 
--12.Ποιο ήταν το πιο τεχνικά δύσκολο, από πλευράς συνταγών, επεισόδιο του διαγωνισμού ανά έτος;
WITH EpisodeDifficulties AS (
    SELECT 
        e.episode_id,
        e.name AS episode_name,
        e.season,
        AVG(r.difficulty) AS average_recipe_difficulty
    FROM Episode e
    JOIN Cook_Episode_Contestants cec ON e.episode_id = cec.episode_id
    JOIN Recipe r ON cec.recipe_id = r.recipe_id
    GROUP BY e.episode_id, e.name, e.season
),
MaxDifficultiesPerSeason AS (
    SELECT 
        season,
        MAX(average_recipe_difficulty) AS max_difficulty
    FROM EpisodeDifficulties
    GROUP BY season
)
SELECT
    ed.season,
    ed.episode_name,
    ed.episode_id,
    ed.average_recipe_difficulty
FROM EpisodeDifficulties ed
JOIN MaxDifficultiesPerSeason mds ON ed.season = mds.season AND ed.average_recipe_difficulty = mds.max_difficulty
ORDER BY ed.season, ed.average_recipe_difficulty DESC;



---QUERY 3.13 
--13.Ποιο επεισόδιο συγκέντρωσε τον χαμηλότερο βαθμό επαγγελματικής κατάρτισης
--(κριτές και μάγειρες); 

WITH CookRankValues AS (
    SELECT
        cej.episode_id,
        CASE
            WHEN c.ranking = 'chef' THEN 5
            WHEN c.ranking = 'sous chef' THEN 4
            WHEN c.ranking = 'cook A' THEN 3
            WHEN c.ranking = 'cook B' THEN 2
            WHEN c.ranking = 'cook C' THEN 1
            ELSE 0 
        END AS ranking_value
    FROM Cook_Episode_Judge cej
    JOIN Cook c ON cej.cook_id = c.cook_id
    UNION ALL
    SELECT
        cec.episode_id,
        CASE
            WHEN c.ranking = 'chef' THEN 5
            WHEN c.ranking = 'sous chef' THEN 4
            WHEN c.ranking = 'cook A' THEN 3
            WHEN c.ranking = 'cook B' THEN 2
            WHEN c.ranking = 'cook C' THEN 1
            ELSE 0 
        END AS ranking_value
    FROM Cook_Episode_Contestants cec
    JOIN Cook c ON cec.cook_id = c.cook_id
),
EpisodeRankings AS (
    SELECT 
        episode_id,
        AVG(ranking_value) AS average_ranking
    FROM CookRankValues
    GROUP BY episode_id
)
SELECT 
    e.episode_id,
    e.name AS episode_name,
    e.season,
    er.average_ranking
FROM EpisodeRankings er
JOIN Episode e ON er.episode_id = e.episode_id
ORDER BY er.average_ranking ASC
LIMIT 1;


---QUERY 3.14 
--14.Ποια θεματική ενότητα έχει εμφανιστεί τις περισσότερες φορές στο διαγωνισμό;

SELECT rt.topic_id, t.name AS topic_name, COUNT(cec.episode_id) AS appearances
FROM Recipe_Topic rt
JOIN Topic t ON rt.topic_id = t.topic_id 
JOIN Cook_Episode_Contestants cec ON cec.recipe_id = rt.recipe_id 
GROUP BY rt.topic_id, t.name
ORDER BY appearances DESC
LIMIT 1;



---QUERY 3.15
--15.Ποιες ομάδες τροφίμων δεν έχουν εμφανιστεί ποτέ στον διαγωνισμό;

WITH UsedFoodGroups AS (
    SELECT DISTINCT r.food_group_identity
    FROM Recipe r
    JOIN Cook_Episode_Contestants cec ON r.recipe_id = cec.recipe_id
)

SELECT fg.food_group_id, fg.name AS food_group_name
FROM Food_Group fg
LEFT JOIN UsedFoodGroups ufg ON fg.group_identity = ufg.food_group_identity
WHERE ufg.food_group_identity IS NULL;
