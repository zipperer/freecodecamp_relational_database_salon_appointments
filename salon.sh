#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --record-separator='\n' --tuples-only -c"

WELCOME () {
  echo -e "\n~~~~~ MY SALON ~~~~~"
  echo -e "\nWelcome to My Salon, how can I help you?"
  PRESENT_AVAILABLE_SERVICES_AND_PROMPT_FOR_SERVICE_AND_PROCEED
}

PRESENT_AVAILABLE_SERVICES_AND_PROMPT_FOR_SERVICE_AND_PROCEED () {
  MESSAGE_TO_USER=$1
  if [[ $1 ]]
  then
    echo "\n$MESSAGE_TO_USER"
  fi
  PRESENT_AVAILABLE_SERVICES
  PROMPT_FOR_SERVICE_AND_PROCEED
}

PRESENT_AVAILABLE_SERVICES () {
  #echo -e "\nWe offer these services:"
  echo
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
}

PROMPT_FOR_SERVICE_AND_PROCEED () {
  #echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED

  LOOK_FOR_SERVICE_BY_ID_AND_PROCEED $SERVICE_ID_SELECTED

}

LOOK_FOR_SERVICE_BY_ID_AND_PROCEED () {
  USER_INPUT_FOR_CHOICE_OF_SERVICE_BY_ID=$1
  if [[ ! $USER_INPUT_FOR_CHOICE_OF_SERVICE_BY_ID =~ ^[0-9]+$ ]]
  then
    #PRESENT_AVAILABLE_SERVICES_AND_PROMPT_FOR_SERVICE_AND_PROCEED 'Please provide a number that corresponds to an available service.'
    PRESENT_AVAILABLE_SERVICES_AND_PROMPT_FOR_SERVICE_AND_PROCEED "I could not find that service. What would you like today?"
  else
    SERVICE_NAME_OR_EMPTY_RESPONSE=$($PSQL "SELECT name FROM services WHERE service_id = $USER_INPUT_FOR_CHOICE_OF_SERVICE_BY_ID")
    if [[ -z $SERVICE_NAME_OR_EMPTY_RESPONSE ]]
    then
      PRESENT_AVAILABLE_SERVICES_AND_PROMPT_FOR_SERVICE_AND_PROCEED 'Please provide a number that corresponds to an available service.'
    else
      echo -e "\nThank you for your interest in $SERVICE_NAME_OR_EMPTY_RESPONSE"
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      # todo: validate phone number
      # lookup customer name by phone number
      CUSTOMER_NAME_IN_DATABASE=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer does not yet exist, prompt for name and insert into table
      if [[ -z $CUSTOMER_NAME_IN_DATABASE ]]
      then
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        INSERT_INTO_CUSTOMERS_TABLE_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        # todo: confirm INSERT worked
      else
        echo -e "\nWelcome back, $CUSTOMER_NAME_IN_DATABASE"
        CUSTOMER_NAME=$CUSTOMER_NAME_IN_DATABASE
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # prompt for a time
      echo -e "\nWhen would you like to receive this service?"
      read SERVICE_TIME
      # todo: validate time
      INSERT_INTO_APPOINTMENTS_TABLE_RESULT=$($PSQL "INSERT INTO appointments (service_id, customer_id, time) VALUES ('$USER_INPUT_FOR_CHOICE_OF_SERVICE_BY_ID', '$CUSTOMER_ID', '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME_OR_EMPTY_RESPONSE at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
  
}

#PRESENT_AVAILABLE_SERVICES
WELCOME
