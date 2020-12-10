{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hasura-graphql-engine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hasura-graphql-engine.fullname" -}}
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
{{- define "hasura-graphql-engine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "hasura-graphql-engine.labels" -}}
helm.sh/chart: {{ include "hasura-graphql-engine.chart" . }}
{{ include "hasura-graphql-engine.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "hasura-graphql-engine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hasura-graphql-engine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "hasura-graphql-engine.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "hasura-graphql-engine.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trimSuffix "-app" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "appname" -}}
{{- $releaseName := default .Release.Name .Values.releaseOverride -}}
{{- printf "%s" $releaseName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "imagename" -}}
{{- if eq .Values.image.tag "" -}}
{{- .Values.image.repository -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}
{{- end -}}

{{- define "imagenameCliMigrationsV2" -}}
{{- if eq .Values.image.tag "" -}}
{{- printf "%s.cli-migrations-v2" .Values.image.repository -}}
{{- else -}}
{{- printf "%s:%s.cli-migrations-v2" .Values.image.repository .Values.image.tag -}}
{{- end -}}
{{- end -}}

{{- define "trackableappname" -}}
{{- $trackableName := printf "%s-%s" (include "appname" .) .Values.application.track -}}
{{- $trackableName | trimSuffix "-stable" | trunc 63 | trimSuffix "-" -}}
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


{{/*
Get a hostname from URL
*/}}
{{- define "hostname" -}}
{{- . | trimPrefix "http://" |  trimPrefix "https://" | trimSuffix "/" | quote -}}
{{- end -}}

{{/*
Get SecRule's arguments with unescaped single&double quotes
*/}}
{{- define "secrule" -}}
{{- $operator := .operator | quote | replace "\"" "\\\"" | replace "'" "\\'" -}}
{{- $action := .action | quote | replace "\"" "\\\"" | replace "'" "\\'" -}}
{{- printf "SecRule %s %s %s" .variable $operator $action -}}
{{- end -}}

{{/*
Formats environment variable name
*/}}
{{- define "prefixenv" -}}
{{- "HASURA_GRAPHQL_" | upper -}}{{- . | upper }}
{{- end -}}
