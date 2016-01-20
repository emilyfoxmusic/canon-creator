require "mini_kanren"

# This contains a fully fleshed-out canon, with a link to the matadata that created it
class Canon
  def initialize(metadata)
    @metadata = metadata.clone() # We don't want the original version to change when we fiddle arond with it here.
    @concrete_scale = nil
    @canon_skeleton = nil
    @canon_complete = nil
  end

  def get_concrete_scale()
    return @concrete_scale
  end

  def get_chord_prog()
    return @metadata.get_chord_progression
  end

  def get_canon_skeleton()
    return @canon_skeleton
  end

  def get_canon_complete()
    return @canon_complete
  end

  def generate_concrete_scale()
    # Find the highest tonic lower than the lower limit
    min_tonic = SonicPi::Note.resolve_midi_note_without_octave(@metadata.get_key_note)
    lowest_note = SonicPi::Note.resolve_midi_note(@metadata.get_lowest_note)
    while lowest_note < min_tonic
      min_tonic -= 12
    end

    # Find the lowest tonic higher than the upper limit
    max_tonic = SonicPi::Note.resolve_midi_note(@metadata.get_key_note)
    highest_note = SonicPi::Note.resolve_midi_note(@metadata.get_highest_note)
    while highest_note > max_tonic
      max_tonic += 12
    end

    # ASSERT: the whole range is encompassed between the two tonics- min and max

    # Get the scale between those tonics
    num_octaves = (max_tonic - min_tonic) / 12
    concrete_scale = SonicPi::Scale.new(min_tonic, @metadata.get_key_type, num_octaves = num_octaves).notes

    # Convert to an array and trim to range
    concrete_scale = concrete_scale.to_a
    concrete_scale.delete_if { |note| (lowest_note != nil && note < lowest_note) || (highest_note != nil && note > highest_note) }
    @concrete_scale = concrete_scale
    puts @concrete_scale
  end

  def generate_chord_progression()
    # If the chord progression is given, do nothing except check it for consistency, else generate it.
    if @metadata.get_chord_progression != nil
      # The length of the chord progression must be the same as the number of beats in the bar
      if @metadata.get_chord_progression.length != @metadata.get_beats_in_bar
        raise "The chord progression given is not consistent with the time signature; the number of chords must match the beats in the bar."
      end
    else
      # Create a new array with a chord for each beat
      chord_progression = Array.new(@metadata.get_beats_in_bar)
      # State which chords are available
      chord_choice = [:I, :IV, :V, :VI]
      # Choose each chord at random except the last two which are always IV-I or V-I (plagal or perfect cadence)
      for i in 0..chord_progression.length - 3
        chord_progression[i] = chord_choice.choose
      end
      chord_progression[chord_progression.length - 2] = [:IV, :V].choose
      chord_progression[chord_progression.length - 1] = :I
      @metadata.chord_progression(chord_progression)
      return chord_progression
    end
  end

  def generate_canon_skeleton()
    metadata = @metadata # TODO: get a less hacky fix for passing the variables around!!
    concrete_scale = @concrete_scale
    # Use MiniKanren to get compatible notes
    canon_structure_options = MiniKanren.exec do
      @metadata = metadata
      @concrete_scale = concrete_scale
      extend SonicPi::Lang::Core
      extend SonicPi::RuntimeMethods
      # Generate the structure with the root notes as fresh variables
      canon = Array.new(@metadata.get_beats_in_bar)
      for i in 0..canon.length - 1
        canon[i] = Array.new(@metadata.get_beats_in_bar)
        for j in 0..canon[i].length - 1
          canon[i][j] = {root_note: fresh, rhythm: nil, notes: nil}
        end
      end

      # Add constraints
      constraints = []

      ## Add constraint: final root note is the tonic
      ### Find all the tonics in the given range and add their disjunction as a constraint
      mod_tonic = SonicPi::Note.resolve_midi_note(metadata.get_key_note) % 12
      tonics_in_scale = @concrete_scale.select { |note| (note % 12) == mod_tonic }

      conde_options = []
      tonics_in_scale.map { |tonic| conde_options << eq(canon[@metadata.get_beats_in_bar - 1][@metadata.get_beats_in_bar - 1][:root_note], tonic) }

      constraints << conde(*conde_options)

      ## Add constraint on beats, going BACKWARDS from the last. They must be within max_jump in either direction.
      ### Find notes in that chord from the scale
      def notes_in_chord(name)
        mod_tonic = SonicPi::Note.resolve_midi_note(@metadata.get_key_note) % 12
        case name
        when :I
          ### Find mods of notes needed
          ### I is tonics, thirds and fifths
          if @metadata.get_key_type == :major
            mod_third = (mod_tonic + 4) % 12
          else
            mod_third = (mod_tonic + 3) % 12
          end
          mod_fifth = (mod_tonic + 7) % 12
          ### Find notes from scale
          notes_in_I = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_tonic) || (mod_note == mod_third) || (mod_note == mod_fifth)
          end
          return notes_in_I
        when :IV
          ### Find mods of notes needed
          ### IV is fourths, sixths and tonics
          if @metadata.get_key_type == :major
            mod_sixth = (mod_tonic + 9) % 12
          else
            mod_sixth = (mod_tonic + 8) % 12
          end
          mod_fourth = (mod_tonic + 5) % 12
          ### Find notes from scale
          notes_in_IV = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_fourth) || (mod_note == mod_sixth) || (mod_note == mod_tonic)
          end
          return notes_in_IV
        when :V
          ### Find mods of notes needed
          ### V is fifths, sevenths and seconds
          if @metadata.get_key_type == :major
            mod_second = (mod_tonic + 2) % 12
            mod_seventh = (mod_tonic + 11) % 12
          else
            mod_second = (mod_tonic + 1) % 12
            mod_seventh = (mod_tonic + 10) % 12
          end
          mod_fifth = (mod_tonic + 7) % 12
          ### Find notes from scale
          notes_in_V = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_fifth) || (mod_note == mod_seventh) || (mod_note == mod_second)
          end
          return notes_in_V
        when :VI
          ### Find mods of notes needed
          ### VI is sixths, tonics and thirds
          if @metadata.get_key_type == :major
            mod_third = (mod_tonic + 4) % 12
            mod_sixth = (mod_tonic + 9) % 12
          else
            mod_third = (mod_tonic + 3) % 12
            mod_sixth = (mod_tonic + 8) % 12
          end
          ### Find notes from scale
          notes_in_VI = @concrete_scale.select do |note|
            mod_note = note % 12
            (mod_note == mod_sixth) || (mod_note == mod_tonic) || (mod_note == mod_third)
          end
          return notes_in_VI
        else
          raise "Error: unrecognised chord #{ name }"
        end
      end

      def constrain_to_key_and_distance(current_beat_var, next_beat_var, chord_name)

        max_jump = @metadata.get_max_jump
        #puts max_jump

        ### Get all notes in the right chord then keep only those not too far from the next beat
        possible_notes = notes_in_chord(chord_name)
        project(next_beat_var, lambda do |next_beat|
          refined_possibilities = possible_notes.select do |note|
            b = (note - next_beat).abs <= max_jump #&& (note - next_beat).abs != 0
            if b != true && b != false
              raise "BOOOOOM"
            else
              true
            end
          end
          ### Return a conde clause of all these options
          conde_options = []
          refined_possibilities.map do |note|
            conde_options << eq(current_beat_var, note)
          end
          return conde(*conde_options)
        end)
      end

      ### Set the constraint for each note
      (canon.length - 1).downto(0) do |bar|
        (canon[bar].length - 1).downto(0) do |beat|
          ### No constraint for the final beat
          if !(bar == canon.length - 1 && beat == canon[bar].length - 1)
            if beat < canon[bar].length - 1
              ### Next beat is in the same bar
              constraints << constrain_to_key_and_distance(canon[bar][beat][:root_note], canon[bar][beat + 1][:root_note], @metadata.get_chord_progression[beat])
            else
              ### Next beat is in the next bar
              constraints << constrain_to_key_and_distance(canon[bar][beat][:root_note], canon[bar + 1][0][:root_note], @metadata.get_chord_progression[beat])
            end
          end
        end
      end

      ## Successive bars do not have the same note for the same position in the chord
      #      def is_different(*vars)
      #        var1, var2, var3, var4 = *vars
      #        if (var4 == nil)
      #          ### Three args
      #          project(var1,
      #          lambda do |var1| project(var2,
      #            lambda do |var2| project(var3,
      #              lambda do |var3|
      #                (var1 != var2 && var1 != var3 && var2 != var3) ? lambda { |x| x } : lambda { |x| nil }
      #              end)
      #            end)
      #          end)
      #        else
      #          ### Four args
      #          project(var1,
      #          lambda do |var1| project(var2,
      #            lambda do |var2| project(var3,
      #              lambda do |var3| project(var4,
      #                lambda do |var4|
      #                  (var1 != var2 && var1 != var3 && var1 != var4 && var2 != var3 && var2 != var4 && var3 != var4) ? lambda { |x| x } : lambda { |x| nil }
      #                end)
      #              end)
      #            end)
      #          end)
      #        end
      #      end

      ### Set the notes to be different in every bar for each beat
      #      if @metadata.get_beats_in_bar == 3
      #        for j in 0..@metadata.get_beats_in_bar - 1
      #          constraints << is_different(canon[0][j][:root_note], canon[1][j][:root_note], canon[2][j][:root_note])
      #        end
      #      else
      #        for j in 0..@metadata.get_beats_in_bar - 1
      #          constraints << is_different(canon[0][j][:root_note], canon[1][j][:root_note], canon[2][j][:root_note], canon[3][j][:root_note])
      #        end
      #      end

      # Run the query
      q = fresh
      run(50, q, eq(q, canon), *constraints)
    end

    # Choose one to be this structure
    @canon_skeleton = canon_structure_options.choose
  end

  def populate_canon()

    ### TODO: Less hacky way of getting these variables through!
    metadata = @metadata
    concrete_scale = @concrete_scale
    canon_skeleton = @canon_skeleton

    canon_completed_options = MiniKanren.exec do
      extend SonicPi::Lang::Core
      extend SonicPi::RuntimeMethods

      @metadata = metadata
      @concrete_scale = concrete_scale
      @canon_skeleton = canon_skeleton

      ##### FUNCTIONS FOR FINDING SPECIFIC NOTES #####
      # Given two notes, return an array of options for notes that could be used to walk between them in a certain number of steps
      def find_walking_notes(note1, note2, number_of_steps = 1)
        difference_in_index = @concrete_scale.index(note1) - @concrete_scale.index(note2)
        case number_of_steps
        when 1
          # Find the median between the notes (both if there are multiple)
          walking_notes = find_median_note(note1, note2)
          # Add relevant adjacent notes if they are adjacent or the same
          if difference_in_index == 0 || difference_in_index == 1
            walking_notes << get_note_at_offset(note1, 1)
          end
          if difference_in_index == 0 || difference_in_index == -1
            walking_notes << get_note_at_offset(note1, -1)
          end
          return walking_notes
        when 2
          walking_notes = []
          # Choose good notes
          if difference_in_index == 0
            return [
              [get_note_at_offset(note1, 1), get_note_at_offset(note1, -1)],
              [get_note_at_offset(note1, -1), get_note_at_offset(note1, 1)]
            ]
          elsif difference_in_index == 1
            return [
              [get_note_at_offset(note1, 1), get_note_at_offset(note1, -2)],
              [get_note_at_offset(note1, 1), get_note_at_offset(note1, 2)],
              [get_note_at_offset(note1, -2), get_note_at_offset(note1, -3)]
            ]
          elsif difference_in_index == -1
            return [
              [get_note_at_offset(note1, -1), get_note_at_offset(note1, 2)],
              [get_note_at_offset(note1, -1), get_note_at_offset(note1, -2)],
              [get_note_at_offset(note1, 2), get_note_at_offset(note1, 3)]
            ]
          elsif difference_in_index == 2
            return [
              [get_note_at_offset(note1, -1), get_note_at_offset(note1, -3)],
              [get_note_at_offset(note1, -3), get_note_at_offset(note1, -1)],
              [get_note_at_offset(note1, -1), get_note_at_offset(note1, -2)],
              [note1, get_note_at_offset(note1, -1)]
            ]
          elsif difference_in_index == -2
            return [
              [get_note_at_offset(note1, 1), get_note_at_offset(note1, 3)],
              [get_note_at_offset(note1, 3), get_note_at_offset(note1, 1)],
              [get_note_at_offset(note1, 1), get_note_at_offset(note1, 2)],
              [note1, get_note_at_offset(note1, 1)]
            ]
          else
            #TODO: delete this/make it bettttterrr!
            return [
              [note1, note1]
            ]
          end
        when 3
          # TODO: Actually implement this!!!
          return [
            [note1, note1, note1]
          ]
        else
          puts "Error: invalid number of steps. Only 1 or 2 or 3 are valid."
        end
      end

      def find_median_note(note1, note2)
        index_1 = @concrete_scale.index(note1)
        index_2 = @concrete_scale.index(note2)
        median_index = (index_1 + index_2) / 2.0
        lower_median = @concrete_scale[median_index.floor]
        upper_median = @concrete_scale[median_index.ceil]
        if lower_median == upper_median
          return [lower_median]
        else
          return [lower_median, upper_median]
        end
      end

      # Given a note, return the note at that offset in the scale
      def get_note_at_offset(note, offset)
        index = @concrete_scale.index(note)
        index = index + offset
        return @concrete_scale[index]
      end
      ################################################

      ########### TRANSFORMATION FUNCTIONS ###########
      # Transform this beat into a more interesting melody, taking into account the previous beat if this is the last one in the piece, or the next beat otherwise
      # v1.0 supports up to a four way split
      # The logic does not supply every option for every variable else it would be too inefficient. Rhythm is hardcoded in v1.0, based on the random variable
      def transform_beat(constraints, current_beat, other_beat, is_last_note)
        probabilities = @metadata.get_probabilities

        fate = rand()
        if fate < probabilities[0]
          transform_beat_single(constraints, current_beat)
        elsif fate < probabilities[0] + probabilities[1]
          transform_beat_double(constraints, current_beat, other_beat, is_last_note)
        elsif fate < probabilities[0] + probabilities[1] + probabilities[2]
          transform_beat_triple(constraints, current_beat, other_beat, is_last_note)
        else
          transform_beat_quadruple(constraints, current_beat, other_beat, is_last_note)
        end

      end

      # Transform beat into a single note
      def transform_beat_single(constraints, current_beat)
        # This note should be the root
        constraints << all(eq(current_beat[:rhythm], [Rational(1)]), eq(current_beat[:notes], [current_beat[:root_note]]))
      end

      # Transform the beat into a two notes
      def transform_beat_double(constraints, current_beat, other_beat, is_last_note)
        # Rhythm
        constraints << eq(current_beat[:rhythm], [Rational(1,2), Rational(1,2)])
        # Pitch
        n1, n2 = fresh(2)
        constraints << eq(current_beat[:notes], [n1, n2])
        if is_last_note
          # This is the final note of the piece. The second note should be the root and the first a good step to it
          constraints << eq(n2, current_beat[:root_note])
          constraints << project(other_beat, lambda do |prev|
            conde_options = []
            find_walking_notes(prev[:notes].last, current_beat[:root_note], 1).map do |possible_note|
              conde_options << eq(n1, possible_note)
            end
            return conde(*conde_options)
          end)
        else
          # The first note should be the root, and the second a good step to the next
          constraints << eq(n1, current_beat[:root_note])
          conde_options = []
          find_walking_notes(current_beat[:root_note], other_beat[:root_note], 1).map do |possible_note|
            conde_options << eq(n2, possible_note)
          end
          constraints << conde(*conde_options)
        end
      end

      def transform_beat_triple(constraints, current_beat, other_beat, is_last_note)
        # Rhythm
        constraints << conde(
        eq(current_beat[:rhythm], [Rational(1,4), Rational(1,4), Rational(1,2)]),
        eq(current_beat[:rhythm], [Rational(1,2), Rational(1,4), Rational(1,4)]),
        eq(current_beat[:rhythm], [Rational(1,3), Rational(1,3), Rational(1,3)])
        )
        # Pitch
        n1, n2, n3 = fresh(3)
        constraints << eq(current_beat[:notes], [n1, n2, n3])
        if is_last_note
          # The last should be the root
          constraints << eq(n3, current_beat[:root_note])
          constraints << project(other_beat, lambda do |prev|
            conde_options = []
            find_walking_notes(prev[:notes].last, current_beat[:root_note], 2).map do |possible_notes|
              conde_options << eq([n1, n2], possible_notes)
            end
            return conde(*conde_options)
          end)
        else
          # The first should be the root, and find other good ones.
          constraints << eq(n1, current_beat[:root_note])
          conde_options = []
          find_walking_notes(current_beat[:root_note], other_beat[:root_note], 2).map do |possible_notes|
            conde_options << eq([n2, n3], possible_notes)
          end
          constraints << conde(*conde_options)
        end
      end

      def transform_beat_quadruple(constraints, current_beat, other_beat, is_last_note)
        # Rhythm
        constraints << eq(current_beat[:rhythm], [Rational(1,4), Rational(1,4), Rational(1,4), Rational(1,4)])
        # Pitch
        n1, n2, n3, n4 = fresh(4)
        constraints << eq(current_beat[:notes], [n1, n2, n3, n4])
        if is_last_note
          # The final one should be the root
          constraints << eq(n4, current_beat[:root_note])
          constraints << project(other_beat, lambda do |prev|
            conde_options = []
            find_walking_notes(prev[:notes].last, current_beat[:root_note], 3).map do |possible_notes|
              conde_options << eq([n1, n2, n3], possible_notes)
              puts possible_notes
            end
            return conde(*conde_options)
          end)
        else
          # The first should be the root, and find other good ones.
          constraints << eq(n1, current_beat[:root_note])
          conde_options = []
          find_walking_notes(current_beat[:root_note], other_beat[:root_note], 3).map do |possible_notes|
            conde_options << eq([n2, n3, n4], possible_notes)
            puts possible_notes
          end
          constraints << conde(*conde_options)
        end
      end

      ############ ACTAULLY TRANSFORM THE SKELETON ############
      # Initialise canon and constraints
      constraints = []
      canon = @canon_skeleton

      # Make the notes into fresh variables
      for i in 0..canon.length - 1
        for j in 0..canon[i].length - 1
          canon[i][j][:rhythm] = fresh
          canon[i][j][:notes] = fresh
        end
      end

      # Transform all the beats
      for i in 0..canon.length - 1
        for j in 0..canon[i].length - 1
          other_beat = nil
          is_last_note = false
          # is the next beat in this bar?
          if j == canon[i].length - 1
            # NO, is it in the next?
            if i == canon.length - 1
              # NO (there is no next beat- this is the final beat)
              other_beat = canon[i][j - 1]
              is_last_note = true
            else
              # YES (the next beat is the first beat of the next bar)
              other_beat = canon[i + 1][0]
            end
          else
            # YES (the next beat is in this bar)
            other_beat = canon[i][j + 1]
          end
          transform_beat(constraints, canon[i][j], other_beat, is_last_note)
        end
      end

      # run the query using q, a fresh query variable
      q = fresh
      run(1, q, eq(q, canon), *constraints)
      ################################################

    end
    @canon_complete = canon_completed_options
  end
end
