{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "unifi-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "unifi-controller.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "unifi-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Compile MongoDB connection string
*/}}
{{- define "unifi-controller.mongodb-replicaset-uri" -}}
{{- $dbs := dict "dbs" (list) -}}
{{- range int (index .Values "mongodb-replicaset" "replicas") | until -}}
{{- $noop := printf "%s-mongodb-replicaset-%d.%s-mongodb-replicaset.%s.svc.cluster.local" (include "unifi-controller.fullname" $) . (include "unifi-controller.fullname" $) $.Release.Namespace | append $dbs.dbs | set $dbs "dbs" -}}
{{- end -}}
{{- printf "%s" (join "," $dbs.dbs) -}}
{{- end -}}
