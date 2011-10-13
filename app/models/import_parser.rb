class ImportParser

  include Enumerable

  def initialize(csv_data, klass = nil)
    @lines = csv_data.split(/\r*\n\r*/)
    @header_line = @lines.shift
    @klass = klass
  end

  def headers
    @headers = process_line(@header_line)
    error "No header line was found in the CSV document." unless @header_line
    return @headers
  end

  def each
    row = [""]
    @lines.each do |line|
      row = process_line(line, row)
      if !@inside_string
        if @klass
          yield @klass.new(headers, row)
        else
          yield row
        end
        row = [""]
      end
    end

    return self
  end

  protected

  def error(msg)
    raise ImportParserException, msg
  end

  def process_line(line, row = [""])
    row.last << "\n" if @inside_string

    i = 0

    while i < line.length
      one = line[i, 1]
      two = line[i, 2]

      if @inside_string && (two == '""' || two == '\"')
        row.last << '"'
        i += 1
      elsif one == '"'
        @inside_string = !@inside_string
      elsif @inside_string
        row.last << one
      elsif one == ','
        row << ""
      else
        row.last << one
      end

      i += 1
    end

    return row
  end

end

class ImportParserException < Exception; end
