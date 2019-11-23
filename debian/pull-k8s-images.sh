#!/bin/bash

docker pull haxqer/kube-apiserver:v1.16.3
docker pull haxqer/kube-controller-manager:v1.16.3
docker pull haxqer/kube-scheduler:v1.16.3
docker pull haxqer/kube-proxy:v1.16.3
docker pull haxqer/pause:3.1
docker pull haxqer/etcd:3.3.15-0
docker pull haxqer/coredns:1.6.2

docker tag haxqer/kube-apiserver:v1.16.3 k8s.gcr.io/kube-apiserver:v1.16.3
docker tag haxqer/kube-controller-manager:v1.16.3 k8s.gcr.io/kube-controller-manager:v1.16.3
docker tag haxqer/kube-scheduler:v1.16.3 k8s.gcr.io/kube-scheduler:v1.16.3
docker tag haxqer/kube-proxy:v1.16.3 k8s.gcr.io/kube-proxy:v1.16.3
docker tag haxqer/pause:3.1 k8s.gcr.io/pause:3.1
docker tag haxqer/etcd:3.3.15-0 k8s.gcr.io/etcd:3.3.15-0
docker tag haxqer/coredns:1.6.2 k8s.gcr.io/coredns:1.6.2



