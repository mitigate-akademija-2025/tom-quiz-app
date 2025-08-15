class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  encrypts :openai_api_key
  encrypts :gemini_api_key
  
  has_many :quizzes
  
  def has_api_key?
    openai_api_key.present? || gemini_api_key.present?
  end

end
