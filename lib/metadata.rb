# This class contains a hash map with only information about the canon to be generated.
# TODO: 1) Add validation 2) Add defaults? Or does this only happen later?
class Metadata
  def initialize()
    # Set the metadata to be empty
    @metadata = Hash.new()
    return self
  end

  ##### Setters #####

  def key_note(note)
    @metadata[:key_note] = note
    return self
  end

  def key_type(type)
    @metadata[:key_type] = type
    return self
  end

  def time_signature(time_sig)
    @metadata[:time_sig] = time_sig
    return self
  end

  def lowest_note(note)
    @metadata[:lowest_note] = note
    return self
  end

  def highest_note(note)
    @metadata[:highest_note] = note
    return self
  end

  def chord_progression(chord_progression)
    @metadata[:chord_progression] = chord_progression
    return self
  end

  def max_jump(jump)
    @metadata[:max_jump] = jump
    return self
  end

  def number_of_voices(num)
    @metadata[:number_of_voices] = num
    return self
  end

  ##### Getters #####

  def get_data()
    return @metadata
  end

  def get_key_note()
    return @metadata[:key_note]
  end

  def get_key_type()
    return @metadata[:key_type]
  end

  def get_time_signature()
    return @metadata[:time_sig]
  end

  def get_lowest_note()
    return @metadata[:lowest_note]
  end

  def get_highest_note()
    return @metadata[:highest_note]
  end

  def get_chord_progression()
    return @metadata[:chord_progression]
  end

  def get_number_of_voices()
    return :metadata[:number_of_voices]
  end

  def get_beats_in_bar()
    return get_time_signature() == "3/4" ? 3 else 4
  end

end
