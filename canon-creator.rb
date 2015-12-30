#$: << '/home/emily/Software/SonicPi/sonic-pi/app/server/vendor/mini_kanren/lib'
require 'mini_kanren'

################# USER PARAMETERS #################
key = nil # [:c, :major]
scale_range = nil # [:c3, :c6] # inclusive
time_sig = "4/4"
num_voices = 4
chord_progression = [:I, :IV, :V, :I]
max_jump = 6
probabilities = [0.25, 0.25, 0.25, 0.2, 0.05]
###################################################

########### SYSTEM GENERATED PARAMETERS ###########
concrete_scale = nil
###################################################

########### DO VALIDATION ON PARAMETERS ###########
# TODO: Check that notes given are valid, and return if they are not
# TODO: Make whole thing into a procedure so that this is possible
if (key != nil && key.length != 2) || (key != nil && key[0] == nil)
  puts "Invalid input: key #{ key }."
end
if scale_range != nil && scale_range.length != 2
  puts "Invalid input: range #{ scale_range }."
end
if time_sig == "4/4" && num_voices > 4
  puts "Invalid input: the number of voices cannot be more than 4 for a piece in 4/4 time."
elsif time_sig == "3/4" && num_voices > 3
  puts "Invalid input: the number of voices cannot be more than 3 for a piece in 3/4 time."
elsif time_sig != "3/4" && time_sig != "4/4" && time_sig != nil
  puts "Invalid time signature: #{ time_sig }."
end
# TODO: add validation to check that the chord progression has the right number of chords in
###################################################

################## PROCESS INPUT ##################
if scale_range!= nil
  scale_range = [note(scale_range[0]), note(scale_range[1])]
end
if time_sig == "3/4"
  time_sig = [3,4]
elsif time_sig == "4/4"
  time_sig = [4,4]
end
if key != nil
  key[0] = note(key[0])
end
###################################################

############## SET THE CONCRETE SCALE #############
def get_concrete_scale(key, scale_range)
  # If key is not given, choose one at random
  if key == nil
    tonic = [:c, :cs, :d, :ds, :e, :f, :fs, :g, :gs, :a, :bs, :b].choose
    type = [:major, :minor].choose
    key = [note(tonic), type]
  end

  # If range is not given, default to entire scale from :c3 to :c6
  # If part of range is given, set the other to :c3/:c6 as appropriate
  if scale_range == nil
    scale_range = [note(:c3), note(:c6)]
  else
    if scale_range[0] == nil
      scale_range[0] = note(:c3)
    end
    if scale_range[1] == nil
      scale_range[1] = note(:c6)
    end
  end

  # Find the highest tonic lower than the lower limit
  min_tonic = note(key[0])
  while scale_range[0] < min_tonic
    min_tonic -= 12
  end

  # Find the lowest tonic higher than the upper limit
  max_tonic = note(key[0])
  while scale_range[1] > max_tonic
    max_tonic += 12
  end

  # Get the scale between those tonics
  num_octaves = (max_tonic - min_tonic) / 12
  concrete_scale = scale(min_tonic, key[1], num_octaves: num_octaves)

  # Convert to an array and trim to range
  concrete_scale = concrete_scale.to_a
  concrete_scale.delete_if { |note| (scale_range[0] != nil && note < scale_range[0]) || (scale_range[1] != nil && note > scale_range[1]) }

  # return a hash map containing the scale and other information in case it's been newly generated
  return {concrete_scale: concrete_scale, key: key, scale_range: scale_range}
end

# Call the function, and set the properties returned
concrete_scale_data = get_concrete_scale(key, scale_range)
concrete_scale = concrete_scale_data[:concrete_scale]
key = concrete_scale_data[:key]
scale_range = concrete_scale_data[:scale_range]
###################################################

########### GENERATE CHORD PROGRESSION ############
# If the chords have NOT already been given, then generate them.
if chord_progression == nil
  # If no time signature has been given either then generate one at random
  if time_sig == nil
    time_sig == [[3,4],[4,4]].choose
  end

  # Create a new array with a chord for each beat
  chord_progression = Array.new(time_sig[0])
  # Choose each chord at random except the last two which are always IV-I or V-I (plagal or perfect cadence)
  for i in 0..chord_progression.length - 3
    chord_progression[i] = chord_choice.choose
  end
  chord_progression[chord_progression.length - 2] = [:IV, :V].choose
  chord_progression[chord_progression.length - 1] = :I
end
###################################################

############ GET EMPTY CANON STRUCTURE ############
# If number of voices is nil then choose one
if num_voices != nil
  num_voices = rrand_i(2, time_sig[0])
end

