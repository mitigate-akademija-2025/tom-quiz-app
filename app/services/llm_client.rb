require 'net/http'
require 'json'

class LlmClient
  def initialize(provider = 'openai')
    @provider = provider
  end
  
  def generate(prompt)
    case @provider
    when 'openai'
      generate_openai(prompt)
    when 'gemini'
      generate_gemini(prompt)
    else
      raise "Unknown provider: #{@provider}"
    end
  end
  
  private
  
  def generate_openai(prompt)
    uri = URI('https://api.openai.com/v1/chat/completions')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
    request['Content-Type'] = 'application/json'
    request.body = {
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.7
    }.to_json
    
    response = http.request(request)
    JSON.parse(response.body).dig('choices', 0, 'message', 'content')
  end
  
  def generate_gemini(prompt)
    api_key = ENV['GEMINI_API_KEY']
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      contents: [{
        parts: [{
          text: prompt
        }]
      }],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 2048
      }
    }.to_json
    
    response = http.request(request)
    parsed = JSON.parse(response.body)
    
    if parsed['error']
      Rails.logger.error "Gemini error: #{parsed['error']['message']}"
      return nil
    end
    
    parsed.dig('candidates', 0, 'content', 'parts', 0, 'text')
  end
end