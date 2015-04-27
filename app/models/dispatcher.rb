class Dispatcher
  def initialize(emergency)
    @emergency = emergency
    @responders_collection = {
      'Fire' => Fire.where(on_duty: true).where(emergency_code: nil),
      'Police' => Police.where(on_duty: true).where(emergency_code: nil),
      'Medical' => Medical.where(on_duty: true).where(emergency_code: nil)
    }
    @severity_collection = {
      'Fire' => @emergency.fire_severity,
      'Police' => @emergency.police_severity,
      'Medical' => @emergency.medical_severity
    }
    @total_capacity = 0
    @total_severity = 0
  end

  def no_severity?
    @severity_collection.values.reduce(:+) <= 0
  end

  def all_responders?
    (@emergency.fire_severity > @responders_collection.values_at('Fire')[0].sum(:capacity) &&
      @emergency.medical_severity > @responders_collection.values_at('Medical')[0].sum(:capacity) &&
      @emergency.police_severity > @responders_collection.values_at('Police')[0].sum(:capacity))
  end

  def responders(type)
    responders = @responders_collection.values_at(type)[0].order(capacity: :desc)
    severity = @severity_collection.values_at(type)[0]
    @total_severity += severity
    @total_capacity += responders.sum(:capacity)

    if responders.where(capacity: severity).exists?
      responders.find_by(capacity: severity).update_attributes(emergency_code: @emergency.code)
    else
      sum = 0
      responders.each do |responder|
        next if responder.capacity + sum > severity
        sum += responder.capacity
        responder.update_attributes(emergency_code: @emergency.code)
        break if sum >= severity
      end
    end
  end

  def full_response?
    all_responders? ? false : @total_capacity >= @total_severity
  end
end
