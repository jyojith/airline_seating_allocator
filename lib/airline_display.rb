class AirlineDisplay

  def display(result,outfile)
    File.open(outfile, "w") do |file|
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
  end
end
