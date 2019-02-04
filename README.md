# docker-image-certmerge-operator

This is Docker image build of certmerge-operator
(https://github.com/prune998/certmerge-operator). Certmerge-operator is a
Kubernetes Operator that can merge many TLS secrets inside one Opaque secrets.
This is required for using Istio Gateway with more than one TLS certificate.

## Building

### Master

On push/merge to master, CI will automatically build and push
`gpii/certmerge-operator:latest` image.

### Tags

Create and push git tag and CI will build and publish corresponding`
`gpii/certmerge-operator:${git_tag}` docker image.

#### Tag format

Tags should follow actual certmerge-operator version, suffixed by
`-gpii.${gpii_build_number}`, where `gpii_build_number` is monotonically
increasing number denoting Docker image build number,  starting from `0`
for each upstream version.

Example:
```
0.0.3-gpii.0
0.0.3-gpii.1
...
0.0.4-gpii.0
```

### Manually

Run `make` to see all available steps.

- `make build` to build image as latest
- `make push` to push this image to registry
