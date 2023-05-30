#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Empty rows in database
echo $($PSQL "TRUNCATE TABLE games, teams")

# Read and store information from games.csv
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != 'winner' ]]
  then
    # get winner team_id
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # echo "Winner team_id = $WINNER_TEAM_ID"
    # if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert team
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT = 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
      # get new team_id
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      # echo "Winner team_id = $WINNER_TEAM_ID"
    fi
  fi
  if [[ $OPPONENT != 'opponent' ]]
  then
    # get opponent team_id
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # echo "Opponent team_id = $OPPONENT_TEAM_ID"
    # if not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      # insert team
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT = 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
      # get new team_id
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      # echo "Winner team_id = $OPPONENT_TEAM_ID"
    fi
  fi
  # insert into games
  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAMES_RESULT == 'INSERT 01' ]]
  then
    echo "Inserted into games, $YEAR : $ROUND : $WINNER : $OPPONENT : $WINNER_GOALS : $OPPONENT_GOALS"
  fi
done