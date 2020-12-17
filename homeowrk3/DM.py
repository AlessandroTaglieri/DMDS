#!/usr/bin/env python
# coding: utf-8

# # HOMEWORK 3 - DATA MANAGEMENT OF DATA SCIENCE
# 
# * ALESSANDRO TAGLIERI
# * GUGLIELMO LATO

# ## IMPORT LIBRARIES

# In[1]:


import csv
from pymongo import MongoClient
from pprint import pprint
import time


# ## CREATE BSON FROM CSV DATA

# In[2]:




#Create bson


# PLAYER

player_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/players.csv","r") as f:
    player = csv.reader(f,delimiter=";")
    for row in player:
        player_list.append(row)
 
       
player_bson_dict = {}
player_bson = []

for i in range(1,len(player_list)):
    player_dict = {}
    for j in range(len(player_list[0])):
        if j == 0:
            player_dict["_id"] = player_list[i][j]
        else:
            player_dict[player_list[0][j]] = player_list[i][j]
    player_bson.append(player_dict)
    player_bson_dict[player_dict["_id"]] = player_dict




# TEAM

team_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/teams.csv","r") as f:
    team = csv.reader(f,delimiter=";")
    for row in team:
        team_list.append(row)
 
       
team_bson_dict = {}
team_bson = []

for i in range(1,len(team_list)):
    team_dict = {}
    for j in range(len(team_list[0])):
        if j == 2:
            team_dict["_id"] = team_list[i][j]
        else:
            team_dict[team_list[0][j]] = team_list[i][j]
    team_bson.append(team_dict)
    team_bson_dict[team_dict["_id"]] = team_dict






# PLAYER TEAM

player_team_list = []
with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/players_teams.csv","r") as f:
    players_teams = csv.reader(f,delimiter=";")
    for row in players_teams:
        player_team_list.append(row)



player_teams_bson = []

for i in range(1,len(player_team_list)):
    player_teams_dict = {}
    for j in range(len(player_team_list[0])):
        if j == 0:
            player_teams_dict["_id"] = player_team_list[i][j]
        elif player_team_list[0][j] == "playerID":
            player_teams_dict["playerID"] = player_bson_dict[player_team_list[i][j]]
        elif player_team_list[0][j] == "tmID":
            player_teams_dict["tmID"] = team_bson_dict[player_team_list[i][j]]
        else:
            player_teams_dict[player_team_list[0][j]] = player_team_list[i][j]
    player_teams_dict["points"]=int(player_teams_dict["points"])
    player_teams_dict["GP"]=int(player_teams_dict["GP"])
    player_teams_dict["minutes"]=int(player_teams_dict["minutes"])
    player_teams_dict["fgMade"]=int(player_teams_dict["fgMade"])
    player_teams_dict["ftMade"]=int(player_teams_dict["ftMade"])
    player_teams_dict["threeMade"]=int(player_teams_dict["threeMade"])
    player_teams_dict["rebounds"]=int(player_teams_dict["rebounds"])
    player_teams_dict["assists"]=int(player_teams_dict["assists"])
    player_teams_dict["blocks"]=int(player_teams_dict["blocks"])
    player_teams_dict["steals"]=int(player_teams_dict["steals"])
    player_teams_dict["turnovers"]=int(player_teams_dict["turnovers"])
    player_teams_dict["year"]=int(player_teams_dict["year_pt"])
    player_teams_bson.append(player_teams_dict)






# DRAFT

draft_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/draft.csv","r") as f:
    draft = csv.reader(f,delimiter=";")
    for row in draft:
        draft_list.append(row)
 
       
draft_bson_dict = {}
draft_bson = []

for i in range(1,len(draft_list)):
    draft_dict = {}
    for j in range(len(draft_list[0])):
        if j == 0:
            draft_dict["_id"] = draft_list[i][j]
        elif draft_list[0][j] == "tmID":
            draft_dict["tmID"] = team_bson_dict[draft_list[i][j]]
        else:
            draft_dict[draft_list[0][j]] = draft_list[i][j]
    draft_dict["draftYear"] = int(draft_dict["draftYear"])
    draft_bson.append(draft_dict)
    draft_bson_dict[draft_dict["_id"]] = draft_dict




# SERIES POST
series_post_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/series_post.csv","r") as f:
    series_post = csv.reader(f,delimiter=";")
    for row in series_post:
        series_post_list.append(row)
 
       
series_post_bson_dict = {}
series_post_bson = []

