# Setting up gcr for k8s

    kubectl create secret docker-registry gcr-json-key --docker-server=gcr.io --docker-username=_json_key --docker-password="$(cat ./kube/ignore/gcr_pull.json)" --docker-email=bruno.ripa@polaris-br.com

## Add secret to default service account as 'ImagePullSecrets'

    kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'

  
## Verify 

    kubectl get serviceaccount default -o json


Link: https://blog.container-solutions.com/using-google-container-registry-with-kubernetes#:~:text=To%20pull%20images%20from%20the,pod%20created%20in%20its%20namespace.


In case of ingress error: 

kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

# GKE

## Creating a google managed certificate

    gcloud compute ssl-certificates create polaris-certificate \
        --description="Test certificate for rart-test.polaris-br.com test certificate" \
        --domains="polaris-br.com" \
        --global

Check

    gcloud compute ssl-certificates describe polaris-certificate \
    --global \
    --format="get(name,managed.status, managed.domainStatus)"

## Static ip (test) for https

    gcloud compute addresses create polaris-test-ip --global

    # Verify
    gcloud compute addresses describe polaris-test-ip --global


## Cluster creation

    gcloud beta container --project "rart-temp" clusters create "test-cluster" --zone "europe-north1-c" --no-enable-basic-auth --cluster-version "1.19.9-gke.1900" --release-channel "regular" --machine-type "e2-medium" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "3" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/rart-temp/global/networks/default" --subnetwork "projects/rart-temp/regions/europe-north1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "europe-north1-c"

## Cluster deletion

    gcloud container clusters delete test-cluster --zone europe-north1-c

## GKE credentials

    gcloud container clusters get-credentials test-cluster --zone europe-north1-c

# DB

Create instance (public ip, ssl connections only)
Enable access network

## Serving certs for ecto

    kubectl create secret generic rart-postgres-certs --from-file=kube/ignore/certs  # not in github

## Migration 

    kubectl exec --stdin --tty pod -- sh

## Deployment

    kubectl apply -f ignore/secrets.yaml  # Not in git !!
    kubectl apply -f ex_auction_depl.yaml
    kubectl apply -f ingress.yaml



