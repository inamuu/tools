# coding: utf-8

import datetime
import os
import re
import sys
from os.path import dirname, join

from dotenv import load_dotenv

import mysql.connector

def dbconnect():
    dotenv_path = join(dirname(__file__), '.env')
    load_dotenv(dotenv_path)
    conn = mysql.connector.connect(
        user            = os.environ.get("dbuser"),
        passwd          = os.environ.get("dbpass"),
        host            = os.environ.get("dbhost"),
        port            = os.environ.get("dbport"),
        database        = os.environ.get("dbname"),
        connect_timeout = 5
    )
    try:
        conn.ping(reconnect=True)
        conn.is_connected()
    except:
        return

    return conn


def update_email_error(mailaddrlist):
    for row in mailaddrlist:
        print('Check exist: ' + row)
        conn = dbconnect()
        cur  = conn.cursor()

        searchQuery = "\
            SELECT \
                count(email) \
            FROM \
                users \
            WHERE \
                email = %s"
        cur.execute(searchQuery, (row,))
        res = cur.fetchone()
        cur.close()
        if res[0] == 0: continue

        cur2 = conn.cursor(buffered=True)
        try:
            updateQuery = "\
                UPDATE \
                    profiles as up \
                INNER JOIN \
                    users as u \
                        ON u.id = up.user_id \
                SET \
                    up.email = 1 \
                WHERE \
                    u.email = %s"
            cur2.execute(updateQuery, (row,))
            conn.commit()
            cur2.close()
            print("Update email: %s" % row)
        except Exception as e:
            conn.rollback()
            print('QueryError: ', e)


def grep_bounce_logs(filepath):
    bouncelists = []
    logfile = filepath + 'maillog-' + datetime.datetime.now().strftime("%Y%m%d")
    if not os.path.isfile(logfile):
        print('does not exist %s' % logfile)
        sys.exit()

    logdata = open(logfile, "r")
    lines   = logdata.readlines()
    for line in lines:
        """
        smtp status codeより、ユーザーが存在しないと判断できるstatus codeのみを対象とした.
        ref: https://support.google.com/a/answer/3221692?hl=ja
        dsn=5.0.X, 5.1.X のメールアドレスを配信停止対象とする.
        dsn=5.4.X はホストが見つからない場合以外に、拒否された場合も含まれるようなので一旦見送り.
        """
        bouncelog = re.search(r'dsn=5.[0|1]', line)
        if bouncelog:
            bouncelists.append(line)

    logdata.close()
    return bouncelists


def main():
    filepath = '/var/log/'
    bouncelogs = grep_bounce_logs(filepath)

    mailaddrlist = []
    for addrlist in bouncelogs:
        mailaddr_org = re.search('to=<.*>,', addrlist)
        mailaddr     = mailaddr_org.group(0).replace(r'to=<','').replace('>,','')
        mailaddrlist.append(mailaddr)

    """
    setで重複削除しただけだとstrになるため, 元のリストのindexをキーにして再度リスト化
    """
    sortlist = sorted(set(mailaddrlist), key=mailaddrlist.index)
    update_email_error(sortlist)
    return

if __name__ == '__main__': main()

