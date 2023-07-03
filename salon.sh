#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -tc"

MAIN_MENU(){
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
echo -e "~~~MY SALON~~~\n\nServices offered:\n"
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
echo "Please choose a service: "
}


MAIN_MENU
read SERVICE_ID_SELECTED

while [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
do
  echo "not a number"
  MAIN_MENU
  read SERVICE_ID_SELECTED
done
while [ $($PSQL "SELECT COUNT(service_id) FROM services WHERE service_id="$SERVICE_ID_SELECTED"") -lt 1 ]
do
  echo "not a valid number. choose from the list!"
  MAIN_MENU
  read SERVICE_ID_SELECTED
done

echo "Enter phone number: "
read CUSTOMER_PHONE
if [ $($PSQL "SELECT COUNT(customer_id) FROM customers WHERE phone='$CUSTOMER_PHONE'") -lt 1 ]
then
  echo "Enter name: "
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi
echo "Enter time: "
read SERVICE_TIME
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if ! [[ -v CUSTOMER_NAME ]]
then
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
fi
echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
