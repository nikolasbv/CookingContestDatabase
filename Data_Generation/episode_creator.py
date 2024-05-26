import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import random
from PIL import Image, ImageDraw, ImageFont
import os


def run_episode_creator(file_path="../SQL_Code/", file_name = "insert_data.sql"):

    def fetch_dataframes_from_mysql_sqlalchemy(user, password, host, port, database):
        engine = create_engine(f"mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}")

        queries = {
            'Recipe': "SELECT * FROM Recipe",
            'Cook': "SELECT * FROM Cook",
            'Nationality': "SELECT * FROM Nationality",
            'Recipe_Cook': "SELECT * FROM Recipe_Cook",
            'Nationality_Cook': "SELECT * FROM Nationality_Cook",
            'Cook_Episode_Contestant': "SELECT * FROM Cook_Episode_Contestants",
            'Cook_Episode_Judge': "SELECT * FROM Cook_Episode_Judge",
            'Episode_Nationality': "SELECT * FROM Nationality_Episode",
            'Episode': "SELECT * FROM Episode",
            'Image': "SELECT * FROM Image"
        }

        dataframes = {}

        for table, query in queries.items():
            dataframes[table] = pd.read_sql(query, engine)

        return dataframes

    data = fetch_dataframes_from_mysql_sqlalchemy(
        user='root',
        password='',
        host='localhost',
        port='3306',
        database='contest'
    )

    recipe_df = data['Recipe']
    cook_df = data['Cook']
    nationality_df = data['Nationality']
    recipe_cook_df = data['Recipe_Cook']
    nationality_cook_df = data['Nationality_Cook']
    cook_episode_contestant_df = data['Cook_Episode_Contestant']
    cook_episode_judge_df = data['Cook_Episode_Judge']
    episode_nationality_df = data['Episode_Nationality']
    episode_df = data['Episode']
    image_df = data['Image']
    
    unique_nationality_ids = recipe_df['nationality_id'].unique()
    nationality_with_recipe_df = nationality_df[nationality_df['nationality_id'].isin(unique_nationality_ids)]

    def get_episode_id(episode_df):
        if episode_df.empty:
            last_episode_id = 0
        else:
            last_episode_id = episode_df['episode_id'].max()
        next_episode_id = last_episode_id + 1
        return next_episode_id

    next_episode_id = get_episode_id(episode_df)


    def is_overrepresented(entity_id, recent_df, column, limit=3):
        recent_count = recent_df[column].value_counts().get(entity_id, 0)
        return recent_count >= limit

    def select_episode_data_with_restrictions(
            recipe_df, cook_df, nationality_df, recipe_cook_df, nationality_cook_df,
            cook_episode_contestant_df, cook_episode_judge_df, episode_nationality_df):

        last_episode_ids = cook_episode_contestant_df['episode_id'].unique()[-3:]

        recent_contestants_recipes = cook_episode_contestant_df[cook_episode_contestant_df['episode_id'].isin(last_episode_ids)]
        recent_judges = cook_episode_judge_df[cook_episode_judge_df['episode_id'].isin(last_episode_ids)]
        recent_nationalities = episode_nationality_df[episode_nationality_df['episode_id'].isin(last_episode_ids)]

        selected_nationality_ids = set()
        selected_cook_ids = set()
        selected_recipe_ids = set()
        selected_judge_ids = set()

        unique_nationality_ids = recipe_df['nationality_id'].unique()

        nationality_with_recipe_df = nationality_df[nationality_df['nationality_id'].isin(unique_nationality_ids)]

        selected_nationalities = []
        available_nationalities = list(set(nationality_with_recipe_df['nationality_id']) - selected_nationality_ids)
        while len(selected_nationalities) < 10 and available_nationalities:
            nationality_id = random.choice(available_nationalities)
            if not is_overrepresented(nationality_id, recent_nationalities, 'nationality_id'):
                selected_nationalities.append(nationality_id)
                selected_nationality_ids.add(nationality_id)
            available_nationalities.remove(nationality_id)

        contestants = []
        for nationality_id in selected_nationalities:
            available_cooks = list(set(nationality_cook_df[nationality_cook_df['nationality_id'] == nationality_id]['cook_id']) - selected_cook_ids)
            while available_cooks:
                cook_id = random.choice(available_cooks)
                if not is_overrepresented(cook_id, recent_contestants_recipes, 'cook_id'):
                    cook_info = cook_df[cook_df['cook_id'] == cook_id].iloc[0]
                    ranking = cook_info['ranking']
                    contestants.append({'cook_id': cook_id, 'nationality_id': nationality_id, 'ranking': ranking})
                    selected_cook_ids.add(cook_id)
                    break
                available_cooks.remove(cook_id)

        contestant_recipes = []
        for contestant in contestants:
            available_recipes = list(set(recipe_df.loc[recipe_df['nationality_id'] == contestant['nationality_id']]['recipe_id']) - selected_recipe_ids)
            if available_recipes:
                recipe_id = random.choice(available_recipes)
                if not is_overrepresented(recipe_id, recent_contestants_recipes, 'recipe_id'):
                    contestant_recipes.append({'recipe_id': recipe_id, 'cook_id': contestant['cook_id']})
                    selected_recipe_ids.add(recipe_id)

        judges = []
        available_judges = list(set(cook_df['cook_id']) - selected_cook_ids - selected_judge_ids)
        while len(judges) < 3 and available_judges:
            judge_id = random.choice(available_judges)
            if not is_overrepresented(judge_id, recent_judges, 'cook_id'):
                judges.append(judge_id)
                selected_judge_ids.add(judge_id)
            available_judges.remove(judge_id)

        return selected_nationalities, contestants, contestant_recipes, judges


    def attempt_to_select_episode_data(max_attempts=10):
        for attempt in range(max_attempts):
            selected_nationalities, contestants, contestant_recipes, judges = select_episode_data_with_restrictions(
                recipe_df, cook_df, nationality_df, recipe_cook_df, nationality_cook_df,
                cook_episode_contestant_df, cook_episode_judge_df, episode_nationality_df
            )

            if len(selected_nationalities) == 10 and len(contestants) == 10 and len(contestant_recipes) == 10 and len(judges) == 3:
                print("Successfully selected episode data.")
                return selected_nationalities, contestants, contestant_recipes, judges
            else:
                print(f"Attempt {attempt + 1}: Failed to meet criteria, retrying...")

        print("Error: Failed to select the required episode data after multiple attempts.")
        return None, None, None, None

    selected_nationalities, contestants, contestant_recipes, judges = attempt_to_select_episode_data()
    
    if selected_nationalities == None:
        print(f"Episode with episode_id = {next_episode_id} failed to be created")
        return 1


    def create_all_episode_queries(next_episode_id, contestant_recipes, judges, selected_nationalities):

        cook_episode_judge_sql = [
            f"""INSERT INTO Cook_Episode_Judge (episode_id, cook_id, judge_number) VALUES ({next_episode_id}, {judges[i]}, {i + 1});"""
            for i in range(len(judges))
        ]

        nationality_episode_sql = [
            f"""INSERT INTO Nationality_Episode (nationality_id, episode_id) VALUES ({nationality_id}, {next_episode_id});"""
            for nationality_id in selected_nationalities
        ]

        return cook_episode_judge_sql, nationality_episode_sql

    cook_episode_judge_sql, nationality_episode_sql = create_all_episode_queries(next_episode_id, contestant_recipes, judges, selected_nationalities)


    recipe_cook_sql = []

    def generate_recipe_cook_queries(contestant_recipes, recipe_cook_df):
        queries = []
        for record in contestant_recipes:
            recipe_id = record['recipe_id']
            cook_id = record['cook_id']

            exists = not recipe_cook_df[
                (recipe_cook_df['recipe_id'] == recipe_id) &
                (recipe_cook_df['cook_id'] == cook_id)
            ].empty

            if not exists:
                query = f"""INSERT INTO Recipe_Cook (recipe_id, cook_id) VALUES ({recipe_id}, {cook_id});\n"""
                queries.append(query)

        return queries

    recipe_cook_sql = generate_recipe_cook_queries(contestant_recipes, recipe_cook_df)


    def generate_episode_image(season, episode, width=600, height=400, bg_color=(144, 238, 144)):
        image = Image.new('RGB', (width, height), color=bg_color)
        draw = ImageDraw.Draw(image)

        try:
            font_season = ImageFont.truetype("arial.ttf", size=60)  
            font_episode = ImageFont.truetype("arial.ttf", size=40) 
        except IOError:
            font_season = ImageFont.load_default()
            font_episode = ImageFont.load_default()

        text_season = f"Season {season}"
        text_episode = f"Episode {episode}"

        bbox_season = draw.textbbox((0, 0), text_season, font=font_season)
        bbox_episode = draw.textbbox((0, 0), text_episode, font=font_episode)

        text_width_season = bbox_season[2] - bbox_season[0]
        text_height_season = bbox_season[3] - bbox_season[1]
        text_width_episode = bbox_episode[2] - bbox_episode[0]
        text_height_episode = bbox_episode[3] - bbox_episode[1]

        x_season = (width - text_width_season) // 2
        y_season = (height // 2) - text_height_season - 10  
        
        x_episode = (width - text_width_episode) // 2
        y_episode = (height // 2) + 10  

        draw.text((x_season, y_season), text_season, fill="black", font=font_season, align="center")
        draw.text((x_episode, y_episode), text_episode, fill="black", font=font_episode, align="center")

        images_folder = os.path.join(os.getcwd(), 'episode_data_generation/images')
        os.makedirs(images_folder, exist_ok=True)

        file_name = f"season_{season}_episode_{episode}.png"
        image_path = os.path.join(images_folder, file_name)
        image.save(image_path)

        return file_name

    def get_next_episode_and_season(episode_df):
        if episode_df.empty:
            next_season = 1
            next_episode = 1
        else:
            last_episode = episode_df.iloc[-1]
            last_season = last_episode['season']
            last_episode_number = last_episode['name']  

            if last_episode_number == 10:
                next_season = last_season + 1
                next_episode = 1
            else:
                next_season = last_season
                next_episode = last_episode_number + 1

        return next_season, next_episode


    def create_image_sql_query(image_url, description):
        return f"""INSERT INTO Image (image_url, description) VALUES ('{image_url}', '{description}');\n"""

    def get_next_image_id(image_df):
        return image_df['image_id'].max() + 1 if not image_df.empty else 1

    last_image_id = get_next_image_id(image_df)
    image_id = last_image_id

    next_season, next_episode = get_next_episode_and_season(episode_df)
    image_name = generate_episode_image(next_season, next_episode)

    image_url = f"/data_generation/episode_data_generation/images/{image_name}"
    image_description = f"This is an image for Episode {next_episode} Season {next_season}"
    image_sql = create_image_sql_query(image_url, image_description)



    def get_ranking_from_cook_id(cook_id, all_contestants):
        contestant = next((c for c in all_contestants if c["cook_id"] == cook_id), None)

        return contestant["ranking"] if contestant else None

    def assign_ratings_and_find_winner(contestants, judges):
        ratings = {}
        ranking_order = ["chef", "sous chef", "cook A", "cook B", "cook C"]

        for contestant in contestants:
            cook_id = contestant['cook_id']
            ratings[cook_id] = [random.randint(1, 5) for _ in range(len(judges))]

        contestant_scores = {cook_id: sum(scores) for cook_id, scores in ratings.items()}

        max_score = max(contestant_scores.values())
        potential_winners = [cook_id for cook_id, score in contestant_scores.items() if score == max_score]

        if len(potential_winners) == 1:
            winner_id = potential_winners[0]
        else:
            highest_ranking = None
            winner_id = None
            for cook_id in potential_winners:
                ranking = get_ranking_from_cook_id(cook_id, contestants)
                ranking_index = ranking_order.index(ranking)
                if highest_ranking is None or ranking_index < highest_ranking:
                    highest_ranking = ranking_index
                    winner_id = cook_id
                elif ranking_index == highest_ranking:
                    winner_id = random.choice([winner_id, cook_id])

        results = {
            "ratings": ratings,
            "winner_id": winner_id,
            "scores": contestant_scores
        }
        return results



    def create_episode_queries(contestants, judges, season, episode_name, image_id):
        episode_results = assign_ratings_and_find_winner(contestants, judges)
        winner_id = episode_results["winner_id"]

        episode_sql = f"""INSERT INTO Episode (episode_id, season, name, image_id, winner) 
                        VALUES ({next_episode_id}, {season}, {episode_name}, {image_id}, {winner_id});"""

        cook_contestants_sql = []
        for contestant in contestant_recipes:
            cook_id = contestant['cook_id']
            recipe_id = contestant['recipe_id']
            scores = episode_results["ratings"].get(cook_id, [0, 0, 0]) 
            query = f"""INSERT INTO Cook_Episode_Contestants (episode_id, cook_id, recipe_id, rating_1, rating_2, rating_3) 
                        VALUES ({next_episode_id}, {cook_id}, {recipe_id}, {scores[0]}, {scores[1]}, {scores[2]});"""
            cook_contestants_sql.append(query)

        return episode_sql, cook_contestants_sql, episode_results

    episode_sql, cook_episode_contestants_sql, episode_results = create_episode_queries(contestants, judges, next_season, next_episode, image_id)



    def insert_all_queries(user, password, host, port, database,
                        image_sql, episode_sql, cook_episode_contestants_sql,
                        nationality_episode_sql,
                        cook_episode_judge_sql, recipe_cook_sql):

        engine = create_engine(f"mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}")

        Session = sessionmaker(bind=engine)
        session = Session()

        with open(file_path + 'insert_data.sql', 'a') as sql_file:
            with engine.connect() as connection:
                try:

                    print("Executing and logging SQL Insertion Queries...")
                    
                    session.execute(text(image_sql))
                    session.commit()
                    sql_file.write(image_sql + "\n\n")

                    session.execute(text(episode_sql))
                    session.commit()
                    sql_file.write(episode_sql + "\n\n")

                    for query in cook_episode_contestants_sql:
                        session.execute(text(query))
                        session.commit()
                        sql_file.write(query + "\n")

                    for query in nationality_episode_sql:
                        session.execute(text(query))
                        session.commit()
                        sql_file.write(query + "\n")

                    for query in cook_episode_judge_sql:
                        session.execute(text(query))
                        session.commit()
                        sql_file.write(query + "\n")

                    for query in recipe_cook_sql:
                        session.execute(text(query))
                        session.commit()
                        sql_file.write(query + "\n")

                    session.commit()
                    print("All queries successfully executed and committed.")
                    print(f"Episode with episode_id = {next_episode_id} successfully generated.")

                except Exception as e:
                    print("Error encountered, rolling back transactions:", e)
                    session.rollback()
                finally:
                    session.close()
                    print("Database connection closed.\n")


    insert_all_queries(
        user='root',
        password='',
        host='localhost',
        port='3306', 
        database='contest',
        image_sql=image_sql,
        episode_sql=episode_sql,
        cook_episode_contestants_sql=cook_episode_contestants_sql,
        nationality_episode_sql=nationality_episode_sql,
        cook_episode_judge_sql=cook_episode_judge_sql,
        recipe_cook_sql=recipe_cook_sql
    )

    return 0


def main():
    file_path = "../SQL_Code/"
    file_name = 'insert_data.sql'

    with open(file_name, 'a') as file:
        file.write('-- SQL commands generated by episode_creator\n')

    run_episode_creator(file_path, file_name)

if __name__ == '__main__':
    main()
