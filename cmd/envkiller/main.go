package main

import (
	"context"
	"fmt"
	"log"

	"github.com/joho/godotenv"
	"github.com/sgavrylenko/envkiller/pkg/config"
	"github.com/sgavrylenko/envkiller/pkg/version"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

// init is invoked before main()
func init() {
	// loads values from .env into the system
	log.Print("Searching the .env file...")
	if err := godotenv.Load(); err != nil {
		log.Print("No .env file found")
	}
}

func main() {

	log.Printf(
		"Starting the envkiller...\ncommit: %s, build time: %s, release: %s",
		version.Commit, version.BuildTime, version.Release,
	)

	conf := config.New()

	log.Printf("Current config: %v", conf)

	k8s, err := clientcmd.BuildConfigFromFlags("", conf.KubeConfig)
	if err != nil {
		log.Fatal(err)
	}

	clientset, err := kubernetes.NewForConfig(k8s)
	if err != nil {
		log.Fatal(err)
	}

	nsList, err := clientset.CoreV1().Namespaces().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		panic(err.Error())
	}
	fmt.Printf("There are %d namespaces in the cluster\n", len(nsList.Items))
	//fmt.Printf(pods.String())
	for _, ns := range nsList.Items {
		fmt.Printf("NS %s created %s\n", ns.GetName(), ns.CreationTimestamp)
	}

}
