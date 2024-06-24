#!/bin/bash

# Enable strict bash mode to stop the script if an uninitialized variable is used, if a command fails, or if a command with a pipe fails
# Not working in some setups : https://github.com/tigerblue77/Dell_iDRAC_fan_controller/issues/48
# set -euo pipefail

source functions.sh

# Trap the signals for container exit and run gracefull_exit function
trap 'gracefull_exit' SIGQUIT SIGKILL SIGTERM

# Check if the iDRAC host is set to 'local' or not then set the IDRAC_LOGIN_STRING accordingly
if [[ $IDRAC_HOST == "local" ]]
then
  # Check that the Docker host IPMI device (the iDRAC) has been exposed to the Docker container
  if [ ! -e "/dev/ipmi0" ] && [ ! -e "/dev/ipmi/0" ] && [ ! -e "/dev/ipmidev/0" ]; then
    echo "/!\ Could not open device at /dev/ipmi0 or /dev/ipmi/0 or /dev/ipmidev/0, check that you added the device to your Docker container or stop using local mode. Exiting." >&2
    exit 1
  fi
  IDRAC_LOGIN_STRING='open'
else
  echo "iDRAC/IPMI username: $IDRAC_USERNAME"
  echo "iDRAC/IPMI password: $IDRAC_PASSWORD"
  IDRAC_LOGIN_STRING="lanplus -H $IDRAC_HOST -U $IDRAC_USERNAME -P $IDRAC_PASSWORD"
fi

get_Dell_server_model

if [[ ! $SERVER_MANUFACTURER == "DELL" ]]
then
  echo "/!\ Your server isn't a Dell product. Exiting." >&2
  exit 1
fi

# Log main informations
echo "Server model: $SERVER_MANUFACTURER $SERVER_MODEL"
echo "iDRAC/IPMI host: $IDRAC_HOST"

# Log the fan speed objective, CPU temperature threshold and check interval
echo "Check interval: ${CHECK_INTERVAL}s"
echo ""

# Define the interval for printing
readonly TABLE_HEADER_PRINT_INTERVAL=10
i=$TABLE_HEADER_PRINT_INTERVAL
# Set the flag used to check if the active fan control profile has changed
IS_DELL_FAN_CONTROL_PROFILE_APPLIED=true

# Check present sensors
IS_EXHAUST_TEMPERATURE_SENSOR_PRESENT=true
IS_CPU2_TEMPERATURE_SENSOR_PRESENT=true
retrieve_temperatures $IS_EXHAUST_TEMPERATURE_SENSOR_PRESENT $IS_CPU2_TEMPERATURE_SENSOR_PRESENT
if [ -z "$EXHAUST_TEMPERATURE" ]
then
  echo "No exhaust temperature sensor detected."
  IS_EXHAUST_TEMPERATURE_SENSOR_PRESENT=false
fi
if [ -z "$CPU2_TEMPERATURE" ]
then
  echo "No CPU2 temperature sensor detected."
  IS_CPU2_TEMPERATURE_SENSOR_PRESENT=false
fi
# Output new line to beautify output if one of the previous conditions have echoed
if ! $IS_EXHAUST_TEMPERATURE_SENSOR_PRESENT || ! $IS_CPU2_TEMPERATURE_SENSOR_PRESENT
then
  echo ""
fi

# Start monitoring
while true; do
  # Sleep for the specified interval before taking another reading
  sleep $CHECK_INTERVAL &
  SLEEP_PROCESS_PID=$!

  retrieve_temperatures $IS_EXHAUST_TEMPERATURE_SENSOR_PRESENT $IS_CPU2_TEMPERATURE_SENSOR_PRESENT

  # Define functions to check if CPU 1 and CPU 2 temperatures are above the threshold
  function CPU1_OVERHEAT () { [ $CPU1_TEMPERATURE -gt $CPU_TEMPERATURE_THRESHOLD ]; }
  if $IS_CPU2_TEMPERATURE_SENSOR_PRESENT
  then
    function CPU2_OVERHEAT () { [ $CPU2_TEMPERATURE -gt $CPU_TEMPERATURE_THRESHOLD ]; }
  fi

  function EXHAUST_OVERHEAT_1 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_1_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_2 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_2_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_3 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_3_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_4 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_4_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_5 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_5_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_6 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_6_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_7 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_7_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_8 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_8_TEMPERATURE ]; }
  function EXHAUST_OVERHEAT_9 () { [ $EXHAUST_TEMPERATURE -ge $EXHAUST_OVERHEAT_9_TEMPERATURE ]; }

  # Initialize a variable to store the comments displayed when the fan control profile changed
  COMMENT=" -"
  if EXHAUST_OVERHEAT_9
  then
    apply_Dell_fan_control_profile
    COMMENT="Exhaust temperature is too high ($EXHAUST_TEMPERATURE), Dell default dynamic fan control profile applied for safety"
  elif EXHAUST_OVERHEAT_8
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_8_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_8_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_8_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  elif EXHAUST_OVERHEAT_7
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_7_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_7_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_7_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  elif EXHAUST_OVERHEAT_6
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_6_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_6_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_6_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  elif EXHAUST_OVERHEAT_5
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_5_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_5_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_5_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  elif EXHAUST_OVERHEAT_4
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_4_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_4_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_4_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  elif EXHAUST_OVERHEAT_3
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_3_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_3_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_3_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  elif EXHAUST_OVERHEAT_2
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_2_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_2_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_2_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  elif EXHAUST_OVERHEAT_1
  then
    DECIMAL_FAN_SPEED=$EXHAUST_OVERHEAT_1_FANSPEED
    HEXADECIMAL_FAN_SPEED=$(convert_decimal_value_to_hexadecimal $EXHAUST_OVERHEAT_1_FANSPEED)
    apply_user_fan_control_profile
    COMMENT="Exhaust temperature $EXHAUST_TEMPERATURE >= $EXHAUST_OVERHEAT_1_TEMPERATURE°C, ($DECIMAL_FAN_SPEED)% fan speed applied."
  fi

  # Enable or disable, depending on the user's choice, third-party PCIe card Dell default cooling response
  # No comment will be displayed on the change of this parameter since it is not related to the temperature of any device (CPU, GPU, etc...) but only to the settings made by the user when launching this Docker container
  if $DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE
  then
    disable_third_party_PCIe_card_Dell_default_cooling_response
    THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE_STATUS="Disabled"
  else
    enable_third_party_PCIe_card_Dell_default_cooling_response
    THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE_STATUS="Enabled"
  fi

  # Print temperatures, active fan control profile and comment if any change happened during last time interval
  if [ $i -eq $TABLE_HEADER_PRINT_INTERVAL ]
  then
    echo "                     ------- Temperatures -------"
    echo "    Date & time      Inlet  CPU 1  CPU 2  Exhaust          Active fan speed profile          Third-party PCIe card Dell default cooling response  Comment"
    i=0
  fi
  printf "%19s  %3d°C  %3d°C  %3s°C  %5s°C  %40s  %51s  %s\n" "$(date +"%d-%m-%Y %T")" $INLET_TEMPERATURE $CPU1_TEMPERATURE "$CPU2_TEMPERATURE" "$EXHAUST_TEMPERATURE" "$CURRENT_FAN_CONTROL_PROFILE" "$THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE_STATUS" "$COMMENT"
  ((i++))
  wait $SLEEP_PROCESS_PID
done
