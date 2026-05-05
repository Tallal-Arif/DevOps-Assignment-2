import org.yourteam.DockerHelper

def call(Map config) {
    if (!config.imageName) {
        error("buildAndPushImage: 'imageName' parameter is required")
    }
    if (!config.tags || config.tags.isEmpty()) {
        error("buildAndPushImage: 'tags' parameter (List) is required and cannot be empty")
    }

    def dockerHelper = new DockerHelper(this)

    // Build the image with the first tag
    def primaryTag = config.tags[0]
    dockerHelper.buildImage(config.imageName, primaryTag)

    // Tag and push all tags
    for (String tag : config.tags) {
        if (tag != primaryTag) {
            sh "docker tag ${config.imageName}:${primaryTag} ${config.imageName}:${tag}"
        }
        dockerHelper.pushImage(config.imageName, tag)
    }
}
