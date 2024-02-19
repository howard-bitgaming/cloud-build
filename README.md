# requirement
* gcloud auth login
* curl

# use
```bash
#!/bin/bash
GH_TOKEN="ghp_123456789"
HUB_HOST="asia-northeast1-docker.pkg.dev"
HUB_FOLDER="techu-beta/gameapi"
IMAGE_NAME="gameapi.mgt.frontend"
OWNER="TechU8"
REPO="GameAPI.MGT.FrontEnd"
BRANCH="deploy/beta"
NODE_VERSION="10.4"
BUILD_CMD="npm ci && npm run build:beta"

#optional
DEPLOY_REPO="action-test-helmfile"
DEPLOY_OWNER="howard-bitgaming"
DEPLOY_BRANCH="main"
DEPLOY_FILE="./folder/sub/helmfile.yaml"
DEPLOY_KEY="releases.*[name $= frontend].set.*[name $= tag].value"

source <(curl -fsSL https://raw.githubusercontent.com/howard-bitgaming/cloud-build/main/build.sh)
```
