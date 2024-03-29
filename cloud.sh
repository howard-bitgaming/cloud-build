#!/bin/bash

BUILD_ROOT=~/.build

if [ -z "$GH_TOKEN" ] && [ -e $BUILD_ROOT/env ]
then
    . $BUILD_ROOT/env
    echo "---------- using previous build token"
fi

GH_AUTH=`echo -n "x-access-token:$GH_TOKEN" | base64`
BUILD_VERSION=1.0.0.0
CURRENT_TIME=`date +%s`
WORK_FOLDER=$BUILD_ROOT/$CURRENT_TIME
CHMOD_CMD="
chmod -R 777 /home/node/app
"

set -e
mkdir -p $WORK_FOLDER
cd $BUILD_ROOT
for f in 17*
do 
    if echo $f | grep -Eq '^[0-9]+$' && (($((($CURRENT_TIME - $f)/60))>120)); then 
        echo "---------- deleting $f folder"
        sudo rm -fr $f
        echo "---------- deleted $f folder"
    fi
done

cd $WORK_FOLDER

echo "GH_TOKEN=$GH_TOKEN" > $BUILD_ROOT/env

git config --global "http.https://github.com/.extraheader" "AUTHORIZATION: basic $GH_AUTH"
git clone -b $BRANCH https://github.com/$OWNER/$REPO.git

docker run --rm -t -v ./$REPO:/home/node/app -w /home/node/app node:$NODE_VERSION sh -c "${BUILD_CMD}${CHMOD_CMD}"

cd $REPO
BUILD_VERSION=1.0.`git rev-list HEAD --count`$VERSION_SUFFIX
echo $BUILD_VERSION > ./dist/version.html
echo "OK" > ./dist/healthCheck.html

gcloud config set project $HUB_PROJECT
gcloud auth configure-docker $HUB_HOST

IMAGE_REF=$HUB_HOST/$HUB_FOLDER/$IMAGE_NAME
#OLD_IMAGES=$(docker images -aq -f=reference="$IMAGE_REF")

docker build -t $IMAGE_REF:$BUILD_VERSION .
docker push $IMAGE_REF:$BUILD_VERSION
echo "---------- $IMAGE_NAME:$BUILD_VERSION pushed"
docker rmi -f $IMAGE_REF:$BUILD_VERSION

if [ -n "$DEPLOY_REPO" ]
then
    cd $WORK_FOLDER
    git clone -b $DEPLOY_BRANCH https://github.com/$DEPLOY_OWNER/$DEPLOY_REPO.git
    cd $DEPLOY_REPO
    curl -fsSL https://raw.githubusercontent.com/howard-bitgaming/helmfile-updater/main/dist/pure.js -o pure.js
    docker run --rm -t -u 1000 -v .:/home/node/app -w /home/node/app node:20.11.1 sh -c "node pure.js --file=$DEPLOY_FILE --key='$DEPLOY_KEY' --value=$BUILD_VERSION"
    git config user.name lazy-deploy
    git config user.email lazy-deploy@bitgaming.biz
    git add $DEPLOY_FILE
    git commit -m "deploy $IMAGE_NAME:$BUILD_VERSION"
    git push
    echo "---------- $DEPLOY_OWNER/$DEPLOY_REPO updated"
fi

sudo rm -fr $WORK_FOLDER

