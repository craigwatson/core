module Bucky::Dso
  class List
    attr_accessor :list, :pointer

    delegate :each, :each_with_index, :collect, :insert, :delete_at, :[], to: :list

    def initialize(list = [])
      self.pointer = 0
      self.list = if list.first.is_a?(Array) || list.blank?
        list.collect { |sortable, position| Sortable.new(sortable, position) }
      else
        list.each_with_index.collect { |sortable, position| Sortable.new(sortable, position + 1) }
      end
    end

    def to_a
      list.collect(&:to_a)
    end

    def next
      n = peek
      self.pointer += 1
      n
    end

    def reset
      self.pointer = 0
    end

    def peek
      list[pointer]
    end

    def peek_behind
      if position.zero?
        nil
      else
        list[position - 1]
      end
    end

    delegate :empty?, to: :list

    def finished?
      empty? || pointer == list.size
    end

    def -(other)
      hash = other.sortables.inject({}) { |h, key| h.merge(key => true) }
      List.new(to_a.reject { |s| hash.key?(s.first) })
    end

    def index(key)
      key = key.sortable if key.is_a?(Sortable)
      sortables.index(key)
    end

    def move(from, to)
      insert(to, delete_at(from))
    end

    def before(sortable)
      if sortables.first == sortable || !sortables.include?(sortable)
        nil
      else
        s = list[sortables.index(sortable) - 1]
        s.blank? ? nil : s.sortable
      end
    end

    def match_before(sortable, possible_next)
      match = possible_next.blank? ? nil : before(possible_next.sortable)

      !match.blank? && match == sortable
    end

    def update_positions
      list.each_with_index do |sortable, index|
        sortable.position = index + 1
      end
    end

    def sortables
      list.collect(&:sortable)
    end

    def self.sort(master, ordered, sorter = Bucky::Dso::IRelativeSort)
      sorter.sort(master, ordered)
    end

    def self.ordered_list(list)
      List.new(list.each_with_index.collect { |i, index| [i, index + 1.5] })
    end

    def merged_uniques(list)
      (self.sortables + list.sortables).uniq
    end
  end
end
