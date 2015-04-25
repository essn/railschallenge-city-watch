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

  belongs_to :emergency, :primary_key => "code", :foreign_key => "emergency_code"

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

  private

  def default_on_duty
    self.on_duty ||= false
    true
  end
end
