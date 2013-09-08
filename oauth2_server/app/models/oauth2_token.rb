class Oauth2Token < ActiveRecord::Base
  cattr_accessor :default_lifetime
  self.default_lifetime = 1.minute

  belongs_to :user
  belongs_to :client,
             class_name: "Site::Client",
             foreign_key: :site_id

  validates :client, :expires_at, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :setup, on: :create

  scope :valid, lambda {
    where('expires_at >= ?', Time.now.utc)
  }

  def expires_in
    (expires_at - Time.now.utc).to_i
  end

  def expire!
    update_attribute(:expires_at, Time.now.utc) || raise(ActiveRecord::RecordInvalid)
  end

  protected

  def setup
    self.token = SecureRandom.urlsafe_base64(64)
    self.expires_at ||= default_lifetime.from_now
  end
end
