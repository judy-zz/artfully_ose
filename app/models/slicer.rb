class Slicer

  #
  # Pass an array of tickets and an array of blocks to operate on those tickets
  # The block should yeild a hasmap where keys are names and values are the array of tickets that apply, such as
  # { :general_admission => tickets, :vip => tickets }
  #  
  # Blocks (for now) look like [["A", "B"], ["1", "2"], ["XX", "YY"]] simulating an array of arrays of keys
  #

  def self.slice(root_slice, tickets, blocks, current_depth)
    slices ||= []

    if root_slice.nil?
      root_slice = Slice.new("root")
    end
    root_slice.children ||= []

    unless blocks.length == current_depth
      map = blocks[current_depth].call(tickets)
      Array.wrap(map.keys).each do |kee|
        current_slice = Slice.new(kee)
        puts "#{"*" * current_depth}#{kee} #{blocks.length} #{current_depth}"
        if(blocks.length == current_depth+1)
          current_slice.color = "#33DDFF"
          current_slice.value = map[kee]
        end
        root_slice.children << slice(current_slice, tickets, blocks, current_depth+1)
      end
    end
    root_slice.children = nil if root_slice.children.empty?
    root_slice
  end
end