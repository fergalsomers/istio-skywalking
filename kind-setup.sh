# Copyright [2024] Fergal Somers
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#!/bin/sh

set -x

# Pre-requisites (see readme)

# Define some istio ports (k8 container port and K8 nodePort - note we expose the nodeports as hostports in Kind)
# This will allow you to access the ingress gateway via port 8080 (e.g. http://localhost:8080/productpage )

export ISTIO_HTTP_PORT=8080
export ISTIO_HTTP_NODE_PORT=31590
export ISTIO_HTTPS_PORT=8443
export ISTIO_HTTPS_NODE_PORT=31591
export ISTIO_STATUS_PORT=8222
export ISTIO_STATUS_NODE_PORT=31592

kind create cluster \
  --wait 120s \
  --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: istio-skywalking
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
    - containerPort: $ISTIO_HTTP_NODE_PORT  # Istio HTTP
      hostPort: $ISTIO_HTTP_PORT
      protocol: TCP
    - containerPort: $ISTIO_HTTPS_NODE_PORT # Istio HTTPS/TLS
      hostPort: $ISTIO_HTTPS_PORT
      protocol: TCP
    - containerPort: $ISTIO_STATUS_NODE_PORT # Istio status port
      hostPort: $ISTIO_STATUS_PORT
      protocol: TCP      
  
EOF

# Install the OLM operator (cert-manager and olm)
# - optionally you can uncomment this to install OLM 
#
# ./olm-install.sh
# 
# echo "... OLM installed"

echo "Installing Istio... " 

./istio/setup.sh

echo "... Istio installed" 

# echo "Installing ArgoCD via Kustomize  ..." 

# kubectl apply -k argocd

# kubectl wait --for='jsonpath={.status.availableReplicas}'=1 deployment/argocd-server -n  argocd --timeout="60s"

# echo "ArgoCD is running"

# echo "Installing the boot application via Kustomize " 

# kubectl apply -k boot-application

# echo "Boot application has been configured" 

# echo "... ArgoCD Installed. Check ArgoCD application statuses!"

echo "Installing Skywalking... "

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/extras/skywalking.yaml

echo "Skywalking installed" 

echo "Installing the Istio bookdemo"

kubectl label namespace default istio-injection=enabled

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/bookinfo/platform/kube/bookinfo.yaml

kubectl wait --for='jsonpath={.status.availableReplicas}'=1 deployment.apps/reviews-v3 -n  default --timeout="60s"
kubectl wait --for='jsonpath={.status.availableReplicas}'=1 deployment.apps/productpage-v1 -n  default --timeout="60s"

echo "Installing Gateway CRDS and booking VS setup..." 

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml; }

# Note: 8080 is defined as the receiving port on this virtual service. 
# TODO: parameterise the file using the $ISTIO_HTTP_PORT

kubectl apply -f istio/internal-gateway.yaml

kubectl apply -f istio/ingress-bookinfo.yaml

echo "Bookdemo Installed"

