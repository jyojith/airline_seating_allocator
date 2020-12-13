require 'json'

class AirlineSeating
  attr_accessor :booking_overflow, :total_seats, :passengers_count

  def initialize(*args)
    @input_seats = JSON.parse(args.flatten[0])
    @passengers_count = args.flatten[1].strip.to_i
    @total_seats = @input_seats.inject(0) { |sum, x| sum += x[0] * x[1] }
    @booking_overflow = true if @total_seats < @passengers_count
    @max_columns = @input_seats.map(&:last).max
    @passengers_allocated = 0
  end

  def arrangement
    prepare_seats
    allocate_aisle_seats
    allocate_window_seats
    allocate_center_seats
  end

  private

  def prepare_seats
    @available_seats = @input_seats.each_with_object([]).with_index do |(arr, seats), index|
      seats << (1..arr[1]).map { |x| Array.new(arr[0]) { 'N' } }
    end
    @sorted_seats = (1..@max_columns).each_with_object([]).with_index do |(x, arr), index|
      arr << @available_seats.map { |x| x[index] }
    end
  end

  def allocate_aisle_seats
    @aisle_seats = @sorted_seats.each_with_object([]) do |elem_array, res_array|
      res_array << if elem_array.nil?
        nil
      else
        elem_array.each_with_object([]).with_index do |(basic_elem_array, update_arr), index|
          update_arr << if basic_elem_array.nil?
            nil
          else
            if index == 0
              @passengers_allocated += 1
              basic_elem_array[-1] = @passengers_allocated <= @passengers_count ? @passengers_allocated.to_s.rjust(@total_seats.to_s.size, "0") : 'X'*@total_seats.to_s.size
            elsif index == elem_array.size - 1
              unless basic_elem_array.size == 1
                @passengers_allocated += 1
                basic_elem_array[0] = @passengers_allocated <= @passengers_count ? @passengers_allocated.to_s.rjust(@total_seats.to_s.size, "0") : 'X'*@total_seats.to_s.size
              end
            else
              @passengers_allocated += 1
              basic_elem_array[0] = @passengers_allocated <= @passengers_count ? @passengers_allocated.to_s.rjust(@total_seats.to_s.size, "0") : 'X'*@total_seats.to_s.size
              unless basic_elem_array.size == 1
                @passengers_allocated += 1
                basic_elem_array[-1] = @passengers_allocated <= @passengers_count ? @passengers_allocated.to_s.rjust(@total_seats.to_s.size, "0") : 'X'*@total_seats.to_s.size
              end
            end
            basic_elem_array
          end
        end
      end
    end
  end

  def allocate_window_seats
    @window_seats = @aisle_seats.each_with_object([]) do |elem_array, res_array|
      res_array << if elem_array.nil?
        nil
      else
        elem_array.each_with_object([]).with_index do |(basic_elem_array, update_arr), index|
          update_arr << if basic_elem_array.nil?
            nil
          else
            if index == 0
              @passengers_allocated += 1
              basic_elem_array[0] = @passengers_allocated <= @passengers_count ? @passengers_allocated.to_s.rjust(@total_seats.to_s.size, "0") : 'X'*@total_seats.to_s.size
            elsif index == elem_array.size - 1
              @passengers_allocated += 1
              basic_elem_array[-1] = @passengers_allocated <= @passengers_count ? @passengers_allocated.to_s.rjust(@total_seats.to_s.size, "0") : 'X'*@total_seats.to_s.size
            end
            basic_elem_array
          end
        end
      end
    end
  end

  def allocate_center_seats
    @center_seats = @window_seats.each_with_object([]) do |elem_array, res_array|
      res_array << if elem_array.nil?
        nil
      else
        elem_array.each_with_object([]).with_index do |(basic_elem_array, update_arr), index|
          update_arr << if basic_elem_array.nil?
            nil
          else
            if basic_elem_array.size > 2
              (1..basic_elem_array.size - 2).each do |x|
                @passengers_allocated += 1
                basic_elem_array[x] = @passengers_allocated <= @passengers_count ? @passengers_allocated.to_s.rjust(@total_seats.to_s.size, "0") : 'X'*@total_seats.to_s.size
              end
            end
            basic_elem_array
          end
        end
      end
    end
  end
end

lines = File.readlines('input.txt')

seating = AirlineSeating.new(lines)
puts "total number of seats = #{seating.total_seats}"
puts "passengers count = #{seating.passengers_count}"

result = seating.arrangement
File.open("output.txt", "w") do |file|
  result.each_with_index do |row, parent_index|
    row_formatted = ''
    row.each_with_index do |arr, index|
      if index == row.size - 1
        print_value = arr.inspect.gsub(',', '').gsub('"', '')
      else
        print_value = arr.inspect.gsub(',', '').gsub('"', '') + ' '
      end
      if parent_index == 0
        instance_variable_set("@arr_length_#{index}", print_value.length)
      else
        print_value = " " * instance_variable_get("@arr_length_#{index}").to_i if print_value.strip == 'nil'
      end
      row_formatted += print_value
    end
    file.write("#{row_formatted}\n")
  end
end
