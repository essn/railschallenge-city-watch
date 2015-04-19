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

class ResponderSerializer < ActiveModel::Serializer
  attributes :emergency_code, :type, :name, :capacity, :on_duty
end
