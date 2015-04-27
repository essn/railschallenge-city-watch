# == Schema Information
#
# Table name: responders
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  type           :string
#  emergency_code :integer
#  name           :string
#  capacity       :integer
#  on_duty        :boolean
#

class Responder < ActiveRecord::Base
  validates :name, :type, :capacity, presence: true
  validates :name, uniqueness: true
  validates :capacity, inclusion: { in: (1..5) }

  before_save :default_on_duty

  belongs_to :emergency, primary_key: 'code', foreign_key: 'emergency_code'

  def self.all_responders(type)
    type.constantize.all.sum(:capacity)
  end

  def self.available_responders(type)
    type.constantize.where(emergency_code: nil).sum(:capacity)
  end

  def self.on_duty_responders(type)
    type.constantize.where(on_duty: true).sum(:capacity)
  end

  def self.available_on_duty_responders
    where(emergency: nil, on_duty: true).sum(:capacity)
  end

  def self.responders(type)
    [
      all_responders(type),
      available_responders(type),
      on_duty_responders(type),
      available_on_duty_responders
    ]
  end

  private

  def default_on_duty
    self.on_duty ||= false
    true
  end
end
