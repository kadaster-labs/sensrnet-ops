#!/bin/bash

echo 'cloning all repos ...'

git clone git@github.com:kadaster-labs/sensrnet-home.git home

git clone git@github.com:kadaster-labs/sensrnet-ops.git ops

git clone git@github.com:kadaster-labs/sensrnet-registry-frontend.git registry-frontend
git clone git@github.com:kadaster-labs/sensrnet-registry-backend.git registry-backend

git clone git@github.com:kadaster-labs/sensrnet-multichain.git multichain
git clone git@github.com:kadaster-labs/sensrnet-sync.git sync

git clone git@github.com:kadaster-labs/sensrnet-central-viewer.git central-viewer
