# Copyright (c) 2015 Emily Fox, MIT License.
# Full code available at https://github.com/EJCFox/canon-creator/

# This file contains all the Sonic Pi definitions required to use the canon generator, and play those generated.

require 'metadata'
require 'canon'
require 'exporter'

# ARGS: None.
# DESCRIPTION: Make a new canon metadata object.
# RETURNS: Empty, new, Metadata object.
define :canon do
  return Metadata.new()
end

# ARGS: Metadata object.
# DESCRIPTION: Generates a complete canon and plays it.
# RETURNS: Nil.
define :canon_play do |canon_arg|

  # ARGS: A melody (array of bars which are arrays of beats) and a value for the pan of this melody.
  # DESCRIPTION: Plays the melody by playing each bar in turn.
  # RETURNS: Nil.
  define :play_melody do |melody, pan, voice, transpose|
    use_synth voice
    use_transpose transpose * 12
    num_bars = melody.length
    for i in 0..num_bars - 1
      play_bar(melody[i], pan)
    end
  end

  # ARGS: A bar (array of beats) and a value for the pan of this melody.
  # DESCRIPTION: Plays the bar by playing each beat in turn.
  # RETURNS: Nil.
  define :play_bar do |bar, pan|
    num_beats = bar.length
    for i in 0..num_beats - 1
      play_beat(bar[i], pan)
    end
  end

  # ARGS: A beat (hash with the root note, rhythm values and pitch values) and a value for the pan of this melody.
  # DESCRIPTION: Plays the beat by playing each note in turn, specified by the array of values for rhythm and pitch.
  # RETURNS: Nil.
  define :play_beat do |beat, pan|
    proportion_sustain = 0.7
    proportion_release = 0.3
    pairs = beat[:rhythm].zip(beat[:notes])
    pairs.map do |pair|
      play pair[1], attack: 0, sustain: pair[0] * proportion_sustain, release: pair[0] * proportion_release, pan: pan
      sleep pair[0].to_f
    end
  end

  # If the argument is metadata, generate a canon from it.
  if canon_arg.is_a?(Metadata)
    canon = Canon.new(canon_arg)
  elsif canon_arg.is_a?(Canon)
    canon = canon_arg
  else
    raise "Wrong argument type for canon_play: #{ metadata.class }."
  end
  # Get the array representation of the canon from the canon object.
  canon_internal_rep = canon.get_canon_as_array
  # Check for an empty canon.
  if canon_internal_rep.length == 0 || canon_internal_rep[0].length == 0
    raise "This canon is empty"
  else
    # Find how many voices to play- this is the same as beats in a bar.
    num_voices = canon.get_metadata.get_number_of_voices
    offset = canon.get_metadata.get_beats_in_bar * canon.get_metadata.get_offset
    voices = canon.get_metadata.get_sounds
    transpositions = canon.get_metadata.get_transpositions
    # Play the melody the correct number of times at the different offsets.
    for voice in 0..num_voices - 1
      in_thread do
        # Start this voice with a random pan value.
        play_melody(canon_internal_rep, rand * 0.75, voices[voice], transpositions[voice])
      end
      # Sleep until the next bar.
      sleep offset
    end
  end
  return canon
end

# ARGS: Canon metadata object, file location to export to, and whether to play the canon or not.
# DESCRIPTION: Creates a canon from the metadata, exports it to file and then if the third argument is true, plays it.
# RETURNS: Nil.
define :canon_export do |canon_arg, file_loc, composer="Canon Creator", title="A Brave New Canon", play=true, bpm=nil|
  # If the argument is metadata, generate a canon from it.
  if canon_arg.is_a?(Metadata)
    canon = Canon.new(canon_arg)
  elsif canon_arg.is_a?(Canon)
    canon = canon_arg
  else
    raise "Wrong argument type for canon_export: #{ canon_arg.class }."
  end
  # Create a new exporter object for this canon with the file location specified.
  exporter = Exporter.new(canon, file_loc, title, composer, bpm)
  # Export the canon.
  exporter.export()
  # If play is set to true, also play the canon.
  if play
    canon_play(canon)
  end
end
