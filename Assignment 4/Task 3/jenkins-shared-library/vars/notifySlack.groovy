import org.yourteam.NotificationService

def call(Map config) {
    if (!config.message) {
        error("notifySlack: 'message' parameter is required")
    }
    if (!config.webhookUrl) {
        error("notifySlack: 'webhookUrl' parameter is required")
    }

    def notifier = new NotificationService(this)
    notifier.sendSlack(config.message, config.webhookUrl)
}
