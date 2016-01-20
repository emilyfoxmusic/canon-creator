require 'mini_kanren'

# This contains a fully fleshed-out canon, with a link to the matadata that created it
class Canon
  def initialize(metadata)
    @metadata = metadata.clone() # We don't want the original version to change when we fiddle arond with it here.
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
    
  end

  def populate_canon(skeleton)

  end
end
