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

  def self.all_responders(type)
    capacity = 0

    Object.const_get(type).all.each do |type|
      capacity += type.capacity
    end

    capacity
  end

  def self.available_responders(type)
    capacity = 0

    Object.const_get(type).where(emergency_code: nil).each do |type|
      capacity += type.capacity
    end

    capacity
  end

  def self.on_duty_responders(type)
    capacity = 0

    Object.const_get(type).where(on_duty: true).each do |type|
        capacity += type.capacity
    end

    capacity
  end

  def self.available_and_on_duty_responders(type)
    capacity = self.available_responders(type) + self.on_duty_responders(type)
  end

  def self.dispatch(type, severity, emergency)
    severity = severity

    available_responders = Object.const_get(type).where(emergency_code: nil).where(on_duty: true).order(capacity: :desc)
    
    while severity - available_responders.first.capacity > 0
      available_responders.first.emergency_code = emergency

      available_responders.shift
    end
  end

  private

  def default_on_duty
    self.on_duty ||= false
    true
  end
end
