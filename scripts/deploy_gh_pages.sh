#!/bin/bash
set -e

if [ ! -f "build/web/index.html" ]; then
    echo "Error: build/web/index.html does not exist. Run scripts/build_web.sh first!"
    exit 1
fi

echo "=== Deploying to gh-pages ==="
DEPLOY_DIR=$(mktemp -d)
cp -r build/web/* "$DEPLOY_DIR/"
touch "$DEPLOY_DIR/.nojekyll"

CURRENT_BRANCH=$(git branch --show-current)
git checkout gh-pages
rm -rf *
cp -r "$DEPLOY_DIR"/* .
git add -A
git commit -m "deploy: Update Web build $(date +'%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
git push origin gh-pages

git checkout "$CURRENT_BRANCH"
rm -rf "$DEPLOY_DIR"

echo "=== Deployed successfully to https://kimver2.github.io/hero/ ==="