for i in range(1,len(series_post_list)):
    series_post_dict = {}
    for j in range(len(series_post_list[0])):
        if j == 0:
            series_post_dict["_id"] = series_post_list[i][j]
        elif series_post_list[0][j] == "tmIDWinner":
            series_post_dict["tmIDWinner"] = team_bson_dict[series_post_list[i][j]]
        elif series_post_list[0][j] == "tmIDLoser":
            try:
                series_post_dict["tmIDLoser"] = team_bson_dict[series_post_list[i][j]]
            except:
                pass
        else:
            series_post_dict[series_post_list[0][j]] = series_post_list[i][j]
    series_post_bson.append(series_post_dict)
    series_post_bson_dict[series_post_dict["_id"]] = series_post_dict




# COACHES

coaches_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/coaches.csv","r") as f:
    coaches = csv.reader(f,delimiter=";")
    for row in coaches:
        coaches_list.append(row)
 
       
coaches_bson_dict = {}
coaches_bson = []

for i in range(1,len(coaches_list)):
    coaches_dict = {}
    coaches_dict["_id"] = (coaches_list[i][0],coaches_list[i][1])
    for j in range(len(coaches_list[0])):
        if coaches_list[0][j] == "tmID":
            coaches_dict["tmID"] = team_bson_dict[coaches_list[i][j]]
        else:
            coaches_dict[coaches_list[0][j]] = coaches_list[i][j]
    coaches_bson.append(coaches_dict)
    coaches_bson_dict[coaches_dict["_id"]] = coaches_dict
    
    

# COACHES AWARDS

coaches_awards_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/awards_coaches.csv","r") as f:
    coaches_awards = csv.reader(f,delimiter=";")
    for row in coaches_awards:
        coaches_awards_list.append(row)
 
       
coaches_awards_bson_dict = {}
coaches_awards_bson = []

for i in range(1,len(coaches_awards_list)):
    coaches_awards_dict = {}
    for j in range(len(coaches_awards_list[0])):
        if j == 0:
            coaches_awards_dict["_id"] = coaches_awards_list[i][j]
        elif coaches_awards_list[0][j] == "coachID":
            coaches_awards_dict["coachID"] = coaches_bson_dict[(coaches_awards_list[i][j],coaches_awards_list[i][1])]
        else:
            coaches_awards_dict[coaches_awards_list[0][j]] = coaches_awards_list[i][j]
    coaches_awards_bson.append(coaches_awards_dict)
    coaches_awards_bson_dict[coaches_awards_dict["_id"]] = coaches_awards_dict
    
    
    
    
    
    
    
    
# AWARD PLAYERS

awards_players_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/awards_players.csv","r") as f:
    awards_players = csv.reader(f,delimiter=";")
    for row in awards_players:
        awards_players_list.append(row)
 
       
awards_players_bson_dict = {}
awards_players_bson = []

for i in range(1,len(awards_players_list)):
    awards_players_dict = {}
    awards_players_dict["_id"] = i
    for j in range(len(awards_players_list[0])):

        if awards_players_list[0][j] == "playerID":
            awards_players_dict["playerID"] = player_bson_dict[awards_players_list[i][j]]
        else:
            awards_players_dict[awards_players_list[0][j]] = awards_players_list[i][j]
    awards_players_bson.append(awards_players_dict)
    awards_players_bson_dict[awards_players_dict["_id"]] = awards_players_dict
    
    
    
   


    
# PLAYER ALL STAR

player_all_star_list = []

with open("/Users/digitalfirst/Desktop/dmds-3hw/csv_DMDS/dataset/player_allstar.csv","r") as f:
    player_all_star = csv.reader(f,delimiter=";")
    for row in player_all_star:
        player_all_star_list.append(row)
 
       
player_all_star_bson_dict = {}
player_all_star_bson = []

for i in range(1,len(player_all_star_list)):
    player_all_star_dict = {}
    player_all_star_dict["_id"] = i
    for j in range(len(player_all_star_list[0])):

        if player_all_star_list[0][j] == "playerID":
            player_all_star_dict["playerID"] = player_bson_dict[player_all_star_list[i][j]]
        else:
            player_all_star_dict[player_all_star_list[0][j]] = player_all_star_list[i][j]
    player_all_star_dict["season_id"] = int(player_all_star_dict["season_id"])
    player_all_star_dict["points"] = int(player_all_star_dict["points"])
    player_all_star_bson.append(player_all_star_dict)
    player_all_star_bson_dict[player_all_star_dict["_id"]] = player_all_star_dict
    
    
    
    





# ## SET CONNECTION TO MONGODB WITH PYMONGO LIBRARY.
# ## CREATE DB "BasketBall_Men"

# In[3]:



# Connect to Mongo
client = MongoClient('localhost', 27017)


# Create database 
db = client["Basketball_men"]


# ## CREATE COLLECTIONS

# In[ ]:



