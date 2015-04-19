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

class Medical < Responder
end
