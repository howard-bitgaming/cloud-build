#!/bin/sh

AUTH_ACCOUNT=`gcloud auth list --filter="status:ACTIVE" --format="value(account)"`
if [ -z "$AUTH_ACCOUNT" ]
then
  gcloud auth login
fi

if [ -z "$GH_TOKEN" ]
then
  GH_TOKEN=$GH_AUTH
fi

gcloud cloud-shell ssh --authorize-session --command=`curl -fsSL https://raw.githubusercontent.com/howard-bitgaming/cloud-build/main/cloud.sh`
