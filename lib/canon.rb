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
    @canon_skeletons = nil
    @canon_complete = nil
    # Generate the canon.
    generate_concrete_scale()
    generate_chord_progression()
    generate_canon_skeleton()
    #populate_canon()
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

  ## TODO DELETE
  def get_skel()
    return @canon_skeletons
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
    concrete_scale = SonicPi::Scale.new(min_tonic, @metadata.get_key_type, num_octaves = num_octaves).notes
    # Convert to an array and trim to range
    concrete_scale = concrete_scale.to_a
    concrete_scale.delete_if { |note| (lowest_note != nil && note < lowest_note) || (highest_note != nil && note > highest_note) }
    # Set the member variable.
    @concrete_scale = concrete_scale
  end

  # ARGS: None.
  # DESCRIPTION: Generates a chord progression at random if one does not already exist.
  # RETURNS: Nil.
  def generate_chord_progression()
    # If the chord progression is given, do nothing except check it for consistency, else generate it.
    if @metadata.get_chord_progression != nil
      # Already exists.
      # The length of the chord progression must be the same as the number of beats in the bar.
      if @metadata.get_chord_progression.length % @metadata.get_beats_in_bar != 0
        raise "Chord progression must be a multiple of bars in length."
      elsif [:crab, :palindrome].include?(@metadata.get_type) && !(@metadata.get_chord_progression == @metadata.get_chord_progression.reverse)
        # If this is a crab canon or palindrome, the progression must be symmetrical.
        raise "Chord progression must be symmetrical for a #{ @metadata.get_type } canon."
      end
    else
      # Does not already exist.
      # Create a new array with a chord for each beat, one or two bars long.
      number_of_bars_in_prog = [1,2].choose
      chord_progression = Array.new(@metadata.get_beats_in_bar * number_of_bars_in_prog)
      # State which chords are available
      chord_choice = [:I, :IV, :V, :VI]
      if @metadata.get_type == :round
        # Choose each chord at random except the last two which are always V-I (perfect cadence)
        for i in 0..chord_progression.length - 3
          chord_progression[i] = chord_choice.choose
        end
        chord_progression[chord_progression.length - 2] = :V
        chord_progression[chord_progression.length - 1] = :I
      elsif @metadata.get_type == :crab || @metadata.get_type == :palindrome
        # The first two chords must be I-V for a perfect cadence when it is reversed.
        chord_progression[0] = :I
        chord_progression[1] = :V
        # The rest of the first half are unconstrained.
        for i in 2..((chord_progression.length - 1) / 2)
          chord_progression[i] = chord_choice.choose
        end
        # The second half is a mirror of the first.
        for i in (((chord_progression.length - 1) / 2) + 1)..(chord_progression.length - 1)
          chord_progression[i] = chord_progression[chord_progression.length - (i + 1)]
        end
      else
        raise "Unknown canon type: #{ @metadata.get_type }."
      end
      # Set the member variable.
      @metadata.chord_progression(chord_progression)
    end
  end

  # ARGS: None.
  # DESCRIPTION: Populates the canon skeleton using the key and scale to find good root notes for each beat.
  # RETURNS: Nil.
  def generate_canon_skeleton()
    # Pass the variables through to MiniKanren.
    metadata = @metadata
    concrete_scale = @concrete_scale
    # Begin the logic block.
    canon_structure_options = MiniKanren.exec do
      # Get the variables that have been passed through.
      @metadata = metadata
      @concrete_scale = concrete_scale
      # Extend MiniKanren so that Sonic Pi's methods can be used.
      extend SonicPi::Lang::Core
      extend SonicPi::RuntimeMethods
      # Generate the array of skeletons, the number specified by the number of variations. For palindromes and crab, multiply by 2.
      canon_skeletons = nil
      if @metadata.get_type == :round
        canon_skeletons = Array.new(@metadata.get_variations)
      else
        canon_skeletons = Array.new(@metadata.get_variations * 2)
      end
      # For each skeleton, create the structure depending on the chord progression.
      bars_per_variation = @metadata.get_chord_progression.length / @metadata.get_beats_in_bar
      # For each variation, create an array of bars.
      for variation in 0..@metadata.get_variations - 1
        canon_skeletons[variation] = Array.new(bars_per_variation)
        # For each bar, create an array of beats.
        for bar in 0..bars_per_variation - 1
          canon_skeletons[variation][bar] = Array.new(@metadata.get_beats_in_bar)
          for beat in 0..@metadata.get_beats_in_bar - 1
            canon_skeletons[variation][bar][beat] = {root_note: fresh, rhythm: nil, notes: nil}
          end
        end
      end
      # Initialise constraints.
      constraints = []
      # CONSTRAINT: Final root note of each variation is the tonic.
      # Find all the tonics in the given range and add their disjunction as a constraint.
      mod_tonic = SonicPi::Note.resolve_midi_note(metadata.get_key_note) % 12
      tonics_in_scale = @concrete_scale.select { |note| (note % 12) == mod_tonic }
      conde_options = []
      # For each variation, add that the final beat is a tonic.
      for variation in 0..@metadata.get_variations - 1
        tonics_in_scale.map { |tonic| conde_options << eq(canon_skeletons[variation][bars_per_variation - 1][@metadata.get_beats_in_bar - 1][:root_note], tonic) }
      end
      constraints << conde(*conde_options)
      # Crabs and palindromes also need the first note to be the tonic.
      conde_options = []
      if @metadata.get_type == :crab || @metadata.get_type == :palindrome
        for variation in 0..@metadata.get_variations - 1
          tonics_in_scale.map { |tonic| conde_options << eq(canon_skeletons[variation][0][0][:root_note], tonic) }
        end
        constraints << conde(*conde_options)
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

      # ARGS: MiniKanren variables: the current beat's root note, the next beats's root note and the notes that have already been used in this position. The name of the chord assciated with this beat.
      # DESCRIPTION: This method adds constraints on the current beat to constrain it to:
      # 1) A note in the scale given
      # 2) A note not exceeding max_jump distance from the next
      # 3) Not the same note as in other variations in the same position.
      # 4) For crabs and palindromes, not the same as the note in the mirrored position.
      # It fails if no such unification exists.
      # RETURNS: The project constraint which contains all this information.
      def constrain_to_possible_notes(current_beat_var, next_beat_var, chord_name, unavailable_notes)
        # Get all notes in the right chord.
        possible_notes = notes_in_chord(chord_name)
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
              conde(*conde_options)
            end
          end)
        end)
      end

      def constrain_to_possible_notes_no_next_beat(current_beat_var, chord_name, unavailable_notes)
        # Get all notes in the right chord.
        possible_notes = notes_in_chord(chord_name)
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
            conde(*conde_options)
          end
        end)
      end

      # CONSTRAINT: All beats must be in the relevant chord, within max_jump in either direction from the next (but not the same), and not be the same as that in the same position in a different variation. For crabs and palindromes, the notes in the mirrored places must also not clash.
      for variation in 0..@metadata.get_variations - 1
        (bars_per_variation - 1).downto(0) do |bar|
          (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
            # The used notes are any in previous variations in this position.
            used_notes_in_this_position = []
            for prev_variation in 0..variation - 1
              used_notes_in_this_position << canon_skeletons[prev_variation][bar][beat][:root_note]
            end
            # If this is a crab or palindrome, and we are in the FIRST HALF of the piece, we cannot use the mirrored part.
            if @metadata.get_type == :crab || @metadata.get_type == :palindrome
              if bar < bars_per_variation / 2.0 && ((bar == bars_per_variation / 2) ? (beat < get_beats_in_bar / 2) : true)
                mirrored_bar = bars_per_variation - (bar + 1)
                mirrored_beat = @metadata.get_beats_in_bar - (beat + 1)
                # Add constraint for all mirror parts of variations already unified, including this one.
                for prev_variation in 0..variation
                  used_notes_in_this_position << canon_skeletons[prev_variation][mirrored_bar][mirrored_beat][:root_note]
                end
              end
            end
            # Find the chord for this beat.
            number_of_bars_in_prog = @metadata.get_chord_progression.length / @metadata.get_beats_in_bar
            chord_index = beat + @metadata.get_beats_in_bar * (bar % number_of_bars_in_prog)
            chord_for_beat = @metadata.get_chord_progression[chord_index]
            # If this is the final beat of a variation, use the method with only the current beat.
            if (bar == number_of_bars_in_prog - 1 && beat == @metadata.get_beats_in_bar - 1)
              new_constraint = constrain_to_possible_notes_no_next_beat(canon_skeletons[variation][bar][beat][:root_note], chord_for_beat, used_notes_in_this_position)
              constraints << new_constraint
            else # If not the last beat, constrain the current beat in relation to the next one.
              if beat < @metadata.get_beats_in_bar - 1
                # Next beat is in the same bar
                new_constraint = constrain_to_possible_notes(canon_skeletons[variation][bar][beat][:root_note], canon_skeletons[variation][bar][beat + 1][:root_note], chord_for_beat, used_notes_in_this_position)
                constraints << new_constraint
              else
                # Next beat is in the next bar
                new_constraint = constrain_to_possible_notes(canon_skeletons[variation][bar][beat][:root_note], canon_skeletons[variation][bar + 1][beat][:root_note], chord_for_beat, used_notes_in_this_position)
                constraints << new_constraint
              end
            end
          end
        end
      end
      # Run the query.
      q = fresh
      run(1000, q, eq(q, canon_skeletons), *constraints)
    end
    # Choose one to be this canon's structure
    if canon_structure_options.empty?
      raise "No canons available for these settings. Try increasing the range of the piece."
    else
      @canon_skeletons = canon_structure_options.choose
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
    # Begin the logic block.
    canon_completed_options = MiniKanren.exec do
      extend SonicPi::Lang::Core
      extend SonicPi::RuntimeMethods
      # Get the variables that have been passed through.
      @metadata = metadata
      @concrete_scale = concrete_scale
      @canon_skeleton = canon_skeleton

      # ARGS: Two notes (midi numbers) ad the number of steps needed between them.
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
          note_walk = choose_n(@concrete_scale[note1_index..note2_index], number_of_steps).sort
        else
          note_walk = choose_n(@concrete_scale[note2_index..note1_index], number_of_steps).sort.reverse
        end
        return note_walk
      end

      # ARGS: The current array of constraints, the MiniKanren variables representing the current beat and the next beat (unless this is the last beat in which case the previous beat) and a boolean specifying whether this is the last beat in the piece.
      # DESCRIPTION: Unifies this beat's rhythm and pitches with a more interesting pattern. Randomly pick which transform to do for each beat based on the probabilities.
      # RETURNS: Nil.
      def transform_beat(constraints, current_beat, other_beat, is_last_note)
        # Get the probabilities.
        probabilities = @metadata.get_probabilities
        # Randomly choose a value between 0 and 1 to decide which transform to use.
        fate = rand()
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
        if is_last_note
          # This is the final note of the piece. Unify the second note with the root and the first with a walking note.
          constraints << eq(n2, current_beat[:root_note])
          # Project the previous beat so that we can find a walking note from it.
          constraints << project(other_beat, lambda do |prev|
            return eq([n1], find_walking_notes(prev[:notes].last, current_beat[:root_note], 1))
          end)
        else
          # The first note is the root and the second walks to the next root note.
          constraints << eq(n1, current_beat[:root_note])
          constraints << eq([n2], find_walking_notes(current_beat[:root_note], other_beat[:root_note], 1))
        end
      end

      # ARGS: The current array of constraints, the MiniKanren variables representing the current beat and the next beat (unless this is the last beat in which case the previous beat) and a boolean specifying whether this is the last beat in the piece.
      # DESCRIPTION: Unifies this beat's rhythm and pitches with a triple note. The first is the root note, and the second and third walk to the next beat, unless this is the final note in which case the third note is the root and the first two walk to it.
      # RETURNS: Nil.
      def transform_beat_triple(constraints, current_beat, other_beat, is_last_note)
        # Constrain the rhythm.
        constraints << conde(
        eq(current_beat[:rhythm], [Rational(1,4), Rational(1,4), Rational(1,2)]),
        eq(current_beat[:rhythm], [Rational(1,2), Rational(1,4), Rational(1,4)]),
        eq(current_beat[:rhythm], [Rational(1,3), Rational(1,3), Rational(1,3)])
        )
        # Constrain the pitch.
        # Create new variables for each note.
        n1, n2, n3 = fresh(3)
        # Unify this beat's pitch with the three notes.
        constraints << eq(current_beat[:notes], [n1, n2, n3])
        if is_last_note
          # This is the final note of the piece. Unify the third note with the root and the first two with walking notes.
          constraints << eq(n3, current_beat[:root_note])
          # Project the previous beat so that we can find a walking note from it.
          constraints << project(other_beat, lambda do |prev|
            return eq([n1, n2], find_walking_notes(prev[:notes].last, current_beat[:root_note], 2))
          end)
        else
          # The first note is the root and the second two walk to the next root note.
          constraints << eq(n1, current_beat[:root_note])
          constraints << eq([n2, n3], find_walking_notes(current_beat[:root_note], other_beat[:root_note], 2))
        end
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
        if is_last_note
          # This is the final note of the piece. Unify the fourth note with the root and the first three with walking notes.
          constraints << eq(n4, current_beat[:root_note])
          # Project the previous beat so that we can find a walking note from it.
          constraints << project(other_beat, lambda do |prev|
            return eq([n1, n2, n3], find_walking_notes(prev[:notes].last, current_beat[:root_note], 3))
          end)
        else
          # The first note is the root and the second two walk to the next root note.
          constraints << eq(n1, current_beat[:root_note])
          constraints << eq([n2, n3, n4], find_walking_notes(current_beat[:root_note], other_beat[:root_note], 3))
        end
      end

      # Initialise canon and constraints.
      constraints = []
      canon = @canon_skeleton
      # Make the notes and rhythms into fresh variables.
      for i in 0..canon.length - 1
        for j in 0..canon[i].length - 1
          canon[i][j][:rhythm] = fresh
          canon[i][j][:notes] = fresh
        end
      end
      # Transform all the beats.
      for i in 0..canon.length - 1
        for j in 0..@metadata.get_beats_in_bar - 1
          other_beat = nil
          is_last_note = false
          # is the next beat in this bar?
          if j == canon[i].length - 1
            # NO, is it in the next?
            if i == canon.length - 1
              # NO (there is no next beat- this is the final beat).
              other_beat = canon[i][j - 1]
              is_last_note = true
            else
              # YES (the next beat is the first beat of the next bar).
              other_beat = canon[i + 1][0]
            end
          else
            # YES (the next beat is in this bar).
            other_beat = canon[i][j + 1]
          end
          transform_beat(constraints, canon[i][j], other_beat, is_last_note)
        end
      end
      # Run the query using q, a fresh query variable.
      q = fresh
      run(1000, q, eq(q, canon), *constraints)
    end
    # Choose one of the canons.
    @canon_complete = canon_completed_options.choose
  end
end
