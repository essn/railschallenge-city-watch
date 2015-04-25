class Dispatcher
  def initialize(emergency)
    @emergency = emergency
    @fire_responders = Fire.where(on_duty: true).where(emergency_code: nil)
    @police_responders = Police.where(on_duty: true).where(emergency_code: nil)
    @medical_responders = Medical.where(on_duty: true).where(emergency_code: nil)
  end

  def dispatch_responders

  end

  def no_responders?
    ( @emergency.fire_severity.zero? &&
    @emergency.medical_severity.zero? &&
    @emergency.police_severity.zero? )
  end

  def all_responders?
    ( @emergency.fire_severity > @fire_responders.sum(:capacity) && 
      @emergency.medical_severity > @medical_responders.sum(:capacity) &&
      @emergency.police_severity > @police_responders.sum(:capacity) )
  end

  def fire_responders
    capable_responders = @fire_responders.where(capacity: (severity..5)).order(capacity: :desc)
    severity_to_modify = @emergency.fire_severity

    i = 0

    while severity_to_modify >= capable_responders[i].capacity && severity_to_modify > 0
      capable_responders[i].update_attributes(emergency_code: @emergency.code)
      severity_to_modify -= severity_to_modify
      i += 1
    end
  end

  def police_responder

  end

  def medical_responder

  end
end