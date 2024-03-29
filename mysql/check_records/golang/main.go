package main

import (
    "database/sql"
    "fmt"
    "log"
    "os"
    "github.com/go-sql-driver/mysql"
    "github.com/joho/godotenv"
)

func main() {
    // .env ファイルから設定情報を読み込む
    err := godotenv.Load()
    if err != nil {
        log.Fatal("Error loading .env file")
    }

    // MySQLへの接続情報を設定
    config := mysql.Config{
        User:     os.Getenv("DB_USER"),
        Passwd:   os.Getenv("DB_PASS"),
        Net:      "tcp",
        Addr:     fmt.Sprintf("%s:%s", os.Getenv("DB_HOST"), os.Getenv("DB_PORT")),
        DBName:   os.Getenv("DB_NAME"),
        AllowNativePasswords: true,
    }

    // MySQLデータベースに接続
    db, err := sql.Open("mysql", config.FormatDSN())
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    // テーブル一覧の取得
    rows, err := db.Query("SHOW TABLES")
    if err != nil {
        log.Fatal(err)
    }
    defer rows.Close()

    // 最初のテーブル名を取得
    var tableName string
    tableFound := false // テーブルが見つかったかどうかを追跡

    for rows.Next() {
        if err := rows.Scan(&tableName); err != nil {
            log.Fatal(err)
        }
        fmt.Println(tableName)
        tableFound = true // テーブルが見つかったことをマーク
    }

    if !tableFound {
        log.Fatal("テーブルが見つかりませんでした。")
    }

    // 最初のテーブルの最初のレコードを取得
    //テーブル名を指定して、最初のレコードを取得するようにfor文で回す
    query := fmt.Sprintf("SELECT * FROM %s LIMIT 1", tableName)
    for _, value := range os.Args[1:] {
        query += fmt.Sprintf(" %s", value)
    }
    row := db.QueryRow(query)

    fmt.Println(row)

    // レコードのスキャン
    //columns, err := row.Columns()
    //if err != nil {
    //    log.Fatal(err)
    //}

    //// カラム数に応じてスライスを作成
    //values := make([]interface{}, len(columns))
    //for i := range columns {
    //    values[i] = new(interface{})
    //}

    //if err := row.Scan(values...); err != nil {
    //    log.Fatal(err)
    //}

    //// レコードの値を取得してリストに追加
    //var recordList []interface{}
    //for _, value := range values {
    //    recordList = append(recordList, *value.(*interface{}))
    //}

    //// リストの内容を表示
    //fmt.Println(recordList)
}
