DROP DATABASE contest;
CREATE DATABASE IF NOT EXISTS contest;
USE contest;

CREATE TABLE IF NOT EXISTS Image (
    image_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    image_url VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    PRIMARY KEY (image_id)
);

CREATE TABLE IF NOT EXISTS Nationality (
    nationality_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    image_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (nationality_id),
    CONSTRAINT fk_nationality_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Recipe (
    recipe_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    recipe_type ENUM("pastry", "cooking") NOT NULL,
    difficulty INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    preparation_time INT UNSIGNED NOT NULL,
    execution_time INT UNSIGNED NOT NULL,
    portions INT UNSIGNED NOT NULL,
    fat_grams_per_portion DECIMAL(7,2) UNSIGNED,
    protein_grams_per_portion DECIMAL(7,2) UNSIGNED,
    curbs_grams_per_portion DECIMAL(7,2) UNSIGNED,
    kcal_per_portion DECIMAL(7,2) UNSIGNED NOT NULL DEFAULT 0,
    image_id INT UNSIGNED NOT NULL,
    nationality_id INT UNSIGNED NOT NULL,
    food_group_identity VARCHAR(50),
    PRIMARY KEY (recipe_id),
    CONSTRAINT fk_recipe_nationality
        FOREIGN KEY (nationality_id) REFERENCES Nationality(nationality_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_recipe_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT CHK_difficulty 
        CHECK (difficulty BETWEEN 1 AND 5),
    CONSTRAINT CHK_portions
        CHECK (portions > 0)
);

CREATE TABLE IF NOT EXISTS Step (
    recipe_id INT UNSIGNED NOT NULL,
    step_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name TEXT NOT NULL,
    sequence INT UNSIGNED NOT NULL,
    PRIMARY KEY (step_id, recipe_id),
    CONSTRAINT fk_step_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Tag (
    tag_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (tag_id)
);

CREATE TABLE IF NOT EXISTS Tip (
    tip_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (tip_id)
);

CREATE TABLE IF NOT EXISTS Meal_type (
    meal_type_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (meal_type_id)
);

CREATE TABLE IF NOT EXISTS Recipe_Tag (
    recipe_id INT UNSIGNED NOT NULL,
    tag_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (recipe_id, tag_id),
    CONSTRAINT fk_tag_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_recipe_tag
        FOREIGN KEY (tag_id) REFERENCES Tag(tag_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Recipe_Tip (
    recipe_id INT UNSIGNED NOT NULL,
    tip_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (recipe_id, tip_id),
    CONSTRAINT fk_tip_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_recipe_tip
        FOREIGN KEY (tip_id) REFERENCES Tip(tip_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Recipe_Meal_Type (
    recipe_id INT UNSIGNED NOT NULL,
    meal_type_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (recipe_id, meal_type_id),
    CONSTRAINT fk_meal_type_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_recipe_meal_type
        FOREIGN KEY (meal_type_id) REFERENCES Meal_type(meal_type_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Food_Group (
    food_group_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    image_id INT UNSIGNED NOT NULL,
    group_identity VARCHAR(50) NOT NULL,
    PRIMARY KEY (food_group_id),
    CONSTRAINT fk_food_group_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Ingredient (
    ingredient_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    kcal_per_100 DECIMAL(7,2) NOT NULL,
    image_id INT UNSIGNED NOT NULL,
    food_group_id INT UNSIGNED NOT NULL,
    avg_grams INT UNSIGNED,
    PRIMARY KEY (ingredient_id),
    CONSTRAINT fk_ingredient_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ingredient_food_group
        FOREIGN KEY (food_group_id) REFERENCES Food_Group(food_group_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Recipe_Ingredient (
    recipe_id INT UNSIGNED NOT NULL,
    ingredient_id INT UNSIGNED NOT NULL,
    basic_ingredient BOOLEAN NOT NULL DEFAULT FALSE,
    quantity_type ENUM('grams', 'serving', 'non_numeric') NOT NULL,
    quantity VARCHAR(50) NOT NULL, 
    serving_type VARCHAR(50), 
    PRIMARY KEY (recipe_id, ingredient_id),
    CONSTRAINT fk1_ingredient_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_recipe_ingredient
        FOREIGN KEY (ingredient_id) REFERENCES Ingredient(ingredient_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Equipment (
    equipment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    manual TEXT NOT NULL,
    image_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (equipment_id),
    CONSTRAINT fk_equipment_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Recipe_Equipment (
    recipe_id INT UNSIGNED NOT NULL,
    equipment_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (equipment_id, recipe_id),
    CONSTRAINT fk1_equipment_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_recipe_equipment
        FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Topic (
    topic_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(50) NOT NULL,
    image_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (topic_id),
    CONSTRAINT fk_topic_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
); 

CREATE TABLE IF NOT EXISTS Recipe_Topic (
    recipe_id INT UNSIGNED NOT NULL,
    topic_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (topic_id, recipe_id),
    CONSTRAINT fk1_topic_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_recipe_topic
        FOREIGN KEY (topic_id) REFERENCES Topic(topic_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Administrator (
    admin_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    PRIMARY KEY (admin_id)
);

CREATE TABLE IF NOT EXISTS Cook (
    cook_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    contact_number VARCHAR(10) NOT NULL,
    date_of_birth DATE NOT NULL,
    years_of_experience INT NOT NULL,
    ranking ENUM("chef", "sous chef", "cook A", "cook B", "cook C") NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    image_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (cook_id),
    CONSTRAINT fk_cook_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Nationality_Cook (
    nationality_id INT UNSIGNED NOT NULL,
    cook_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (nationality_id, cook_id),
    CONSTRAINT fk1_cook_nationality
        FOREIGN KEY (nationality_id) REFERENCES Nationality(nationality_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_nationality_cook
        FOREIGN KEY (cook_id) REFERENCES Cook(cook_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Recipe_Cook (
    recipe_id INT UNSIGNED NOT NULL,
    cook_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (recipe_id, cook_id),
    CONSTRAINT fk1_cook_recipe
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_recipe_cook
        FOREIGN KEY (cook_id) REFERENCES Cook(cook_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Episode (
    episode_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name INT NOT NULL,
    season INT NOT NULL,
    winner INT UNSIGNED,
    image_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (episode_id),
    CONSTRAINT fk_episode_image
        FOREIGN KEY (image_id) REFERENCES Image(image_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT CHK_episode_number
        CHECK (name BETWEEN 1 AND 10)
);

CREATE TABLE IF NOT EXISTS Nationality_Episode (
    nationality_id INT UNSIGNED NOT NULL,
    episode_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (nationality_id, episode_id),
    CONSTRAINT fk1_episode_nationality
        FOREIGN KEY (nationality_id) REFERENCES Nationality(nationality_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_nationality_episode
        FOREIGN KEY (episode_id) REFERENCES Episode(episode_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Cook_Episode_Judge (
    episode_id INT UNSIGNED NOT NULL,
    cook_id INT UNSIGNED NOT NULL, 
    judge_number INT NOT NULL,
    PRIMARY KEY (episode_id, cook_id),
    CONSTRAINT fk1_judge_episode
        FOREIGN KEY (episode_id) REFERENCES Episode(episode_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_episode_judge
        FOREIGN KEY (cook_id) REFERENCES Cook(cook_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Cook_Episode_Contestants (
    episode_id INT UNSIGNED NOT NULL,
    cook_id INT UNSIGNED NOT NULL,
    recipe_id INT UNSIGNED NOT NULL,
    rating_1 INT NOT NULL,
    rating_2 INT NOT NULL,
    rating_3 INT NOT NULL,
    PRIMARY KEY (episode_id, cook_id, recipe_id),
    CONSTRAINT fk1_cook_episode
        FOREIGN KEY (episode_id) REFERENCES Episode(episode_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk2_episode_cook
        FOREIGN KEY (cook_id) REFERENCES Cook(cook_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk3_recipe_episode_cook
        FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE INDEX idx_recipe_on_nationality_id_recipe_id ON Recipe(nationality_id, recipe_id);
CREATE INDEX idx_cec_on_episode_id_recipe_id ON Cook_Episode_Contestants(episode_id, recipe_id);
CREATE INDEX idx_episode_on_episode_id_season ON Episode(episode_id, season);
CREATE INDEX idx_cec_on_cook_id_recipe_id ON Cook_Episode_Contestants(cook_id, recipe_id);
CREATE INDEX idx_cej_on_cook_id_episode_id ON Cook_Episode_Judge(cook_id, episode_id);
CREATE INDEX idx_recipe_tag_on_recipe_id_tag_id ON Recipe_Tag(recipe_id, tag_id);
CREATE INDEX idx_re_on_recipe_id_equipment_id ON Recipe_Equipment(recipe_id, equipment_id);
CREATE INDEX idx_ne_on_episode_id_nationality_id ON Nationality_Episode(episode_id, nationality_id);
CREATE INDEX idx_recipe_on_recipe_id_difficulty ON Recipe(recipe_id, difficulty);
CREATE INDEX idx_cej_on_episode_id_cook_id ON Cook_Episode_Judge(episode_id, cook_id);


DROP ROLE 'Cook_User';
DROP ROLE 'Administrator';

CREATE ROLE "Cook_User";
CREATE ROLE "Administrator";

GRANT ALL PRIVILEGES ON contest.* TO "Administrator";

GRANT SELECT, INSERT, UPDATE ON contest.Recipe TO "Cook_User";
GRANT SELECT, UPDATE ON contest.Cook TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Recipe TO "Cook_User";
GRANT SELECT, INSERT, UPDATE, DELETE ON contest.Step TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Meal_type TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Tip TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Tag TO "Cook_User";
GRANT SELECT, INSERT, UPDATE, DELETE ON contest.Recipe_Meal_type TO "Cook_User";
GRANT SELECT, INSERT, UPDATE, DELETE ON contest.Recipe_Tip TO "Cook_User";
GRANT SELECT, INSERT, UPDATE, DELETE ON contest.Recipe_Tag TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Recipe_Cook TO "Cook_User";
GRANT SELECT, INSERT, UPDATE, DELETE ON contest.Recipe_Equipment TO "Cook_User";
GRANT SELECT, INSERT, UPDATE, DELETE ON contest.Recipe_Ingredient TO "Cook_User";
GRANT SELECT, INSERT, UPDATE, DELETE ON contest.Recipe_Topic TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Image TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Nationality TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Ingredient TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Equipment TO "Cook_User";
GRANT SELECT, INSERT, UPDATE ON contest.Topic TO "Cook_User";
GRANT SELECT ON contest.Cook_Episode_Contestants TO "Cook_User";
GRANT SELECT ON contest.Episode TO "Cook_User";


DELIMITER //

DROP TRIGGER IF EXISTS check_tip_limit_before_insert;
DROP TRIGGER IF EXISTS add_step_in_middle_of_recipe;
DROP TRIGGER IF EXISTS food_group_identity_on_recipe;
DROP TRIGGER IF EXISTS food_group_identity_on_recipe_update;
DROP TRIGGER IF EXISTS pick_winner_in_episode;
DROP TRIGGER IF EXISTS match_season_with_unique_episode;
DROP TRIGGER IF EXISTS nationality_episode_regulator;
DROP TRIGGER IF EXISTS contestant_episode_regulator;
DROP TRIGGER IF EXISTS calculate_kcal_per_portion_dynamically;
DROP TRIGGER IF EXISTS update_kcal_per_portion_dynamically;
DROP TRIGGER IF EXISTS delete_kcal_per_portion_dynamically;
DROP TRIGGER IF EXISTS update_kcal_on_ingredient_kcal_change;
DROP TRIGGER IF EXISTS update_kcal_on_portions_change;
DROP TRIGGER IF EXISTS three_different_judges_per_episode;
DROP TRIGGER IF EXISTS check_consecutive_episodes_per_contestant;
DROP TRIGGER IF EXISTS check_consecutive_episodes_per_judge;
DROP TRIGGER IF EXISTS check_consecutive_episodes_per_nationality;
DROP TRIGGER IF EXISTS check_consecutive_episodes_per_recipe;
DROP TRIGGER IF EXISTS link_recipe_to_cook_after_insert;
DROP TRIGGER IF EXISTS check_user_before_edit_on_cook;
DROP TRIGGER IF EXISTS check_user_before_edit_on_recipe;
DROP TRIGGER IF EXISTS check_user_before_add_on_recipe_ingredient;
DROP TRIGGER IF EXISTS check_user_before_edit_on_recipe_ingredient;
DROP TRIGGER IF EXISTS check_user_before_add_on_recipe_equipment;
DROP TRIGGER IF EXISTS check_user_before_edit_on_recipe_equipment;
DROP TRIGGER IF EXISTS check_user_before_add_on_recipe_topic;
DROP TRIGGER IF EXISTS check_user_before_edit_on_recipe_topic;
DROP TRIGGER IF EXISTS check_user_before_add_on_recipe_tag;
DROP TRIGGER IF EXISTS check_user_before_edit_on_recipe_tag;
DROP TRIGGER IF EXISTS check_user_before_add_on_recipe_tip;
DROP TRIGGER IF EXISTS check_user_before_edit_on_recipe_tip;
DROP TRIGGER IF EXISTS check_user_before_add_on_recipe_meal_type;
DROP TRIGGER IF EXISTS check_user_before_edit_on_recipe_meal_type;
DROP TRIGGER IF EXISTS check_user_before_add_on_step;
DROP TRIGGER IF EXISTS check_user_before_edit_on_step;
DROP TRIGGER IF EXISTS check_user_before_delete_on_recipe_ingredient;
DROP TRIGGER IF EXISTS check_user_before_delete_on_recipe_equipment;
DROP TRIGGER IF EXISTS check_user_before_delete_on_recipe_topic;
DROP TRIGGER IF EXISTS check_user_before_delete_on_recipe_tag;
DROP TRIGGER IF EXISTS check_user_before_delete_on_recipe_tip;
DROP TRIGGER IF EXISTS check_user_before_delete_on_recipe_meal_type;
DROP TRIGGER IF EXISTS check_user_before_delete_on_step;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_tip_limit_before_insert
BEFORE INSERT ON Recipe_Tip
FOR EACH ROW
BEGIN
    DECLARE tip_count INT;
    SELECT COUNT(*) INTO tip_count FROM Recipe_Tip WHERE recipe_id = NEW.recipe_id;
    IF tip_count >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add more than 3 tips per recipe';
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER add_step_in_middle_of_recipe
BEFORE INSERT ON Step
FOR EACH ROW
BEGIN
    IF (SELECT NEW.sequence-MAX(sequence) FROM Step WHERE NEW.recipe_id = recipe_id)>1
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot skip step in recipe';
        END IF;
    IF (SELECT sequence FROM Step WHERE recipe_id = NEW.recipe_id AND sequence = NEW.sequence)
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This step already exists';
        END IF;
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER delete_step_in_middle_of_recipe
BEFORE DELETE ON Step
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete existing step'; 
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER food_group_identity_on_recipe
BEFORE INSERT ON Recipe_Ingredient
FOR EACH ROW
BEGIN
	DECLARE temp_food_group_id INT;
    DECLARE temp_food_group VARCHAR(50);
    IF NEW.basic_ingredient
        THEN
        IF EXISTS (SELECT basic_ingredient FROM Recipe_Ingredient
        WHERE recipe_id  = NEW.recipe_id and basic_ingredient = TRUE)
            THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This recipe already has a basic ingredient';
        ELSE
            SELECT food_group_id INTO temp_food_group_id FROM Ingredient
            WHERE ingredient_id = NEW.ingredient_id;
            SELECT group_identity INTO temp_food_group FROM Food_Group
            WHERE food_group_id = temp_food_group_id;

            UPDATE Recipe
            SET food_group_identity = temp_food_group 
            WHERE recipe_id = NEW.recipe_id;
        END IF;
    END IF;
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER food_group_identity_on_recipe_update
BEFORE UPDATE ON Recipe_Ingredient
FOR EACH ROW
BEGIN
    DECLARE prev_basic_ingredient INT DEFAULT NULL;
    IF NEW.basic_ingredient THEN
        
        SELECT ingredient_id INTO prev_basic_ingredient FROM Recipe_Ingredient
        WHERE recipe_id  = NEW.recipe_id and basic_ingredient = TRUE;
        
        IF prev_basic_ingredient THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This recipe already has a basic ingredient';
        END IF;
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER pick_winner_in_episode
AFTER INSERT ON Cook_Episode_Contestants
FOR EACH ROW
BEGIN
    DECLARE current_winner INT;
    DECLARE total_rating INT;

    SELECT Cook_Episode_Contestants.cook_id, SUM(rating_1 + rating_2 + rating_3)
    INTO current_winner, total_rating
    FROM Cook_Episode_Contestants
    INNER JOIN Cook ON Cook.cook_id = Cook_Episode_Contestants.cook_id
    WHERE episode_id = NEW.episode_id
    GROUP BY Cook_Episode_Contestants.cook_id
    ORDER BY SUM(rating_1 + rating_2 + rating_3) DESC, Cook.ranking DESC
    LIMIT 1;

    UPDATE Episode
    SET winner = current_winner 
    WHERE episode_id = NEW.episode_id;
END;
//

DELIMITER ;


DELIMITER // 

CREATE TRIGGER match_season_with_unique_episode 
BEFORE INSERT ON Episode 
FOR EACH ROW 
BEGIN 
    DECLARE episode_count INT ;
    IF EXISTS (
        SELECT 1 FROM Episode 
        WHERE season = NEW.season 
        AND name = NEW.name
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add episode with duplicate name in this season';
    END IF; 
        SELECT count(*) INTO episode_count FROM Episode WHERE season = NEW.season;
    IF episode_count >=10 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot add another episode in this season';
    END IF; 

END; 
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER nationality_episode_regulator
BEFORE INSERT ON Nationality_Episode
FOR EACH ROW
BEGIN
    DECLARE num_of_nationalities INT;
    SELECT COUNT(*) INTO num_of_nationalities 
    FROM Nationality_Episode
    WHERE episode_id = NEW.episode_id;
    IF num_of_nationalities >= 10 
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Episode already has maximum Nationalities';
    END IF;

    IF EXISTS(SELECT nationality_id FROM Nationality_Episode 
    WHERE episode_id = NEW.episode_id AND nationality_id = NEW.nationality_id)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nationality already in this Episode';
	END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER contestant_episode_regulator
BEFORE INSERT ON Cook_Episode_Contestants
FOR EACH ROW
BEGIN
    DECLARE num_of_contestants INT;
    SELECT COUNT(*) INTO num_of_contestants 
    FROM Cook_Episode_Contestants
    WHERE episode_id = NEW.episode_id;
    IF num_of_contestants >= 10 
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Episode already has maximum Contestants';
    END IF;

    IF EXISTS (SELECT cook_id FROM Cook_Episode_Contestants 
    WHERE episode_id = NEW.episode_id AND cook_id = NEW.cook_id)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contestant already in this Episode';
	END IF;

    IF EXISTS(SELECT cook_id FROM Cook_Episode_Judge 
    WHERE cook_id = NEW.cook_id AND episode_id = NEW.episode_id)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cook is a Judge in this Episode';
    END IF;
    
END;
//
DELIMITER ;


DELIMITER //

CREATE TRIGGER calculate_kcal_per_portion_dynamically
AFTER INSERT ON Recipe_Ingredient
FOR EACH ROW
BEGIN
    DECLARE temp_total_kcal DECIMAL(7,2) DEFAULT 0;
    DECLARE temp_portions INT;
    DECLARE temp_avg_grams INT;
    DECLARE temp_kcal_per_100 INT;
    DECLARE converted_quantity INT;

    SELECT portions INTO temp_portions FROM Recipe WHERE recipe_id = NEW.recipe_id;
    SELECT avg_grams, kcal_per_100 INTO temp_avg_grams, temp_kcal_per_100 
    FROM Ingredient WHERE ingredient_id = NEW.ingredient_id;

    IF NEW.quantity_type IN ('grams', 'serving') THEN
        SET converted_quantity = CAST(NEW.quantity AS UNSIGNED);

        IF NEW.quantity_type = 'grams' THEN
            SET temp_total_kcal = (converted_quantity / 100) * temp_kcal_per_100 / temp_portions;
        ELSEIF NEW.quantity_type = 'serving' THEN
            SET temp_total_kcal = ((temp_avg_grams * converted_quantity / 100) * temp_kcal_per_100) / temp_portions;
        END IF;

        UPDATE Recipe
        SET kcal_per_portion = kcal_per_portion + temp_total_kcal
        WHERE recipe_id = NEW.recipe_id;
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER update_kcal_per_portion_dynamically
AFTER UPDATE ON Recipe_Ingredient
FOR EACH ROW
BEGIN
    DECLARE old_total_kcal DECIMAL(7,2) DEFAULT 0;
    DECLARE new_total_kcal DECIMAL(7,2) DEFAULT 0;
    DECLARE temp_portions INT;
    DECLARE temp_avg_grams INT;
    DECLARE temp_kcal_per_100 INT;
    DECLARE old_converted_quantity INT;
    DECLARE new_converted_quantity INT;

    IF OLD.quantity <> NEW.quantity OR OLD.quantity_type <> NEW.quantity_type THEN
        SELECT portions INTO temp_portions FROM Recipe WHERE recipe_id = OLD.recipe_id;
        SELECT avg_grams, kcal_per_100 INTO temp_avg_grams, temp_kcal_per_100 
        FROM Ingredient WHERE ingredient_id = OLD.ingredient_id;

        IF OLD.quantity_type IN ('grams', 'serving') THEN
            SET old_converted_quantity = CAST(OLD.quantity AS UNSIGNED);

            IF OLD.quantity_type = 'grams' THEN
                SET old_total_kcal = (old_converted_quantity / 100) * temp_kcal_per_100 / temp_portions;
            ELSEIF OLD.quantity_type = 'serving' THEN
                SET old_total_kcal = ((temp_avg_grams * old_converted_quantity / 100) * temp_kcal_per_100) / temp_portions;
            END IF;
        END IF;

        IF NEW.quantity_type IN ('grams', 'serving') THEN
            SET new_converted_quantity = CAST(NEW.quantity AS UNSIGNED);

            IF NEW.quantity_type = 'grams' THEN
                SET new_total_kcal = (new_converted_quantity / 100) * temp_kcal_per_100 / temp_portions;
            ELSEIF NEW.quantity_type = 'serving' THEN
                SET new_total_kcal = ((temp_avg_grams * new_converted_quantity / 100) * temp_kcal_per_100) / temp_portions;
            END IF;
        END IF;

        UPDATE Recipe
        SET kcal_per_portion = kcal_per_portion - old_total_kcal + new_total_kcal
        WHERE recipe_id = OLD.recipe_id;
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER delete_kcal_per_portion_dynamically
AFTER DELETE ON Recipe_Ingredient
FOR EACH ROW
BEGIN
    DECLARE deleted_kcal DECIMAL(7,2) DEFAULT 0;
    DECLARE temp_portions INT;
    DECLARE temp_avg_grams INT;
    DECLARE temp_kcal_per_100 INT;
    DECLARE converted_quantity INT;

    SELECT portions INTO temp_portions FROM Recipe WHERE recipe_id = OLD.recipe_id;
    SELECT avg_grams, kcal_per_100 INTO temp_avg_grams, temp_kcal_per_100 
    FROM Ingredient WHERE ingredient_id = OLD.ingredient_id;

    IF OLD.quantity_type IN ('grams', 'serving') THEN

        SET converted_quantity = CAST(OLD.quantity AS UNSIGNED);

        IF OLD.quantity_type = 'grams' THEN
            SET deleted_kcal = (converted_quantity / 100) * temp_kcal_per_100 / temp_portions;
        ELSEIF OLD.quantity_type = 'serving' THEN
            SET deleted_kcal = ((temp_avg_grams * converted_quantity / 100) * temp_kcal_per_100) / temp_portions;
        END IF;

        UPDATE Recipe
        SET kcal_per_portion = kcal_per_portion - deleted_kcal
        WHERE recipe_id = OLD.recipe_id;
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER update_kcal_on_ingredient_kcal_change
AFTER UPDATE ON Ingredient
FOR EACH ROW
BEGIN
    DECLARE temp_recipe_id INT;
    DECLARE old_kcal DECIMAL(10,2) DEFAULT 0;
    DECLARE new_kcal DECIMAL(10,2) DEFAULT 0;
    DECLARE temp_quantity INT;
    DECLARE temp_avg_grams INT;
    DECLARE temp_portions INT;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE quantity_type ENUM('grams', 'serving', 'non_numeric');
    
    DECLARE cur CURSOR FOR
        SELECT recipe_id, Recipe_Ingredient.quantity, avg_grams, quantity_type
        FROM Recipe_Ingredient
        JOIN Ingredient ON Recipe_Ingredient.ingredient_id = Ingredient.ingredient_id
        WHERE Ingredient.ingredient_id = NEW.ingredient_id AND quantity_type IN ('grams', 'serving');
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    IF OLD.kcal_per_100 <> NEW.kcal_per_100 THEN
        OPEN cur;
        
        recipe_loop: LOOP
            FETCH cur INTO temp_recipe_id, temp_quantity, temp_avg_grams, quantity_type;
            IF done THEN
                LEAVE recipe_loop;
            END IF;
            
            SELECT portions INTO temp_portions FROM Recipe WHERE recipe_id = temp_recipe_id;

            IF quantity_type = 'grams' THEN
                SET old_kcal = (CAST(temp_quantity AS UNSIGNED) / 100) * OLD.kcal_per_100 / temp_portions;
                SET new_kcal = (CAST(temp_quantity AS UNSIGNED) / 100) * NEW.kcal_per_100 / temp_portions;
            ELSEIF quantity_type = 'serving' THEN
                SET old_kcal = ((temp_avg_grams * CAST(temp_quantity AS UNSIGNED) / 100) * OLD.kcal_per_100) / temp_portions;
                SET new_kcal = ((temp_avg_grams * CAST(temp_quantity AS UNSIGNED) / 100) * NEW.kcal_per_100) / temp_portions;
            END IF;

            UPDATE Recipe
            SET kcal_per_portion = kcal_per_portion - old_kcal + new_kcal
            WHERE recipe_id = temp_recipe_id;

        END LOOP;

        CLOSE cur;
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER restrict_update_kcal_on_portions_change
BEFORE UPDATE ON Recipe
FOR EACH ROW
BEGIN
    IF OLD.portions <> NEW.portions 
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot change recipe portions';
    END IF;
END;
//

DELIMITER ;


DELIMITER // 

CREATE TRIGGER three_different_judges_per_episode 
BEFORE INSERT ON Cook_Episode_Judge 
FOR EACH ROW 
BEGIN 
        DECLARE temp_judge_count INT;  
        DECLARE temp_judge_number INT;
        IF EXISTS(SELECT cook_id FROM Cook_Episode_Judge 
        WHERE cook_id = NEW.cook_id AND episode_id = NEW.episode_id) 
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cook is already a Judge in this Episode' ;
        END IF;  
         IF EXISTS(SELECT cook_id FROM Cook_Episode_Contestants
         WHERE cook_id = NEW.cook_id AND episode_id = NEW.episode_id) 
         THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cook already competes in this Episode' ;
        END IF;
      SELECT COUNT(*) INTO temp_judge_count  
      FROM Cook_Episode_Judge 
      WHERE episode_id = NEW.episode_id;
      IF temp_judge_count >= 3 
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Episode already has maximum Judges'; 
      END IF;
      

       SET temp_judge_number = temp_judge_count + 1;
       SET NEW.judge_number = temp_judge_number ;

    END; 
// 

DELIMITER ; 


DELIMITER //

CREATE TRIGGER check_consecutive_episodes_per_contestant
BEFORE INSERT ON Cook_Episode_Contestants
FOR EACH ROW
BEGIN
    DECLARE prev_episode_id INT DEFAULT 0;
    DECLARE second_last_episode_id INT DEFAULT 0;
    DECLARE third_last_episode_id INT DEFAULT 0;
    DECLARE count_episodes INT DEFAULT 0;

    SELECT episode_id INTO prev_episode_id
    FROM Cook_Episode_Contestants
    WHERE cook_id = NEW.cook_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 0;

    SELECT episode_id INTO second_last_episode_id
    FROM Cook_Episode_Contestants
    WHERE cook_id = NEW.cook_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 1;

    SELECT episode_id INTO third_last_episode_id
    FROM Cook_Episode_Contestants
    WHERE cook_id = NEW.cook_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 2;

    SELECT COUNT(*) INTO count_episodes
    FROM Cook_Episode_Contestants
    WHERE cook_id = NEW.cook_id;

    IF (count_episodes >= 3 AND NEW.episode_id = prev_episode_id + 1 AND prev_episode_id = second_last_episode_id + 1 AND second_last_episode_id = third_last_episode_id + 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cook cannot participate in more than 3 consecutive episodes as a contestant';
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_consecutive_episodes_per_judge
BEFORE INSERT ON Cook_Episode_Judge
FOR EACH ROW
BEGIN
    DECLARE prev_episode_id INT DEFAULT 0;
    DECLARE second_last_episode_id INT DEFAULT 0;
    DECLARE third_last_episode_id INT DEFAULT 0;
    DECLARE count_episodes INT DEFAULT 0;

    SELECT episode_id INTO prev_episode_id
    FROM Cook_Episode_Judge
    WHERE cook_id = NEW.cook_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 0;

    SELECT episode_id INTO second_last_episode_id
    FROM Cook_Episode_Judge
    WHERE cook_id = NEW.cook_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 1;

    SELECT episode_id INTO third_last_episode_id
    FROM Cook_Episode_Judge
    WHERE cook_id = NEW.cook_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 2;

    SELECT COUNT(*) INTO count_episodes
    FROM Cook_Episode_Judge
    WHERE cook_id = NEW.cook_id;

    IF (count_episodes >= 3 AND NEW.episode_id = prev_episode_id + 1 AND prev_episode_id = second_last_episode_id + 1 AND second_last_episode_id = third_last_episode_id + 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cook cannot participate in more than 3 consecutive episodes as a judge';
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_consecutive_episodes_per_nationality
BEFORE INSERT ON Nationality_Episode
FOR EACH ROW
BEGIN
    DECLARE prev_episode_id INT DEFAULT 0;
    DECLARE second_last_episode_id INT DEFAULT 0;
    DECLARE third_last_episode_id INT DEFAULT 0;
    DECLARE count_episodes INT DEFAULT 0;

    SELECT episode_id INTO prev_episode_id
    FROM Nationality_Episode
    WHERE nationality_id = NEW.nationality_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 0;

    SELECT episode_id INTO second_last_episode_id
    FROM Nationality_Episode
    WHERE nationality_id = NEW.nationality_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 1;

    SELECT episode_id INTO third_last_episode_id
    FROM Nationality_Episode
    WHERE nationality_id = NEW.nationality_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 2;

    SELECT COUNT(*) INTO count_episodes
    FROM Nationality_Episode
    WHERE nationality_id = NEW.nationality_id;

    IF (count_episodes >= 3 AND NEW.episode_id = prev_episode_id + 1 AND prev_episode_id = second_last_episode_id + 1 AND second_last_episode_id = third_last_episode_id + 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nationality cannot appear in more than 3 consecutive episodes';
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_consecutive_episodes_per_recipe
BEFORE INSERT ON Cook_Episode_Contestants
FOR EACH ROW
BEGIN
    DECLARE prev_episode_id INT DEFAULT 0;
    DECLARE second_last_episode_id INT DEFAULT 0;
    DECLARE third_last_episode_id INT DEFAULT 0;
    DECLARE count_episodes INT DEFAULT 0;

    SELECT episode_id INTO prev_episode_id
    FROM Cook_Episode_Contestants
    WHERE recipe_id = NEW.recipe_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 0;

    SELECT episode_id INTO second_last_episode_id
    FROM Cook_Episode_Contestants
    WHERE recipe_id = NEW.recipe_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 1;

    SELECT episode_id INTO third_last_episode_id
    FROM Cook_Episode_Contestants
    WHERE recipe_id = NEW.recipe_id
    ORDER BY episode_id DESC
    LIMIT 1 OFFSET 2;

    SELECT COUNT(*) INTO count_episodes
    FROM Cook_Episode_Contestants
    WHERE recipe_id = NEW.recipe_id;

    IF (count_episodes >= 3 AND NEW.episode_id = prev_episode_id + 1 AND prev_episode_id = second_last_episode_id + 1 AND second_last_episode_id = third_last_episode_id + 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Recipe cannot appear in more than 3 consecutive episodes';
    END IF;
END;
//

DELIMITER ;


DELIMITER //

CREATE TRIGGER link_recipe_to_cook_after_insert
AFTER INSERT ON Recipe
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        INSERT INTO Recipe_Cook (recipe_id, cook_id)
        VALUES (NEW.recipe_id, current_cook_id);
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_cook 
BEFORE UPDATE ON Cook 
FOR EACH ROW 
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SET error_message = CONCAT("Unauthorized attempt to modify Cook with cook_id: ", CAST(OLD.cook_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR));

        IF OLD.cook_id <> current_cook_id THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_recipe
BEFORE UPDATE ON Recipe
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_recipe_ingredient
BEFORE UPDATE ON Recipe_Ingredient
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_add_on_recipe_ingredient
BEFORE INSERT ON Recipe_Ingredient
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = NEW.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(NEW.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_recipe_equipment
BEFORE UPDATE ON Recipe_Equipment
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_add_on_recipe_equipment
BEFORE INSERT ON Recipe_Equipment
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = NEW.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(NEW.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_recipe_topic
BEFORE UPDATE ON Recipe_Topic
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_add_on_recipe_topic
BEFORE INSERT ON Recipe_Topic
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = NEW.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(NEW.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_recipe_tag
BEFORE UPDATE ON Recipe_Tag
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_add_on_recipe_tag
BEFORE INSERT ON Recipe_Tag
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = NEW.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(NEW.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_recipe_tip
BEFORE UPDATE ON Recipe_Tip
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_add_on_recipe_tip
BEFORE INSERT ON Recipe_Tip
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = NEW.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(NEW.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_recipe_meal_type
BEFORE UPDATE ON Recipe_Meal_Type
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_add_on_recipe_meal_type
BEFORE INSERT ON Recipe_Meal_Type
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = NEW.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(NEW.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_edit_on_step
BEFORE UPDATE ON Step
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_add_on_step
BEFORE INSERT ON Step
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = NEW.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(NEW.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_delete_on_recipe_ingredient
BEFORE DELETE ON Recipe_Ingredient
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_delete_on_recipe_equipment
BEFORE DELETE ON Recipe_Equipment
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_delete_on_recipe_topic
BEFORE DELETE ON Recipe_Topic
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_delete_on_recipe_tag
BEFORE DELETE ON Recipe_Tag
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_delete_on_recipe_tip
BEFORE DELETE ON Recipe_Tip
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_delete_on_recipe_meal_type
BEFORE DELETE ON Recipe_Meal_Type
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_user_before_delete_on_step
BEFORE DELETE ON Step
FOR EACH ROW
BEGIN
    DECLARE current_cook_id INT;
    DECLARE current_username VARCHAR(255);
    DECLARE is_cook_linked BOOLEAN DEFAULT FALSE;
    DECLARE error_message VARCHAR(255);

    SELECT cook_id INTO current_cook_id FROM Cook WHERE username = SUBSTRING_INDEX(USER(), '@', 1);
    SET current_username = SUBSTRING_INDEX(USER(), '@', 1);

    IF current_cook_id IS NOT NULL THEN
        SELECT EXISTS(
            SELECT 1 FROM Recipe_Cook
            WHERE cook_id = current_cook_id AND recipe_id = OLD.recipe_id
        ) INTO is_cook_linked;

        SET error_message = CONCAT("Unauthorized attempt to modify Recipe with recipe_id: ", CAST(OLD.recipe_id AS CHAR), 
                                ".\nAction attempted by user: ", current_username,
                                " with cook_id: ", CAST(current_cook_id AS CHAR),
                                ". Cook not linked to this recipe.");

        IF NOT is_cook_linked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END //

DELIMITER ;

