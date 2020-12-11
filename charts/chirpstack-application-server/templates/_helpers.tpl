{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "chirpstack-application-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chirpstack-application-server.fullname" -}}
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
{{- define "chirpstack-application-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "chirpstack-application-server.labels" -}}
helm.sh/chart: {{ include "chirpstack-application-server.chart" . }}
{{ include "chirpstack-application-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "chirpstack-application-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chirpstack-application-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "chirpstack-application-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "chirpstack-application-server.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
env: {{ list .Values.config "CONFIG" | include "recurseFlattenMap2" | nindent 2 }}
*/}}
{{- define "recurseFlattenMap1" -}}
{{- $map := first . -}}
{{- $label := last . -}}
{{- $sep := "_" -}}
{{- range $key, $val := $map -}}
  {{- $sublabel := list $label $key | join $sep | upper -}}
  {{- if kindOf $val | eq "map" -}}
    {{- list $val $sublabel | include "recurseFlattenMap1" -}}
  {{- else -}}
- name: {{ $sublabel | trimPrefix $sep | quote }}
  value: {{ $val | quote }}
{{ end -}}
{{- end -}}
{{- end -}}

{{/*
env: {{ list .Values.config "CONFIG" | include "recurseFlattenMap2" | nindent 2 }}
*/}}
{{- define "recurseFlattenMap2" -}}
{{- $map := first . -}}
{{- $label := last . -}}
{{- $sep := "__" -}}
{{- range $key, $val := $map -}}
  {{- $sublabel := list $label $key | join $sep | upper -}}
  {{- if kindOf $val | eq "map" -}}
    {{- list $val $sublabel | include "recurseFlattenMap2" -}}
  {{- else -}}
- name: {{ $sublabel | trimPrefix $sep | quote }}
  value: {{ $val | quote }}
{{ end -}}
{{- end -}}
{{- end -}}

