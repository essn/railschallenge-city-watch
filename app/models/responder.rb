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

  def self.dispatch(type, severity, emergency_code)
    if severity != 0
      available_responders_desc = Object.const_get(type).where(emergency_code: nil).where(on_duty: true).all.order(capacity: :desc)
      available_responders_asec = Object.const_get(type).where(emergency_code: nil).where(on_duty: true).all.order(capacity: :asec)
      # .all should turn the relation into an array so I can use the array methods later, otherwise none of this works.........
      severity_to_modify = severity

      if severity > available_responders.inject{ |sum,x| sum + x } # Sum of available responders capacities

        available_responders.each do |resp|
          resp.emergency_code = emergency_code
        end

      elsif severity >= available_responders_desc[0].capacity
        i = 0

        while severity_to_modify >= available_responders_desc[i].capacity
          available_responders_desc[i].emergency_code = emergency_code
          severity_to_modify -= available_responders_desc[i].capacity
          i++
        end

        available_responders.reverse

        i = 0

        while severity_to_modify - available_responders[i].capacity > 0
          available_responders[i] = emergency_code
          severity_to_modify -= available_responders[i].capacity
          i++
        end
      end

    elsif severity =< available_responders_asec[0].capacity
      i = 0

      while severity_to_modify >= available_responders_asec[i].capacity
        available_responders_asec[i].emergency_code = emergency_code
        severity_to_modify -= available_responders_asec[i].capacity
        i++
      end
    end
  end

  private

  def default_on_duty
    self.on_duty ||= false
    true
  end
end
