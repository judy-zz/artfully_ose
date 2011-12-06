def set_watch_for(*attr_names)
  class_eval(<<-EOS, __FILE__, __LINE__)
    def #{attr_names[0]}_local_to_#{attr_names[1][:local_to]}
      time_zoned_class = self.#{attr_names[1][:local_to]}
      #{attr_names[0]}.in_time_zone(time_zoned_class.time_zone)
    end
  EOS
end