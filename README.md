# shakahl/helm-charts

[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE) [![Release Charts](https://github.com/shakahl/helm-charts/workflows/Release%20Charts/badge.svg?branch=master)](https://github.com/shakahl/helm-charts/actions) [![Slack Status](https://img.shields.io/badge/slack-join_chat-white.svg?logo=slack&style=social)](https://shakahl.slack.com)

> Personal Helm Charts Repository of a lazy cloud infrastructure engineer. 

Online documentation: [shakahl.github.io/helm-charts](https://shakahl.github.io/helm-charts/)

## Usage

1. Install [Helm](https://helm.sh). For more information, see [Helm documentation](https://helm.sh/docs/).

2. Add the **shakahl** Helm repository:

```console
helm repo add stable https://charts.helm.sh/stable/
helm repo add shakahl https://shakahl.github.io/helm-charts/
```

3. View Helm charts in this repository:

```console
helm search repo shakahl
```

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

## Manual Release

I set up GitHub Pages to point to the `docs` folder. From there, I can
create and publish docs like this:

```console
$ helm create mychart
$ helm package mychart
$ mv mychart-0.1.0.tgz docs
$ helm repo index docs --url https://shakahl.github.io/helm-charts/
$ git add -i
$ git commit -av
$ git push origin master
```

From there, I can do a `helm repo add shakahl https://shakahl.github.io/helm-charts/`.

## License

[MIT License](./LICENSE.md)

Check out [shakahl.com](https://shakahl.com) for contact information.
