package main

import (
	 "database/sql"
	 "fmt"
	 "log"
     "os"
	 "net/http"
	 "github.com/gorilla/mux"
	_ "github.com/go-sql-driver/mysql"
)

var db *sql.DB
func main() {
	r := mux.NewRouter()

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true&charset=utf8mb4",
		os.Getenv("DB_USER"), os.Getenv("DB_PASS"),
		os.Getenv("DB_HOST"), os.Getenv("DB_PORT"),
		os.Getenv("DB_DATABASE"),
	)

	var err error
	db, err = sql.Open("mysql", dsn)

	if err != nil {
		log.Fatal(err)
	}

	makeTableAndData()

    r.HandleFunc("/", TestHandler)
	http.ListenAndServe(":8080", r)
}

func makeTableAndData(){
	var err error

	_, err = db.Exec(
		`CREATE TABLE IF NOT EXISTS TEST (host VARCHAR(255))`,
	)

	if err != nil {
		log.Fatal(err)
	}

	name, err := os.Hostname()
	if err != nil {
		panic(err)
	}

	_, err = db.Exec(
		`INSERT INTO TEST (host) VALUES (?) `,
		name,
	)

	if err != nil {
		log.Fatal(err)
	}
}

func TestHandler(w http.ResponseWriter, r *http.Request) {
	name, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	fmt.Fprintf(w, "[go app] hostname: %v\n", name)

	fmt.Fprintf(w, "[go app] following host are connecting to the mariadb.\n")
    rows, err := db.Query(
        `SELECT * FROM TEST`,
    )
    if err != nil {
		log.Fatal(err)
    }

    defer rows.Close()
    for rows.Next() {
        host := ""
        err = rows.Scan(&host)
        if err != nil {
			log.Fatal(err)
        }

		fmt.Fprintf(w, " - hostname: %v\n", host)
    }
}
