def set_watch_for(*attr_names)
  class_eval(<<-EOS, __FILE__, __LINE__)
    def #{attr_names[0]}_local_to_#{attr_names[1][:local_to]}
      org = self.#{attr_names[1][:local_to]}
      puts org.time_zone
    end
  EOS
end