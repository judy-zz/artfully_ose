class Slicer

  #
  # Pass an array of things and an array of blocks to operate on those things
  # The block should yeild a hasmap where keys are names and values are the array of things that apply, such as
  # { :general_admission => things, :vip => things }
  #

  cattr_accessor :color
  @@color = 0x1D1547

  def self.html_color(hex)
    "#%06x" % hex
  end

  def self.darker
    @@color = @@color - 0x111111
  end

  def self.lighter
    @@color = @@color + 0x111111
  end

  def self.slice(root_slice, things, blocks, current_depth)
    slices ||= []

    if root_slice.nil?
      root_slice = Slice.new("root")
    end
    root_slice.children ||= []

    unless blocks.length == current_depth
      map = blocks[current_depth].call(things)
      Array.wrap(map.keys).each do |kee|
        current_slice = Slice.new(kee)
        puts "#{"*" * current_depth}#{kee} #{blocks.length} #{current_depth}"
        if(blocks.length == current_depth+1)
          current_slice.color = html_color(@@color)
          lighter
          current_slice.value = map[kee].length
        end
        root_slice.children << slice(current_slice, map[kee], blocks, current_depth+1)
      end
    end
    root_slice.children = nil if root_slice.children.empty?
    root_slice
  end
end