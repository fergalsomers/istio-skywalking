<!---
Copyright (c) [2024] Fergal Somers
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# Istio Skywalking Demo  <!-- omit from toc -->

This is a sample Kubernetes demo that uses [kind](https://kind.sigs.k8s.io/) to create a local kubernetes cluster on your
laptop that runs the following:

1. Istio
2. Apache Skywalking
3. Istio bookinfo sample

**Contents**

- [Pre-requisites](#pre-requisites)
- [How to install](#how-to-install)
- [To test](#to-test)
- [To clean up](#to-clean-up)


# Pre-requisites

1. Install [Docker](https://docs.docker.com/engine/install/)
1. Install [kind](https://kind.sigs.k8s.io/) - for mac "brew install kind"
1. Install [kubectl](https://kubernetes.io/docs/reference/kubectl/) - for mac "brew install kubectl"
1. Install [git](https://git-scm.com/) - git comes with Xcode on mac. 

# How to install

Clone the repo and 

```
git clone https://github.com/fergalsomers/istio-skywalking.git
cd istio-skywalking
./kind-setup.sh
```

This can take a few minutes  


1. Create a kind cluster call `istio-skywalking`
2. Create a kubeconfig in istio-skywalking directory. 
3. Install Istio service mesh - configured for using apache skywalking as a provider
4. Install BookInfo application
   

# To test

First hit the [Bookinfo productpage](http://localhost:8080/productpage) a couple of times to generate some trace data. 

Then look at the traces in the [Skywalking UI](http://localhost:8080/)

# To clean up

```
kind delete cluster --name=istio-skywalking
```
