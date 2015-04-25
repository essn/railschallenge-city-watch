# == Schema Information
#
# Table name: emergencies
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  resolved_at      :datetime
#  code             :string
#  police_severity  :integer
#  medical_severity :integer
#  fire_severity    :integer
#

class Emergency < ActiveRecord::Base
  validates :fire_severity, :police_severity, :medical_severity, :code, presence: true
  validates :fire_severity, :police_severity, :medical_severity, numericality: { greater_than_or_equal_to: 0 }
  validates :code, uniqueness: true

  has_many :responders, :primary_key => "code", :foreign_key => "emergency_code"

  after_create :dispatch

  def dispatch
    dispatcher = Dispatcher.new(self)

    unless dispatcher.no_severity?
      dispatcher.responders("Fire") unless self.fire_severity.zero?
      dispatcher.responders("Police") unless self.police_severity.zero?
      dispatcher.responders("Police" unless self.medical_severity.zero?
    end
  end
end