def call(Map config) {
    if (!config.projectKey) {
        error("runSonarScan: 'projectKey' parameter is required")
    }
    
    withSonarQubeEnv('SonarQube') {
        sh """
        sonar-scanner \
          -Dsonar.projectKey=${config.projectKey} \
          -Dsonar.sources=${config.sources ?: '.'} \
          -Dsonar.host.url=${env.SONAR_HOST_URL} \
          -Dsonar.login=${env.SONAR_AUTH_TOKEN}
        """
    }
    
    timeout(time: 10, unit: 'MINUTES') {
        def qg = waitForQualityGate()
        if (qg.status != 'OK') {
            error "Pipeline aborted due to quality gate failure: ${qg.status}"
        }
    }
}
