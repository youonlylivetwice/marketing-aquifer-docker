# marketing-aquifer-docker
Docker image that can run the application defined in the marketing-aquifer codebase. This image is used in marketing-aquifer's CircleCI builds. It is deployed, at it's latest version, to the Docker Hub, and can be found [here](https://hub.docker.com/r/forcepointweb/marketing-aquifer-docker/).

## Development

### Requirements
 - Docker (latest stable version).

### Build
To build a new version of this docker container, run the following in this repository's root directory:
```bash
docker build -t forcepointweb/marketing-aquifer-docker .
```

### Deployment
Successfully built images can be deployed to the Docker hub very easily.

 - Log into Docker with an account that can publish images to marketing-aquifer's org: `docker login`.
 - Run this command: `docker push forcepointweb/marketing-aquifer-docker`.

### CircleCI
This image can be used by CircleCI. Simply tell CircleCI in your `.circleci/config.yml` file that it should use this docker image instead of the standard one...

```yml
defaults: &defaults
  docker:
    - image: forcepointweb/marketing-aquifer-docker:latest
      environment:
        DATE_TIMEZONE: America/Chicago
        TERM: xterm
        NODE_VERSION: 8.0.0
        NPM_VERSION: 5.0.0
  build:
    <<: *defaults
    steps:
      - checkout
...
```
