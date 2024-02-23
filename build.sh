#!/bin/sh

AUTH_ACCOUNT=`gcloud auth list --filter="status:ACTIVE" --format="value(account)"`
if [ -z "$AUTH_ACCOUNT" ]
then
  gcloud auth login
fi

CMD_VAR="
GH_TOKEN='$GH_TOKEN'
HUB_PROJECT='$HUB_PROJECT'
HUB_HOST='$HUB_HOST'
HUB_FOLDER='$HUB_FOLDER'
IMAGE_NAME='$IMAGE_NAME'
OWNER='$OWNER'
REPO='$REPO'
BRANCH='$BRANCH'
NODE_VERSION='$NODE_VERSION'
BUILD_CMD='$BUILD_CMD'
VERSION_SUFFIX='$VERSION_SUFFIX'
DEPLOY_REPO='$DEPLOY_REPO'
DEPLOY_OWNER='$DEPLOY_OWNER'
DEPLOY_BRANCH='$DEPLOY_BRANCH'
DEPLOY_FILE='$DEPLOY_FILE'
DEPLOY_KEY='$DEPLOY_KEY'
"

gcloud cloud-shell ssh --authorize-session --command="${CMD_VAR}`curl -fsSL https://raw.githubusercontent.com/howard-bitgaming/cloud-build/main/cloud.sh`"
