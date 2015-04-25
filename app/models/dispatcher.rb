class Dispatcher
  def initialize(emergency)
    @emergency = emergency
    @responders_collection = { 
      "Fire" => Fire.where(on_duty: true).where(emergency_code: nil),
      "Police" => Police.where(on_duty: true).where(emergency_code: nil),
      "Medical" => Medical.where(on_duty: true).where(emergency_code: nil)
    }
    @severity_collection = {
      "Fire" => @emergency.fire_severity,
      "Police" => @emergency.police_severity,
      "Medical" => @emergency.medical_severity
    }
  end

  def no_severity?
    ( @emergency.fire_severity.zero? &&
    @emergency.medical_severity.zero? &&
    @emergency.police_severity.zero? )
  end

  def all_responders?
    ( @emergency.fire_severity > @responders_collection.values_at("Fire")[0].sum(:capacity) && 
      @emergency.medical_severity > @responders_collection.values_at("Medical")[0].sum(:capacity) &&
      @emergency.police_severity > @responders_collection..values_at("Police")[0].sum(:capacity) )
  end

  def responders(type)
    responders = @responders_collection.values_at(type)[0].order(capacity: :desc)
    severity = @severity_collection.values_at(type)[0]

    if responders.where(capacity: severity).exists?
      responders.where(capacity: severity).first.update_attributes(emergency_code: @emergency.code)
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
endƒ