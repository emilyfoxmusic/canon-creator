# Copyright (c) 2015 Emily Fox, MIT License.
# Full code available at https://github.com/EJCFox/canon-creator/

# CLASS DECRIPTION: An exporter object which facilitates exporting to Lilypond.
# MEMBER VARIABLES:
## canon (canon representation using arrays) - the canon in the internal representation.
## time_sig (String) - the time signature of the canon.
## key_sig_note (immutable String) - the tonic of the piece.
## key_sig_type (immutable String) - the type of scale used for this canon.
## num_voices (integer) - the number of voices in the piece.
## file_loc (String) - the file name to export to.
## title (String) - the title of the piece.
## composer (String) - the composer of the piece.
## bpm (integer) - the tempo of the piece, in beats per minute.
## notes (array of Strings) - the Lilypond notes.
# INTERFACE METHODS
## export - exports the canon to the lilypond file specified by the file_loc variable.

class Exporter
  include SonicPi::Lang::Core

  # ARGS: A canon object and file location string
  # DESCRIPTION: Creates an exporter object, by initiasing the member variables.
  # RETURNS: This exporter object.
  def initialize(canon, file_loc, title, composer, bpm)
    @canon = canon
    @time_sig = canon.get_metadata.get_time_signature
    @key_sig_note = canon.get_metadata.get_key_note
    @key_sig_type = canon.get_metadata.get_key_type
    @num_voices = canon.get_metadata.get_number_of_voices
    @file_loc = file_loc
    @title = title
    @composer = composer
    @bpm = bpm
    @notes = []
    @canon_internal_rep = canon.get_canon_as_array
    return self
  end

  # ARGS: The midi number of a note.
  # DESCRIPTION: Finds the Lilypond representation of this note for the current key, in absolute octave mode.
  # RETURNS: The lilypond representation of this note as a String.
  def get_lilypond_note(note_number)
    # ASSERT: No accidentals, or key signatures with more than 7 flats or sharps.

    # ARGS: The midi number of a note.
    # DESCRIPTION: Finds the Lilypond representation of this note for the current key, ignoring octave.
    # RETURNS: The lilypond representation of this note as a String, pitch only- no octave information.
    def get_note_name(note_number)
      # Hard code for each note which keys contain it.
      c_keys_major = [:db, :ab, :eb, :bb, :f, :c, :g]
      c_keys_minor = [:bb, :f, :c, :g, :d, :a, :e]
      b_sharp_keys_major = [:cs]
      b_sharp_keys_minor = [:as]
      c_sharp_keys_major = [:d, :a, :e, :b, :fs, :cs]
      c_sharp_keys_minor = [:b, :fs, :cs, :gs, :ds, :as]
      d_flat_keys_major = [:ab, :db, :gb, :cb]
      d_flat_keys_minor = [:f, :bb, :eb, :ab]
      d_keys_major = [:eb, :bb, :f, :c, :g, :d, :a]
      d_keys_minor = [:c, :g, :d, :a, :e, :b, :fs]
      d_sharp_keys_major = [:e, :b, :fs, :cs]
      d_sharp_keys_minor = [:cs, :gs, :ds, :as]
      e_flat_keys_major = [:bb, :eb, :ab, :db, :gb, :cb]
      e_flat_keys_minor = [:g, :c, :f, :bb, :eb, :ab]
      e_keys_major = [:f, :c, :g, :d, :a, :e, :b]
      e_keys_minor = [:d, :a, :e, :b, :fs, :cs, :gs]
      f_flat_keys_major = [:cb]
      f_flat_keys_minor = [:ab]
      f_keys_major = [:gb, :db, :ab, :eb, :bb, :f, :c]
      f_keys_minor = [:eb, :bb, :f, :c, :g, :d, :a]
      e_sharp_keys_major = [:fs, :cs]
      e_sharp_keys_minor = [:ds, :as]
      f_sharp_keys_major = [:g, :d, :a, :e, :b, :fs, :cs]
      f_sharp_keys_minor = [:e, :b, :fs, :cs, :gs, :ds, :as]
      g_flat_keys_major = [:db, :gb, :cb]
      g_flat_keys_minor = [:bb, :eb, :ab]
      g_keys_major = [:ab, :eb, :bb, :f, :c, :g, :d]
      g_keys_minor = [:f, :c, :g, :d, :a, :e, :b]
      g_sharp_keys_major = [:a, :e, :b, :fs, :cs]
      g_sharp_keys_minor = [:fs, :cs, :gs, :ds, :as]
      a_flat_keys_major = [:eb, :ab, :db, :gb, :cb]
      a_flat_keys_minor = [:c, :f, :bb, :eb, :ab]
      a_keys_major = [:bb, :f, :c, :g, :d, :a, :e]
      a_keys_minor = [:g, :d, :a, :e, :b, :fs, :cs]
      a_sharp_keys_major = [:b, :fs, :cs]
      a_sharp_keys_minor = [:gs, :ds, :as]
      b_flat_keys_major = [:f, :bb, :eb, :ab, :db, :gb, :cb]
      b_flat_keys_minor = [:d, :g, :c, :f, :bb, :eb, :ab]
      b_keys_major = [:c, :g, :d, :a, :e, :b, :fs]
      b_keys_minor = [:a, :e, :b, :fs, :cs, :gs, :ds]
      c_flat_keys_major = [:gb, :cb]
      c_flat_keys_minor = [:eb, :ab]
      # Return the right note for the key given.
      case note_number % 12
      when 0 # C / B#
        if @key_sig_type == :major
          if c_keys_major.include?(@key_sig_note)
            return "c"
          elsif b_sharp_keys_major.include?(@key_sig_note)
            return "bis"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if c_keys_minor.include?(@key_sig_note)
            return "c"
          elsif b_sharp_keys_minor.include?(@key_sig_note)
            return "bis"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 1 # C# / Db
        if @key_sig_type == :major
          if c_sharp_keys_major.include?(@key_sig_note)
            return "cis"
          elsif d_flat_keys_major.include?(@key_sig_note)
            return "des"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if c_sharp_keys_minor.include?(@key_sig_note)
            return "cis"
          elsif d_flat_keys_minor.include?(@key_sig_note)
            return "des"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 2 # D
        if @key_sig_type == :major
          if d_keys_major.include?(@key_sig_note)
            return "d"
          else
            raise "Note #{ note_number } not in key."
          end
        elsif @key_sig_type == :minor
          if d_keys_minor.include?(@key_sig_note)
            return "d"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 3 # D# / Eb
        if @key_sig_type == :major
          if d_sharp_keys_major.include?(@key_sig_note)
            return "dis"
          elsif e_flat_keys_major.include?(@key_sig_note)
            return "ees"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if d_sharp_keys_minor.include?(@key_sig_note)
            return "dis"
          elsif e_flat_keys_minor.include?(@key_sig_note)
            return "ees"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 4 # E / Fb
        if @key_sig_type == :major
          if e_keys_major.include?(@key_sig_note)
            return "e"
          elsif f_flat_keys_major.include?(@key_sig_note)
            return "fes"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if e_keys_minor.include?(@key_sig_note)
            return "e"
          elsif f_flat_keys_minor.include?(@key_sig_note)
            return "fes"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 5 # F / E#
        if @key_sig_type == :major
          if f_keys_major.include?(@key_sig_note)
            return "f"
          elsif e_sharp_keys_major.include?(@key_sig_note)
            return "eis"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if f_keys_minor.include?(@key_sig_note)
            return "f"
          elsif e_sharp_keys_minor.include?(@key_sig_note)
            return "eis"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 6 # F# / Gb
        if @key_sig_type == :major
          if f_sharp_keys_major.include?(@key_sig_note)
            return "fis"
          elsif g_flat_keys_major.include?(@key_sig_note)
            return "ges"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if f_sharp_keys_minor.include?(@key_sig_note)
            return "fis"
          elsif g_flat_keys_minor.include?(@key_sig_note)
            return "ges"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 7 # G
        if @key_sig_type == :major
          if g_keys_major.include?(@key_sig_note)
            return "g"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if g_keys_minor.include?(@key_sig_note)
            return "g"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 8 # G# / Ab
        if @key_sig_type == :major
          if g_sharp_keys_major.include?(@key_sig_note)
            return "gis"
          elsif a_flat_keys_major.include?(@key_sig_note)
            return "aes"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if g_sharp_keys_minor.include?(@key_sig_note)
            return "gis"
          elsif a_flat_keys_minor.include?(@key_sig_note)
            return "aes"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 9 # A
        if @key_sig_type == :major
          if a_keys_major.include?(@key_sig_note)
            return "a"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if a_keys_minor.include?(@key_sig_note)
            return "a"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 10 # A# / Bb
        if @key_sig_type == :major
          if a_sharp_keys_major.include?(@key_sig_note)
            return "ais"
          elsif b_flat_keys_major.include?(@key_sig_note)
            return "bes"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if a_sharp_keys_minor.include?(@key_sig_note)
            return "ais"
          elsif b_flat_keys_minor.include?(@key_sig_note)
            return "bes"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      when 11 # B / Cb
        if @key_sig_type == :major
          if b_keys_major.include?(@key_sig_note)
            return "b"
          elsif c_flat_keys_major.include?(@key_sig_note)
            return "ces"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        elsif @key_sig_type == :minor
          if b_keys_minor.include?(@key_sig_note)
            return "b"
          elsif c_flat_keys_minor.include?(@key_sig_note)
            return "ces"
          else
            raise "Note #{ note_number } not in key #{ @key_sig_note } #{ @key_sig_type }."
          end
        else
          raise "Invalid key type #{ @key_sig_type }"
        end
      end
    end

    # ARGS: A note number and the the name in its Lilypond representation.
    # DESCRIPTION: Finds which (midi) octave this note is in.
    # RETURNS: The octave number.
    def get_note_octave(note_number, note_name)
      # Special cases for C flat and B sharp since they are on the boundary.
      if note_name == "ces"
        return (note_number / 12) # One higher than most.
      elsif note_name == "bis"
        return ((note_number / 12) - 2) # One lower than most.
      else
        return ((note_number / 12) - 1) # Midi octaves change at C with C0 = 12.
      end
    end

    # ARGS: The octave number.
    # DESCRIPTION: Generates a string which will put the note in the correct octave in Lilypond- commas for down an octave and apostrophes for up an octave.
    # RETURNS: The String for adjusting the octave of the note.
    def get_adjustment_string(octave)
      octave_adjustment = octave - 4 # Lilypond uses octave 4 as a reference.
      octave_string = ""
      if octave_adjustment > 0
        # Need to add apostrophes to make it higher.
        for i in 1..octave_adjustment
          octave_string = octave_string + "\'"
        end
      elsif octave_adjustment < 0
        # Need to add commas to make it lower.
        for i in 1..-octave_adjustment
          octave_string = octave_string + ","
        end
      end
      return octave_string
    end

    # The note name consists of the note name plus the adjustment string.
    note_name = get_note_name(note_number)
    return note_name + get_adjustment_string(get_note_octave(note_number, note_name))
  end

  # ARGS: None.
  # DESCRIPTION: Exports the canon to the filename given in the object.
  # RETURNS: Nil.
  def export()

    # ARGS: None.
    # DESCRIPTION: Interprets each bar in turn.
    # RETURNS: Nil.
    def interpret_canon()
      for i in 0..@canon_internal_rep.length - 1
        add_bar(@canon_internal_rep[i])
      end
    end

    # ARGS: None.
    # DESCRIPTION: Interprets each beat in turn.
    # RETURNS: Nil.
    def add_bar(bar)
      for i in 0..bar.length - 1
        add_beat(bar[i])
      end
    end

    # ARGS: None.
    # DESCRIPTION: Turns the internal beat representation to a lilypond note and add it to the notes member variable.
    # RETURNS: Nil.
    def add_beat(beat)
      # Deal with tuplets separately- these have a different Lilypond representation.
      if beat[:rhythm] == [Rational(1,3), Rational(1,3), Rational(1,3)]
        note1 = get_lilypond_note(beat[:notes][0])
        note2 = get_lilypond_note(beat[:notes][1])
        note3 = get_lilypond_note(beat[:notes][2])
        lilypond_rep = "\\tuplet 3/2 { #{ note1 }8 #{ note2 } #{ note3 }}"
        @notes << lilypond_rep
      else
        # For each rhythm and pitch pair, convert to the lilypond note.
        beat[:rhythm].zip(beat[:notes]) do |duration, pitch|
          lilypond_rep = get_lilypond_note(pitch)
          if duration == Rational(1, 4)
            lilypond_rep << "16"
          elsif duration == Rational(1, 2)
            lilypond_rep << "8"
          elsif duration == 1
            lilypond_rep << "4"
          else
            raise "Unknown duration #{ duration }"
          end
          # Add the note to the member variable array.
          @notes << lilypond_rep
        end
      end
    end

    # ARGS: The tonic note of the key.
    # DESCRIPTION: Finds the Lilypond representation of this note (no octave information needed) so that the key signature can be exported.
    # RETURNS: The tonic note in Lilypond representation.
    def convert_key_note_to_lilypond(note)
      # Turn the note into a mutable string.
      lp_note = note.to_s
      # If the note is a b then we must deal with this case separately- a blind find/replace will not work.
      if lp_note[0,1] == "b"
        case lp_note
        when "b"
          lp_note = "b"
        when "bb"
          lp_note = "bes"
        when "bs"
          lp_note = "bs"
        else
          raise "Unknown note #{ note }"
        end
      else
        # Replace an 's' (sharp) with 'is'.
        lp_note.sub!(/s/, "is")
        # Replace a 'b' (flat) with 'es'.
        lp_note.sub!(/b/, "es")
      end
      return lp_note
    end

    # ARGS: None.
    # DESCRIPTION: Find the Lilypond string that represents this canon.
    # RETURNS: The Lilypond string.
    def convert_to_lilypond()
      # Get the transpositions
      transpositions = @canon.get_metadata.get_transpositions
      # We need a staff for each voice.
      whole = ""
      for staff in 0..@num_voices - 1
        # Set the cless and transposition adjustment.
        if transpositions[staff] < 0
          clef = "bass"
        else
          clef = "treble"
        end
        # Get the key note in lilypond representation.
        lilypond_key_note = convert_key_note_to_lilypond(@key_sig_note)
        transpose_adjustment = ""
        case transpositions[staff]
        when -2
          transpose_adjustment = ",,"
        when -1
          transpose_adjustment = ","
        when 1
          transpose_adjustment = "\'"
        when 2
          transpose_adjustment = "\'\'"
        end
        # Get the instrument name.
        instrument = @canon.get_metadata.get_sounds[staff].capitalize
        # Find the tempo (if specified)
        tempo_string = ""
        if @bpm != nil
          tempo_string = "\\tempo 4 = #{ @bpm }\n"
        end
        # Add the staff information- clef, time signature, key signature etc..
        repeats = @canon.get_metadata.get_repeats
        if repeats > 1
          repeat_string = " \\repeat volta #{ repeats } {"
        else
          repeat_string = " {"
        end
        lp = "\\new Staff \\with {\ninstrumentName = \#\"#{ instrument }\"\n}\n{\n#{ tempo_string }\\transpose #{ lilypond_key_note } #{ lilypond_key_note }#{ transpose_adjustment } {\n\\clef #{ clef }\n\\time #{ @time_sig }\n\\key #{ lilypond_key_note } \\#{ @key_sig_type.to_s }\n #{ repeat_string }"
        # Add start rests, staff number * bars per chord progression.
        one_bar_rest = (@time_sig == "3/4") ? "R2." : "R1"
        for bar in 1..(@canon.get_metadata.get_offset * staff)
          lp = lp + one_bar_rest + " "
        end
        # Add the notes.
        @notes[0..1].map do |note|
          lp << "#{ note } "
        end
        if repeats > 1 && staff == 0
          lp << "\\mark \\markup { \\italic { Play #{ repeats } times } } "
        end
        @notes[2..-1].map do |note|
          lp << "#{ note } "
        end
        # Add rests to the end.
        for bar in 1..((@num_voices - 1 - staff) * @canon.get_metadata.get_offset)
          lp = lp + one_bar_rest + " "
        end
        whole = whole + lp + "}\n}\n}\n"
      end
      # Get rid of extra text from staves except the first.

      # Return the whole string, wrapped in curly braces.
      return "{\n<<\n" + whole + "\n>>\n}"
    end

    # Interpret the canon to populate 'notes'.
    interpret_canon()
    # Open the file specified for writing.
    f = File.open(@file_loc, "w")
    # Write out the version of Lilypond.
    f.write("\\version \"2.18.2\"\n\n")
    # Write out the title of the piece.
    f.write("\\header {\ntitle = \"#{ @title }\"\ncomposer = \"#{ @composer }\"}\n")
    # Write the lilypond string out to file.
    f.write(convert_to_lilypond())
    # Close the file.
    f.close
  end
end
