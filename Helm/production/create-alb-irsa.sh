#!/bin/bash

# Configuration
CLUSTER_NAME="sm-statuspage-eks"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
NAMESPACE="kube-system"
POLICY_NAME="SM-AWSLoadBalancerControllerIAMPolicy"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"  

echo "Checking if IAM policy exists..."
POLICY_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME"
aws iam get-policy --policy-arn $POLICY_ARN > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "IAM policy does not exist - creating it..."
  curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.3/docs/install/iam_policy.json
  aws iam create-policy --policy-name $POLICY_NAME --policy-document file://iam_policy.json
else
  echo "IAM policy exists: $POLICY_ARN"
fi

eksctl delete iamserviceaccount \
  --cluster="sm-statuspage-eks" \
  --namespace="kube-system" \
  --name="aws-load-balancer-controller" \
  --region="us-east-1"

echo "Creating ServiceAccount with IRSA..."
eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=$NAMESPACE \
  --name=$SERVICE_ACCOUNT_NAME \
  --attach-policy-arn=$POLICY_ARN \
  --approve

echo "ServiceAccount '$SERVICE_ACCOUNT_NAME' has been successfully created!"

helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller using Helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=$SERVICE_ACCOUNT_NAME \
  -n $NAMESPACE

echo "AWS Load Balancer Controller has been successfully installed!"
