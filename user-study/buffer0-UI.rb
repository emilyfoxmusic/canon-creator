###########################################
###### PLEASE DO NOT TOUCH THIS CODE ######
###########################################

# This is the UI code. Run once upon opening Sonic Pi.

## DIY Creator

# Check that the user's canon is ok to play.
define :validate_canon do |canon, beats_per_bar, offset|
  # Check that the beats per bar is 3 or 4.
  if ![3, 4].include?(beats_per_bar)
    raise "There must be 3 or 4 beats in a bar, not #{ beats_per_bar }."
  end
  # Check that each beat has a note and a length of 1, 0.5 or 0.25.
  canon.map do |note|
    if !note.has_key?(:pitch) || !note.has_key?(:length)
      raise "For every note in your canon you MUST have a note AND a length."
    elsif ![1, 0.5, 0.25].include?(note[:length])
      raise "Only notes of lengh 1, 0.5 and 0.25 are permitted."
    end
  end
  # Check that the piece has breaks at the bar boundaries.
  duration_count = 0
  bar_count = 0
  canon.map do |note|
    duration_count += note[:length]
    if duration_count == beats_per_bar
      bar_count += 1
      duration_count = 0
    elsif duration_count > beats_per_bar
      raise "Notes can't be played over a bar line (check bar #{ bar_count }). "
    end
  end
end

# Play the user's canon.
define :play_user_canon do |canon, beats_per_bar, offset, num_voices, sounds, transpose|
  proportion_sustain = 0.7
  proportion_release = 0.3
  # Start a new voice the specified number of times.
  for voice in 0..num_voices - 1
    # Start this voice with a random pan value.
    in_thread do
      use_synth sounds[voice]
      use_transpose transpose[voice] * 12
      canon.map do |note|
        play note[:pitch], attack: 0, sustain: note[:length] * proportion_sustain, release: note[:length] * proportion_release
        sleep note[:length]
      end
    end
    # Sleep until the next voice starts.
    sleep beats_per_bar * offset
  end
end


## Canon Creator
