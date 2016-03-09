###########################################
###### PLEASE DO NOT TOUCH THIS CODE ######
###########################################

# This is the UI code. Run once upon opening Sonic Pi.

## DIY Creator

# Check that the user's canon is ok to play.
define :validate_canon do |canon|
  # Check that each beat has a note and a length.
  canon.map do |note|
    if !note.has_key?(:pitch) || !note.has_key?(:length)
      raise "For every note in your canon you MUST have a note AND a length."
    end
  end
end

define :play_user_canon do |canon, offset, num_voices, sounds, transpose|
  proportion_sustain = 0.7
  proportion_release = 0.3
  # Start a new voice the specified number of times.
  for voice in 0..num_voices - 1
    # Start this voice with a random pan value.
    in_thread do
      use_synth sounds[voice]
      use_transpose transpose[voice]
      canon.map do |note|
        play note[:pitch], attack: 0, sustain: note[:length] * proportion_sustain, release: note[:length] * proportion_release
        sleep note[:length]
      end
    end
    # Sleep until the next bar.
    sleep offset
  end
end


## Canon Creator
