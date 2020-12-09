# Hasura GraphQL Engine Helm chart

The [Hasura GraphQL engine](https://github.com/hasura/graphql-engine) makes your data instantly accessible over a real-time GraphQL API, so you can build and ship modern apps and APIs faster. Hasura connects to your databases, REST servers, GraphQL servers, and third party APIs to provide a unified realtime GraphQL API across all your data sources.

The Hasura GraphQL Engine Helm chart uses the [Helm](https://helm.sh) package manager to bootstrap a Deployment and Service on a [Kubernetes](http://kubernetes.io) cluster.

## Resources

- [hasura.io](https://hasura.io/) official website
- [github.com/hasura/graphql-engine](https://github.com/hasura/graphql-engine) **GitHub** repository
- [hasura/graphql-engine](https://hub.docker.com/r/hasura/graphql-engine) at **Docker HUB**


## Prerequisites

- Helm v2 or later
- Kubernetes 1.4+
- PostgreSQL database (11+)

## Install the chart

1. Add the Helm repository:

   ```bash
   helm repo add shakahl https://shakahl.github.io/helm-charts/
   ```

2. Run the following command, providing a name for your release:

   ```bash
   helm upgrade --install my-release shakahl/hasura-graphql-engine
   ```

   > **Tip**: `--install` can be shortened to `-i`.

   This command deploys **Hasura GraphQL Engine** on the Kubernetes cluster using the default configuration. To find parameters you can configure during installation, see [Configure the chart](#configure-the-chart).

   > **Tip**: To view all Helm chart releases, run `helm list`.

## Uninstall the chart

To uninstall the `my-release` deployment, use the following command:

```bash
helm uninstall my-release
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

## Configure the chart

The following table lists configurable parameters, their descriptions, and their default values stored in `values.yaml`.

| Parameter                          | Description                                                                                                                                       | Default                                                 |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| image.repository                   | Image repository url                                                                                                                              | hasura/graphql-engine                                   |
| image.tag                          | Image tag                                                                                                                                         | v1.3.3                                                  |
| image.pullPolicy                   | Image pull policy                                                                                                                                 | IfNotPresent                                            |
| image.pullSecrets                  | It will store the repository's credentials to pull image                                                                                          | []                                                      |
| fullnameOverride                   |                                                                                                                                                   | “”                                                      |
| deploymentApiVersion               |                                                                                                                                                   | app/v1                                                  |
| application.track                  |                                                                                                                                                   | stable                                                  |
| application.tier                   |                                                                                                                                                   | web                                                     |
| application.migrateCommand         |                                                                                                                                                   | `hasura migrate apply`                                  |
| application.initializeCommand      |                                                                                                                                                   | `hasura seeds apply`                                    |
| application.secretName             |                                                                                                                                                   | nil                                                     |
| application.secretChecksum         |                                                                                                                                                   | nil                                                     |
| serviceAccount.create              | It will create service account                                                                                                                    | true                                                    |
| serviceAccount.name                | Service account name                                                                                                                              | nil                                                     |
| serviceAccount.annotations         | Service account annotations                                                                                                                       | {}                                                      |
| podSecurityContext                 |                                                                                                                                                   | {}                                                      |
| livenessProbe                      | Health check for pod                                                                                                                              | {}                                                      |
| readinessProbe                     | Health check for pod                                                                                                                              | {}                                                      |
| startupProbe                       | Health check for pod                                                                                                                              | {}                                                      |
| service.enabled                    |                                                                                                                                                   | true                                                    |
| service.type                       | Kubernetes service type                                                                                                                           | ClusterIP                                               |
| service.port                       |                                                                                                                                                   | 5000                                                    |
| service.internalPort               |                                                                                                                                                   | 8080                                                    |
| service.name                       |                                                                                                                                                   | http                                                    |
| service.protocol                   |                                                                                                                                                   | TCP                                                     |
| service.annotations                |                                                                                                                                                   | {}                                                      |
| service.url                        |                                                                                                                                                   | http://hasura.my.host.com/                              |
| service.additionalHosts            |                                                                                                                                                   | nil                                                     |
| service.commonName                 |                                                                                                                                                   | nil                                                     |
| podAnnotations                     | Annotations for pod                                                                                                                               | {}                                                      |
| podLabels                          | Labels for pod                                                                                                                                    | {}                                                      |
| ingress.enabled                    | Boolean flag to enable or disable ingress                                                                                                         | false                                                   |
| ingress.annotations                |                                                                                                                                                   | {}                                                      |
| ingress.hosts                      |                                                                                                                                                   | `- host: hasura-graphql-engine.local`<br />`-paths: []` |
| ingress.tls                        | Boolean to enable or disable tls for ingress. If enabled provide a secret in `ingress.tls.secretName` containing TLS private key and certificate. | []                                                      |
| ingress.tls[0].secretName          | Kubernetes secret containing TLS private key and certificate. It is `only` required if `ingress.tls` is enabled.                                  | nil                                                     |
| ingress.tls[0].hosts               | Array of hostnames for the ingress                                                                                                                | nil                                                     |
| ingress.modSecurity.enabled        |                                                                                                                                                   | false                                                   |
| ingress.modSecurity.secRuleEngine  |                                                                                                                                                   | DetectionOnly                                           |
| prometheus.metrics                 |                                                                                                                                                   | false                                                   |
| annotations                        | ingress annotations                                                                                                                               | nil                                                     |
| schedulerName                      | Use an [alternate scheduler](https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/), e.g. "stork".                   | nil                                                     |
| nodeSelector                       | Node labels for pod assignment                                                                                                                    | {}                                                      |
| affinity                           | [Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) for pod assignment                      | {                                                       |
| tolerations                        | [Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) for pod assignment                                         | []                                                      |
| securityContext                    | [securityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for pod                                             | {}                                                      |
| strategyType                       |                                                                                                                                                   | nil                                                     |
| livenessProbe.path                 |                                                                                                                                                   | `/healthz`                                              |
| livenessProbe.initialDelaySeconds  |                                                                                                                                                   | 15                                                      |
| livenessProbe.timeoutSeconds       |                                                                                                                                                   | 15                                                      |
| readinessProbe.path                |                                                                                                                                                   | `/v1/version`                                           |
| readinessProbe.initialDelaySeconds |                                                                                                                                                   | 5                                                       |
| readinessProbe.timeoutSeconds      |                                                                                                                                                   | 3                                                       |
| hpa.enabled                        |                                                                                                                                                   | false                                                   |
| hpa.minReplicas                    |                                                                                                                                                   | 1                                                       |
| hpa.maxReplicas                    |                                                                                                                                                   | 5                                                       |
| hpa.targetCPUUtilizationPercentage |                                                                                                                                                   | 80                                                      |
| podDisruptionBudget.enabled        |                                                                                                                                                   | false                                                   |
| podDisruptionBudget.maxUnavailable |                                                                                                                                                   | 1                                                       |
| hasura.graphql.*                   |                                                                                                                                                   | {}                                                      |
| hasura.serverOptions.*             |                                                                                                                                                   | {}                                                      |
| hasura.envPrefix                   |                                                                                                                                                   | `HASURA_GRAPHQL_`                                       |
| hasura.config.*                    | See [config options](#hasura-config-options)                                                                                                      | {}                                                      |



To configure the chart, do either of the following:

- Specify each parameter using the `--set key=value[,key=value]` argument to `helm upgrade --install`. For example:

  ```bash
  helm upgrade --install my-release \
    --set ingress.tls.enabled=true,ingress.tls.secretName=my-secret \
      shakahl/hasura-graphql-engine
  ```

  This command enables ingress TLS and sets TLS secret to `my-secret`.

- Provide a YAML file that specifies the parameter values while installing the chart. For example, use the following command:

  ```bash
  helm upgrade --install my-release -f values.yaml shakahl/hasura-graphql-engine
  ```

  > **Tip**: Use the default [values.yaml](values.yaml).

For information about running **Hasura GraphQL Engine** in Docker, see the [full image documentation](https://hub.docker.com/r/hasura/graphql-engine).



### Hasura Config Options <a name="hasura-config-options"></a>

```yaml
# ...

# Hasura graphql-engine configuration
hasura:
  # graphql:  
  #   # PostgreSQL database DSN
  #   database_url: "postgres://username:password@hostname:port/dbname"
  #   # Enables the web console
  #   enable_console: "true"
  #   # Enabled log types
  #   enabled_log_types: "startup, http-log, webhook-log, websocket-log, query-log"
  #   admin:
  #     secret: ""

  serverOptions: {}
  	#- name: HASURA_GRAPHQL_ADMIN_SECRET
    #  value: "{{ .Values.hasura.graphql.admin.secret }}"

  envPrefix: "HASURA_GRAPHQL_"

  config:

    # Port on which graphql-engine should be served (default: 8080)
    SERVER_PORT: 8080

    # Host on which graphql-engine will listen (default: *)
    SERVER_HOST: "*"

    # Enable the Hasura Console (served by the server on / and /console) (default: false)
    ENABLE_CONSOLE: false
    
    # Admin secret key, required to access this instance. This is mandatory when you use webhook or JWT.
    ADMIN_SECRET: "" # !
    
    # URL of the authorization webhook required to authorize requests. See auth webhooks docs for more details.
    AUTH_HOOK: ""

    # HTTP method to use for the authorization webhook (default: GET)
    AUTH_HOOK_MODE: "GET"

    # A JSON string containing type and the JWK used for verifying (and other
    # optional details).
    # Example: {"type": "HS256", "key": "3bd561c37d214b4496d09049fadc542c"}.
    # See the JWT docs for more details.
    JWT_SECRET: ""

    # Unauthorized role, used when access-key is not sent in access-key only
    # mode or the Authorization header is absent in JWT mode.
    # Example: anonymous. Now whenever the "authorization" header is
    # absent, the request's role will default to anonymous.
    UNAUTHORIZED_ROLE: "anonymous"

    # CSV of list of domains, incuding scheme (http/https) and port, to allow for CORS. Wildcard domains are allowed. (See :ref:configure-cors)
    CORS_DOMAIN: "*"

    # Disable CORS. Do not send any CORS headers on any request.
    DISABLE_CORS: null

    # Read cookie on WebSocket initial handshake even when CORS is disabled.
    # This can be a potential security flaw! Please make sure you know what
    # you're doing. This configuration is only applicable when CORS is disabled.
    # (default: false)
    WS_READ_COOKIE: false

    # Enable anonymous telemetry (default: true)
    ENABLE_TELEMETRY: true

    # Maximum number of concurrent http workers delivering events at any time (default: 100)
    EVENTS_HTTP_POOL_SIZE: 100

    # Interval in milliseconds to sleep before trying to fetch events again after a fetch returned no events from postgres
    EVENTS_FETCH_INTERVAL: 10

    # Number of stripes (distinct sub-pools) to maintain with Postgres (default: 1).
    # New connections will be taken from a particular stripe pseudo-randomly.
    PG_STRIPES: 1

    # Maximum number of Postgres connections that can be opened per stripe (default: 50).
    # When the maximum is reached we will block until a new connection becomes available,
    # even if there is capacity in other stripes.
    PG_CONNECTIONS: 50

    # Each connection's idle time before it is closed (default: 180 sec)
    PG_TIMEOUT: "180 sec"

    # Use prepared statements for queries (default: true)
    USE_PREPARED_STATEMENTS: true

    # Transaction isolation. read-committed / repeatable-read / serializable (default: read-commited)
    TX_ISOLATION: "read-commited"

    # Stringify certain Postgres numeric types, specifically bigint, numeric, decimal and
    # double precision as they don't fit into the IEEE-754 spec for JSON encoding-decoding.
    # (default: false)
    STRINGIFY_NUMERIC_TYPES: false

    # Comma separated list of APIs (options: metadata, graphql, pgdump) to be enabled.
    # (default: metadata,graphql,pgdump)
    ENABLED_APIS: "metadata,graphql,pgdump"

    # Updated results (if any) will be sent at most once in this interval (in milliseconds) for live queries
    # which can be multiplexed. Default: 1000 (1sec)
    LIVE_QUERIES_MULTIPLEXED_REFETCH_INTERVAL: 1000

    # Multiplexed live queries are split into batches of the specified size. Default: 100
    LIVE_QUERIES_MULTIPLEXED_BATCH_SIZE: 100

    # Restrict queries allowed to be executed by the GraphQL engine to those that are part of the configured allow-list. Default: false
    ENABLE_ALLOWLIST: false

    # Set the value to /srv/console-assets for the console to load assets from the server itself
    # instead of CDN *(Available for versions > v1.0.0-beta.1)*
    #CONSOLE_ASSETS_DIR: ""
    
    # Set the enabled log types. This is a comma-separated list of log-types to
    # enable. Default: startup, http-log, webhook-log, websocket-log. See
    # :ref:log types <log-types> for more details.
    ENABLED_LOG_TYPES: "startup, http-log, webhook-log, websocket-log"

    # Set the logging level. Default: info. Options: debug, info, warn, error.
    LOG_LEVEL: "info"

    # Set dev mode for GraphQL requests; include the internal key in the errors extensions of the response (if required).
    DEV_MODE: false

    # Include the internal key in the errors extensions of the response for GraphQL requests with the admin role (if required).
    ADMIN_INTERNAL_ERRORS: false

    # cli-migrations.v2 configuration
    # -------------------------------
    
    MIGRATIONS_DIR: /hasura-migrations
    METADATA_DIR: /hasura-metadata

    # Defines a pointer to an environment variable, which holds the database url e.g.
    MIGRATIONS_DATABASE_ENV_VAR: DATABASE_URL
    MIGRATIONS_DATABASE_URL: 'postgres://postgres:postgres@localhost:5432/postgres'

    DATABASE_URL: null
    
    MIGRATIONS_SERVER_PORT: 9691

    MIGRATIONS_SERVER_TIMEOUT: 30s
    
    
```



## Upgrading

TODO

## License

[MIT License](./LICENSE.md)

Check out [github.com/shakahl/helm-charts](https://github.com/shakahl/helm-charts) for more information.

