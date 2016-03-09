# Copyright (c) 2015 Emily Fox, MIT License.
# Full code available at https://github.com/EJCFox/canon-creator/

# CLASS DECRIPTION: A Metadata object contains information about a canon.
# MEMBER VARIABLES:
## metadata (Hash) - this is the object that contains all the information about the canon in a hash map.
# INTERFACE METHODS: (S) = setter and (G) = getter
# (S) key_note
# (S) key_type
# (S) beats_per_bar
# (S) lowest_note
# (S) highest_note
# (S) max_jump
# (S) probabilities
# (S) number_of_bars
# (S) number_of_voices
# (S) voice_offset
# (S) type
# (S) variation
# (S) voice_transpositions
# (G) get_key_note
# (G) get_key_type
# (G) get_time_signature
# (G) get_lowest_note
# (G) get_highest_note
# (G) get_max_jump
# (G) get_beats_in_bar
# (G) get_probabilities
# (G) get_number_of_bars
# (G) get_number_of_voices
# (G) get_type
# (G) get_variations
# (G) get_voice_octaves
# (G) get_offset

class Metadata

  # ARGS: None.
  # DESCRIPTION: Makes a new Metadata object, with a empty information.
  # RETURNS: This Metadata object.
  def initialize()
    @metadata = Hash.new()
    return self
  end

  ## SETTER
  # ARGS: A note, without specified octave.
  # DESCRIPTION: Set the tonic note.
  # RETURNS: This Metadata object.
  def key_note(note)
    # Specify valid tonics.
    valid_keys = [:cb, :b, :c, :cs, :db, :d, :ds, :eb, :e, :f, :fs, :gb, :g, :gs, :ab, :a, :as, :bb]
    if valid_keys.include?(note)
      # If the key is valid, we must also check for consistency with the type of scale.
      if @metadata[:key_type] == nil
        # No type specified so this is valid.
        @metadata[:key_note] = note
      elsif @metadata[:key_type] == :major
        if note != :gs && note != :ds && note != :as
          # The note is valid for a major key.
          @metadata[:key_note] = note
        else
          raise "Key note #{ note } not valid for a #{ @metadata[:key_type] } key."
        end
      elsif @metadata[:key_type] == :minor
        if note != :cb || note != :gb || note != :db
          # The note is valid for a minor key.
          @metadata[:key_note] = note
        else
          raise "Key note #{ note } not valid for a #{ @metadata[:key_type] } key."
        end
      else
        raise "Invalid key type."
      end
    else
      raise "The key: #{ note } is not valid."
    end
    return self
  end

  ## SETTER
  # ARGS: The type of the scale.
  # DESCRIPTION: Set the key type- major or minor.
  # RETURNS: This Metadata object.
  def key_type(type)
    # Specify valid types of key.
    valid_types = [:major, :minor]
    if valid_types.include?(type)
      # If the type is valid we must also check for consistency with the tonic note.
      if type == :minor && (@metadata[:key_note] == :cb || @metadata[:key_note] == :gb || @metadata[:key_note] == :db)
        # Cb, Gb, Db minors are NOT valid.
        raise "Key note #{ @metadata[:key_note] } not valid for a #{ type } key."
      elsif type == :major && (@metadata[:key_note] == :gs || @metadata[:key_note] == :ds || @metadata[:key_note] == :as)
        # Gs, Ds, As majors are NOT valid.
        raise "Key note #{ @metadata[:key_note] } not valid for a #{ type } key."
      else
        # Key is valid if no key note is specified, or it does not fall into one of the above cases.
        @metadata[:key_type] = type
      end
    else
      raise "The type of key: #{ type } is not supported."
    end
    return self
  end

  ## SETTER
  # ARGS: The time signature.
  # DESCRIPTION: Set the time signature. Only 3 and 4 are supported.
  # RETURNS: This Metadata object.
  def beats_per_bar(time_sig)
    # Specify valid time signatures.
    valid_beats = [3, 4]
    if valid_beats.include?(time_sig)
      if time_sig == 3
        @metadata[:time_sig] = "3/4"
      else
        @metadata[:time_sig] = "4/4"
      end
    else
      raise "The number of beats #{ time_sig } is not supported- must be 3 or 4."
    end
    return self
  end

  ## SETTER
  # ARGS: The lowest note.
  # DESCRIPTION: Set the lowest note. There must be a range of at least one octave.
  # RETURNS: This Metadata object.
  def lowest_note(note)
    note_number = SonicPi::Note.resolve_midi_note(note)
    # Ensure the range is at least an octave.
    if @metadata[:highest_note] != nil
      if note_number <= SonicPi::Note.resolve_midi_note(@metadata[:highest_note]) - 24
        @metadata[:lowest_note] = note
      else
        raise "The range must cover one octave, minimum. For a 4/4 piece more is needed."
      end
    else
      # This note is valid.
      @metadata[:lowest_note] = note
    end
    return self
  end

  ## SETTER
  # ARGS: The highest note.
  # DESCRIPTION: Set the highest note. There must be a range of at least one octave.
  # RETURNS: This Metadata object.
  def highest_note(note)
    note_number = SonicPi::Note.resolve_midi_note(note)
    # Ensure the range is at least an octave.
    if @metadata[:lowest_note] != nil
      if note_number >= SonicPi::Note.resolve_midi_note(@metadata[:lowest_note]) + 24
        @metadata[:highest_note] = note
      else
        raise "The range must cover one octave, minimum."
      end
    else
      # This note is valid.
      @metadata[:highest_note] = note
    end
    return self
  end

  ## SETTER
  # ARGS: The maximum jump between root notes.
  # DESCRIPTION: Set the maximum jump between root notes. This must be at least 5 for a good chance of success.
  # RETURNS: This Metadata object.
  def max_jump(jump)
    # Check the jump is big enough.
    if 5 <= jump
      @metadata[:max_jump] = jump
    else
      raise "The maximum jump must be at least 5."
    end
    return self
  end

  ## SETTER
  # ARGS: The probabilities of each note transform.
  # DESCRIPTION: Sets the probabilities of splitting a beat into 1, 2, 3 or 4, as entries in an array.
  # RETURNS: This Metadata object.
  def probabilities(prob)
    # Must be length 4 and must add up to 1.
    if prob.length == 4
      sum = Rational(0)
      prob.map { |x| sum += Rational(x.abs.to_s) }
      if sum == Rational(1)
        @metadata[:probabilities] = prob
      else
        raise "Probabilities do not add up to 1."
      end
    else
      raise "Four probabilities not given."
    end
    return self
  end

  ## SETTER
  # ARGS: Number of bars in the piece (minimum).
  # DESCRIPTION: Sets the number of bars in the piece. There is a maximum of 50 and a minimum of 2.
  # RETURNS: This Metadata object.
  def number_of_bars(n)
    if n > 1 && n <= 50
      @metadata[:number_of_bars] = n
    else
      raise "The number of bars cannot exceed 50."
    end
    return self
  end

  ## SETTER
  # ARGS: Number of voices.
  # DESCRIPTION: Sets the number of voices for this piece. Must be between 1 and 4.
  # RETURNS: This Metadata object.
  def number_of_voices(n)
    if [1, 2, 3, 4].include?(n)
      @metadata[:number_of_voices] = n
    else
      raise "There must be 1, 2, 3 or 4 voices, not #{ n }."
    end
    return self
  end

  ## SETTER
  # ARGS: Type of canon- either :round, :palindrome or :crab
  # DESCRIPTION: Sets the type of canon.
  # RETURNS: This Metadata object.
  def type(type)
    if [:crab, :round, :palindrome].include?(type)
      @metadata[:type] = type
    else
      raise "Invalid canon type: #{ type }."
    end
    return self
  end

  ## SETTER
  # ARGS: Percentage variation.
  # DESCRIPTION: Sets the number of tune variations to generate, as a percentage of the piece length (between 1 and 100).
  # RETURNS: This Metadata object.
  def variation(number)
    if 0 < number && number <= 100
      @metadata[:variations] = number
    else
      raise "Invalid variation percentage. Must be between 1 and 100."
    end
    return self
  end

  ## SETTER
  # ARGS: Number of bars per variation.
  # DESCRIPTION: Sets the number of bars before the next voice comes in. Must be between 1 and 4.
  # RETURNS: This Metadata object.
  def voice_offset(number)
    if [1, 2, 3, 4].include?(number)
      @metadata[:bars_per_chord_prog] = number
    else
      raise "Invalid offset: #{ number }. It must be between 1 and 4."
    end
    return self
  end

  ## SETTER
  # ARGS: Array of transposition of the voices, in octaves.
  # DESCRIPTION: Sets the transposition of the voices.
  # RETURNS: This Metadata object.
  def voice_transpositions(transposition)
    transposition.map do |transposition|
      if ![0, 1, -1, 2, -2].include?(transposition)
        raise "Invalid transposition: #{ transposition }. Only -2, -1, 0, 1 and 2 are valid."
      end
    end
    @metadata[:voice_octaves] = transposition
    return self
  end

  ## SETTER
  # ARGS: Array of voices (sounds).
  # DESCRIPTION: Sets the voice type of the parts.
  # RETURNS: This Metadata object.
  def sounds(sounds)
    if !sounds.is_a?(Array)
      raise "Invalid sounds: #{ sounds }. It must be an array of synth types."
    end
    @metadata[:voices] = sounds
    return self
  end

  ## NB: There is an assumption that these will only be called by the canon class- so things are not generated ranomly until they are linked with a canon. These should NOT be used in setters!

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Get the tonic note of the key. Generate one randomly (whilst being consistent with key type) if not specified.
  # RETURNS: The tonic note of the key, no octave given.
  def get_key_note()
    if @metadata[:key_note] == nil
      if @metadata[:key_type] == nil
        # There is no key type specified, nor key note, so pick one at random.
        self.key_note([:cb, :b, :c, :cs, :db, :d, :ds, :eb, :e, :f, :fs, :gb, :g, :gs, :ab, :a, :as, :bb].choose)
      elsif @metadata[:key_type] == :major
        # The note picked must be compatible with the key type: major.
        self.key_note([:c, :g, :d, :a, :e, :b, :cb, :fs, :gb, :db, :cs, :ab, :eb, :bb, :f].choose)
      elsif @metadata[:key_type] == :minor
        # The note picked must be compatible with the key type: minor.
        self.key_note([:a, :e, :b, :fs, :cs, :gs, :ab, :ds, :eb, :bb, :as, :f, :c, :g, :d].choose)
      else
        raise "Invalid key type: #{ @metadata[:key_type] }"
      end
    end
    return @metadata[:key_note]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Get the Key type. Generate one randomly (whilst being consistent with tonic) if not specified.
  # RETURNS: The key type- :major or :minor.
  def get_key_type()
    if @metadata[:key_type] == nil
      # Choose a compatible type for the note already chosen (if there is one).
      if @metadata[:key_note] == :cb || @metadata[:key_note] == :gb || @metadata[:key_note] == :db
        self.key_type(:major)
      elsif @metadata[:key_note] == :gs || @metadata[:key_note] == :ds || @metadata[:key_note] == :as
        self.key_type(:minor)
      else
        # No constraint- choose any. (Both are valid for this key note).
        self.key_type([:major, :minor].choose)
      end
    end
    return @metadata[:key_type]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Get the time signature. Generate one randomly (whilst being consistent with the chord progression) if not specified.
  # RETURNS: The time signature (as a string).
  def get_time_signature()
    # If there isn't a time signature chosen, then generate one.
    if @metadata[:time_sig] == nil
      self.beats_per_bar([3, 4].choose)
    end
    return @metadata[:time_sig]
  end

  # ARGS: The note name.
  # DESCRIPTION: Finds the note which is at the offset (in octaves).
  # RETURNS: The note at offset octaves.
  def get_note_at_offset(note, offset)
    note = note.to_s
    # If the note ends with a number, increase it by offset and add it on again.
    if note.end_with?("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
      octave = note[note.length - 1].to_i + offset
      return note.chop + octave.to_s
    else
      # Otherwise, just use the number 4 (default)
      return note + (offset + 4).to_s
    end
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Get the lowest note. Default to 2 octaves below the highest note, or else to the tonic of the default octave.
  # RETURNS: The lowest note (name).
  def get_lowest_note()
    if @metadata[:lowest_note] == nil
      if @metadata[:highest_note] == nil
        # If neither are set, make the lowest note the key note.
        self.lowest_note(get_key_note)
      else
        # Set the lowest note to be two octaves below the highest note.
        self.lowest_note(get_note_at_offset(get_highest_note, -2))
      end
    end
    return @metadata[:lowest_note]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Get the highest note allowed. Default to 2 octaves above the lowest note, or else to the tonic 2 octaves above the default octave.
  # RETURNS: This highest note (name).
  def get_highest_note()
    if @metadata[:highest_note] == nil
      if @metadata[:lowest_note] == nil
        # If neither are set, make the highest note the tonic two octaves higher than the given key note.
        self.highest_note(get_note_at_offset(get_key_note, 2))
      else
        # Set the highest note to be two octaves above the lowest note.
        self.highest_note(get_note_at_offset(get_lowest_note, 2))
      end
    end
    return @metadata[:highest_note]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Get the maximum jump allowed. Default to 6.
  # RETURNS: The maximum jump.
  def get_max_jump()
    if @metadata[:max_jump] == nil
      self.max_jump(6)
    end
    return @metadata[:max_jump]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the number of beats in the bar.
  # RETURNS: Number of beats in a bar.
  def get_beats_in_bar()
    return get_time_signature == "3/4" ? 3 : 4
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the probabilities of transforming each beat into each number of notes. Default to 0.35, 0.3, 0.3, 0.05.
  # RETURNS: Array of probabilities.
  def get_probabilities()
    if @metadata[:probabilities] == nil
      self.probabilities([0.5, 0.25, 0.15, 0.1])
    end
    return @metadata[:probabilities]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the number of bars in the piece. Default to 2 times the number of beats in a bar.
  # RETURNS: Number of bars.
  def get_number_of_bars()
    if @metadata[:number_of_bars] == nil
      @metadata[:number_of_bars] = 2 * get_beats_in_bar
    end
    return @metadata[:number_of_bars]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the number of voices in the piece. Default to the number of beats in a bar.
  # RETURNS: Number of voices.
  def get_number_of_voices()
    if @metadata[:number_of_voices] == nil
      @metadata[:number_of_voices] = 2
    end
    return @metadata[:number_of_voices]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the type of the canon. Choose one at random if not specified.
  # RETURNS: Canon type.
  def get_type()
    if @metadata[:type] == nil
      @metadata[:type] = [:round, :crab, :palindrome].choose
    end
    return @metadata[:type]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the Number of variations to generate. If none, choose between 50 and 100.
  # RETURNS: number of variations.
  def get_variation()
    if @metadata[:variations] == nil
      @metadata[:variations] = [50, 100].choose
    end
    return @metadata[:variations]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the Number of bars per chord progression. If none given, choose a random number between 1 and 4.
  # RETURNS: number of variations.
  def get_offset()
    if @metadata[:bars_per_chord_prog] == nil
      @metadata[:bars_per_chord_prog] = [1, 2].choose
    end
    return @metadata[:bars_per_chord_prog]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the transposition of each voice.
  # RETURNS: Array with transposition of each voice.
  def get_transpositions()
    if @metadata[:voice_octaves] == nil
      voice_octaves = Array.new(get_number_of_voices)
      for voice in 0..voice_octaves.length - 1
        voice_octaves[voice] = [0, 0, 0, -1].choose
      end
      @metadata[:voice_octaves] = voice_octaves
    elsif @metadata[:voice_octaves].length < get_number_of_voices
      # Append some more until it is the right length.
      for i in 1..(get_number_of_voices - @metadata[:voice_octaves].length)
        @metadata[:voice_octaves] << [0, 0, 0, -1].choose
      end
    end
    return @metadata[:voice_octaves]
  end

  ## GETTER
  # ARGS: None.
  # DESCRIPTION: Return the sound for each voice.
  # RETURNS: Array of voices.
  def get_sounds()
    if @metadata[:voices] == nil
      voices = Array.new(get_number_of_voices)
      for voice in 0..voices.length - 1
        voices[voice] = :choose
      end
      @metadata[:voices] = voices
    elsif @metadata[:voices].length < get_number_of_voices
      # Append some more until it is the right length.
      for i in 1..(get_number_of_voices - @metadata[:voices].length)
        @metadata[:voices] << [:pretty_bell, :saw, :prophet, :beep].choose
      end
    end
    return @metadata[:voices]
  end

end