collection_players_teams= db["players_teams"]
collection_draft= db["draft"]
collection_series_post= db["series_post"]
collection_awards_coaches= db["awards_coaches"]
collection_awards_players= db["awards_players"]
collection_player_all_star= db["player_all_star"]


# ## INSERT BSON IN BASKETBALL_MEN DB

# In[ ]:


# Insert data into collections
db.collection_players_teams.insert_many(player_teams_bson)
db.collection_draft.insert_many(draft_bson)
db.collection_series_post.insert_many(series_post_bson)
db.collection_awards_coaches.insert_many(coaches_awards_bson)
db.collection_awards_players.insert_many(awards_players_bson)
db.collection_player_all_star.insert_many(player_all_star_bson)

# ## we have 6 collections:
# - collection_players_teams: it contains data about players, teams and players_teams table
# - collection_draft : It contains all data about draft and team
# - collection_series_post: It contains data about series_post and all data abvoiut team winner and team that lost
# - collection_awards_coaches: it contains data about awards_coach and coach
# - collection_awards_players: It contains all data about awards_player  and player
# - collection_player_all_star:  It contains all data about players_all and and player

# # EXECUTION OF 10 QUERIES

# ## query 1: 
# #### highSchool name and count of players gives by each highSchool

# In[4]:


start_time = time.time()


cursor = db.collection_players_teams.aggregate([
        {"$group":{"_id":"$playerID.highSchool","count":{"$sum":1}}},
        {"$project":{"_id":1,"count":1}},
        {"$sort":{"count":-1}},
        ])
print("--- %s seconds ---" % (time.time() - start_time))

for i in cursor:
    pprint(i)


# ## query 2: 
# #### name,lastname and total points scored by the best 10 players (who scored most)

# In[5]:


start_time = time.time()

cursor = db.collection_players_teams.aggregate([
        {"$group":{"_id":{"firstName":"$playerID.firstName","lastname":"$playerID.lastName"},"points":{"$sum":"$points"}}},
        {"$project":{"_id":1,"points":1}},
        {"$sort":{"points":-1}},
        {"$limit": 10}
        ])
print("--- %s seconds ---" % (time.time() - start_time))   
for i in cursor:
    pprint(i)


# ## query3 : 
# 
# #### the player who won the most awards for each category

# In[6]:


start_time = time.time()

temp = db.collection_awards_players.aggregate([
        
        {"$group":{"_id":{"iden": "$playerID._id","name": "$playerID.firstName","lastName": "$playerID.lastName","awards":"$year_awards_palyer"},"count":{"$sum":1}}},
        { "$sort": { "_id": 1, "name": -1 } },
        {"$group":{"_id":"$_id.awards",  "id" : { "$first": '$_id.iden'  },"name" : { "$first": '$_id.name'  },"lastName" : { "$first": '$_id.lastName'  }, "max": {"$max": "$count"}}},
        {"$project":{"_id":1, "count_awards":1, "id":1,"name":1,"lastName":1}},
        ])
print("--- %s seconds ---" % (time.time() - start_time))
for i in temp:
    pprint(i)


# ## query 4: 
# #### firstname,lastName,height,weight,birthcountry of players born not in USA that played ONLY in 1 team in career(in the USA leagues)

# In[7]:


start_time = time.time()

temp = db.collection_players_teams.aggregate([
        {"$match":{"playerID.birthCountry":{"$ne": "USA"}}},
        {"$group":{"_id":{"id": "$playerID._id","firstName":"$playerID.firstName","lastname":"$playerID.lastName", "height":"$playerID.height", "weight":"$playerID.weight", "birth_country":"$playerID.birthCountry"},"count":{"$sum":1},"totalCustomer": { "$addToSet": "$tmID._id" }}},
        {"$match":{"count":{"$eq": 1}}},
        {"$project":{"_id":1}},
        
        ])
print("--- %s seconds ---" % (time.time() - start_time))
for i in temp:
    pprint(i)


# ## query 5: 
# #### the best 10 players who scored the most but never played in all star match

# In[8]:


start_time = time.time()

temp = db.collection_player_all_star.aggregate([
        {"$group":{"_id":"$playerID._id"}},
        {"$project":{"_id":1}},
        ])


listName = []
for i in temp:
    listName.append(i["_id"])
    
cursor = db.collection_players_teams.aggregate([
        {"$match":{"playerID._id":{"$nin": listName}}},
        {"$group":{"_id":{"id": "$playerID._id","firstName":"$playerID.firstName","lastname":"$playerID.lastName"},"points":{"$sum":"$points"}}},
        {"$project":{"_id":1,"points":1}},
        {"$sort":{"points":-1}},
        {"$limit": 10}
        ])
print("--- %s seconds ---" % (time.time() - start_time))
for i in cursor:
    pprint(i)


