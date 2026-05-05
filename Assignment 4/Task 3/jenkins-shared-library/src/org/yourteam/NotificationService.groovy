package org.yourteam

class NotificationService implements Serializable {
    def script

    NotificationService(script) {
        this.script = script
    }

    def sendSlack(String message, String webhookUrl) {
        script.echo "Sending Slack notification: ${message}"
        script.sh "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"${message}\"}' ${webhookUrl}"
    }

    def sendEmail(String to, String subject, String body) {
        script.echo "Sending email to ${to} with subject '${subject}'"
        // Actual implementation would use mail step
        // script.mail to: to, subject: subject, body: body
    }
}
