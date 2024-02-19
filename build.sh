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
DEPLOY_REPO='$DEPLOY_REPO'
DEPLOY_OWNER='$DEPLOY_OWNER'
DEPLOY_BRANCH='$DEPLOY_BRANCH'
DEPLOY_FILE='$DEPLOY_FILE'
DEPLOY_KEY='$DEPLOY_KEY'
"

CMD=$CMD_VAR'
GH_AUTH=`echo -n "x-access-token:$GH_TOKEN" | base64`
BUILD_VERSION=1.0.0.0

set -e
sudo rm -fr ~/build 
mkdir ~/build 
cd ~/build

git config --global "http.https://github.com/.extraheader" "AUTHORIZATION: basic $GH_AUTH"
git clone -b $BRANCH https://github.com/$OWNER/$REPO.git

docker run --rm -t -u 1000 -v ./$REPO:/home/node/app -w /home/node/app node:$NODE_VERSION sh -c "$BUILD_CMD"

cd $REPO
BUILD_VERSION=1.0.`git rev-list HEAD --count`.`git rev-list HEAD --count --all`
echo $BUILD_VERSION > ./dist/version.html
echo "OK" > ./dist/healthCheck.html

gcloud auth configure-docker $HUB_HOST
docker build -t $HUB_HOST/$HUB_FOLDER/$IMAGE_NAME:$BUILD_VERSION .
docker push $HUB_HOST/$HUB_FOLDER/$IMAGE_NAME --all-tags
docker rmi -f $(docker images -aq)
echo $IMAGE_NAME:$BUILD_VERSION
'

if [ -n "$DEPLOY_REPO" ]
then
    CMD=$CMD'
    cd ..
    git clone -b $DEPLOY_BRANCH https://github.com/$DEPLOY_OWNER/$DEPLOY_REPO.git
    cd $DEPLOY_REPO
    curl -fsSL https://raw.githubusercontent.com/howard-bitgaming/helmfile-updater/main/dist/pure.js -o pure.js
    docker run --rm -t -u 1000 -v .:/home/node/app -w /home/node/app node:20.11.1 sh -c "node pure.js --file=$DEPLOY_FILE --key=$DEPLOY_KEY --value=$BUILD_VERSION"
    git config user.name lazy-deploy
    git config user.email lazy-deploy@bitgaming.biz
    git add $DEPLOY_FILE
    git commit -m "deploy $IMAGE_NAME$:$BUILD_VERSION"
    git push
    '
fi


gcloud cloud-shell ssh --authorize-session --command=$CMD
