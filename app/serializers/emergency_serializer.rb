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

class EmergencySerializer < ActiveModel::Serializer
  attributes :code, :fire_severity, :police_severity, :medical_severity, :resolved_at
end
