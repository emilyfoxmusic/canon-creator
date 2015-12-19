$: << '/home/emily/Software/SonicPi/sonic-pi/app/server/vendor/mini_kanren/lib'

require 'mini_kanren'

###################################################
################# USER PARAMETERS #################
chord_sequence = [:c, :f, :g] # TODO: implement from this
beats_for_each_chord = [1, 1, 1] # TODO: implement from this
beats_per_bar = 3 # TODO: implement from this
$scale = [:c, :d, :e, :f, :g, :a, :b] # TODO: implement this with a ring?
number_of_voices = 3 # TODO: implement from this
length_of_canon = 3 # TODO: implement from this
###################################################
################ SYSTEM PARAMETERS ################
P_SINGLE = 0.5
P_DOUBLE = 1
P_TRIPLE = 0.25
P_QUADRUPLE = 0.25
P_QUINTUPLE = 0.05
###################################################

root_notes = [[:g, :c, :d], [:e, :f, :b], [:c, :f, :g]]

# Generate the canon structure
canon = Array.new(length_of_canon)
for i in 0..canon.length - 1
  canon[i] = Array.new(beats_per_bar)
  for j in 0..beats_per_bar - 1
    canon[i][j] = {root_note: root_notes[i][j], rhythm: nil, notes: nil}
  end
end

canon_results = MiniKanren.exec do

  #scale = [:c, :d, :e, :f, :g, :a, :b] # TODO: fix this

  def find_median_note(scale, note, next_note)
    index_of_note = scale.index(note)
    index_of_next_note = scale.index(next_note)

    mod_diff = (index_of_note - index_of_next_note).abs

    if mod_diff > scale.length / 2
      if index_of_note < index_of_next_note
        index_of_note += scale.length
      else
        index_of_next_note += scale.length
      end
    end
    scale[(((index_of_note + index_of_next_note) / 2).floor)]
  end

  # Make the notes into fresh variables
  for i in 0..canon.length - 1
    for j in 0..canon[i].length - 1
      canon[i][j][:rhythm] = fresh
      canon[i][j][:notes] = fresh
    end
  end

  # Initialise the constraints
  $constraints = []

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
      $constraints << eq(beat[:notes], [beat[:root_note], beat[:root_note]]) # TODO: fix this so that it does something more interesting!
    else

      # The first note must be the root of this beat
      notes = [beat[:root_note], nil]

      options = []
      # The second note should lead into the next note
      # Are they adjacent notes in the scale?
      diff = $scale.index(beat[:root_note]) - $scale.index(next_beat[:root_note])
      if (diff == 1 || diff == $scale.length - 1)
        # If they are adjacent, choose either root note, one higher, or a two lower
        options = [beat[:root_note], next_beat[:root_note], $scale[($scale.index(beat[:root_note]) + 1) % $scale.length], $scale[($scale.index(beat[:root_note]) - 2) % $scale.length]]
      elsif (diff == -1 || diff == -($scale.length - 1))
        # If they are adjacent, choose either root note, one lower, or a two higher
        options = [beat[:root_note], next_beat[:root_note], $scale[($scale.index(beat[:root_note]) - 1) % $scale.length], $scale[($scale.index(beat[:root_note]) + 2) % $scale.length]]
      else
        # If they are not adjacent, find the median
        options = [find_median_note($scale, beat[:root_note], next_beat[:root_note])]
      end

      constraints = []
      for i in 0..options.length - 1
        constraints << eq(beat[:notes], [beat[:root_note], options[i]])
      end
      $constraints << conde(*constraints)
    end
  end

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

puts canon_results.length
puts canon_results[canon_results.length / 2 - 10]
