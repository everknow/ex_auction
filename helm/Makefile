.PHONY: build

install-test:
	@ echo "Installing test..."
	@ ./process.sh test install
	@ echo "Done."

uninstall-test:
	@ echo "Uninstalling test..."
	@ ./uninstall.sh test
	@ echo "Done."

delete-test:
	@ echo "Deleting test cluster"
	@ helm delete test-deployment

create-cluster:
	gcloud beta container --project "rart-temp" clusters create "test-cluster-01" --zone "europe-west3-c" --no-enable-basic-auth --cluster-version "1.20.6-gke.1000" --release-channel "regular" --machine-type "n1-standard-1" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "2" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/rart-temp/global/networks/default" --subnetwork "projects/rart-temp/regions/europe-west3/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "europe-west3-c"
