#!/bin/bash -e

_set_shippable_name() {
  echo $(echo $1 | sed -e 's/[^a-zA-Z_0-9]//g')
}

_to_upper(){
  echo $(echo $1 | awk '{print toupper($0)}')
}

ship_resource_get_name() {
  _set_shippable_name $(_to_upper $1)
}

ship_resource_get_id() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_ID")
}

ship_resource_get_meta() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_META") #loc of integration.json
}

ship_resource_get_state() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_STATE")
}

ship_resource_get_operation() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_OPERATION")
}

ship_resource_get_type() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_TYPE")
}

ship_resource_get_state() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_STATE")
}

ship_resource_get_param() {
  UP=$(ship_resource_get_name $1)
  PARAMNAME=$(_set_shippable_name $(_to_upper $2))
  echo $(eval echo "$"$UP"_PARAMS_"$PARAMNAME)
}

ship_resource_get_integration() {
    UP=$(ship_resource_get_name $1)
    INTKEYNAME=$(_set_shippable_name $(_to_upper $2))
    echo $(eval echo "$"$UP"_INTEGRATION_"$INTKEYNAME)
}

ship_resource_get_version_name() {
    UP=$(ship_resource_get_name $1)
    echo $(eval echo "$"$UP"_VERSIONNAME")
}

ship_resource_get_version_id() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_VERSIONID")
}

ship_resource_get_version_number() {
  UP=$(ship_resource_get_name $1)
  echo $(eval echo "$"$UP"_VERSIONNUMBER")
}

ship_resource_get_integration() {
  META=$(ship_resource_get_meta $1)
  cat "$META/integration.json"  | jq -r '.'$2
}

ship_get_json_value() {
  cat $1 | jq -r '.'$2
}

ship_resource_post_state() {
  RES=$1
  STATENAME=$2
  STATEVALUE=$3
  echo $STATENAME=$STATEVALUE > "$JOB_STATE/$RES.env"
}

ship_resource_put_state() {
  RES=$1
  STATENAME=$2
  STATEVALUE=$3
  echo $STATENAME=$STATEVALUE >> "$JOB_STATE/$RES.env"
}

ship_job_copy_file_to_state() {
  FILENAME=$1
  cp -vr $FILENAME $JOB_STATE
}

ship_job_copy_file_from_prev_state() {
  PREV_TF_STATEFILE=$JOB_PREVIOUS_STATE/$1
  PATH_TO_RESTORE_IN=$2

  echo "---------------- Restoring file from state -------------------"
  if [ -f "$PREV_TF_STATEFILE" ]; then
    echo "------  File exists, copying -----"
    cp -vr $PREV_TF_STATEFILE $PATH_TO_RESTORE_IN
  else
    echo "------  File does not exist in previous state, skipping -----"
  fi
}

ship_job_refresh_file_to_state() {
  NEWSTATEFILE=$1
  #this could contain path i.e / too and hence try and find only filename
  #greedy trimming ## is greedy, / is the string to look for and return last
  #part
  ONLYFILENAME=${NEWSTATEFILE##*/}

  echo "---------------- Copying file to state -------------------"
  if [ -f "$NEWSTATEFILE" ]; then
    echo "---------------  New file exists, copying  ----------------"
    cp -vr $NEWSTATEFILE $JOB_STATE
  else
    echo "---  New file does not exist, hence try to copy from prior state ---"
    local PREVSTATE="$JOB_PREVIOUS_STATE/$ONLYFILENAME"
    if [ -f "$PREVSTATE" ]; then
      echo ""
      echo "------  File exists in previous state, copying -----"
      cp -vr $PREVSTATE $JOB_STATE
    else
      echo "-------  No previous state file exists. Skipping  ---------"
    fi
  fi
}

ship_resource_copy_file_from_state() {
  RES_NAME=$1
  FILE_NAME=$2
  PATH_TO_COPY_INTO=$3
  FULL_PATH="/build/IN/"$RES_NAME"/state/"$FILE_NAME

  echo "---------------- Restoring file from state -------------------"
  if [ -f "$FULL_PATH" ]; then
    echo "------  File exists, copying -----"
    cp -vr $FULL_PATH $PATH_TO_COPY_INTO
  else
    echo "------  File does not exist in previous state, skipping -----"
  fi
}

ship_resource_refresh_file_to_state() {
  FILE_NAME=$1
  RES_NAME=$2

  #this could contain path i.e / too and hence try and find only filename
  #greedy trimming ## is greedy, / is the string to look for and return last
  #part
  ONLYFILENAME=${FILE_NAME##*/}
  RES_OUT_PATH="/build/OUT/"$RES_NAME"/state"
  RES_IN_PATH="/build/IN/"$RES_NAME"/state"

  echo "---------------- Copying file to state -------------------"
  if [ -f "$FILE_NAME" ]; then
      echo "---------------  New file exists, copying  ----------------"
      cp -vr $FILE_NAME $RES_OUT_PATH
  else
    echo "---  New file does not exist, hence try to copy from prior state ---"
    local PREVSTATE="$RES_IN_PATH/$ONLYFILENAME"
    if [ -f "$PREVSTATE" ]; then
      echo "------  File exists in previous state, copying -----"
      cp -vr $PREVSTATE $RES_OUT_PATH
    else
      echo "------  File does not exist in previous state, skipping -----"
    fi
  fi
}
