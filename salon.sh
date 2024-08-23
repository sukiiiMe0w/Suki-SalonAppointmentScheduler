#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?"

MAIN_MENU() {
  echo -e "$1"
  
  # Fetch available services
  SERVICE=$($PSQL "SELECT service_id, name FROM services")
  
  # Display services
  echo "$SERVICE" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Get user input
  read SERVICE_ID_SELECTED

  # Check if input is a valid number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    # If service is not found
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then 
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # Service is found
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      
      # Trim phone input
      TRIMMED_PHONE_INPUT=$(echo "$CUSTOMER_PHONE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      
      # Check if customer exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$TRIMMED_PHONE_INPUT'")
      
      # If customer is not found
      if [[ -z $CUSTOMER_NAME ]]
      then 
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        
        # Trim customer name input
        TRIMMED_NAME_INPUT=$(echo "$CUSTOMER_NAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$TRIMMED_NAME_INPUT', '$TRIMMED_PHONE_INPUT')")
      fi
      # Customer record exist
      echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
      read SERVICE_TIME
      GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$TRIMMED_PHONE_INPUT'")
      INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments (time,customer_id,service_id) VALUES ('$SERVICE_TIME','$GET_CUSTOMER_ID','$SERVICE_ID_SELECTED')" )
      echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

# Call the MAIN_MENU function
MAIN_MENU
