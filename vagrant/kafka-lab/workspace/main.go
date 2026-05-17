package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

type namespace struct {
	id        int
	name      string
	path      string
	kind      string
	full_path string
	web_url   string
}

type gitlabProject struct {
	id                  int
	description         string
	path_with_namespace string
	created_at          string
	web_url             string
	namespace           namespace
}

func main() {
	var responseBody bytes.Buffer
	var gp []gitlabProject

	err := godotenv.Load()
	if err != nil {
		log.Fatalln("Error loading .env file")
	}
	gitlabPAT := os.Getenv("GITLAB_PAT")

	client := &http.Client{}
	baseURL := "https://gitlab.com/api/v4"

	// Create the HTTP request
	req, err := http.NewRequest(http.MethodGet, baseURL+"/projects?owned=true", &responseBody)
	req.Header.Add("PRIVATE-TOKEN", gitlabPAT)

	// Perform the request
	resp, _ := client.Do(req)
	body, _ := io.ReadAll(resp.Body)
	resp.Body.Close()

	err = json.Unmarshal(body, &gp)
	if err != nil {
		log.Fatalln("error at json.Unmarshal: ", err)
	}

	fmt.Println(gp[len(gp)-1].created_at)
}
