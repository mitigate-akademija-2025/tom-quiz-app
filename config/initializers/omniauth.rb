begin
  github_creds = Rails.application.credentials.github
rescue => e
  warn "WARN: Could not load GitHub credentials. Error: #{e.message}"
  github_creds = nil
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  if github_creds&.key?(:client_id) && github_creds&.key?(:client_secret)
    provider :github, github_creds[:client_id], github_creds[:client_secret]
  else
    warn "WARN: GitHub OmniAuth provider is not configured."
  end
end
