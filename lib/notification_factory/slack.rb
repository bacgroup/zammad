class NotificationFactory::Slack

=begin

  result = NotificationFactory::Slack.template(
    template: 'ticket_update',
    locale: 'en-us',
    objects:  {
      recipient: User.find(2),
      ticket: Ticket.find(1)
    },
  )

returns

  {
    subject: 'some subject',
    body: 'some body',
  }

=end

  def self.template(data)

    if data[:templateInline]
      return NotificationFactory::Template.new(data[:objects], data[:locale], data[:templateInline]).render
    end

    template = NotificationFactory.template_read(
      locale: data[:locale] || 'en',
      template: data[:template],
      format: 'md',
      type: 'slack',
    )

    message_subject = NotificationFactory::Template.new(data[:objects], data[:locale], template[:subject]).render
    message_body = NotificationFactory::Template.new(data[:objects], data[:locale], template[:body]).render

    if !data[:raw]
      application_template = NotificationFactory.application_template_read(
        format: 'md',
        type: 'slack',
      )
      data[:objects][:message] = message_body
      data[:objects][:standalone] = data[:standalone]
      message_body = NotificationFactory::Template.new(data[:objects], data[:locale], application_template).render
    end
    {
      subject: message_subject.strip!,
      body: message_body.strip!,
    }
  end

end