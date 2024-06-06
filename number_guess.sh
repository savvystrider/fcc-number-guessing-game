#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GENERATE_RANDOM_NUMBER() {
  echo $(( (RANDOM % 1000) + 1 ))
}

IS_INTEGER() {
  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}

START_GAME() {
  RANDOM_NUMBER=$(GENERATE_RANDOM_NUMBER)
  
  GUESS_TOTAL=0
  GAMES_PLAYED=0
  echo -e "\nGuess the secret number between 1 and 1000:"
  
  while true; do
    read USER_GUESS
    if IS_INTEGER "$USER_GUESS"; then
      if (( USER_GUESS < RANDOM_NUMBER )); then
        ((GUESS_TOTAL++))
        echo "It's higher than that, guess again:"
      elif (( USER_GUESS > RANDOM_NUMBER )); then
        ((GUESS_TOTAL++))
        echo "It's lower than that, guess again:"
      else
        ((GUESS_TOTAL++))
        ((GAMES_PLAYED++))
        UPDATE_GAMES_PLAYED=$($PSQL "UPDATE usernames SET guess_total = $GUESS_TOTAL, games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
        echo "You guessed it in $GUESS_TOTAL tries. The secret number was $RANDOM_NUMBER. Nice job!"
        break
        exit 1
      fi
    else
      echo "That is not an integer, guess again:"
    fi
  done
}

echo "Enter your username: "
read USERNAME

# look up username
USER_SEARCH=$($PSQL "SELECT username FROM usernames WHERE username = '$USERNAME'")

if [[ -z $USER_SEARCH ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
  # add user to database
  START_GAME
else
  # update variables
  USER_GAMES_PLAYED=$($PSQL "SELECT games_played FROM usernames WHERE username = '$USERNAME'")
  USER_BEST_GAME=$($PSQL "SELECT MIN(guess_total) FROM usernames WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $USER_GAMES_PLAYED games, and your best game took $USER_BEST_GAME guesses."
  START_GAME $USERNAME
fi
