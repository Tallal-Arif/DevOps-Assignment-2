# Jenkins Shared Library

This repository contains reusable Jenkins pipeline steps and classes.

## Global Variables (vars)

### `notifySlack`
Sends a Slack notification.
```groovy
notifySlack(message: 'Hello World', webhookUrl: 'https://hooks.slack.com/...')
```

### `buildAndPushImage`
Builds and pushes a Docker image to a registry with multiple tags.
```groovy
buildAndPushImage(imageName: 'my-app', tags: ['v1.0.0', 'latest'])
```

### `runSonarScan`
Executes a SonarQube scan and blocks the pipeline until the Quality Gate returns a result.
```groovy
runSonarScan(projectKey: 'my-project-key', sources: 'src/')
```

## Classes (src/org/yourteam)

### `NotificationService`
Helper class to send notifications via Slack and Email.

### `DockerHelper`
Helper class to build and push Docker images.
