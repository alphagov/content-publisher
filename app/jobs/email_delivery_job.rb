class EmailDeliveryJob < ActionMailer::MailDeliveryJob
  # retry at 3s, 18s, 83s, 258s, 627s
  retry_on(Notifications::Client::RequestError,
           wait: :polynomially_longer,
           attempts: 5)
end
