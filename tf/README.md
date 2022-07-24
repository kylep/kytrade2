# Terraform Infrastructure as Code

```
# Create AWS infra
tf apply

## verify
aws eks list-clusters
aws eks list-nodegroups --cluster-name kytrade2-EKS-Cluster
aws eks describe-nodegroup --cluster-name kytrade2-EKS-Cluster --nodegroup-name kytrade2-EKS-Node-Group

# Delete AWS infra
tf destroy

# Get kubeconfig file
rm -rf ~/.kube
aws eks update-kubeconfig --region ca-central-1 --name kytrade2-EKS-Cluster

# Verify cluster
k get nodes

```

## Fix the config map
```
# get and save your user id
aws sts get-caller-identity --query "Account" --output text
# then
kubectl edit configmap aws-auth -n kube-system
```
go down to mapUsers and add the following (replace `[account_id]` with your Account ID)`
```
mapUsers: |
  - userarn: arn:aws:iam::[account_id]:root
    groups:
    - system:masters
```
