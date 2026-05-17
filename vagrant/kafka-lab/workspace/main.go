package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

type Namespace struct {
	Id       int    `json:"id"`
	Name     string `json:"name"`
	Path     string `json:"path"`
	Kind     string `json:"kind"`
	FullPath string `json:"full_path"`
	WebURL   string `json:"web_url"`
}

type GitlabProject struct {
	Id                int       `json:"id"`
	Description       string    `json:"description"`
	PathWithNamespace string    `json:"path_with_namespace"`
	CreatedAt         string    `json:"created_at"`
	WebURL            string    `json:"web_url"`
	Namespace         Namespace `json:"namespace"`
}

var gp []GitlabProject

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalln("Error loading .env file")
	}
	gitlabPAT := os.Getenv("GITLAB_PAT")

	client := &http.Client{}
	baseURL := "https://gitlab.com/api/v4"

	// Create the HTTP request
	req, err := http.NewRequest(http.MethodGet, baseURL+"/projects?owned=true", nil)
	if err != nil {
		log.Fatal("Error creating request:")
	}

	req.Header.Add("PRIVATE-TOKEN", gitlabPAT)

	// Send request
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal("Error performing request:", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal("Error reading response body:", err)
	}

	// Check status code
	if resp.StatusCode != http.StatusOK {
		log.Fatalf("GitLab API error: %s\n%s", resp.Status, string(body))
	}

	err = json.Unmarshal(body, &gp)
	if err != nil {
		log.Fatal("Error unmarshalling JSON:", err)
	}

	fmt.Println(gp)
}
