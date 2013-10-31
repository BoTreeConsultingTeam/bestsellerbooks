Recaptcha.configure do |config|
  config.public_key  = Settings.security.recaptcha.public_key
  config.private_key = Settings.security.recaptcha.private_key
end