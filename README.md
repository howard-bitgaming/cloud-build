# ENV VAR
GH_TOKEN="ghp_123456789"  
HUB_HOST="asia-northeast1-docker.pkg.dev"  
HUB_FOLDER="techu-beta/gameapi"  
IMAGE_NAME="gameapi.mgt.frontend"  
OWNER="TechU8"  
REPO="GameAPI.MGT.FrontEnd"  
BRANCH="deploy/beta"  
NODE_VERSION="10.4"  
BUILD_CMD="npm ci && npm run build:beta"  

# use
```sh
GH_TOKEN="ghp_123456789"
HUB_HOST="asia-northeast1-docker.pkg.dev"
HUB_FOLDER="techu-beta/gameapi"
IMAGE_NAME="gameapi.mgt.frontend"
OWNER="TechU8"
REPO="GameAPI.MGT.FrontEnd"
BRANCH="deploy/beta"
NODE_VERSION="10.4"
BUILD_CMD="npm ci && npm run build:beta"
curl -fsSL https://raw.githubusercontent.com/howard-bitgaming/cloud-build/main/build.sh | sh -
```
