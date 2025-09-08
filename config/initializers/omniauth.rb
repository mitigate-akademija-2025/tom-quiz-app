begin
  github_creds = Rails.application.credentials.github
rescue => e
  warn "WARN: Could not load GitHub credentials. Error: #{e.message}"
  github_creds = nil
end

begin
  google_creds = Rails.application.credentials.google_oauth2
rescue => e
  warn "WARN: Could not load Google credentials. Error: #{e.message}"
  google_creds = nil
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  if github_creds&.key?(:client_id) && github_creds&.key?(:client_secret)
    provider :github, github_creds[:client_id], github_creds[:client_secret]
  else
    warn "WARN: GitHub OmniAuth provider is not configured."
  end

  if google_creds&.key?(:client_id) && google_creds&.key?(:client_secret)
    provider :google_oauth2, google_creds[:client_id], google_creds[:client_secret]
  else
    warn "WARN: Google OAuth2 provider is not configured."
  end
end
