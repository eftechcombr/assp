# templates/helpers.tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "assp.name" -}}
{{- default .Chart.Name "assp" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "assp.fullname" -}}
{{- if and .Values.name (not (contains .Values.name .Release.Name)) -}}
{{- printf "%s-%s" .Release.Name .Values.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart labels for Kubernetes objects
*/}}
{{- define "assp.labels" -}}
helm.sh/chart: {{ include "assp.chart" . }}
{{ include "assp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "assp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "assp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the chart.
*/}}
{{- define "assp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
