# Setting up gcr for k8s

    kubectl create secret docker-registry gcr-json-key --docker-server=gcr.io --docker-username=_json_key --docker-password="$(cat ./kube/ignore/gcr_pull.json)" --docker-email=bruno.ripa@polaris-br.com

## Add secret to default service account as 'ImagePullSecrets'

    kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'

  
## Verify 

    kubectl get serviceaccount default -o json


Link: https://blog.container-solutions.com/using-google-container-registry-with-kubernetes#:~:text=To%20pull%20images%20from%20the,pod%20created%20in%20its%20namespace.