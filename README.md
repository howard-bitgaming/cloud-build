# requirement
* gcloud auth login
* curl

# use
GH_TOKEN will be saved in ~/.build/env.  
If GH_TOKEN is empty ,will use previous token.
#### build.sh
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
VERSION_SUFFIX=""

#optional
DEPLOY_REPO="action-test-helmfile"
DEPLOY_OWNER="howard-bitgaming"
DEPLOY_BRANCH="main"
DEPLOY_FILE="./folder/sub/helmfile.yaml"
DEPLOY_KEY="fastpack-mgt-frontend"

source <(curl -fsSL https://raw.githubusercontent.com/howard-bitgaming/cloud-build/main/build.sh)
```

#### build.mjs
package.json
```json
{
  "scripts": {
      "deploy": "node ./build.mjs",
  }
}
```
