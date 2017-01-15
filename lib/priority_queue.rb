# Priority queue.
class PriorityQueue
  def initialize
    # Actually, I do not know whether my heap in Ruby is faster than
    # [[1, Object], [6, Object]].min { |a, b| a[0] <=> b[0] }
    @heap = [[-1, nil]]
  end

  # Inserts an element into the queue.
  # @param priority [Numeric] priority of the element. It must be >= 0.
  # @param elem [Object] the element itself
  def []=(priority, elem)
    raise ArgumentError, 'Priority can not be < 0' if priority < 0
    index = @heap.size
    @heap << [priority, elem]
    cur_parent = parent index
    while index.nonzero? && @heap[cur_parent][0] > priority
      swap cur_parent, index
      index = cur_parent
      cur_parent = parent index
    end
    @heap
  end

  # Returns an element with the smallest priority and removes it from queue.
  # @return an element with the smallest priority or `nil` if there are no
  #   elements.
  def pop
    return nil unless @heap[1]
    puts @heap.inspect if @heap[1][1] == nil
    last = @heap.size - 1
    swap 1, last
    result = @heap.pop[1]
    find_place 1
    result
  end

  # @return [TrueClass,FalseClass] `true` if there are no elements
  #    in this queue, `false` otherwise.
  def empty?
    size == 0
  end

  # @return [Integer] how much elements does this queue contain
  def size
    @heap.size - 1
  end

  private

  def parent(i)
    i / 2
  end

  def left_child(i)
    2 * i
  end

  def right_child(i)
    2 * i + 1
  end

  def swap(a, b)
    tmp = @heap[a]
    @heap[a] = @heap[b]
    @heap[b] = tmp
  end

  def find_place(index)
    left = left_child index
    right = right_child index
    current = next_place index, left, right
    return if current == index
    swap index, current
    find_place current
  end

  def next_place(index, left, right)
    current = index
    current = left if left <= size && @heap[left][0] < @heap[current][0]
    current = right if right <= size && @heap[right][0] < @heap[current][0]
    current
  end
end
