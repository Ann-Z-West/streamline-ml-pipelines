- [Set up Jenkins using helm](#set-up-jenkins-using-helm)
  - [Prepare](#prepare)
  - [Deploying Jenkins master instance](#deploying-jenkins-master-instance)
  - [Expose Jenkins to a public IP Address on the Cloud](#expose-jenkins-to-a-public-ip-address-on-the-cloud)
  - [Expose Jenkins as svc on your local minikube](#expose-jenkins-as-svc-on-your-local-minikube)
    - [Proxy broken](#proxy-broken)
  - [Pre-install additional plugins](#pre-install-additional-plugins)
  - [Configure as Code](#configure-as-code)
  - [Back up data volumes](#back-up-data-volumes)
  - [Add agents](#add-agents)

# Set up Jenkins using helm
This is a quick guide for setting up Jenkins on your laptop using `minikube`, `Docker` and `Helm`, which helps you ship it to production on AWS(EKS), GCP(GKE) or Azure(AKS).

Reference -> 
[How to install a Jenkins instance with Helm](https://octopus.com/blog/jenkins-helm-install-guide)

## Prepare
1. knowledge base on k8s, [EKS](https://aws.amazon.com/eks/), 
   [GKE](https://cloud.google.com/kubernetes-engine),
   and [AKS](https://azure.microsoft.com/en-au/services/kubernetes-service/)
2. Install `Docker Desktop`
3. Install `minikube`
4. install `helm`

## Deploying Jenkins master instance
Enter the workspace.
```zsh
cd setup-jenkins-with-helm
```
1. Jenkins Helm charts are provided from https://charts.jenkins.io. To make this chart repository available, run the following commands:
```zsh
helm repo add jenkins https://charts.jenkins.io
helm repo update
# check the repo
helm search repo jenkins
```
2. Deploy the master instance
```zsh
# create a namespace
kubectl create namespace devops
# list all namespaces
kubectl get namespace
# deploy the master instance
helm upgrade --install annz-jenkins jenkins/jenkins --values master/values.yaml
```
When it returns something like:
```text
Release "annz-jenkins" does not exist. Installing it now.
NAME: annz-jenkins
LAST DEPLOYED: Mon Aug 11 16:38:34 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace devops -it svc/annz-jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  echo http://127.0.0.1:8080
  kubectl --namespace devops port-forward svc/annz-jenkins 8080:8080

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://127.0.0.1:8080/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/
```
Save the password and use it to login Jenkins admin page. Once you have loggedin you can change the admin password.

You can export the service to a different `port` for local access, for example:
```zsh
echo http://127.0.0.1:4444
kubectl --namespace devops port-forward svc/annz-jenkins 4444:8080
```
## Expose Jenkins to a public IP Address on the Cloud
To access Jenkins through a publicly available IP address, you must override the default configuration defined in the chart via `master/values-public.yaml`.
```zsh
helm upgrade --install -f master/values-public.yaml annz-jenkins jenkins/jenkins
```
It returns something like:
```text
Release "annz-jenkins" has been upgraded. Happy Helming!
NAME: annz-jenkins
......
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace devops -it svc/annz-jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        You can watch the status of by running 'kubectl get svc --namespace devops -w annz-jenkins'
  export SERVICE_IP=$(kubectl get svc --namespace devops annz-jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
  echo http://$SERVICE_IP:8080/login

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http:///configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/


NOTE: Consider using a custom image with pre-installed plugins
```
To access Jenkins, open http://service_ip_or_hostname:8080
## Expose Jenkins as svc on your local minikube
```zsh
helm upgrade --install -f master/values-minikube.yaml annz-jenkins jenkins/jenkins
```
It returns:
```text
Release "annz-jenkins" has been upgraded. Happy Helming!
NAME: annz-jenkins
LAST DEPLOYED: Mon Aug 11 17:22:23 2025
NAMESPACE: default
STATUS: deployed
REVISION: 2
NOTES:
1. Get your 'admin' user password by running:
  kubectl exec --namespace devops -it svc/annz-jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  export NODE_PORT=$(kubectl get --namespace devops -o jsonpath="{.spec.ports[0].nodePort}" services annz-jenkins)
  export NODE_IP=$(kubectl get nodes --namespace devops -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

3. Login with the password from step 1 and the username: admin
4. Configure security realm and authorization strategy
5. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http://$NODE_IP:$NODE_PORT/configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos

For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine

For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/


NOTE: Consider using a custom image with pre-installed plugins
```
Run command of step1 to get and save initial password.
Run command of step2 to export the service for local access.
Finally, run this command to access it from your localhost.
```zsh
# annz-jenkins is the service name also release-name that you can get 
# by running: kubectl get svc --namespace devops

minikube service annz-jenkins --namespace devops --url
```
### Proxy broken
You may notice that Jenkins reports the following error when you access it.
If the Jenkins is running in localhost, ignore it. Otherwise, it can be resolved by defining the URL in the `controller.jenkinsUrl` property of `master/values-public.yaml` file with the IP address or hostname of your Jenkins instance.
![Proxy broken](./images/proxy-broken.png)

## Pre-install additional plugins
To make sure that each time the deployment comes with the same plugins pre-installed, you may add a list of plugins in the values.file, for example:
```zsh
controller:
    additionalPlugins:
    - blueocean:1.27.21
```
**Note:** This approach is convenient, but the downside is the Jenkins instance is required to 
contact the Jenkins update site to retrieve them as part of the first boot. A more robust approach 
is to download the plugins as part of a custom image, which ensures the plugins are baked into the 
Docker image. It also allows additional tools to be installed on the Jenkins controller.
More details -> [Customize jenkins docker image](https://octopus.com/blog/jenkins-helm-install-guide#installing-additional-plugins)

## Configure as Code

## Back up data volumes

## Add agents