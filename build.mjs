import { spawnSync } from 'node:child_process'
import minimist from 'minimist'
import semver from 'semver'
import _ from 'lodash'


const startTime = Date.now()
const { token = '', env = 'prod', deploy = true } = minimist(process.argv.slice(2))
const envName = env !== 'beta' ? 'prod' : env

const envVars = {
  GH_TOKEN: token,
  HUB_PROJECT: 'GH_TOKEN',
  HUB_HOST: 'HUB_HOST',
  HUB_FOLDER: 'HUB_FOLDER',
  IMAGE_NAME: 'IMAGE_NAME',
  OWNER: 'OWNER',
  REPO: 'REPO',
  BRANCH: 'BRANCH',
  NODE_VERSION: semver.valid(process.env['npm_package_engines_node']) || '20.11.1',
  BUILD_CMD: `
  corepack enable pnpm
  pnpm install --frozen-lockfile
  pnpm build:${envName}
  `,
  VERSION_SUFFIX: '',
  DEPLOY_REPO: 'DEPLOY_REPO',
  DEPLOY_OWNER: 'DEPLOY_OWNER',
  DEPLOY_BRANCH: 'DEPLOY_BRANCH',
  DEPLOY_FILE: 'DEPLOY_FILE',
  DEPLOY_KEY: 'DEPLOY_KEY',
}


if (envName === 'beta') {
  _.assign(envVars, {
    DEPLOY_REPO: "DEPLOY_REPO",
    HUB_PROJECT: "HUB_PROJECT",
    HUB_FOLDER: "HUB_FOLDER",
    BRANCH: "BRANCH",
    DEPLOY_BRANCH: "DEPLOY_BRANCH",
    DEPLOY_FILE: "DEPLOY_FILE",
    VERSION_SUFFIX: "-beta"
  })
}
if (!deploy) {
  envVars.DEPLOY_REPO = ''
}

gcloudChecker()
gcloudLoginChecker()
runScriptsWithGoogleShell()

function runScriptsWithGoogleShell() {
  fetch('https://raw.githubusercontent.com/howard-bitgaming/cloud-build/main/cloud.sh').then(resp => resp.text()).then((scripts) => {
    const setEnvVarsCmd = _.chain(envVars).map((i, k) => `${k}='${i}'`).join('\n').value() + '\n'
    const child = spawnSync('gcloud', ['cloud-shell', 'ssh', '--authorize-session', `--command=${setEnvVarsCmd}${scripts}`], { stdio: 'inherit' });
    const usedSeconds = (Date.now() - startTime) / 1000
    console.info(`---------- total used ${ntos(usedSeconds / 60)}:${ntos(usedSeconds % 60)}`)
  })
}
function ntos(val) {
  return Number(val).toLocaleString('en', { minimumIntegerDigits: 2, maximumFractionDigits: 0 })
}
function gcloudChecker() {
  const gcloudPath = spawnSync('which', ['gcloud'])
  if (!gcloudPath.stdout.toString()) {
    console.error('gcloud not found')
    process.exit(1)
  }
}
function gcloudLoginChecker() {
  const gcAccounts = spawnSync('gcloud', ['auth', 'list'], { stdio: ['inherit', 'pipe', 'pipe'] })
  if (!gcAccounts.stdout.toString()) {
    const gcLogin = spawnSync('gcloud', ['auth', 'login'], { stdio: 'inherit' })
    if (gcLogin.status) process.exit(1)
  }
  console.info(gcAccounts.stdout.toString())
}
