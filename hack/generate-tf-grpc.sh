#!/bin/bash

set -x
cd $(dirname $0)/.. || return

### 1. clean up ###
rm -rf pkg
rm -rf serving
rm -rf tensorflow

### 2. install dependencies ###
# See: https://mauri870.github.io/blog/posts/tensorflow-serving-inception-go/
# only old protoc-gen-go works
go install github.com/golang/protobuf/protoc-gen-go@v1.3.0
# only old TensorFlow works
git clone -b r1.7 https://github.com/tensorflow/serving.git
git clone -b r1.7 https://github.com/tensorflow/tensorflow.git

### 3. build gRPC modules ###
mkdir -p pkg

PROTOC_OPTS='-I tensorflow -I serving --go_out=plugins=grpc:pkg'
eval "protoc $PROTOC_OPTS serving/tensorflow_serving/apis/*.proto"
eval "protoc $PROTOC_OPTS serving/tensorflow_serving/config/*.proto"
eval "protoc $PROTOC_OPTS serving/tensorflow_serving/util/*.proto"
eval "protoc $PROTOC_OPTS serving/tensorflow_serving/core/*.proto"
eval "protoc $PROTOC_OPTS serving/tensorflow_serving/sources/storage_path/*.proto"
eval "protoc $PROTOC_OPTS tensorflow/tensorflow/core/framework/*.proto"
eval "protoc $PROTOC_OPTS tensorflow/tensorflow/core/example/*.proto"
eval "protoc $PROTOC_OPTS tensorflow/tensorflow/core/lib/core/*.proto"
eval "protoc $PROTOC_OPTS tensorflow/tensorflow/core/protobuf/{saver,meta_graph}.proto"

cd pkg/tensorflow
go mod init "tensorflow"
go mod tidy
cd ../..
cd pkg/tensorflow_serving
go mod init "tensorflow_serving"
go mod edit -replace="tensorflow"="../tensorflow"
go mod tidy
cd ../..

### 4. clean up ###
rm -rf serving
rm -rf tensorflow