# Use MiniKanren to get compatible notes
canon_structure_options = MiniKanren.exec do
  extend SonicPi::Lang::Core
  extend SonicPi::RuntimeMethods
  # Generate the structure with the root notes as fresh variables
  canon = Array.new(time_sig[0])
  for i in 0..canon.length - 1
    canon[i] = Array.new(time_sig[0])
    for j in 0..canon[i].length - 1
      canon[i][j] = {root_note: fresh, rhythm: nil, notes: nil}
    end
  end

  # Add constraints
  constraints = []

  ## Add constraint: final root note is the tonic
  ### Find all the tonics in the given range and add their disjunction as a constraint
  mod_tonic = key[0] % 12
  tonics_in_scale = concrete_scale.select { |note| note % 12 == mod_tonic }

  conde_options = []
  tonics_in_scale.map { |tonic| conde_options << eq(canon[time_sig[0] - 1][time_sig[0] - 1][:root_note], tonic) }

  constraints << conde(*conde_options)

  ## Add constraint: All notes are in the relevant chord
  def is_in_chord(var, name, concrete_scale, key)
    case name
    when :I
      ### Find mods of notes needed
      ### I is tonics, thirds and fifths
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_third = mod_tonic + 4 % 12
      else
        mod_third = mod_tonic + 3 % 12
      end
      mod_fifth = mod_tonic + 7 % 12
      ### Find notes from scale
      notes_in_I = concrete_scale.select do |note|
        mod_note = note % 12
        mod_note == mod_tonic || mod_note == mod_third || mod_note == mod_fifth
      end
      ### Return a conde clause of the variable equalling each of these
      conde_options = []
      notes_in_I.map { |note| conde_options << eq(var, note) }
      return conde(*conde_options)
    when :IV
      ### Find mods of notes needed
      ### IV is fourths, sixths and tonics
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_sixth = mod_tonic + 9 % 12
      else
        mod_sixth = mod_tonic + 8 % 12
      end
      mod_fourth = mod_tonic + 5 % 12
      ### Find notes from scale
      notes_in_IV = concrete_scale.select do |note|
        mod_note = note % 12
        mod_note == mod_fourth || mod_note == mod_sixth || mod_note == mod_tonic
      end
      ### Return a conde clause of the variable equalling each of these
      conde_options = []
      notes_in_IV.map { |note| conde_options << eq(var, note) }
      return conde(*conde_options)
    when :V
      ### Find mods of notes needed
      ### V is fifths, sevenths and seconds
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_second = mod_tonic + 2 % 12
        mod_seventh = mod_tonic + 11 % 12
      else
        mod_second = mod_tonic + 1 % 12
        mod_seventh = mod_tonic + 10 % 12
      end
      mod_fifth = mod_tonic + 7 % 12
      ### Find notes from scale
      notes_in_V = concrete_scale.select do |note|
        mod_note = note % 12
        mod_note == mod_fifth || mod_note == mod_seventh || mod_note == mod_second
      end
      ### Return a conde clause of the variable equalling each of these
      conde_options = []
      notes_in_V.map { |note| conde_options << eq(var, note) }
      return conde(*conde_options)
    when :VI
      ### Find mods of notes needed
      ### VI is sixths, tonics and thirds
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_third = mod_tonic + 4 % 12
        mod_sixth = mod_tonic + 9 % 12
      else
        mod_third = mod_tonic + 3 % 12
        mod_sixth = mod_tonic + 8 % 12
      end
      ### Find notes from scale
      notes_in_VI = concrete_scale.select do |note|
        mod_note = note % 12
        mod_note == mod_sixth || mod_note == mod_tonic || mod_note == mod_third
      end
      ### Return a conde clause of the variable equalling each of these
      conde_options = []
      notes_in_VI.map { |note| conde_options << eq(var, note) }
      return conde(*conde_options)
    else
      puts "Error: unrecognised chord #{ name }"
    end
  end

  ### Set the constraint for each note
  for i in 0..canon.length - 1
    for j in 0..canon[i].length - 1
      constraints << is_in_chord(canon[i][j][:root_note], chord_progression[j], concrete_scale, key)
    end
  end

  ## Successive root notes are within max_jump semitones from each other
  def have_max_distance(var1, var2, max_distance)
    project(var1, lambda { |var1| project(var2, lambda { |var2| (var1 - var2).abs <= max_distance ? lambda { |x| x } : lambda { |x| nil } }) })
  end

  for i in 0..canon.length - 1
    for j in 0..canon[i].length - 1
      if j < canon[i].length - 1
        ### Not last in a bar
        constraints << have_max_distance(canon[i][j][:root_note], canon[i][j + 1][:root_note], max_jump)
      elsif i < canon.length - 1
        ### Last note in a bar, but not of the entire piece
        constraints << have_max_distance(canon[i][j][:root_note], canon[i + 1][0][:root_note], max_jump)
      end
    end
  end

  ## Successive bars do not have the same note for the same position in the chord
  def is_different(*vars)
    var1, var2, var3, var4 = *vars
    if (var4 == nil)
      ### Three args
      project(var1,
      lambda do |var1| project(var2,
        lambda do |var2| project(var3,
          lambda do |var3|
            (var1 != var2 && var1 != var3 && var2 != var3) ? lambda { |x| x } : lambda { |x| nil }
          end)
        end)
      end)
    else
      ### Four args
      project(var1,
      lambda do |var1| project(var2,
        lambda do |var2| project(var3,
          lambda do |var3| project(var4,
            lambda do |var4|
              (var1 != var2 && var1 != var3 && var1 != var4 && var2 != var3 && var2 != var4 && var3 != var4) ? lambda { |x| x } : lambda { |x| nil }
            end)
          end)
        end)
      end)
    end
  end

  ### Set the notes to be different in every bar for each beat
  if time_sig[0] == 3
    for j in 0..time_sig[0] - 1
      constraints << is_different(canon[0][j][:root_note], canon[1][j][:root_note], canon[2][j][:root_note])
    end
  else
    for j in 0..time_sig[0] - 1
      constraints << is_different(canon[0][j][:root_note], canon[1][j][:root_note], canon[2][j][:root_note], canon[3][j][:root_note])
    end
  end

  # Run the query
  q = fresh
  run(1, q, eq(q, canon), *constraints)
