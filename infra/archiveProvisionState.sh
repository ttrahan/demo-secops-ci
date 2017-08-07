#!/bin/bash -e

export CURR_JOB_CONTEXT=$1
export REPO_RES="secops_repo"

export REPO_RES_UP=$(echo $REPO_RES | awk '{print toupper($0)}')
export REPO_RES_STATE=$(eval echo "$"$REPO_RES_UP"_STATE") #loc of git repo clone
export REPO_RES_CONTEXT="$REPO_RES_STATE/$CURR_JOB_CONTEXT"
export NEW_TF_STATEFILE="$REPO_RES_CONTEXT/terraform.tfstate"

main() {
  if [ -f "$NEW_TF_STATEFILE" ]; then
    echo "New state file exists, copying"
    echo "-----------------------------------"
    cp -vr $NEW_TF_STATEFILE $JOB_STATE
  else
    local previous_statefile_location="/build/previousState/terraform.tfstate"
    if [ -f "$previous_statefile_location" ]; then
      echo "Previous state file exists, copying"
      echo "-----------------------------------"
      cp -vr previousState/terraform.tfstate /build/state/
    else
      echo "No previous state file exists. Skipping"
      echo "-----------------------------------"
    fi
  fi
}

main
