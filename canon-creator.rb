#$: << '/home/emily/Software/SonicPi/sonic-pi/app/server/vendor/mini_kanren/lib'
require 'mini_kanren'

###################################################
################# USER PARAMETERS #################
$scale_ring = scale(:c, :major)
###################################################
################ SYSTEM PARAMETERS ################
P_SINGLE = 0.25
P_DOUBLE = 0.25
P_TRIPLE = 0.25
P_QUADRUPLE = 0.2
P_QUINTUPLE = 1
###################################################

chords = MiniKanren.exec do
  extend SonicPi::Lang::Core
  extend SonicPi::RuntimeMethods
  # Generate the chord sequence.
  ## Get time signature
  time_sig = [[4,4], [3,4]].choose

  ## Get the chords
  chord_choice = [:I, :IV, :V, :VI]
  chords = Array.new(time_sig[0])
  for i in 0..chords.length - 1
    chords[i] = fresh
  end

  chord_constraints = []
  # End on I
  chord_constraints << eq(chords[chords.length - 1], :I)

  # For the rest, choose a chord at random
  for i in 0..chords.length - 2
    chord_constraints << eq(chords[i], chord_choice.choose())
  end

  q = fresh
  run(1, q, eq(q, chords), *chord_constraints)
end

chords = chords[0]

# Get the root notes by choosing ones from the chords
def names_to_notes(name, scale_ring)
  case name
  when :I
    [scale_ring[1], scale_ring[3], scale_ring[5]].choose
  when :IV
    [scale_ring[4], scale_ring[6], scale_ring[8]].choose
  when :V
    [scale_ring[5], scale_ring[7], scale_ring[9]].choose
  when :VI
    [scale_ring[6], scale_ring[8], scale_ring[10]].choose
  else
    puts "Error: no name matches!"
  end
end

# Get number of voices
num_voices = rrand_i(2,4)

root_notes = Array.new(num_voices)

for i in 0..root_notes.length - 1
  root_notes[i] = Array.new(chords.length)
  for j in 0..chords.length - 1
    if (i == root_notes.length && j == root_notes[i].length)
      root_notes[i][j] = $scale_ring[0]
    else
      root_notes[i][j] = names_to_notes(chords[j], $scale_ring)
    end
  end
end

puts root_notes

# Generate the canon structure
canon = Array.new(root_notes.length)
for i in 0..canon.length - 1
  canon[i] = Array.new(root_notes[i].length)
  for j in 0..root_notes[i].length - 1
    canon[i][j] = {root_note: root_notes[i][j], rhythm: nil, notes: nil}
  end
end

puts canon

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
