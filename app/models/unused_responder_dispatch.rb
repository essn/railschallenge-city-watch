def self.dispatch(type, severity, emergency_code)
    severity = severity.to_i

    if severity != 0
      available_responders_desc = Object.const_get(type).where(emergency_code: nil).where(on_duty: true).order(capacity: :desc)
      # available_responders_asc = Object.const_get(type).where(emergency_code: nil).where(on_duty: true).order(capacity: :asc)
      # .all should turn the relation into an array so I can use the array methods later, otherwise none of this works.........
      severity_to_modify = severity
 
      available_responders_capacities = available_responders_desc.map(&:capacity)

      if severity <= available_responders_desc[-1].capacity
        i = -1

        while severity_to_modify >= available_responders_desc[i].capacity
          available_responders_desc[i].update_attributes(emergency_code: emergency_code)
          severity_to_modify -= available_responders_desc[i].capacity
          i -= 1
        end

      elsif severity <= available_responders_desc[0].capacity
        i = 0

        while severity_to_modify >= available_responders_desc[i].capacity
          available_responders_desc[i].update_attributes(emergency_code: emergency_code)
          severity_to_modify -= available_responders_desc[i].capacity
          i += 1
        end

        i = 0

        while severity_to_modify - available_responders_desc[i].capacity > 0
          available_responders_desc[i].update_attributes(emergency_code: emergency_code)
          severity_to_modify -= available_responders_desc[i].capacity
          i += 1
        end

      else
        available_responders_desc.each do |resp|
          resp.update_attributes(emergency_code: emergency_code)
        end

      end
    end