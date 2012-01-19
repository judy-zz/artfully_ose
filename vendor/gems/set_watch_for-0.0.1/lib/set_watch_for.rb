def set_watch_for(*attr_names)
  
  if attr_names[1][:local_to].eql? :self
    time_zone_method = "time_zone"
  else
    time_zone_method = "self.#{attr_names[1][:local_to]}.time_zone" 
  end

  method_suffix = attr_names[1][:local_to]
  method_suffix = attr_names[1][:as] unless attr_names[1][:as].blank?

  class_eval(<<-EOS, __FILE__, __LINE__)
    def #{attr_names[0]}_local_to_#{method_suffix}
      #{attr_names[0]}.in_time_zone(#{time_zone_method})
    end
  EOS
end