class Slicer

  #
  # Pass an array of tickets and an array of blocks to operate on those tickets
  # The block should yeild a hasmap where keys are names and values are the values, such as
  # { :general_admission => 4, :vip => 10 }
  #  
  # Blocks (for now) look like [["A", "B"], ["1", "2"], ["XX", "YY"]] simulating an array of arrays of keys
  #

  def self.slice(root_slice, tickets, blocks, current_depth)
    slices ||= []

    if root_slice.nil?
      root_slice = Slice.new("root")
    end
    root_slice.children ||= []

    Array.wrap(blocks[current_depth]).each do |bk|
      current_slice = Slice.new(bk)
      puts "#{"*" * current_depth}#{bk}"
      root_slice.children << slice(current_slice, tickets, blocks, current_depth+1)   
    end
    root_slice
  end

  # def self.slice(root_slice, tickets, blocks, current_depth)
  #   slices ||= []
  #   Array.wrap(blocks[current_depth]).each do |bk|
  #     current_slice = Slice.new(bk)
  #     if (blocks.length == current_depth+1)
  #       current_slice.value = rand(10000)
  #       current_slice.color = "#339945"
  #     end
  #     current_slice.children = slice(current_slice, tickets, blocks, current_depth+1)   
  #     slices << current_slice 
  #   end
  #   slices
  # end

  # def self.slice(root_slice, tickets, blocks, current_depth)  
  #   root_slice ||= Slice.new

  #   if(blocks.length == current_depth+1)
  #     root_slice.children ||= []
  #     blocks[current_depth].each do |bk|
  #       puts "#{bk} setting value"
  #       root_slice.children << Slice.new(bk, "#3399ED", rand(1000))
  #     end

  #     return root_slice
  #   else
  #     Array.wrap(blocks[current_depth]).each do |bk|
  #       puts "#{bk} slicing children"
  #       root_slice.name = bk
  #       slice(root_slice, tickets, blocks, current_depth+1)
  #     end
  #   end 

  #   root_slice
  # end
end