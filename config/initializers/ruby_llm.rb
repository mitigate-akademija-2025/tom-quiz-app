RubyLLM.configure do |config|
  # Demo/free user keys from credentials
  demo_keys = Rails.application.credentials.llm_api_keys || {}

  config.openai_api_key = demo_keys[:openai]
  config.gemini_api_key = demo_keys[:gemini]
  # config.anthropic_api_key = demo_keys[:anthropic]

  # Use Rails logger
  config.logger = Rails.logger

  # Environment-specific settings
  config.request_timeout = Rails.env.production? ? 120 : 30
  config.log_level = Rails.env.production? ? :info : :debug
end
