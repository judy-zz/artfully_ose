class Slicer

  #
  # Pass an array of things and an array of blocks to operate on those things
  # The block should yeild a hasmap where keys are names and values are the array of things that apply, such as
  # { :general_admission => things, :vip => things }
  #  
  # Blocks (for now) look like [["A", "B"], ["1", "2"], ["XX", "YY"]] simulating an array of arrays of keys
  #

  def self.slice(root_slice, things, blocks, current_depth)
    slices ||= []

    if root_slice.nil?
      root_slice = Slice.new("root")
    end
    root_slice.children ||= []

    unless blocks.length == current_depth
      puts "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  CALLING"
      map = blocks[current_depth].call(things)
      puts "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  DONE"
      Array.wrap(map.keys).each do |kee|
        current_slice = Slice.new(kee)
        puts "#{"*" * current_depth}#{kee} #{blocks.length} #{current_depth}"
        if(blocks.length == current_depth+1)
          current_slice.color = "#33DDFF"
          current_slice.value = map[kee].length
        end
        root_slice.children << slice(current_slice, map[kee], blocks, current_depth+1)
      end
    end
    root_slice.children = nil if root_slice.children.empty?
    root_slice
  end
end