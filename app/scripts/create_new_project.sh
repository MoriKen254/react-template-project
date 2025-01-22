#!/bin/bash
#
# create_new_project.sh
# Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
#

export APP_NAME=react-template

cd ../src/
# $APP_NAME のフォルダを確認し、存在すれば強制削除する
if [ -d $APP_NAME ]; then
    rm -rf $APP_NAME
fi

# プロジェクト作成
echo "y" | npm create vite@latest $APP_NAME -- --template react-ts

# 新規プロジェクト作成後、vite.config_template.ts を上書きコピー
# port 3000 で起動するように設定し、docker でのホットリロードを有効にする
cp ../scripts/vite.config_template.ts $APP_NAME/vite.config.ts

# tsconfig.app.json を上書きコピー
# @をsrc/にマッピングする
cp ../scripts/tsconfig.app_template.json $APP_NAME/tsconfig.app.json

# 必要なライブラリ等をインストール
cd $APP_NAME
npm install --omit=dev
 
# インストールされたものを確認する。
npm ls --omit=dev
