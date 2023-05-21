# Example Appmesh on Fargate EKS

## Description
This project will deploy EKS on Fargate (All pods on Fargate even kube-system resources) and deploy inside on it Appmesh controler, mostly using eksctl

## Prerequisites

To use this project you need:
- eksctl
- kubectl
- docker
- aws cli
- aws-iam-authenticator
- helm 

## Install

1. Export three environment variables:

```md
export CLUSTER_NAME="Your Cluster Name"
export AWS_REGION="Your Prefered Region"   
export AWS_ACCOUNT_ID="Your AWS Account number"
```
2. Run Deploy:
```md
./deploy.sh
```