end

# Choose one to be this structure
canon = canon_structure_options.choose
###################################################


canon_results = MiniKanren.exec do

  ################### DEFINE FUNCTIONS ###################

  # Given two notes in the scale, find the median between them (rounded down if the median is between two values)
  def find_median_note(note, next_note)
    index_of_note = $scale_ring.index(note)
    index_of_next_note = $scale_ring.index(next_note)

    mod_diff = (index_of_note - index_of_next_note).abs

    if mod_diff > $scale_ring.length / 2
      if index_of_note < index_of_next_note
        index_of_note += $scale_ring.length
      else
        index_of_next_note += $scale_ring.length
      end
    end
    $scale_ring[(((index_of_note + index_of_next_note) / 2).floor)]
  end

  # Given a note in the scale, return the note at an offset within the scale
  def get_note_at_offset(note, offset)
    $scale_ring[($scale_ring.index(note) + offset) % $scale_ring.length]
  end

  # Given two notes, find a good passing note between them
  def get_passing_note(note_1, note_2)
    # Are they adjacent notes in the scale?
    diff = $scale_ring.index(note_1) - $scale_ring.index(note_2)
    if (diff == 1 || diff == $scale_ring.length - 1)
      # If they are adjacent, choose either root note, one higher, or a two lower
      [note_1, note_2, get_note_at_offset(note_1, + 1), get_note_at_offset(note_1, - 2)]
    elsif (diff == -1 || diff == -($scale_ring.length - 1))
      # If they are adjacent, choose either root note, one lower, or a two higher
      [note_1, note_2, get_note_at_offset(note_1, - 1), get_note_at_offset(note_1, + 2)]
    else
      # If they are not adjacent, find the median
      [find_median_note(note_1, note_2)]
    end
  end

  ############## TRANSFORMATION FUNCTIONS ################

  # For each beat, unify with a suitable sub-melody by defining functions which unify notes and rhythms to it
  def transform_beat(beat, next_beat)
    fate = rand()
    if (fate < P_SINGLE)
      transform_beat_single(beat)
    elsif (fate < P_SINGLE + P_DOUBLE)
      transform_beat_double(beat, next_beat)
    elsif (fate < P_SINGLE + P_DOUBLE + P_TRIPLE)
      transform_beat_triple(beat, next_beat)
    elsif (fate < P_SINGLE + P_DOUBLE + P_TRIPLE + P_QUADRUPLE)
      transform_beat_quadruple(beat, next_beat)
    else
      transform_beat_quintuple(beat, next_beat)
    end
  end

  # Place a single note in the beat
  def transform_beat_single(beat)
    # There is only one note for this beat so it should be the root note
    $constraints << all(eq(beat[:rhythm], [1]), eq(beat[:notes], [beat[:root_note]]))
  end

  def transform_beat_double(beat, next_beat)
    # Split the beat in half
    $constraints << eq(beat[:rhythm], [0.5, 0.5])

    if (next_beat == nil)
      # This is the last note of the piece
      $constraints << eq(beat[:notes], [beat[:root_note], beat[:root_note]]) # TODO: fix this so that it does something more interesting!
    else
      # The first note must be the root of this beat
      # The second note should lead into the next note
      options_for_second_note = get_passing_note(beat[:root_note], next_beat[:root_note])

      options_for_both_notes = []
      for i in 0..options_for_second_note.length - 1
        options_for_both_notes << eq(beat[:notes], [beat[:root_note], options_for_second_note[i]])
      end
      $constraints << conde(*options_for_both_notes)
    end
  end

  def transform_beat_triple(beat, next_beat)
    # Split the beat into three, 3 cases
    cases = [[eq(beat[:rhythm], [0.25, 0.25, 0.5])],
    [eq(beat[:rhythm], [0.5, 0.25, 0.25])],
    [eq(beat[:rhythm], [Rational(1, 3), Rational(1, 3), Rational(1, 3)])]]

    # CASE 1: The first and third note must be the root of this beat and the middle one an adjacent note
    cases[0] << conde(
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], 1), beat[:root_note]]),
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], - 1), beat[:root_note]]))

    # CASE 2 and 3: The first must be the root of this beat and either:
    options = []
    # Only valid if this is not the last note of the piece
    if !next_beat == []
      ## second also the root note and third a passing note TODO: (not the same one as the root)
      options << eq(beat[:notes], [beat[:root_note], beat[:root_note], get_passing_note(beat[:root_note], next_beat[:root_note])])
    end

    ## third is root note and the second is an adjacent one
    options << conde(
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], 1), beat[:root_note]]),
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], - 1), beat[:root_note]]))

    ## TODO: neither second or third are root notes but 'walk' to the next note

    cases[1] << conde(*options)
    cases[2] << conde(*options)

    cases.map! do
      |x| all(*x)
    end
    $constraints << conde(*cases)
  end

  def transform_beat_quadruple(beat, next_beat)
    # Split the note into 4
    $constraints << eq(beat[:rhythm], [0.25, 0.25, 0.25, 0.25])

    # The first note must be the root
    options = []
    # One other must be the root
    ## Second TODO: make the next ones 'walk'

    ## Third. Second must be adjacent and fourth is leading to the next. Only valid if not the final note of the melody.
    if next_beat != nil
      options << conde(
      eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], 1), beat[:root_note], get_passing_note(beat[:root_note], next_beat[:root_note]).choose]),
      eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], - 1), beat[:root_note], get_passing_note(beat[:root_note], next_beat[:root_note]).choose]))
    end

    ## Fourth. Second and third are each side, or on the same side (either one)
    options << conde(
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], 1), get_note_at_offset(beat[:root_note], 2), beat[:root_note]]),
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], - 1), get_note_at_offset(beat[:root_note], - 2), beat[:root_note]]),
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], 2), get_note_at_offset(beat[:root_note], 1), beat[:root_note]]),
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], - 2), get_note_at_offset(beat[:root_note], - 1), beat[:root_note]]),
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], + 1), get_note_at_offset(beat[:root_note], - 1), beat[:root_note]]),
    eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], - 1), get_note_at_offset(beat[:root_note], + 1), beat[:root_note]]))

    $constraints << conde(*options)
  end

  def transform_beat_quintuple(beat, next_beat)
    # Constrain the rhythm
    $constraints << eq(beat[:rhythm], [0.25, 0.25, 0.25, 0.125, 0.125])

    # One simple pattern for now TODO: actually do this properly
    $constraints << eq(beat[:notes], [beat[:root_note], get_note_at_offset(beat[:root_note], 1), get_note_at_offset(beat[:root_note], 2), get_note_at_offset(beat[:root_note], 1), beat[:root_note]])
  end

  #######################################################

  # Make the notes into fresh variables
  for i in 0..canon.length - 1
    for j in 0..canon[i].length - 1
      canon[i][j][:rhythm] = fresh
      canon[i][j][:notes] = fresh
    end
  end

  # Initialise the constraints
  $constraints = []

  # Transform all the beats
  for i in 0..canon.length - 1
    for j in 0..canon[i].length - 1
      next_beat = nil
      # is the next beat in this bar?
      if j == canon[i].length - 1
        # NO, is it in the next?
        if i == canon.length - 1
          # NO (there is no next beat)
          next_beat = nil
        else
          # YES (the next beat is the first beat of the next bar)
          next_beat = canon[i+1][0]
        end
      else
        # YES (the next beat is in this bar)
        next_beat = canon[i][j + 1]
      end
      transform_beat(canon[i][j], next_beat)
    end
  end

  # run the query using q, a fresh query variable
  q = fresh
  run(q, eq(q, canon), *$constraints)
end

len = canon_results.length
print canon_results[20]
puts " "
