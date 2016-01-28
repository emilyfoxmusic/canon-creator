# Copyright (c) 2015 Emily Fox, MIT License.
# Full code available at https://github.com/EJCFox/canon-creator/

# CLASS DECRIPTION: A Metadata object contains information about a canon.
# MEMBER VARIABLES:
## metadata (Hash) - this is the object that contains all the information about the canon in a hash map.
# INTERFACE METHODS: (S) = setter and (G) = getter
# (S) key_note
# (S) key_type
# (S) time_signature
# (S) lowest_note
# (S) highest_note
# (S) chord_progression
# (S) max_jump
# (S) probabilities
# (G) get_key_note
# (G) get_key_type
# (G) get_time_signature
# (G) get_lowest_note
# (G) get_highest_note
# (G) get_chord_progression
# (G) get_max_jump
# (G) get_beats_in_bar
# (G) get_probabilities

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
  # DESCRIPTION: Set the time signature. Only 3/4 and 4/4 are supported.
  # RETURNS: This Metadata object.
  def time_signature(time_sig)
    # Specify valid time signatures.
    valid_time_sigs = ["3/4", "4/4"]
    if valid_time_sigs.include?(time_sig)
      # The time signature is valid but it must also be consistent with the chord progression (if specified).
      if @metadata[:chord_progression] == nil || (@metadata[:chord_progression].length == 3 && time_sig == "3/4") || (@metadata[:chord_progression].length == 4 && time_sig == "4/4")
        # Consistent.
        @metadata[:time_sig] = time_sig
      else
        # Not consistent.
        raise "Time signature incompatible with chord progression. Length must be equal to beats in a bar."
      end
    else
      raise "The time signature #{ time_sig } is not supported."
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
      if note_number <= SonicPi::Note.resolve_midi_note(@metadata[:highest_note]) - 12
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
      if note_number >= SonicPi::Note.resolve_midi_note(@metadata[:lowest_note]) + 12
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
  # ARGS: The chord progression.
  # DESCRIPTION: Set the chord progression. This must have the same number of beats in as the number of beats per bar.
  # RETURNS: This Metadata object.
  def chord_progression(chord_progression)

    # ARGS: The chord progression.
    # DESCRIPTION: Check that only valid chords are used.
    # RETURNS: A boolean of whether this is valid or not.
    def check_chords(chord_progression)
      # Specify valid chords.
      valid_chords = [:I, :IV, :V, :VI]
      # Check each one in the chord progression given.
      is_valid = true
      chord_progression.map do |chord|
        if !valid_chords.include?(chord)
          is_valid = false
        end
      end
      return is_valid
    end

    # Check for consistency with the time signature.
    case @metadata[:time_sig]
    when nil
      # No time signature means it must just be 3 or 4 beats long.
      if chord_progression.length == 3 || chord_progression.length == 4
        if check_chords(chord_progression)
          @metadata[:chord_progression] = chord_progression
        else
          raise "Invalid chord given. They must be one of: :I, :IV, :V or :VI."
        end
      else
        raise "The chord progression must have the same number of chords as beats per bar, i.e. 3 or 4."
      end
    when "3/4"
      # The length must be 3.
      if chord_progression.length == 3 && check_chords(chord_progression)
        @metadata[:chord_progression] = chord_progression
      else
        raise "Invalid chord progression."
      end
    when "4/4"
      # The length must be 4.
      if chord_progression.length == 4 && check_chords(chord_progression)
        @metadata[:chord_progression] = chord_progression
      else
        raise "Invalid chord progression."
      end
    else
      raise "Invalid chord progression."
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
      sum = 0
      prob.map { |x| sum += x }
      if sum == 1
        @metadata[:probabilities] = prob
      else
        raise "Probabilities do not add up to 1."
      end
    else
      raise "Four probabilities not given."
    end
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
  # RETURNS: The tme signature (as a string).
  def get_time_signature()
    # If there isn't a time signature chosen, then generate one.
    if @metadata[:time_sig] == nil
      # Ensure it's compatible with the chord progression.
      if get_chord_progression == nil
        self.time_signature(["3/4", "4/4"].choose)
      elsif @metadata.get_chord_progression.length == 3
        self.time_signature("3/4")
      else
        self.time_signature("4/4")
      end
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
  # DESCRIPTION: Get the chord progression. Returns nil is one hasn't been explicitly specified.
  # RETURNS: The chord progression.
  def get_chord_progression()
    return @metadata[:chord_progression]
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
  # DESCRIPTION: Return the probabilities of transforming each beat into each number of notes. Default to equal probabilities.
  # RETURNS: Array of probabilities.
  def get_probabilities()
    if @metadata[:probabilities] == nil
      self.probabilities([0.25, 0.25, 0.25, 0.25])
    end
    return @metadata[:probabilities]
  end
end