# ## query 6 : 
# #### The number of choaches awards for the top ten team in descresent order

# In[9]:


start_time = time.time()

cursor = db.collection_awards_coaches.aggregate([
        {"$group":{"_id":"$coachID.tmID.name_team","count":{"$sum":1}}},
        {"$project":{"_id":1,"count":1}},
        {"$sort":{"count":-1}},
        {"$limit": 10}
        ])
print("--- %s seconds ---" % (time.time() - start_time))
for i in cursor:
    pprint(i)


# ## query 7 : 
# #### Top player for different ranking (games played, minutes played, best scorer, best assistman, best carcher, best stealer, best blocker, best free throws, best sniper from 2, best sniper from 3)

# In[10]:


start_time = time.time()

list_type=["$GP","$minutes","$points","$assists","$rebounds","$steals","$blocks","$ftMade","$fgMade","$threeMade"]
for type_current in list_type:
    print(type_current)
    temp = db.collection_players_teams.aggregate([
        
        {"$group":{"_id":{"id": "$playerID._id","firstName":"$playerID.firstName","lastname":"$playerID.lastName"},"points":{"$sum":type_current}}},
        {"$project":{"_id":1,"points":1}},
        {"$sort":{"points":-1}},
        {"$limit":1}
    ])

    for i in temp:
        pprint(i)
print("--- %s seconds ---" % (time.time() - start_time))


# ## query 8: 
# #### For every decade (80s, 90s,00s), we show top 3 players about their avg points

# In[11]:


start_time = time.time()

year90=[1990,1991,1992,1993,1994,1995,1996,1997,1998,1999]
year00=[2000,2001,2002,2003,2004,2005,2006,2007,2008,2009]
year80=[1980,1981,1982,1983,1984,1985,1986,1987,1988,1989]
for year in [year80,year90,year00]:
    if year == year80:
        print("Decade 80s")
    elif year == year90:
        print("Decade 90s")
    else:
        print("Decade 00s")
        
    
    cursor = db.collection_players_teams.aggregate([
            {"$match":{"year":{"$in": year}}},
            {"$group":{"_id":{"surname":"$playerID.lastName","name":"$playerID.firstName"},"pts":{"$avg":"$points"}}},
            {"$project":{"_id":1,"pts":1,"year":1}},
            {"$sort":{"pts":-1}},
            {"$limit": 3}
            ])
    for i in cursor:
        pprint(i)
print("--- %s seconds ---" % (time.time() - start_time))


# ## query 9: 
# #### Michael Jordan's team mate

# In[12]:


start_time = time.time()

temp = db.collection_players_teams.find(
        {"playerID.firstName":"Michael","playerID.lastName":"Jordan"},
        projection={"tmID.name_team":1,"year":1,"_id":0})

team_aux = []
year_aux = []
for i in temp:
    team_aux.append(i["tmID"]["name_team"])
    year_aux.append(i["year"])
    

    
cursor = db.collection_players_teams.aggregate([
        {"$match":{"tmID.name_team":{"$in":team_aux},"year":{"$in":year_aux},"playerID.lastName":{"$ne":"Jordan"}}},
        {"$group":{"_id":{"lastName":"$playerID.lastName","firstName":"$playerID.firstName"}}},
        {"$project":{"_id":1}}
        ])
print("--- %s seconds ---" % (time.time() - start_time))
for i in cursor:
    pprint(i)


# ## query 10: 
# #### Top 10 players that won more MVP awards. For every player we show numebr of total MVP awards taht he won. We show also with which team he won them and number of MVP for every team.

# In[13]:


start_time = time.time()

temp = db.collection_awards_players.aggregate([
        {"$match":{"year_awards_palyer":{"$eq": "Most Valuable Player"}}},
        {"$group":{"_id": "$playerID._id","year":{"$addToSet":"$year"},"count":{"$sum":1}}},
        { "$sort": {"count": -1 } },
        {"$limit": 10}
        ])
lista = {}
for i in temp:
    lista[i['_id']] = i['year']
for i in lista.keys():
    
    for j in range(len(lista[i])):
        lista[i][j] = int(lista[i][j])
    cursor = db.collection_players_teams.aggregate([
        {"$match":{"playerID._id":i,"year":{"$in":lista[i]}}},
      
        {"$project":{"playerID._id":1,"playerID.firstName":1,"playerID.lastName":1,"tmID.name_team":1, "year":1}},
        {"$group":{"name" : { "$first": '$playerID.firstName'  },"lastName" : { "$first": '$playerID.lastName'  },"_id": "$tmID.name_team", "count_MVP":{"$sum":1}}},
        
    ])
 
    for i in cursor:
        pprint(i)
print("--- %s seconds ---" % (time.time() - start_time))        


# In[ ]:




