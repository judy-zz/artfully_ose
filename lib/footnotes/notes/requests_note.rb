module Footnotes
  module Notes
    class RequestsNote < AbstractNote
      cattr_accessor :alert_request_time, :alert_request_number, :orm, :instance_writter => false
      @@alert_request_time    = 60.0
      @@alert_request_number = 12
      @@request_subscriber = nil
      @@orm              = [:active_resource]

      def self.start!(controller)
        self.request_subscriber.reset!
      end

      def self.request_subscriber
        @@request_subscriber ||= Footnotes::Notes::RequestSubscriber.new(self.orm)
      end

      def events
        self.class.request_subscriber.events
      end

      def title
        requests = self.events.count
        total_time = self.events.map(&:duration).sum
        request_color = generate_red_color(self.events.count, alert_request_number)
        time_color    = generate_red_color(total_time, alert_request_time)

        <<-TITLE
        <span style="background-color:#{request_color}">Requests (#{requests})</span>
        <span style="background-color:#{time_color}">Time (#{"%.3f" % total_time}ms)</span>
        TITLE
      end

      def content
        html = ''
        self.events.each_with_index do |event, index|
          sql_links = []
          sql_links << "<a href=\"javascript:Footnotes.toggle('rtrace_#{index}')\" style=\"color:#00A;\">trace</a>"

          html << <<-HTML
            <b id="qtitle_#{index}">#{escape(event.http_method.to_s.upcase)}</b>
            #{print_resource_and_time(event.payload[:request_uri], event.duration)}
            (#{sql_links.join(' | ')})<br />
            <p id="rtrace_#{index}" style="display:none;">#{parse_trace(event.trace)}</p>
          HTML
        end
        return html
      end

      protected
      def print_resource_and_time(resource, time)
        "<span style='background-color:#{generate_red_color(time, alert_ratio)}'>#{escape(resource)} (#{'%.3fms' % time})</span>"
      end

      def print_request(request)
        escape(request.to_s.gsub(/(\s)+/, ' ').gsub('`', ''))
      end

      def generate_red_color(value, alert)
        c = ((value.to_f/alert).to_i - 1) * 16
        c = 0  if c < 0; c = 15 if c > 15; c = (15-c).to_s(16)
        "#ff#{c*4}"
      end

      def alert_ratio
        alert_request_time / alert_request_number
      end

      def parse_trace(trace)
        trace.map do |t|
          s = t.split(':')
          %[<a href="#{escape(Footnotes::Filter.prefix("#{Rails.root.to_s}/#{s[0]}", s[1].to_i, 1))}">#{escape(t)}</a><br />]
        end.join
      end
    end

    class RequestSubscriberNotifactionEvent
      attr_reader :event, :trace
      delegate :name, :payload, :duration, :time, :to => :event

      def initialize(event, ctrace)
        @event, @ctrace = event, ctrace
      end

      def trace
        @trace ||= @ctrace.collect(&:strip).select{|i| i.gsub!(/^#{Rails.root.to_s}\//, '') } || []
      end

      def http_method
        @http_method ||= self.payload[:method].to_s.match(/(get|post|put|delete)/im) || 'Unknown'
      end
    end

    class RequestSubscriber < ActiveSupport::LogSubscriber
      attr_accessor :events, :ignore_regexps

      def initialize(orm)
        @events = []
        orm.each {|adapter| ActiveSupport::LogSubscriber.attach_to adapter, self}
      end

      def reset!
        self.events.clear
      end

      def request(event)
        @events << RequestSubscriberNotifactionEvent.new(event.dup, caller)
      end
    end
  end
end
