# Copyright (c) 2015 Emily Fox, MIT License.
# Full code available at https://github.com/EJCFox/canon-creator/

# CLASS DECRIPTION: A Canon object represents an instance of a canon.
# MEMBER VARIABLES:
## metadata (Metadata) - this is the object that contains all the information about the canon.
## concrete_scale (array of integers) - this array contains all the possible notes that can be used in this canon.
## canon_skeleton (canon representation using arrays) - the canon with only the root notes filled in.
## canon_complete (canon representation using arrays) - the fully fleshed out canon.
# INTERFACE METHODS
## get_metadata - returns the metadata object associated with this canon. This is not necessarily the same as that which was passed in to initialise the canon.
## get_canon_as_array - returns the internal representation of the canon.

require "mini_kanren"

class Canon

  # ARGS: A metadata object with canon properties.
  # DESCRIPTION: Automatically generates the whole canon to populate the other member variables of this object.
  # RETURNS: This canon object.
  def initialize(metadata)
    # Initialise member variables
    @metadata = metadata.clone() # Clone because the original version should not change when this one is modified for this specific canon.
    @concrete_scale = nil
    @chord_progression = nil
    @variations = nil
    @canon_skeleton = nil
    @canon_complete = nil
    # Generate the canon.
    generate_concrete_scale()
    generate_chord_progression()
    generate_variations()
    generate_skeleton()
    populate_canon()
    return self
  end

  # ARGS: None.
  # DESCRIPTION: Returns the metadata object associated with this canon.
  # RETURNS: Metadata.
  def get_metadata()
    return @metadata
  end

  # ARGS: None.
  # DESCRIPTION: Returns the canon in its internal representation.
  # RETURNS: The canon in its internal representation.
  def get_canon_as_array()
    return @canon_complete
  end

  def get_chord_prog
    return @chord_progression
  end

  def get_variations
    return @variations
  end

  def get_skeleton
    return @canon_skeleton
  end

  # ARGS: None.
  # DESCRIPTION: Populates the concrete scale by finding all notes in the scale between the highest and lowest notes allowed. Generates randomly other metadata that it doesn't already have.
  # RETURNS: Nil.
  def generate_concrete_scale()
    # Find the highest tonic lower than the lower limit.
    min_tonic = SonicPi::Note.resolve_midi_note(@metadata.get_key_note)
    lowest_note = SonicPi::Note.resolve_midi_note(@metadata.get_lowest_note)
    while lowest_note < min_tonic
      min_tonic -= 12
    end
    # Find the lowest tonic higher than the upper limit.
    max_tonic = SonicPi::Note.resolve_midi_note(@metadata.get_key_note)
    highest_note = SonicPi::Note.resolve_midi_note(@metadata.get_highest_note)
    while highest_note > max_tonic
      max_tonic += 12
    end
    # ASSERT: the whole range is encompassed between the two tonics- min and max.
    # Get the scale between those tonics.
    num_octaves = (max_tonic - min_tonic) / 12
    @concrete_scale = SonicPi::Scale.new(min_tonic, @metadata.get_key_type, num_octaves = num_octaves).notes
    # Convert to an array and trim to range
    @concrete_scale = @concrete_scale.to_a
    @concrete_scale.delete_if { |note| (lowest_note != nil && note < lowest_note) || (highest_note != nil && note > highest_note) }
  end

  # ARGS: None.
  # DESCRIPTION: Generates a chord progression at random if one does not already exist.
  # RETURNS: Nil.
  def generate_chord_progression()
    # Create a new array with a chord for each beat, with the number of beats dictated by the metadata.
    @chord_progression = Array.new(@metadata.get_beats_in_bar * @metadata.get_bars_per_chord_prog)
    # State which chords are available
    chord_choice = [:I, :IV, :V, :VI]
    if @metadata.get_type == :round
      # Choose each chord at random except the last two which are always V-I (perfect cadence).
      for i in 0..@chord_progression.length - 3
        @chord_progression[i] = chord_choice.choose
      end
      @chord_progression[@chord_progression.length - 2] = :V
      @chord_progression[@chord_progression.length - 1] = :I
    elsif @metadata.get_type == :crab || @metadata.get_type == :palindrome
      # The first two chords must be I-V for a perfect cadence when it is reversed.
      @chord_progression[0] = :I
      @chord_progression[1] = :V
      # The rest of the first half are unconstrained.
      for i in 2..((@chord_progression.length - 1) / 2)
        @chord_progression[i] = chord_choice.choose
      end
      # The second half is a mirror of the first.
      for i in (((@chord_progression.length - 1) / 2) + 1)..(@chord_progression.length - 1)
        @chord_progression[i] = @chord_progression[@chord_progression.length - (i + 1)]
      end
    else
      raise "Unknown canon type: #{ @metadata.get_type }."
    end
  end

  # ARGS: None.
  # DESCRIPTION: Generates variationswhich are arrays of uniform random variables to specify which transformation to do.
  # RETURNS: Nil.
  def generate_variations()
    @variations = []
    for variation in 0..@metadata.get_variations - 1
      this_variation = []
      for beat in 0..@metadata.get_beats_in_bar - 1
        this_variation << rand()
      end
      @variations << this_variation
    end
  end

  def generate_skeleton()
    # Pass the variables through to MiniKanren.
    metadata = @metadata
    concrete_scale = @concrete_scale
    chord_progression = @chord_progression
    # Begin the logic block.
    canon_structure_options = MiniKanren.exec do
      # Get the variables that have been passed through.
      @metadata = metadata
      @concrete_scale = concrete_scale
      @chord_progression = chord_progression
      # Extend MiniKanren so that Sonic Pi's methods can be used.
      extend SonicPi::Lang::Core
      extend SonicPi::RuntimeMethods
      # Generate the canon skeleton structure, with the root notes as variables.
      canon_skeleton = Array.new(@metadata.get_number_of_bars) # One cell per bar.
      for bar in 0..@metadata.get_number_of_bars - 1
        canon_skeleton[bar] = Array.new(@metadata.get_beats_in_bar) # One cell per beat.
        for beat in 0..@metadata.get_beats_in_bar - 1
          canon_skeleton[bar][beat] = {root_note: fresh, notes: nil, rhythm: nil} # The root note is a variable.
        end
      end

      # ARGS: MiniKanren variables: the current beat's root note, the next beats's root note and the notes that have already been used in this position. The name of the chord assciated with this beat.
      # DESCRIPTION: This method adds constraints on the current beat to constrain it to:
      # 1) A note in the scale given (tonic option included)
      # 2) A note not exceeding max_jump distance from the next
      # 3) Not the same note as in other variations in the same position
      # It fails if no such unification exists.
      # RETURNS: The project constraint which contains all this information.
      def constrain_to_possible_notes(current_beat_var, next_beat_var, chord_name, unavailable_notes)
        possible_notes = nil
        # Get all notes in the right chord, or tonics.
        if chord_name == :tonic
          # Get all tonic notes.
          mod_tonic = SonicPi::Note.resolve_midi_note(@metadata.get_key_note) % 12
          possible_notes = @concrete_scale.select { |note| (note % 12) == mod_tonic }
        else
          possible_notes = notes_in_chord(chord_name)
        end
        # If this is the last beat, then there is no next beat.
        if next_beat_var == nil
          # Return the project function, with the next beat and unavailable notes projected.
          return project(unavailable_notes, lambda do |unavailable_notes|
            refined_possibilities = possible_notes
            # Keep only those not too far from the next beat, not the same as the next and not the same as one of the unavailable notes.
            refined_possibilities = possible_notes.select do |note|
              !unavailable_notes.include?(note)
            end
            # Return a conde clause of all these options unless there are none, in which case fail.
            if refined_possibilities.empty?
              # There are no options- return FAIL.
              lambda { |x| nil }
            else
              # Constrain this note to these possibilities.
              conde_options = []
              refined_possibilities.map do |note|
                conde_options << eq(current_beat_var, note)
              end
              conde(*conde_options.shuffle)
            end
          end)
        else
          # Return the project function, with the next beat and unavailable notes projected.
          return project(next_beat_var, lambda do |next_beat|
            project(unavailable_notes, lambda do |unavailable_notes|
              refined_possibilities = possible_notes
              # Keep only those not too far from the next beat, not the same as the next and not the same as one of the unavailable notes.
              refined_possibilities = possible_notes.select do |note|
                b = (note - next_beat).abs <= @metadata.get_max_jump
                b = b && (note - next_beat).abs != 0
                b && !unavailable_notes.include?(note)
              end
              # Return a conde clause of all these options unless there are none, in which case fail.
              if refined_possibilities.empty?
                # There are no options- return FAIL.
                lambda { |x| nil }
              else
                # Constrain this note to these possibilities.
                conde_options = []
                refined_possibilities.map do |note|
                  conde_options << eq(current_beat_var, note)
                end
                conde(*conde_options.shuffle)
              end
            end)
          end)
        end
      end

      # ARGS: Name of the chord (e.g. :I).
      # DESCRIPTION: Finds the notes in the given chord.
      # RETURNS: An array containing the notes (midi numbers) in that chord, within the concrete scale.
      def notes_in_chord(name)
        # Find the mod of the tonic note for this key.
        mod_tonic = SonicPi::Note.resolve_midi_note(@metadata.get_key_note) % 12
        # Split on the name of the chord.
        case name
        when :I
          # Find mods of notes needed:
          # I is tonics, thirds and fifths.
          if @metadata.get_key_type == :major
            mod_third = (mod_tonic + 4) % 12
          else
            mod_third = (mod_tonic + 3) % 12
          end
          mod_fifth = (mod_tonic + 7) % 12
          # Select only notes in the concrete scale, and return it.
          notes_in_I = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_tonic) || (mod_note == mod_third) || (mod_note == mod_fifth)
          end
          return notes_in_I
        when :IV
          # Find mods of notes needed:
          # IV is fourths, sixths and tonics
          if @metadata.get_key_type == :major
            mod_sixth = (mod_tonic + 9) % 12
          else
            mod_sixth = (mod_tonic + 8) % 12
          end
          mod_fourth = (mod_tonic + 5) % 12
          # Select only notes in the concrete scale, and return it.
          notes_in_IV = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_fourth) || (mod_note == mod_sixth) || (mod_note == mod_tonic)
          end
          return notes_in_IV
        when :V
          # Find mods of notes needed:
          # V is fifths, sevenths and seconds.
          if @metadata.get_key_type == :major
            mod_second = (mod_tonic + 2) % 12
            mod_seventh = (mod_tonic + 11) % 12
          else
            mod_second = (mod_tonic + 1) % 12
            mod_seventh = (mod_tonic + 10) % 12
          end
          mod_fifth = (mod_tonic + 7) % 12
          # Select only notes in the concrete scale, and return it.
          notes_in_V = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_fifth) || (mod_note == mod_seventh) || (mod_note == mod_second)
          end
          return notes_in_V
        when :VI
          # Find mods of notes needed:
          # VI is sixths, tonics and thirds.
          if @metadata.get_key_type == :major
            mod_third = (mod_tonic + 4) % 12
            mod_sixth = (mod_tonic + 9) % 12
          else
            mod_third = (mod_tonic + 3) % 12
            mod_sixth = (mod_tonic + 8) % 12
          end
          # Select only notes in the concrete scale, and return it.
          notes_in_VI = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_sixth) || (mod_note == mod_tonic) || (mod_note == mod_third)
          end
          return notes_in_VI
        else
          # The chord given is not valid.
          raise "Error: unrecognised chord #{ name }"
        end
      end

      # ARGS: The array of constraints, the skeleton so far, the bar number and the beat number.
      # DESCRIPTION: Adds a constraint to the root note of that beat based on those that mustn't overlap and the next beat.
      # RETURNS: Nil.
      def add_constraints(constraints, canon_skeleton, bar, beat)
        used_notes_in_this_position = []
        for overlapping_bar in (bar + 1)..(bar + (@metadata.get_number_of_voices - 1) * @metadata.get_bars_per_chord_prog)
          # If this bar exists then add the corresponding beat to the one to watch.
          if overlapping_bar < @metadata.get_number_of_bars
            used_notes_in_this_position << canon_skeleton[overlapping_bar][beat][:root_note]
          end
        end
        # Constrain the notes.
        # Find the chord for this beat.
        chord_for_beat = @chord_progression[beat + @metadata.get_beats_in_bar * (bar % @metadata.get_bars_per_chord_prog)]
        # Split depending on which beat this is.
        if beat < @metadata.get_beats_in_bar - 1 # The next beat is in the same bar.
          new_constraint = constrain_to_possible_notes(canon_skeleton[bar][beat][:root_note], canon_skeleton[bar][beat + 1][:root_note], chord_for_beat, used_notes_in_this_position)
          constraints << new_constraint
        elsif bar != @metadata.get_number_of_bars - 1 # The next beat is in the next bar.
          new_constraint = constrain_to_possible_notes(canon_skeleton[bar][beat][:root_note], canon_skeleton[bar + 1][0][:root_note], chord_for_beat, used_notes_in_this_position)
          constraints << new_constraint
        end # If not matched then it's the final note which has already been dealt with.
      end

      # Initialise constraints.
      constraints = []
      # CONSTRAINT (ALL): Final root note is the tonic.
      constraints << constrain_to_possible_notes(canon_skeleton[@metadata.get_number_of_bars - 1][@metadata.get_beats_in_bar - 1][:root_note], nil, :tonic, [])
      # Deal with the types individually.
      case @metadata.get_type
      when :round
        # Cycle through the bars, adding constraints that each note is in the chord and different to overlapping ones.
        (@metadata.get_number_of_bars - 1).downto(0) do |bar|
          (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
            add_constraints(constraints, canon_skeleton, bar, beat)
          end
        end
      when :crab
        # Cycle through copies of the chord progression, unifying them alternately with a new set of notes (in the chord and different to overlapping notes) and then the mirror of the successive chord progression's root notes.
        # Is this version of the chord progression a mirror of the next?
        mirror = false # MUST start with false.
        # For the number of cycles of the chord progression that happen in this piece.
        ((@metadata.get_number_of_bars - 1) / @metadata.get_bars_per_chord_prog).downto(0) do |chord_progression_count|
          # For the offset of bars within this (up to length of chord progression).
          (@metadata.get_bars_per_chord_prog - 1).downto(0) do |bar_offset|
            # Find the actual bar number.
            bar = chord_progression_count * @metadata.get_bars_per_chord_prog + bar_offset
            if mirror
              # Mirror the next version of the chord progression.
              (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
                mirrored_bar = (chord_progression_count + 1) * @metadata.get_bars_per_chord_prog + (@metadata.get_bars_per_chord_prog - 1 - bar_offset)
                mirrored_beat = @metadata.get_beats_in_bar - 1 - beat
                constraints << eq(canon_skeleton[bar][beat][:root_note], canon_skeleton[mirrored_bar][mirrored_beat][:root_note])
              end
            else
              # Just generate some more music.
              (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
                add_constraints(constraints, canon_skeleton, bar, beat)
              end
            end
          end
          # Flip whether we're mirroring or not.
          mirror = !mirror
        end
      when :palindrome
        # Cycle through to half way through the melody unifying as a round, then mirror for the first half. Exclude central one if odd number of bars.
        (@metadata.get_number_of_bars - 1).downto((@metadata.get_number_of_bars + 1) / 2) do |bar|
          (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
            add_constraints(constraints, canon_skeleton ,bar, beat)
          end
        end
        # ASSERT: the last half is unified, excluding middle bar if there's an odd number of bars.
        # If there's an odd number of bars, deal with the middle one.
        if (@metadata.get_number_of_bars % 2 == 1)
          (@metadata.get_beats_in_bar - 1).downto((@metadata.get_beats_in_bar - 1) / 2) do |beat|
            add_constraints(constraints, canon_skeleton,bar, beat)
          end
        end
        # ASSERT: half the canon is unified.
        # Mirror the canon for the first half.
        # If there's an odd number of bars, constrain half the middle bar to mirror the other half.
        if (@metadata.get_number_of_bars % 2 == 1)
          ((@metadata.get_beats_in_bar - 2) / 2).downto(0) do |beat|
            mirrored_bar = @metadata.get_number_of_bars - bar - 1
            mirrored_beat = @metadata.get_beats_in_bar - beat - 1
            constraints << eq(canon_skeleton[bar][bar][:root_note], canon_skeleton[mirrored_bar][mirrored_beat][:root_note])
          end
        end
        # The first half mirrors the second half.
        for bar in 0..((@metadata.get_number_of_bars - 2) / 2)
          for beat in 0..(@metadata.get_beats_in_bar - 1)
            mirrored_bar = @metadata.get_number_of_bars - bar - 1
            mirrored_beat = @metadata.get_beats_in_bar - beat - 1
            constraints << eq(canon_skeleton[bar][beat][:root_note], canon_skeleton[mirrored_bar][mirrored_beat][:root_note])
          end
        end
      else
        throw "No such type: #{ @metadata.get_type }"
      end
      # Run the query.
      q = fresh
      run(40, q, eq(q, canon_skeleton), *constraints)
    end
    # Choose one to be this canon's structure
    if canon_structure_options.empty?
      raise "No canons available for these settings. Try increasing the range of the piece."
    else
      @canon_skeleton = canon_structure_options.choose
    end
  end

  # ARGS: None.
  # DESCRIPTION: Fleshes out the canon by transforming the beats into multiple notes. (Between 1 and 4).
  # RETURNS: Nil.
  def populate_canon()
    # Pass the variables through to MiniKanren.
    metadata = @metadata
    concrete_scale = @concrete_scale
    canon_skeleton = @canon_skeleton
    chord_progression = @chord_progression
    variations = @variations
    # Begin the logic block.
    populated_canons = MiniKanren.exec do
      extend SonicPi::Lang::Core
      extend SonicPi::RuntimeMethods
      # Get the variables that have been passed through.
      @metadata = metadata
      @concrete_scale = concrete_scale
      canon = canon_skeleton
      @variations = variations
      @chord_progression = chord_progression
      @variation_counter = 0

      def get_next_variation
        this_variation = @variations[@variation_counter]
        @variation_counter = (@variation_counter + 1) % @metadata.get_variations
        return this_variation
      end

      # ARGS: Two notes (midi numbers) and the number of steps needed between them.
      # DESCRIPTION: Finds notes to walk from note 1 to note 2 in a certain number of steps.
      # RETURNS: An array of notes (midi numbers) with this walk.
      def find_walking_notes(note1, note2, number_of_steps = 1)

        # ARGS: An array and a number to choose (n).
        # DESCRIPTION: Picks n numbers at random from the array.
        # RETURNS: Array of n numbers chosen at random from the array.
        def choose_n(array, n)
          sample = []
          for i in 1..n
            sample << array.choose
          end
          return sample
        end

        # Find the index in the scale of the two notes, and get their difference.
        note1_index = @concrete_scale.index(note1)
        note2_index = @concrete_scale.index(note2)
        difference_in_index = note1_index - note2_index
        # Find the notes in between, making sure that the lower note is the first index.
        if note1_index < note2_index
          # Extend the note1 range by 2 if possible.
          for i in 1..2
            if note1_index - 1 > -1
              note1_index = note1_index - 1
            end
          end
          # Extend the note2 range by 2 if possible.
          for i in 1..2
            if note2_index + 1 < @concrete_scale.length
              note2_index = note2_index + 1
            end
          end
          note_walk = choose_n(@concrete_scale[note1_index..note2_index], number_of_steps).sort
        else
          # Extend the note1 range by 2 if possible.
          for i in 1..2
            if note2_index - 1 > -1
              note2_index = note2_index - 1
            end
          end
          # Extend the note2 range by 2 if possible.
          for i in 1..2
            if note1_index + 1 < @concrete_scale.length
              note1_index = note1_index + 1
            end
          end
          note_walk = choose_n(@concrete_scale[note2_index..note1_index], number_of_steps).sort.reverse
        end
        return note_walk
      end

      # ARGS: The current array of constraints, the MiniKanren variables representing the current beat and the next beat (unless this is the last beat in which case the previous beat) and a boolean specifying whether this is the last beat in the piece.
      # DESCRIPTION: Unifies this beat's rhythm and pitches with a more interesting pattern. Randomly pick which transform to do for each beat based on the probabilities.
      # RETURNS: Nil.
      def transform_beat(constraints, current_beat, other_beat, is_last_note, fate)
        # Get the probabilities.
        probabilities = @metadata.get_probabilities
        # Choose which transform to use.
        if fate < probabilities[0]
          # Single transform.
          transform_beat_single(constraints, current_beat)
        elsif fate < probabilities[0] + probabilities[1]
          # Double transform.
          transform_beat_double(constraints, current_beat, other_beat, is_last_note)
        elsif fate < probabilities[0] + probabilities[1] + probabilities[2]
          # Triple transform.
          transform_beat_triple(constraints, current_beat, other_beat, is_last_note)
        else
          # Quadruple transform.
          transform_beat_quadruple(constraints, current_beat, other_beat, is_last_note)
        end
      end

      # ARGS: The current array of constraints and the MiniKanren variable representing the current beat.
      # DESCRIPTION: Unifies this beat's rhythm and pitches with a single note (the root note).
      # RETURNS: Nil.
      def transform_beat_single(constraints, current_beat)
        # This note should be the root.
        constraints << all(eq(current_beat[:rhythm], [Rational(1)]), eq(current_beat[:notes], [current_beat[:root_note]]))
      end

      # ARGS: The current array of constraints, the MiniKanren variables representing the current beat and the next beat (unless this is the last beat in which case the previous beat) and a boolean specifying whether this is the last beat in the piece.
      # DESCRIPTION: Unifies this beat's rhythm and pitches with a double note. The first is the root note, and the second walks to the next beat, unless this is the final note in which case the second note is the root and the first one walks to it.
      # RETURNS: Nil.
      def transform_beat_double(constraints, current_beat, other_beat, is_last_note)
        # Constrain the rhythm.
        constraints << eq(current_beat[:rhythm], [Rational(1,2), Rational(1,2)])
        # Constrain the pitch.
        # Create new variables for each note.
        n1, n2 = fresh(2)
        # Unify this beat's pitch with the two notes.
        constraints << eq(current_beat[:notes], [n1, n2])
        # Both are the root.
        constraints << eq(n1, current_beat[:root_note])
        constraints << eq(n2, current_beat[:root_note])
      end

      # ARGS: The current array of constraints, the MiniKanren variables representing the current beat and the next beat (unless this is the last beat in which case the previous beat) and a boolean specifying whether this is the last beat in the piece.
      # DESCRIPTION: Unifies this beat's rhythm and pitches with a triple note. The first is the root note, and the second and third walk to the next beat, unless this is the final note in which case the third note is the root and the first two walk to it.
      # RETURNS: Nil.
      def transform_beat_triple(constraints, current_beat, other_beat, is_last_note)
        # Constrain the rhythm.
        conde_options = [
          eq(current_beat[:rhythm], [Rational(1,4), Rational(1,4), Rational(1,2)]),
          eq(current_beat[:rhythm], [Rational(1,2), Rational(1,4), Rational(1,4)]),
          eq(current_beat[:rhythm], [Rational(1,3), Rational(1,3), Rational(1,3)])
        ]
        constraints << conde(*conde_options.shuffle)
        # Constrain the pitch.
        # Create new variables for each note.
        n1, n2, n3 = fresh(3)
        # Unify this beat's pitch with the three notes.
        constraints << eq(current_beat[:notes], [n1, n2, n3])
        # The first note is the root and the second two walk to the next root note.
        constraints << eq(n1, current_beat[:root_note])
        constraints << eq([n2], find_walking_notes(current_beat[:root_note], other_beat[:root_note], 1))
        constraints << eq(n3, current_beat[:root_note])
      end

      # ARGS: The current array of constraints, the MiniKanren variables representing the current beat and the next beat (unless this is the last beat in which case the previous beat) and a boolean specifying whether this is the last beat in the piece.
      # DESCRIPTION: Unifies this beat's rhythm and pitches with a quadruple note. The first is the root note, and the second, third and fourth walk to the next beat, unless this is the final note in which case the fourth note is the root and the first three walk to it.
      # RETURNS: Nil.
      def transform_beat_quadruple(constraints, current_beat, other_beat, is_last_note)
        # Constrain the rhythm.
        constraints << eq(current_beat[:rhythm], [Rational(1,4), Rational(1,4), Rational(1,4), Rational(1,4)])
        # Constrain the pitch.
        # Create new variables for each note.
        n1, n2, n3, n4 = fresh(4)
        # Unify this beat's pitch with the four notes.
        constraints << eq(current_beat[:notes], [n1, n2, n3, n4])
        # The first note is the root and the second two walk to the next root note.
        constraints << eq(n1, current_beat[:root_note])
        constraints << eq([n2, n3], find_walking_notes(current_beat[:root_note], other_beat[:root_note], 2))
        constraints << eq(n4, current_beat[:root_note])
      end

      def transform_beat_intelligent(constraints, canon, variation, bar, beat)
        other_beat = nil
        is_last_note = false
        if beat < @metadata.get_beats_in_bar - 1 # If the next beat is in this bar, constrain using next beat.
          other_beat = canon[bar][beat + 1]
        elsif bar < (@chord_progression.length / @metadata.get_beats_in_bar) - 1 # Else, if it's in the next, constrain using that beat.
          other_beat = canon[bar + 1][0]
        else # Else, if there is no next beat (last in variation) then transform with previous beat.
          other_beat = canon[bar][beat - 1]
          is_last_note = true
        end
        transform_beat(constraints, canon[bar][beat], other_beat, is_last_note, variation[beat])
      end

      def are_mirrored(mirror_beat, ground_beat)
        return project(ground_beat, lambda do |ground_beat|
          all(
          eq(mirror_beat[:rhythm], ground_beat[:rhythm].reverse),
          eq(mirror_beat[:notes], ground_beat[:notes].reverse)
          )
        end)
      end

      # Initialise canon and constraints.
      constraints = []
      # Make the notes and rhythms into fresh variables.
      for bar in 0..canon.length - 1
        for beat in 0..canon[bar].length - 1
          canon[bar][beat][:rhythm] = fresh
          canon[bar][beat][:notes] = fresh
        end
      end
      # Treat each type differently.
      case @metadata.get_type
      when :round
        # Cycle through the bars, tranforming them.
        for bar in 0..@metadata.get_number_of_bars - 1
          variation = get_next_variation
          for beat in 0..@metadata.get_beats_in_bar - 1
            transform_beat_intelligent(constraints, canon, variation, bar, beat)
          end
        end
      when :crab
        # Cycle through copies of the chord progression, alternately mirroring and transforming.
        # Is this version of the chord progression a mirror of the next?
        mirror = false # MUST start with false.
        # For the number of cycles of the chord progression that happen in this piece.
        ((@metadata.get_number_of_bars - 1) / @metadata.get_bars_per_chord_prog).downto(0) do |chord_progression_count|
          # For the offset of bars within this (up to length of chord progression).
          (@metadata.get_bars_per_chord_prog - 1).downto(0) do |bar_offset|
            # Find the actual bar number.
            bar = chord_progression_count * @metadata.get_bars_per_chord_prog + bar_offset
            if mirror
              # Mirror the notes.
              (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
                mirrored_bar = (chord_progression_count + 1) * @metadata.get_bars_per_chord_prog + (@metadata.get_bars_per_chord_prog - 1 - bar_offset)
                mirrored_beat = @metadata.get_beats_in_bar - 1 - beat
                constraints << are_mirrored(canon[bar][beat], canon[mirrored_bar][mirrored_beat])
              end
            else
              # Just do the transform.
              variation = get_next_variation
              (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
                transform_beat_intelligent(constraints, canon, variation, bar, beat)
              end
            end
          end
          # Flip whether we're mirroring or not.
          mirror = !mirror
        end
      when :palindrome
        # Cycle through to half way through the melody doing the transforms. Exclude central one if odd number of bars.
        (@metadata.get_number_of_bars - 1).downto((@metadata.get_number_of_bars + 1) / 2) do |bar|
          variation = get_next_variation
          (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
            transform_beat_intelligent(constraints, canon, variation, bar, beat)
          end
        end
        # ASSERT: the last half is transformed, excluding middle bar if there's an odd number of bars.
        # If there's an odd number of bars, deal with the middle one.
        if (@metadata.get_number_of_bars % 2 == 1)
          variation = get_next_variation
          (@metadata.get_beats_in_bar - 1).downto((@metadata.get_beats_in_bar - 1) / 2) do |beat|
            transform_beat_intelligent(constraints, canon, variation, bar, beat)
          end
        end
        # ASSERT: half the canon is unified.
        # Mirror the canon for the first half.
        # If there's an odd number of bars, constrain half the middle bar to mirror the other half.
        if (@metadata.get_number_of_bars % 2 == 1)
          ((@metadata.get_beats_in_bar - 2) / 2).downto(0) do |beat|
            mirrored_bar = @metadata.get_number_of_bars - bar - 1
            mirrored_beat = @metadata.get_beats_in_bar - beat - 1
            constraints << are_mirrored(canon[bar][beat], canon[mirrored_bar][mirrored_beat])
          end
        end
        # The first half mirrors the second half.
        for bar in 0..((@metadata.get_number_of_bars - 2) / 2)
          for beat in 0..(@metadata.get_beats_in_bar - 1)
            mirrored_bar = @metadata.get_number_of_bars - bar - 1
            mirrored_beat = @metadata.get_beats_in_bar - beat - 1
            constraints << are_mirrored(canon[bar][beat], canon[mirrored_bar][mirrored_beat])
          end
        end
      else
        throw "No such type: #{ @metadata.get_type }"
      end
      # Run the query using q, a fresh query variable.
      q = fresh
      run(40, q, eq(q, canon), *constraints)
    end
    # Choose one of the canons.
    @canon_complete = populated_canons.choose
  end
end
