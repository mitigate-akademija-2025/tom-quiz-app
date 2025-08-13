# app/services/llm_client.rb
require 'net/http'
require 'json'

class LlmClient
  def generate(prompt)
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
end