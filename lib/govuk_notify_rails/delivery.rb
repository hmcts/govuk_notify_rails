module GovukNotifyRails
  class Delivery
    attr_accessor :settings

    def initialize(settings)
      self.settings = settings
    end

    def deliver!(message)
      response = notify_client.send_email(
        payload_for(message)
      )
      message.govuk_notify_response = response
    end

    private

    def api_key
      settings[:api_key]
    end

    def base_url
      settings[:base_url]
    end

    def payload_for(message)
      {
        email_address: message.to.first,
        template_id: message.govuk_notify_template,
        reference: message.govuk_notify_reference,
        personalisation: message.govuk_notify_personalisation,
        email_reply_to_id: message.govuk_notify_email_reply_to
      }.compact
    end

    def notify_client
      @notify_client ||= Notifications::Client.new(api_key, base_url)
    end
  end
end
