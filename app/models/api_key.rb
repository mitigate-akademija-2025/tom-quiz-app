class ApiKey < ApplicationRecord
  encrypts :key

  # Virtual attribute for form input
  attribute :new_key, :string

  belongs_to :user
  belongs_to :key_type

  before_save :assign_key_from_new_key, if: :new_key?

  validates :key_type_id, uniqueness: {
    scope: :user_id,
    message: "already has a key of this type"
  }
  validates :new_key, presence: true, on: :create
  validates :new_key, length: { minimum: 8 }, if: :new_key?

  # Validate actual key format if needed
  validates :new_key, format: {
    with: /\A[A-Za-z0-9\-_]+\z/,
    message: "must contain only letters, numbers, hyphens, and underscores"
  }, if: :new_key?

  # Scope for finding by key type name - use includes for better performance
  scope :for_key_type, ->(type_name) {
    includes(:key_type).where(key_types: { name: type_name.to_s })
  }

  # Check if key exists (since we can't read encrypted key directly)
  def key_present?
    key.present?
  end

  def has_key?
    key_present?
  end

  # Clear the virtual attribute after save to prevent memory leaks
  after_save :clear_new_key
  after_initialize :clear_new_key, if: :persisted?

  private

  # Use Rails built-in method instead of custom one
  def new_key?
    new_key.present?
  end

  def assign_key_from_new_key
    self.key = new_key
  end

  def clear_new_key
    self.new_key = nil
  end
end
