# Running local images of the SensRNet stack on localhost

# The current workdirectory needs to be the sensrnet-helm-charts folder
CHARTS_FOLDER=$(dirname $PWD)/sensrnet-helm-charts/charts
SKIP_DEPENDENCIES=false

# SensRNet is designed to be run on Kubernetes. Running the stack locally can
# therefore be done using tools like Minikube or Docker Desktop. The purpose of
# this script is to demonstrate how to deploy -locally build- images to a local
# cluster.

# This script assumes the default image names as generated by the Docker-compose
# files in the corresponding repo's (docker-compose build)

if [ $SKIP_DEPENDENCIES = false ] ; then
  helm repo add traefik https://helm.traefik.io/traefik
  helm repo add dex https://charts.dexidp.io

  helm repo update

  helm upgrade --install traefik traefik/traefik
  helm upgrade --install dex dex/dex \
    --set "livenessProbe.httpPath=/dex/healthz" \
    --set "readinessProbe.httpPath=/dex/healthz" \
    --set "config.issuer=http://localhost/dex" \
    --set "config.storage.type=kubernetes" \
    --set "config.storage.config.inCluster=true" \
    --set "config.enablePasswordDB=true" \
    --set "config.staticPasswords[0].email=admin@sensrnet.nl" \
    --set "config.staticPasswords[0].hash=\$2a\$10\$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W" \
    --set "config.staticPasswords[0].id=1" \
    --set "config.staticPasswords[0].username=admin" \
    --set "config.staticPasswords[0].name=admin" \
    --set "config.staticClients[0].name=SensrnetRegistry" \
    --set "config.staticClients[0].id=registry-frontend" \
    --set "config.staticClients[0].public=true" \
    --set "config.oauth2.responseTypes={code,token,id_token}" \
    --set "config.oauth2.skipApprovalScreen=true" \
    --set "ingress.enabled=true" \
    --set "ingress.hosts[0].host=localhost" \
    --set "ingress.hosts[0].paths[0].path=/dex" \
    --set "ingress.hosts[0].paths[0].pathType=ImplementationSpecific"
fi

create_kube_ns_if_not_exists () {
  kubectl create namespace $1 --dry-run=client -o yaml | kubectl apply -f -
}

create_kube_ns_if_not_exists "registry"

# Install charts for registry node
helm upgrade --install multichain-node $CHARTS_FOLDER/multichain-node \
  --namespace registry \
  --set image.repository=sensrnet-multichain_node \
  --set image.tag=latest \
  --set image.pullPolicy=Never

echo "Deploying databases, this might take a while..."
helm upgrade --install registry-backend $CHARTS_FOLDER/registry-backend \
  --wait \
  --namespace registry \
  --set mongodb.podAntiAffinityPreset=soft \
  --set eventstore.affinity=null

helm upgrade --install registry-backend $CHARTS_FOLDER/registry-backend \
  --namespace registry \
  --set replicaCount=1 \
  --set image.repository=sensrnet-registry-backend_registry-backend \
  --set image.tag=latest \
  --set image.pullPolicy=Never \
  --set settings.oidc_issuer=http://localhost/dex \
  --set settings.oidc_jwks_url=http://dex:5556/dex/keys \
  --set mongodb.podAntiAffinityPreset=soft \
  --set eventstore.affinity=null

helm upgrade --install sync-bridge $CHARTS_FOLDER/sync-bridge \
  --namespace registry \
  --set image.repository=sensrnet-sync_sync-bridge \
  --set image.tag=latest \
  --set image.pullPolicy=Never

helm upgrade --install registry-frontend $CHARTS_FOLDER/registry-frontend \
  --namespace registry \
  --set image.repository=sensrnet-registry-frontend_registry-frontend \
  --set image.tag=latest \
  --set image.pullPolicy=Never \
  --set settings.oidc_issuer=http://localhost/dex