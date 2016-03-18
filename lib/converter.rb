# This file is just to take in one of the hardcoded canons and turn it into a canon in the canon-creator Canon class representation so that it can be exported to lilypond.
# WE ASSUME THAT ALL PIECES ARE WRITTEN IN C.

class Converter

  def initialize(canon, beats_in_bar, num_voices, tempo, instruments, transpose, file_loc, title, composer)
    @canon = canon
    @beats_in_bar = beats_in_bar
    @num_voices = num_voices
    @tempo = tempo
    @instruments = instruments
    @transpose = transpose
    @file_loc = file_loc
    @title = title
    @composer = composer
    export()
  end

  def export()

    # ARGS: The octave number.
    # DESCRIPTION: Generates a string which will put the note in the correct octave in Lilypond- commas for down an octave and apostrophes for up an octave.
    # RETURNS: The String for adjusting the octave of the note.
    def get_adjustment_string(octave)
      if octave == nil
        octave = 4
      end
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

    def get_note(pi_note, length)
      pi_note = pi_note.to_s
      case length
      when 0.25
        length = 16
      when 0.5
        length = 8
      when 1
        length = 4
      end
      # Find the adjustment string for it.
      if pi_note.length == 2
        if pi_note[1] == "s"
          note_name = pi_note[0] + "is"
          octave = 4
        elsif pi_note[1] == "b"
          note_name = pi_note[0] + "es"
          octave = 4
        else
          note_name = pi_note[0]
          octave = pi_note[1].to_i
        end
      elsif pi_note.length == 3
        note_name = pi_note[0..1]
        if note_name[1] == "s"
          note_name = note_name[0] + "is"
        else
          note_name = note_name[0] + "es"
        end
        octave = pi_note[2].to_i
      else
        note_name = pi_note[0]
        octave = 4
      end
      adjustment_string = get_adjustment_string(octave)
      return note_name + adjustment_string + length.to_s
    end

    # Find the representation of a bar rest.
    bar_rest = nil
    if @beats_in_bar == 3
      bar_rest = "R2."
    else
      bar_rest = "R1"
    end

    # Open the file specified for writing.
    f = File.open(@file_loc, "w")
    # Write out the version of Lilypond.
    f.write("\\version \"2.18.2\"\n\n")
    # Write out the title of the piece.
    f.write("\\header {\ntitle = \"#{ @title }\"\ncomposer = \"#{ @composer }\"}\n")
    # Write out the starter stuff.
    f.write("{\n<<\n")
    # Find the lilypond string for the staff.
    # Write it out the number of times there are voices.
    for voice in 0..@num_voices - 1 do
      # Find the transpose string.
      transpose_string = ""
      case @transpose[voice]
      when 1
        transpose_string = "\'"
      when 2
        transpose_string = "\'\'"
      when -1
        transpose_string = ","
      when -2
        transpose_string = ",,"
      end
      # Write out staff beginnings.
      f.write("\\new Staff \\with {\ninstrumentName = \#\"#{ @instruments[voice].capitalize }\"\n}\n{\n \\tempo 4 = #{ @tempo }\n\\transpose c c#{ transpose_string } {\n \\clef treble\n\\time #{ @beats_in_bar }/4\n\\key c \\major\n")
      # Write out start rests.
      voice.times do
        f.write(bar_rest + " ")
      end
      # Write notes out.
      @canon.map do |note|
        f.write(get_note(note[:pitch], note[:length]) + " ")
      end
      # Write out end rests.
      (@num_voices - 1 - voice).times do
        f.write(bar_rest + " ")
      end
      # Write out end of staff.
      f.write("}\n }")
    end
    # Write out the closing stuff.
    f.write(">>\n}")
    # Close the file.
    f.close
  end

end
