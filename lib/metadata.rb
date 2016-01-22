# This class contains a hash map with only the information about the canon to be generated.

class Metadata

  ###################### Constructor ######################

  # Set the metadata to be empty, no inputs required.
  def initialize()
    @metadata = Hash.new()
    return self
  end

  ######################## Setters ########################
  #########################################################

  # Set the tonic of the key. Octaves must NOT be specified.
  def key_note(note)
    valid_keys = [:cb, :b, :c, :cs, :db, :d, :ds, :eb, :e, :f, :fs, :gb, :g, :gs, :ab, :a, :as, :bb]
    if valid_keys.include?(note)
      if @metadata[:key_type] == nil
        @metadata[:key_note] = note
      elsif @metadata[:key_type] == :major
        if note != :gs && note != :ds && note != :as
          @metadata[:key_note] = note
        else
          raise "Key note #{ note } not valid for a #{ @metadata[:key_type] } key."
        end
      elsif @metadata[:key_type] == :minor
        if note != :cb || note != :gb || note != :db
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

  # Set the type of the key. Only majors and minors are supported.
  def key_type(type)
    valid_types = [:major, :minor]
    if valid_types.include?(type)
      if type == :minor && (@metadata[:key_note] == :cb || @metadata[:key_note] == :gb || @metadata[:key_note] == :db)
        raise "Key note #{ @metadata[:key_note] } not valid for a #{ type } key."
      elsif type == :major && (@metadata[:key_note] == :gs || @metadata[:key_note] == :ds || @metadata[:key_note] == :as)
        raise "Key note #{ @metadata[:key_note] } not valid for a #{ type } key."
      else
        @metadata[:key_type] = type
      end
    else
      raise "The type of key: #{ type } is not supported."
    end
    return self
  end

  # Set the time signature for the piece. Only 3/4 and 4/4 are supported.
  def time_signature(time_sig)
    valid_time_sigs = ["3/4", "4/4"]
    if valid_time_sigs.include?(time_sig)
      @metadata[:time_sig] = time_sig
    else
      raise "The time signature #{ time_sig } is not supported."
    end
    return self
  end

  # Set the lowest note that can be used in this piece.
  # There must be a range of at least an octave.
  def lowest_note(note)
    note_number = SonicPi::Note.resolve_midi_note(note)
    if @metadata[:highest_note] != nil
      if note_number <= SonicPi::Note.resolve_midi_note(@metadata[:highest_note]) - 12
        @metadata[:lowest_note] = note
      else
        raise "The range must cover one octave, minimum."
      end
    else
      @metadata[:lowest_note] = note
    end
    return self
  end

  # Set the lowest note that can be used in this piece.
  # There must be a range of at least an octave.
  def highest_note(note)
    note_number = SonicPi::Note.resolve_midi_note(note)
    if @metadata[:lowest_note] != nil
      if note_number >= SonicPi::Note.resolve_midi_note(@metadata[:lowest_note]) + 12
        @metadata[:highest_note] = note
      else
        raise "The range must cover one octave, minimum."
      end
    else
      @metadata[:highest_note] = note
    end
    return self
  end

  # Explictly define a chord progression. This must have the same number of beats in as the number of beats per bar.
  def chord_progression(chord_progression)

    def check_chords(chord_progression)
      valid_chords = [:I, :IV, :V, :VI]
      is_valid = true
      chord_progression.map do |chord|
        if !valid_chords.include?(chord)
          is_valid = false
        end
      end
      return is_valid
    end

    case @metadata[:time_sig]
    when nil
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
      if chord_progression.length == 3 && check_chords(chord_progression)
        @metadata[:chord_progression] = chord_progression
      else
        raise "Invalid chord progression."
      end
    when "4/4"
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

  # Define how large the jump between consecutive root notes is allowed to be. It must be at least 5.
  def max_jump(jump)
    if 5 <= jump
      @metadata[:max_jump] = jump
    else
      raise "The maximum jump must be at least 5."
    end
    return self
  end

  # Set the probabilities of each split of a beat into various numbers
  def probabilities(prob)
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

  ######################## Getters ########################
  #########################################################
  ## Note the assumption that these will only be called by the canon class- so things are not generated until they are linked with a canon.

  # Return the whole hash map of metadata
  def get_data()
    return @metadata
  end

  # Get the tonic note. Set one at random if not specified.
  def get_key_note()
    if @metadata[:key_type] == nil
      if @metadata[:key_note] == nil
        self.key_note([:cb, :b, :c, :cs, :db, :d, :ds, :eb, :e, :f, :fs, :gb, :g, :gs, :ab, :a, :as, :bb].choose)
      else
        # The note picked must be compatible with the key type!
        if @metadata[:key_type] == :major
          self.key_note([:c, :g, :d, :a, :e, :b, :cb, :fs, :gb, :db, :cs, :ab, :eb, :bb, :f].choose)
        elsif @metadata[:key_type] == :minor
          self.key_note([:a, :e, :b, :fs, :cs, :gs, :ab, :ds, :eb, :bb, :as, :f, :c, :g, :d].choose)
        else
          raise "Invalid key type: #{ @metadata[:key_type] }"
        end
      end
    end
    return @metadata[:key_note]
  end

  # Get the type of key. Set one at random if not specified.
  def get_key_type()
    if @metadata[:key_type] == nil
      # Choose a compatible type for the note already chosen (if there is one).
      if @metadata[:key_note] == :cb || @metadata[:key_type] == :gb || @metadata[:key_type] == :db
        self.key_type(:major)
      elsif @metadata[:key_type] == :gs || @metadata[:key_type] == :ds || @metadata[:key_type] == :as
        self.key_type(:minor)
      else
        self.key_type([:major, :minor].choose)
      end
    end
    return @metadata[:key_type]
  end

  # Get the time signature. Set one at random if not specified, compatible with the chord progression if applicable.
  def get_time_signature()
    if @metadata[:time_sig] == nil
      if @metadata.get_chord_progression == nil
        self.time_signature(["3/4", "4/4"].choose)
      elsif @metadata.get_chord_progression.length == 3
        self.time_signature("3/4")
      else
        self.time_signature("4/4")
      end
    end
    return @metadata[:time_sig]
  end

  # Get the lowest note allowed. Default to 2 octaves below the highest note, or else to the tonic of the default octave.
  def get_lowest_note()
    if @metadata[:lowest_note] == nil
      if @metadata[:highest_note] == nil
        self.lowest_note(get_key_note)
      else
        self.lowest_note(Note.resolve_note_name(Note.resolve_midi_note(get_highest_note) - 24))
      end
    end
    return @metadata[:lowest_note]
  end

  # Get the highest note allowed. Default to 2 octaves above the lowest note, or else to the tonic 2 octaves above the default octave.
  def get_highest_note()
    if @metadata[:highest_note] == nil
      if @metadata[:lowest_note] == nil
        self.lowest_note(Note.resolve_note_name(Note.resolve_midi_note(get_key_note) + 24))
      else
        self.lowest_note(Note.resolve_note_name(Note.resolve_midi_note(get_lowest_note) + 24))
      end
    end
    return @metadata[:highest_note]
  end

  def get_chord_progression()
    return @metadata[:chord_progression]
  end

  # Get the max jump allowed. Default to 6.
  def get_max_jump()
    if @metadata[:max_jump] == nil
      self.max_jump(6)
    end
    return @metadata[:max_jump]
  end

  # Get the number of beats in each bar.
  def get_beats_in_bar()
    return get_time_signature == "3/4" ? 3 : 4
  end

  # Get the probabilities. Choose equal probabilities by default.
  def get_probabilities()
    if @metadata[:probabilities] == nil
      self.probabilities([0.25, 0.25, 0.25, 0.25])
    end
    return @metadata[:probabilities]
  end

end
