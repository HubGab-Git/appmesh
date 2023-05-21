## insert desired cluster name and  region into eksConfig.yaml
cat eksConfig.yaml | \
  sed "s/{{cluster_name}}/$CLUSTER_NAME/g" | \
  sed "s/{{aws_region}}/$AWS_REGION/g" > eksConfig_processed.yaml

## insert desired proxy-auth.json into proxy-auth.json  
cat proxy-auth.json | \
  sed "s/{{aws_account_id}}/$AWS_ACCOUNT_ID/g" | \
  sed "s/{{aws_region}}/$AWS_REGION/g" > proxy-auth_processed.json

#creating eks fargate cluster
eksctl create cluster -f eksConfig_processed.yaml

## installing appmesh-controller 
helm repo add eks https://aws.github.io/eks-charts
kubectl apply -k "https://github.com/aws/eks-charts/stable/appmesh-controller/crds?ref=master"
helm upgrade -i appmesh-controller eks/appmesh-controller \
    --namespace appmesh-system \
    --set region=$AWS_REGION \
    --set serviceAccount.create=false \
    --set serviceAccount.name=appmesh-controller

## wait until appmesh-controller is ready
sleep 60 

## install appmesh Resources (Mesh, VirtualNode, VirtualRouter, VirtualService)
kubectl apply -f appmeshResources.yaml

## Create Policy to allow appmesh:StreamAggregatedResources
aws iam create-policy --policy-name my-policy --policy-document file://proxy-auth_processed.json --no-cli-pager

## Create Service Account and attach Policy
eksctl create iamserviceaccount \
    --cluster $CLUSTER_NAME \
    --namespace my-apps \
    --name my-service-a \
    --attach-policy-arn  arn:aws:iam::$AWS_ACCOUNT_ID:policy/my-policy \
    --override-existing-serviceaccounts \
    --approve

## Create example-service
kubectl apply -f example-service.yaml