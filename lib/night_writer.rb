require_relative 'alphabet'

class NightWriter

  def initialize
    @alphabet = Alphabet.new
  end

  def lookup(character, position)
    @alphabet.braille_letter_hash[character].chars[position]
  end

  def encode_to_braille(plain)
    result = [0,2,4].inject([]) do |output, offset|
      plain.chars.each do |letter|
        if letter == letter.upcase
          output << lookup(:capitalize, offset) << lookup(:capitalize, offset + 1)
          letter = letter.downcase
        end
        output << lookup(letter, offset) << lookup(letter, offset + 1)
      end
      output << "\n"
    end
    result.join
  end

  def encode_from_braille(braille)
    lines = braille.split("\n")
    n = lines[0].length
    as_one_line = lines.join
    output = []

    (0..(n-1)).each_slice(2) do |column_offset|

      braille_character = (0..2).inject([]) do |inner_braille_character, row_offset|
        inner_braille_character << as_one_line[(row_offset * n) + column_offset[0]]
        inner_braille_character << as_one_line[(row_offset * n) + column_offset[1]]
      end

      decoded_braille = @alphabet.braille_letter_hash.key(braille_character.join)

      determine_capitalization(decoded_braille, output)
    end

    output.join
  end

  private
  def determine_capitalization(decoded_braille, output)
    should_capitalize_next = false
    if decoded_braille == :capitalize
      should_capitalize_next = true
    elsif should_capitalize_next
      output << decoded_braille.upcase
      should_capitalize_next = false
    else
      output << decoded_braille
      should_capitalize_next = false
    end
  end

end


