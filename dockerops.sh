#!/bin/bash

up () {
	IMAGES=$(docker ps -q | wc -l)
  if [ "${IMAGES}" -ge 1 ]; then
    echo "\n現在起動しているコンテナを停止します..."
    docker kill $(docker ps -q)
  fi
  echo "\nコンテナを起動します..."
  docker-compose up -d
}

build() {
  IMAGES=$(docker ps -q | wc -l)
  if [ "${IMAGES}" -ge 1 ]; then
    echo "\n現在起動しているコンテナを停止します..."
    docker kill $(docker ps -q)
  fi
  echo "\nコンテナを作り直します..."
  docker-compose build
  echo "\nコンテナを起動します..."
  docker-compose up -d
}

clean () {
  IMAGES=$(docker images | awk '/docker_/ {print $1}' | wc -l)
  if [ "${IMAGES}" -ge 1 ]; then
    echo "コンテナとして使用できないイメージを削除します..."
    docker image prune -f
    echo "\nコンテナを停止します..."
    docker kill $(docker ps -q)
    echo "\nコンテナを削除します..."
    docker rm -f $(docker ps -q -a)
    echo "\nイメージを削除します..."
    docker rmi -f $(docker images | awk '/docker_/ {print $1}')
  fi
}

usage () {
  echo $1
  cat <<_EOF_
Usage:
$(basename $0) [OPTION]

Description:
"$(pwd)" のDockerのオペレーション用スクリプトです。

Options:
  -u upを実行します。現在起動しているコンテナを停止して、"$(pwd)"にあるdocker-composeを起動します。
  -b buildを実行します。コンテナのイメージの作り直しをします。Dockerfileを更新した場合はこちら。
  -c cleanを実行します。コンテナのイメージを削除します。
  -r cleanを実行してからupを実行します。なにかトラブルシュートなどできれいにしたい場合はこちら。
  -h ヘルプを表示します。

_EOF_

exit 0
}

while getopts :ubcrh OPT
do
  case $OPT in
    u ) up;;
    b ) build;;
    c ) clean;;
    r ) clean ; up;;
    h ) usage;;
    :|\? ) usage;;
  esac
done

[ "${OPTIND}" -eq 1 ] && usage