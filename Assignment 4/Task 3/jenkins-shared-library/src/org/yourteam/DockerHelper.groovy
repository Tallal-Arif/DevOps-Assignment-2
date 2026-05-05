package org.yourteam

class DockerHelper implements Serializable {
    def script

    DockerHelper(script) {
        this.script = script
    }

    def buildImage(String name, String tag) {
        script.echo "Building docker image ${name}:${tag}"
        script.sh "docker build -t ${name}:${tag} ."
    }

    def pushImage(String name, String tag) {
        script.echo "Pushing docker image ${name}:${tag}"
        script.sh "docker push ${name}:${tag}"
    }
}
