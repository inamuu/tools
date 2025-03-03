# Elasticsearch ドメインのリポジトリ登録スクリプト
# Google Workspace 認証を通した状況で以下コマンドを実行する
#
#   $ python　./register-repo.py　${host} ${repo_name} ${repo_bucket_name} ${role_arn} ${is_readonly}

from argparse import ArgumentError
import os
import requests
import sys

from distutils.util import strtobool
from requests_aws4auth import AWS4Auth

#if len(sys.argv) != 6:
#  raise ArgumentError("Please input required arguments: host, repo_name, repo_bucket_name, role_arn, is_readonly")

AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_SESSION_TOKEN = os.getenv('AWS_SESSION_TOKEN')
region = 'ap-northeast-1'
service = 'es'

awsauth = AWS4Auth(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, region, service,
            session_token=AWS_SESSION_TOKEN)

# Parameters
host = sys.argv[1]
repo_name = sys.argv[2]
#repo_bucket_name = sys.argv[3]
#role_arn = sys.argv[4]
#is_readonly = bool(strtobool(sys.argv[5]))

path = f'/_snapshot/{repo_name}'
url = host + path

payload = {
  "type": "s3",
  "settings": {
    "bucket": "example",
    "region": "ap-northeast-1",
    "base_path": "opensearch/" + repo_name,
    "role_arn": "arn:aws:iam::xxxxxxxxx:role/AllowAccessS3ForBackupOpenSearchRole",
  }
}

headers = {"Content-Type": "application/json"}

r = requests.put(url, auth=awsauth, json=payload, headers=headers)

print(r.text)

