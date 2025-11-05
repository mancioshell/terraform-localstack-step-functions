#!/bin/bash

# This script deploys the user-spa application to an AWS S3 bucket and invalidates the CloudFront cache.

APP_NAME="user-spa"
S3_BUCKET="static-website-cognito-auth-spa"
CLOUDFRONT_DISTRIBUTION_ID="14e9a161"
BUILD_DIR="dist/"

echo "Starting deployment of $APP_NAME..."

# Build the application
echo "Building the application..."
rm -rf $BUILD_DIR
yarn build

# Sync the build directory to the S3 bucket
echo "Syncing files to S3 bucket $S3_BUCKET..."
aws --endpoint-url=http://localhost:4566 s3 sync $BUILD_DIR s3://$S3_BUCKET/ --exclude "*.js" --delete
aws --endpoint-url=http://localhost:4566 s3 sync $BUILD_DIR s3://$S3_BUCKET/ --exclude "*" --include "*.js" --content-type application/javascript

# # Invalidate the CloudFront cache
echo "Invalidating CloudFront cache for distribution $CLOUDFRONT_DISTRIBUTION_ID..."
aws --endpoint-url=http://localhost:4566 cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"

echo "Deployment of $APP_NAME completed successfully."  

