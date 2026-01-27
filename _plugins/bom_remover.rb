# _plugins/bom_remover.rb
module Jekyll
  class BomRemover < Generator
    priority :highest

    def generate(site)
      puts "BOM Remover: Plugin running..."
      
      unless site.data
        puts "BOM Remover: No data found in site."
        return
      end

      puts "BOM Remover: Found data keys: #{site.data.keys.inspect}"

      site.data.each do |data_key, data_value|
        puts "BOM Remover: Inspecting '#{data_key}' (#{data_value.class})"
        # Check if it's an array of hashes (typical for CSV/TSV)
        if data_value.is_a?(Array) && !data_value.empty?
          puts "BOM Remover: '#{data_key}' is an array. First element type: #{data_value.first.class}"
          if data_value.first.is_a?(Hash)
            fix_keys_in_array(data_value, data_key)
          end
        else
            puts "BOM Remover: Skipping '#{data_key}' (Not an array of hashes)"
        end
      end
    end

    def fix_keys_in_array(array, data_key)
      # We only need to check the keys of the first element to know if there's a BOM in the header
      first_row = array.first
      return unless first_row
      
      puts "BOM Remover: Checking keys for '#{data_key}'..."
      # Inspect bytes of keys to be sure
      first_row.keys.each do |k| 
         if k.is_a?(String)
            puts "  Key: '#{k}' Bytes: #{k.bytes.map{|b| b.to_s(16)}.join(' ')}"
         end
      end
      
      bom_keys = first_row.keys.select { |k| k.is_a?(String) && k.start_with?("\uFEFF") }
      
      if bom_keys.any?
        puts "  FOUND BOM KEYS: #{bom_keys.inspect}. FIXING..."
        
        # Create a mapping of bad keys to good keys
        key_map = bom_keys.each_with_object({}) do |k, hash|
          hash[k] = k.sub("\uFEFF", "")
        end
        
        # Fix all rows
        array.each do |row|
          key_map.each do |bad_key, good_key|
            if row.key?(bad_key)
              row[good_key] = row.delete(bad_key)
            end
          end
        end
      end
    end
  end
end
