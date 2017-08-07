#!/bin/bash -e

export CURR_JOB_CONTEXT=$1
export STATE_RES=$2

export RES_REPO="secops_repo"
export RES_REPO_STATE=$(ship_resource_get_state $RES_REPO)
export REPO_RES_CONTEXT="$RES_REPO_STATE/$CURR_JOB_CONTEXT"
export NEW_TF_STATEFILE="$REPO_RES_CONTEXT/terraform.tfstate"


echo "CURR_JOB_CONTEXT=$CURR_JOB_CONTEXT"
echo "RES_REPO=$RES_REPO"
echo "RES_REPO_STATE=$RES_REPO_STATE"
echo "REPO_RES_CONTEXT=$REPO_RES_CONTEXT"
echo "NEW_TF_STATEFILE=$NEW_TF_STATEFILE"


main() {
  ship_resource_refresh_file_to_state $NEW_TF_STATEFILE $STATE_RES
}

main
