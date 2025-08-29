require "net/http"
require "json"

class LlmClient
  def initialize(provider = "openai", api_key: nil)
    @provider = provider
    @api_key = api_key
  end

  def generate(prompt)
    case @provider
    when "openai"
      generate_openai(prompt)
    when "gemini"
      generate_gemini(prompt)
    else
      raise "Unknown provider: #{@provider}"
    end
  end

  private

  def generate_openai(prompt)
    uri = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
      model: "gpt-4.1-mini",
      messages: [
        { role: "system", content: "You are a helpful, precise assistant." },
        { role: "user", content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 2048 # allows longer, more detailed answers
    }.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      error_response = JSON.parse(response.body)
      Rails.logger.error "OpenAI API error: #{error_response['error']['message']}"
      return nil # Return nil on API failure
    end

    JSON.parse(response.body).dig("choices", 0, "message", "content")
  end

  def generate_gemini(prompt)
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{@api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 2048 # matches OpenAI for fair comparison
      }
    }.to_json

    response = http.request(request)
    parsed = JSON.parse(response.body)

    if parsed["error"]
      Rails.logger.error "Gemini error: #{parsed['error']['message']}"
      return nil
    end

    parsed.dig("candidates", 0, "content", "parts", 0, "text")
  end
end
