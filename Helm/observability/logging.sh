#!/bin/bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki grafana/loki-distributed -n observability
helm install promtail grafana/promtail -n observability -f promtail-config.yaml