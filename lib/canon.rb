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
    @canon_complete = nil
    # Generate the canon.
    generate_concrete_scale()
    generate_chord_progression()
    generate_variations()
    generate_canon()
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
    # Multiply the total number of bars by the variation percentage.
    number_to_generate = (@metadata.get_number_of_bars * (@metadata.get_variations / 100.0)).ceil
    for variation in 0..number_to_generate - 1
      this_variation = []
      for beat in 0..@metadata.get_beats_in_bar - 1
        this_variation << rand()
      end
      @variations << this_variation
    end
  end

  def generate_canon()
    # Pass the variables through to MiniKanren.
    metadata = @metadata
    concrete_scale = @concrete_scale
    chord_progression = @chord_progression
    variations = @variations
    # Begin the logic block.
    canon_structure_options = MiniKanren.exec do
      # Get the variables that have been passed through.
      @metadata = metadata
      @concrete_scale = concrete_scale
      @chord_progression = chord_progression
      @variations = variations
      # Extend MiniKanren so that Sonic Pi's methods can be used.
      extend SonicPi::Lang::Core
      extend SonicPi::RuntimeMethods
      # Generate the canon skeleton structure, with root notes and notes as fresh variables.
      canon_skeleton = Array.new(@metadata.get_number_of_bars) # One cell per bar.
      for bar in 0..@metadata.get_number_of_bars - 1
        canon_skeleton[bar] = Array.new(@metadata.get_beats_in_bar) # One cell per beat.
        for beat in 0..@metadata.get_beats_in_bar - 1
          canon_skeleton[bar][beat] = {root_note: fresh, notes: fresh, rhythm: nil} # The root note is a variable.
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

      def set_rhythm(canon_skeleton, bar, beat)
        # Find the random value associated with this beat.
        value_for_beat = @variations[bar % (@variations.length)][beat]
        # Get the probabilities for splitting the note.
        probabilities = @metadata.get_probabilities
        # If this is the last note then don't split it, otherwise use the value to find out which to transform it to.
        if bar == canon_skeleton.length - 1 && beat == @metadata.get_beats_in_bar - 1
          canon_skeleton[bar][beat][:rhythm] = [Rational(1)]
        else
          if value_for_beat < probabilities[0] # Single note.
            canon_skeleton[bar][beat][:rhythm] = [Rational(1)]
          elsif value_for_beat < probabilities[0] + probabilities[1] # Two notes.
            canon_skeleton[bar][beat][:rhythm] = [Rational(1,2), Rational(1,2)]
          elsif value_for_beat < probabilities[0] + probabilities[1] + probabilities[2] # Three notes
            canon_skeleton[bar][beat][:rhythm] = [
              [Rational(1,2), Rational(1,4), Rational(1,4)],
              [Rational(1,4), Rational(1,4), Rational(1,2)]
            ].choose
          else # Four notes.
            canon_skeleton[bar][beat][:rhythm] = [Rational(1,4), Rational(1,4), Rational(1,4), Rational(1,4)]
          end
        end
      end

      def unify_note(note_var, next_note_var, root_note, overlapping_notes)
        # Find notes between this note and the next.
        return project(next_note_var, lambda do |next_note|
          project(root_note, lambda do |root_note|
            project(overlapping_notes, lambda do |overlapping_note|
              # Find the index in the scale of the two notes, and get their difference.
              root_index = @concrete_scale.index(root_note)
              next_note_index = @concrete_scale.index(next_note)
              # Find the notes in between, making sure that the lower note is the first index.
              if root_index < next_note_index
                possible_notes = @concrete_scale[root_index..next_note_index]
              else
                possible_notes = @concrete_scale[next_note_index..root_index]
              end
              # Select only those notes that don't overlap.
              possible_notes = possible_notes.select { |possible_note| !overlapping_notes.include?(possible_note) }
              # Add all these possible notes as options.
              conde_options = []
              possible_notes.map do |possible_note|
                conde_options << eq(note_var, possible_note)
              end
              conde(*conde_options.shuffle)
            end)
          end)
        end)
      end

      # Initialise constraints.
      constraints = []
      # CONSTRAINT (ALL): Final root note is the tonic.
      constraints << constrain_to_possible_notes(canon_skeleton[@metadata.get_number_of_bars - 1][@metadata.get_beats_in_bar - 1][:root_note], nil, :tonic, [])
      # Deal with the types individually. Add constrints for the root notes, and add in the rhythm.
      case @metadata.get_type
      when :round
        # Cycle through the bars, adding constraints that each note is in the chord and different to overlapping ones.
        (@metadata.get_number_of_bars - 1).downto(0) do |bar|
          (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
            add_constraints(constraints, canon_skeleton, bar, beat)
            set_rhythm(canon_skeleton, bar, beat)
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
                # Rhythm is the reverse of the mirrored beat.
                canon_skeleton[bar][beat][:rhythm] = canon_skeleton[mirrored_bar][mirrored_beat][:rhythm].reverse
              end
            else
              # Just generate some more music.
              (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
                add_constraints(constraints, canon_skeleton, bar, beat)
                set_rhythm(canon_skeleton, bar, beat)
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
            set_rhythm(canon_skeleton, bar, beat)
          end
        end
        # ASSERT: the last half is unified, excluding middle bar if there's an odd number of bars.
        # If there's an odd number of bars, deal with the middle one.
        if (@metadata.get_number_of_bars % 2 == 1)
          (@metadata.get_beats_in_bar - 1).downto((@metadata.get_beats_in_bar - 1) / 2) do |beat|
            add_constraints(constraints, canon_skeleton,bar, beat)
            set_rhythm(canon_skeleton, bar, beat)
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
            # Rhythm is the reverse of the mirrored beat.
            canon_skeleton[bar][beat][:rhythm] = canon_skeleton[mirrored_bar][mirrored_beat][:rhythm].reverse
          end
        end
        # The first half mirrors the second half.
        for bar in 0..((@metadata.get_number_of_bars - 2) / 2)
          for beat in 0..(@metadata.get_beats_in_bar - 1)
            mirrored_bar = @metadata.get_number_of_bars - bar - 1
            mirrored_beat = @metadata.get_beats_in_bar - beat - 1
            constraints << eq(canon_skeleton[bar][beat][:root_note], canon_skeleton[mirrored_bar][mirrored_beat][:root_note])
            # Rhythm is the reverse of the mirrored beat.
            canon_skeleton[bar][beat][:rhythm] = canon_skeleton[mirrored_bar][mirrored_beat][:rhythm].reverse
          end
        end
      else
        throw "No such type: #{ @metadata.get_type }"
      end
      # ASSERT: the root notes now have been unified, and the rhythm is fixed.
      # Now deal with the pitches of the notes.
      # Cycle through the canon, creating new arrays of fresh variables for the notes.
      for bar in 0..canon_skeleton.length - 1
        for beat in 0..canon_skeleton[bar].length - 1
          number_of_notes = canon_skeleton[bar][beat][:rhythm].length
          canon_skeleton[bar][beat][:notes] = Array.new(number_of_notes)
          for note in 0..number_of_notes - 1
            canon_skeleton[bar][beat][:notes][note] = fresh
          end
        end
      end
      # Cycle through the bars, last bar first, unifying first note with the root and the others with notes that don't clash with overlapping notes.
      # Treat each type differently.
      case @metadata.get_type
      when :round
        # Cycle through the bars, tranforming them, last first.
        (@metadata.get_number_of_bars - 1).downto(0) do |bar|
          (@metadata.get_beats_in_bar - 1).downto(0) do |beat|
            current_beat = canon_skeleton[bar][beat]
            # For each note except the first, find those overlapping notes and unify it with those remaining.
            (canon_skeleton[bar][beat][:notes].length - 1).downto(1) do |note|
              # Find the next note.
              next_note = nil
              if note == current_beat[:notes].length - 1
              # Next note is in next beat (the root note of it).
                if beat == @metadata.get_beats_in_bar - 1
                  # The next beat is in the next bar- the root note.
                  next_note = canon_skeleton[bar + 1][0][:root_note]
                else
                  # The next beat is in this bar.
                  next_note = canon_skeleton[bar][beat + 1][:root_note]
                end
              else
                # The next note is in this beat.
                next_note = current_beat[:notes][note + 1]
              end
              # Find the overlapping notes.
              overlapping_notes = []
              # Get overlapping notes, and call them parallel beats.
              for overlapping_bar in (bar + 1)..(bar + (@metadata.get_number_of_voices - 1) * @metadata.get_bars_per_chord_prog)
                # If this bar exists then add the corresponding beat to the one to watch.
                if overlapping_bar < @metadata.get_number_of_bars
                  overlapping_beat = canon_skeleton[overlapping_bar][beat]
                  # Split on the rhythm for THE OVERLAPPING beat
                  case overlapping_beat[:rhythm].length
                  when 1
                    # Defintely overlaps
                    overlapping_notes << overlapping_beat[:root_note]
                  when 2
                    # In all cases except the 2nd note of the 3 way split (0.25, 0.25, 0.5) and 4 way split, we clash with the second note.
                    if note == 1 && current_beat[:rhythm][0] == Rational(1,4) && current_beat[:rhythm][1] == Rational(1,4)
                      overlapping_notes << overlapping_beat[:notes][0]
                    else
                      overlapping_notes << overlapping_beat[:notes][1]
                    end
                  when 3
                    # Check the rhythm of the overlapping note.
                    if current_beat[:rhythm] == [Rational(1,4), Rational(1,4), Rational(1,2)]
                      # In all cases except the 2nd note of the 3 way split (0.25, 0.25, 0.5) and 4 way split, we clash with the third note.
                      if note == 1 && current_beat[:rhythm][0] == Rational(1,4) && current_beat[:rhythm][1] == Rational(1,4)
                        overlapping_notes << overlapping_beat[:notes][1]
                      else
                        overlapping_notes << overlapping_beat[:notes][2]
                      end
                    else
                      # The 2nd note of the 3 way split (0.25, 0.25, 0.5) and 4 way split, we clash with the first note
                      if note == 1 && current_beat[:rhythm][0] == Rational(1,4) && current_beat[:rhythm][1] == Rational(1,4)
                        overlapping_notes << overlapping_beat[:root_note]
                      elsif current_beat[:rhythm].length == 2 || current_beat[:rhythm] == [Rational(1,4), Rational(1,4), Rational(1,2)]
                        # If this is the second note of the two way split or the third of the three way (0.25, 0.25, 0.5) split then we clash with the second AND third of the overlap.
                        overlapping_notes = overlapping_notes + overlapping_beat[:notes][1..2]
                      elsif current_beat[:rhythm].length == 3
                        # If this is the three way split then if corresponds to the equivalent note in the bar.
                        overlapping_notes << overlapping_beat[:notes][note]
                      else
                        # This is the four way split so corresponds to -1 of the index
                        overlapping_notes << overlapping_beat[:notes][note - 1]
                      end
                    end
                  when 4
                    # The 2nd note of the 3 way split (0.25, 0.25, 0.5) and 4 way split, we clash with the second note
                    if note == 1 && current_beat[:rhythm][0] == Rational(1,4) && current_beat[:rhythm][1] == Rational(1,4)
                      overlapping_notes << overlapping_beat[:notes][1]
                    elsif current_beat[:rhythm].length == 2 || current_beat[:rhythm] == [Rational(1,4), Rational(1,4), Rational(1,2)]
                      # If this is the second note of the two way split or the third of the three way (0.25, 0.25, 0.5) split then we clash with the third AND fourth of the overlap.
                      overlapping_notes = overlapping_notes + overlapping_beat[:notes][2..3]
                    elsif current_beat[:rhythm].length == 3
                      # If this is the three way split then if corresponds to the equivalent note in the bar + 1.
                      overlapping_notes << overlapping_beat[:notes][note + 1]
                    else
                      # This is the four way split so corresponds to the equivalent note.
                      overlapping_notes << overlapping_beat[:notes][note]
                    end
                  end
                end
              end
              constraints << unify_note(canon_skeleton[bar][beat][:notes][note], next_note, canon_skeleton[bar][beat][:root_note], overlapping_notes)
            end
            # Set the first note to be the root note.
            constraints << eq(canon_skeleton[bar][beat][:notes][0], canon_skeleton[bar][beat][:root_note])
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

      # Run the query.
      q = fresh
      run(40, q, eq(q, canon_skeleton), *constraints)
    end
    # Choose one to be this canon's structure
    if canon_structure_options.empty?
      raise "No canons available for these settings. Try increasing the range of the piece."
    else
      @canon_complete = canon_structure_options.choose
    end
  end
end
