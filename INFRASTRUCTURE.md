# Infrastructure setup

## Postgres instance creation

Note: for now there's a single instance, described below.

Instance details: [!DB instance configuration](./doc_images/db-instance-01.png)

## Connections configuration


- enable `0.0.0.0/0` subnet (all internet for now, fix later).

- enable SSL only connection

## Credentials

Prerequisites: `google-cloud-sdk` must be installed.

Authenticating in google cloud platform:

    gcloud auth login

Select an account which has access to Reasoned Art cloud account (in this example, I am using `reasonedart.cloud@gmail.com`).

If everything is successful, you'll see:

    You are now logged in as [reasonedart.cloud@gmail.com]. 
    Your current project is [xxxx].  You can change this setting by running:
    
    $ gcloud config set project PROJECT_ID

Setup project to `reasoned-project-01`:

    $ gcloud config set project reasoned-project-01


## Cluster configuration

[Cluster basics](./doc_images/cluster-basics.png)

[Node pool configuration](./doc_images/node-pool-configuration.png)

Create the cluster:

    gcloud beta container --project "reasoned-project-01" clusters create "reasoned-cluster-01" --zone "europe-west3-c" --no-enable-basic-auth --cluster-version "1.19.9-gke.1900" --release-channel "regular" --machine-type "n1-standard-1" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "2" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/reasoned-project-01/global/networks/default" --subnetwork "projects/reasoned-project-01/regions/europe-west3/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "europe-west3-c"


Now, you need to give `kubectl` the right credentials:

    gcloud container clusters get-credentials reasoned-cluster-01 --region europe-west3-c

### Static IP creation

    gcloud compute addresses create reasoned-static-ip-01 --global

    # Verify
    gcloud compute addresses describe reasoned-static-ip-01 --global

Note: there is a second static ip, needed for test purposes. It's `reasoned-static-test-ip-01`.

### Create the production namespace

    kubectl create namespace prod

### Image pull features

We need K8s being able to pull images from Google Container Registry.

First we need to generate a service account and save it (for example in a file named `gcr_pull.json`). After this, we need to create a k8s secret with the following:

    kubectl create secret docker-registry gcr-json-key --docker-server=gcr.io --docker-username=_json_key --docker-password="$(cat gcr_pull.json)" --docker-email=reasonedart.cloud@gmail.com --namespace=prod

### Creating a managed certificate

We generate a Google Managed Certificate:

    gcloud compute ssl-certificates create reasoned-certificate-01 --description="Test certificate for api.reasonedart.com" --domains="api.reasonedart.com" --global


    gcloud compute ssl-certificates create reasoned-certificate-test-01 --description="Test certificate for test-api.reasonedart.com" --domains="test-api.reasonedart.com" --global

Check:

    gcloud compute ssl-certificates describe reasoned-certificate-01 --global --format="get(name,managed.status, managed.domainStatus)"

### Creating DB certificates for Ecto

The 3 certificates that have been created in postgres must be pushed to k8s:

    kubectl create secret generic reasoned-postgres-certs --namespace=prod --from-file=kube/ignore/certs  # files not in github

At this point we should have the following secrets:

    NAME                      TYPE                                  DATA   AGE
    gcr-json-key              kubernetes.io/dockerconfigjson        1      8m24s
    reasoned-postgres-certs   Opaque                                3      5s

This should be enough to have the cluster ready to rollout the deployment.

## Deployment rollout

Secrets push to k8s:

    kubectl apply -f kube/ignore/secrets.yaml

Managed certificates creation:

    kubectl apply -f kube/cert.yaml

Deployment:

    kubectl apply -f kube/deployment.yaml

Ingress:

    kubectl apply -f kube/ingress.yaml


## DB tables

So far we create the database from a local instance. Migration, can be applied like this:

    kubectl exec --tty --stdin --namespace=prod POD_NAME -- sh

and, once logged in:

    bin/ex_auctions eval 'ExAuctionsDB.ReleaseTasks.db_migrate()'

# Appendix

## Secrets management

Secrets must be base64 encoded in a file like the following:


    apiVersion: v1
    kind: Secret
    metadata:
    name: auctions-secrets
    namespace: prod
    type: Opaque
    data:
    google_client_id: B64 encoded value
    database_hostname: B64 encoded value
    database_user: B64 encoded value
    database_password: B64 encoded value
    database_name: B64 encoded value
    database_port: B64 encoded value

