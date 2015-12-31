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
  tonics_in_scale = concrete_scale.select { |note| (note % 12) == mod_tonic }

  conde_options = []
  tonics_in_scale.map { |tonic| conde_options << eq(canon[time_sig[0] - 1][time_sig[0] - 1][:root_note], tonic) }

  constraints << conde(*conde_options)

  ## Add constraint on beats, going BACKWARDS from the last. They must be within max_jump in either direction.
  ### Find notes in that chord from the scale
  def notes_in_chord(name, concrete_scale, key)
    case name
    when :I
      ### Find mods of notes needed
      ### I is tonics, thirds and fifths
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_third = (mod_tonic + 4) % 12
      else
        mod_third = (mod_tonic + 3) % 12
      end
      mod_fifth = (mod_tonic + 7) % 12
      ### Find notes from scale
      notes_in_I = concrete_scale.select do |note|
        mod_note = note % 12
        (mod_note == mod_tonic) || (mod_note == mod_third) || (mod_note == mod_fifth)
      end
      return notes_in_I
    when :IV
      ### Find mods of notes needed
      ### IV is fourths, sixths and tonics
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_sixth = (mod_tonic + 9) % 12
      else
        mod_sixth = (mod_tonic + 8) % 12
      end
      mod_fourth = (mod_tonic + 5) % 12
      ### Find notes from scale
      notes_in_IV = concrete_scale.select do |note|
        mod_note = note % 12
        (mod_note == mod_fourth) || (mod_note == mod_sixth) || (mod_note == mod_tonic)
      end
      return notes_in_IV
    when :V
      ### Find mods of notes needed
      ### V is fifths, sevenths and seconds
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_second = (mod_tonic + 2) % 12
        mod_seventh = (mod_tonic + 11) % 12
      else
        mod_second = (mod_tonic + 1) % 12
        mod_seventh = (mod_tonic + 10) % 12
      end
      mod_fifth = (mod_tonic + 7) % 12
      ### Find notes from scale
      notes_in_V = concrete_scale.select do |note|
        mod_note = note % 12
        (mod_note == mod_fifth) || (mod_note == mod_seventh) || (mod_note == mod_second)
      end
      return notes_in_V
    when :VI
      ### Find mods of notes needed
      ### VI is sixths, tonics and thirds
      mod_tonic = key[0] % 12
      if key[1] == :major
        mod_third = (mod_tonic + 4) % 12
        mod_sixth = (mod_tonic + 9) % 12
      else
        mod_third = (mod_tonic + 3) % 12
        mod_sixth = (mod_tonic + 8) % 12
      end
      ### Find notes from scale
      notes_in_VI = concrete_scale.select do |note|
        mod_note = note % 12
        (mod_note == mod_sixth) || (mod_note == mod_tonic) || (mod_note == mod_third)
      end
      return notes_in_VI
    else
      puts "Error: unrecognised chord #{ name }"
    end
  end

  def constrain_to_key_and_distance(current_beat_var, next_beat_var, chord_name, concrete_scale, key, max_jump)
    ### Get all notes in the right chord then keep only those not too far from the next beat
    possible_notes = notes_in_chord(chord_name, concrete_scale, key)
    project(next_beat_var, lambda do |next_beat|
      refined_possibilities = possible_notes.select do |note|
        (note - next_beat).abs <= max_jump
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
          constraints << constrain_to_key_and_distance(canon[bar][beat][:root_note], canon[bar][beat + 1][:root_note], chord_progression[beat], concrete_scale, key, max_jump)
        else
          ### Next beat is in the next bar
          constraints << constrain_to_key_and_distance(canon[bar][beat][:root_note], canon[bar + 1][0][:root_note], chord_progression[beat], concrete_scale, key, max_jump)
        end
      end
    end
  end

  # Run the query
  q = fresh
  run(1, q, eq(q, canon), *constraints)
end

# Choose one to be this structure
canon = canon_structure_options.choose
###################################################

puts canon
