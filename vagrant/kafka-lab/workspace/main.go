package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/confluentinc/confluent-kafka-go/kafka"
	"github.com/joho/godotenv"
)

type GitlabProjectNamespace struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Path     string `json:"path"`
	Kind     string `json:"kind"`
	FullPath string `json:"full_path"`
	WebURL   string `json:"web_url"`
}

type GitlabProject struct {
	ID                     int                    `json:"id"`
	Description            string                 `json:"description"`
	PathWithNamespace      string                 `json:"path_with_namespace"`
	CreatedAt              string                 `json:"created_at"`
	WebURL                 string                 `json:"web_url"`
	GitlabProjectNamespace GitlabProjectNamespace `json:"namespace"`
}

type GitlabAPIResponse interface {
	GitlabProject
}

func fetchGitlabAPI(url string) []byte {
	gitlabPAT := os.Getenv("GITLAB_PAT")
	if gitlabPAT == "" {
		log.Fatal("GITLAB_PAT is not set")
	}

	// Create the HTTP request
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		log.Fatal("Error creating request:", err)
	}

	req.Header.Add("PRIVATE-TOKEN", gitlabPAT)

	// TODO: Handle pagination
	// Send request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal("Error performing request:", err)
	}
	defer resp.Body.Close()

	// Read response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal("Error reading response body:", err)
	}

	// Check status code
	if resp.StatusCode != http.StatusOK {
		log.Fatalf("Request status code error: %s\n%s", resp.Status, string(body))
	}

	return body
}

func produceToKafka[T GitlabAPIResponse](resp []byte, topic string) {
	var object []T

	err := json.Unmarshal(resp, &object)
	if err != nil {
		log.Fatal("Error unmarshalling JSON:", err)
	}

	p, err := kafka.NewProducer(&kafka.ConfigMap{"bootstrap.servers": "localhost"})
	if err != nil {
		log.Fatal("Error creating Kafka producer: ", err)
	}
	defer p.Close()

	// Get results back from producing to Kafka and print to console
	go func() {
		for e := range p.Events() {
			switch ev := e.(type) {
			case *kafka.Message:
				if ev.TopicPartition.Error != nil {
					fmt.Printf("Delivery failed %v\n", ev.TopicPartition)
				} else {
					fmt.Printf("Delivered message to %v\n", ev.TopicPartition)
				}
			}
		}
	}()

	// Produce to Kafka topic
	for _, project := range object {
		projectBytes, err := json.Marshal(project)
		if err != nil {
			log.Println("Error marshalling project:", err)
			continue
		}

		err = p.Produce(&kafka.Message{
			TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
			Value:          projectBytes,
		}, nil)

		if err != nil {
			log.Println("Error producing message:", err)
		}
	}

	p.Flush(1000)
}

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalln("Error loading .env file")
	}

	baseURL := "https://gitlab.com/api/v4"
	url := baseURL + "/projects?owned=true"
	resp := fetchGitlabAPI(url)

	topic := "git.projects"

	produceToKafka(resp, topic)
}
