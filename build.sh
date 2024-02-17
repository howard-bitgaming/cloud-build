#!/bin/sh

CMD_VAR="
GH_TOKEN='$GH_TOKEN'
HUB_HOST='$HUB_HOST'
HUB_FOLDER='$HUB_FOLDER'
IMAGE_NAME='$IMAGE_NAME'
OWNER='$OWNER'
REPO='$REPO'
BRANCH='$BRANCH'
NODE_VERSION='$NODE_VERSION'
BUILD_CMD='$BUILD_CMD'
"
echo $CMDVAR
CMD=$CMD_VAR'
GH_AUTH=`echo -n "x-access-token:$GH_TOKEN" | base64`
BUILD_VERSION=1.0.0.0

sudo rm -fr ~/build 
mkdir ~/build 
cd ~/build

git config --global "http.https://github.com/.extraheader" "AUTHORIZATION: basic $GH_AUTH"
git clone -b $BRANCH https://github.com/$OWNER/$REPO.git

docker run --rm -t -u 1000 -v ./$REPO:/home/node/app -w /home/node/app node:$NODE_VERSION sh -c "$BUILD_CMD"

cd $REPO
BUILD_VERSION=1.0.`git rev-list HEAD --count --all`.0
echo $BUILD_VERSION > ./dist/version.html
echo "OK" > ./dist/healthCheck.html

gcloud auth configure-docker $HUB_HOST
docker build -t $HUB_HOST/$HUB_FOLDER/$IMAGE_NAME:$BUILD_VERSION .
docker push $HUB_HOST/$HUB_FOLDER/$IMAGE_NAME --all-tags
echo $IMAGE_NAME:$BUILD_VERSION
'

gcloud cloud-shell ssh --authorize-session --command=$CMD
