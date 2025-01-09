#!/bin/bash

# Set variables
ACCOUNT_ID=951872725222
REGION=ap-northeast-1
ECR_URL=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and push backend
cd chatapp/backend
docker build -t chat-app-backend -f web.Dockerfile .
docker tag chat-app-backend:latest $ECR_URL/chat-app-backend:latest
docker push $ECR_URL/chat-app-backend:latest
cd ../..

# Build and push frontend
cd chatapp/frontend
docker build -t chat-app-frontend -f frontend.Dockerfile .
docker tag chat-app-frontend:latest $ECR_URL/chat-app-frontend:latest
docker push $ECR_URL/chat-app-frontend:latest
cd ../..

# Build and push nginx
cd chatapp/nginx
docker build -t chat-app-nginx -f nginx.Dockerfile .
docker tag chat-app-nginx:latest $ECR_URL/chat-app-nginx:latest
docker push $ECR_URL/chat-app-nginx:latest
cd ../..
