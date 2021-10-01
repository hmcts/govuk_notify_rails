module GovukNotifyRails
  class Mailer < ActionMailer::Base
    default delivery_method: :govuk_notify

    attr_accessor :govuk_notify_template
    attr_accessor :govuk_notify_reference
    attr_accessor :govuk_notify_personalisation
    attr_accessor :govuk_notify_email_reply_to
    attr_accessor :govuk_notify_template_name

    protected

    def mail(headers = {})
      find_template if govuk_notify_template_name
      raise ArgumentError, 'Missing template ID. Make sure to use `set_template` before calling `mail`' if govuk_notify_template.nil?

      headers[:body] ||= _default_body

      message = super(headers)
      message.govuk_notify_template = govuk_notify_template
      message.govuk_notify_reference = govuk_notify_reference
      message.govuk_notify_personalisation = govuk_notify_personalisation
      message.govuk_notify_email_reply_to = govuk_notify_email_reply_to
    end

    def set_template(template)
      self.govuk_notify_template = template
    end

    def set_template_name(template_name)
      self.govuk_notify_template_name = template_name
    end

    def set_reference(reference)
      self.govuk_notify_reference = reference
    end

    def set_personalisation(personalisation)
      self.govuk_notify_personalisation = personalisation
    end

    def set_email_reply_to(address)
      self.govuk_notify_email_reply_to = address
    end

    def _default_body
      'This is a GOV.UK Notify email with template %s and personalisation: %s' % [govuk_notify_template, govuk_notify_personalisation]
    end

    private

    def client
      @client ||= ::Notifications::Client.new(govuk_notify_settings[:api_key], govuk_notify_settings[:base_url])
    end

    def find_template_id(name)
      templates_collection = client.get_all_templates(type: :email)
      template = templates_collection.collection.detect do |t|
        t.name == name
      end
      raise "No template for reference: #{template_reference}" unless template.present?
  
      template.id
    end

    def find_template
      set_template find_template_id(govuk_notify_template_name)
    end
  end
end
