#
# Dockerfile
# Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
#

ARG NODE_VERSION=22

# ベースイメージとしてNode.jsを使用
FROM node:${NODE_VERSION}-slim as react_template_image_prep

ENV USER=node

# Create necessary directories as root and change ownership
USER root
RUN echo "USER is set to: root"

# 必要なパッケージのインストールとロケールの設定
RUN apt-get update && apt-get install -y locales && \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 環境変数の設定
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ Asia/Tokyo

# ディレクトリの作成と権限の設定
RUN mkdir -p /home/node/Project/scripts && \
    mkdir -p /home/node/Project/src && \
    chown -R node:node /home/node/Project && \
    chmod -R 755 /home/node/Project

# ワーキングディレクトリの設定
WORKDIR /home/node/Project

# ユーザーをnodeに切り替え
USER ${USER}

ENV TERM=xterm-256color

# コンテナ起動時のコマンド
ENTRYPOINT ["/bin/bash"]


FROM react_template_image_prep as react_template_image_dev

# ステージ内で利用できるようにするために、USER_ARGを再度 ARG で宣言する
ARG USER_ARG
ENV USER ${USER_ARG}
# Switch to the user
USER ${USER}
RUN echo "USER is set to: ${USER}"

# プロジェクトファイルをコンテナにコピー
COPY --chown=${USER_ARG}:${USER_ARG} ./src/react_template /home/${USER_ARG}/Project/src/react_template

# 作業ディレクトリを設定
WORKDIR /home/${USER_ARG}/Project/src/react_template

# 依存関係のインストール
RUN npm install --production=false

RUN rm -rf /home/${USER_ARG}/Project/src/react_template/

# コンテナ起動時のコマンド
ENTRYPOINT ["/bin/bash"]


FROM react_template_image_dev as react_template_image_prod

ARG RUNTIME_ENV
ARG USER_ARG

# ユーザーをnodeに切り替え
USER ${USER_ARG}
USER ${USER}

# Switch back to the user
ENV USER ${USER_ARG}
USER ${USER}
RUN echo "USER is set to: ${USER}"

COPY ./src/react_template/react_template /home/${USER}/Project/react_template/src/react_template

# Switch back to root to copy the entrypoint script and set permissions
USER root
RUN echo "USER is set to: root"

# 不要なファイルを削除
RUN find /home/${USER}/Project/react_template -depth -name '__pycache__' -exec rm -rf '{}' +

USER ${USER}
RUN echo "USER is set to: ${USER}"

ENTRYPOINT ["/bin/bash"]