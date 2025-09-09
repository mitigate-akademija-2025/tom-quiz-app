# app/models/llm_api_usage.rb
class LlmApiUsage < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :expires_at, presence: true

  # Check if user can use free LLM API today
  def self.can_use?(email)
    !exists?(email: email, expires_at: Time.current..)
  end

  # Record usage and set 24-hour expiration (update existing or create new)
  def self.record_usage!(email)
    usage = find_or_initialize_by(email: email)
    usage.expires_at = 24.hours.from_now
    usage.save!
    usage
  end

  # Get remaining time until user can use API again
  def self.time_until_available(email)
    usage = find_by(email: email, expires_at: Time.current..)
    return 0 if usage.nil?

    (usage.expires_at - Time.current).to_i
  end

  # Admin helpers - simplified for single record per user
  def self.usage_stats
    {
      total_users_with_limits: where(expires_at: Time.current..).count,
      total_users_ever: count
    }
  end
end
