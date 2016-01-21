# This class deals with exporting the canon to a lilypond file for typesetting in musical notation.
class Exporter

  def initialize(canon, file_loc)
    @canon = canon
    @time_sig = canon.get_metadata.get_time_signature
    @key_sig_note = canon.get_metadata.get_key_note
    @key_sig_type = canon.get_metadata.get_key_type
    @clef = "treble"
    @file_loc = file_loc
    @notes = []
  end

  def get_lilypond_note(note_number)
    # Assume that key is between c4 and b4 and NO ACCIDENTALS and NO COMPLEX key signatures
    # TODO: make the keys correct and all (even normal notes) options- full keys support

    # Find the name of the note in this key
    def get_note_name(note_number)
      # Arrays with the keys that contain that note.
      c_sharp_keys = [[:fs, :major], [:b, :major], [:e, :major], [:a, :major], [:d, :major], [:b, :minor], [:fs, :minor], [:cs, :minor], [:gs, :minor], [:ds, :minor], [:as, :minor]]
      d_flat_keys = [[:ab, :major], [:db, :major], [:gb, :major], [:f, :minor], [:bb, :minor], [:eb, :minor], [:ab, :minor]]
      d_sharp_keys = [[:fs, :major],[:b, :major],[:e, :major], [:cs, :minor], [:gs, :minor], [:ds, :minor], [:as, :minor]]
      e_flat_keys = [[:bb, :major], [:eb, :major], [:ab, :major], [:db, :major], [:gb, :major], [:g, :minor], [:c, :minor], [:f, :minor], [:bb, :minor], [:eb, :minor], [:ab, :minor]]
      f_sharp_keys = [[:fs, :major],[:b, :major],[:e, :major],[:a, :major],[:d, :major], [:g, :major], [:e, :minor], [:b, :minor], [:fs, :minor], [:cs, :minor], [:gs, :minor], [:ds, :minor], [:as, :minor]]
      g_flat_keys = [[:db, :major], [:gb, :major], [:bb, :minor], [:eb, :minor], [:ab, :minor]]
      g_sharp_keys = [[:fs, :major], [:b, :major], [:e, :major], [:a, :major], [:fs, :minor], [:cs, :minor], [:gs, :minor], [:ds, :minor], [:as, :minor]]
      a_flat_keys = [[:eb, :major], [:ab, :major], [:db, :major], [:gb, :major], [:c, :minor], [:f, :minor], [:bb, :minor], [:eb, :minor], [:ab, :minor]]
      a_sharp_keys = [[:fs, :major],[:b, :major], [:gs, :minor], [:ds, :minor], [:as, :minor]]
      b_flat_keys = [[:f, :major], [:bb, :major], [:eb, :major], [:ab, :major], [:db, :major], [:gb, :major], [:d, :minor], [:g, :minor], [:c, :minor], [:f, :minor], [:bb, :minor], [:eb, :minor], [:ab, :minor]]
      # Ones without sharps/flats are all the same
      # Special cases depend on the key
      case note_number % 12
        # ~~~~ normal notes ~~~~ #
      when 0 # C
        return "c"
      when 2 # D
        return "d"
      when 4 # E
        return "e"
      when 5 # F
        return "f"
      when 7 # G
        return "g"
      when 9 # A
        return "a"
      when 11 # B
        return "b"
        # ~~~~ strange ones ~~~~ #
      when 1 # C# / Db
        if c_sharp_keys.include?([@key_sig_note, @key_sig_type])
          # This is C#
          return "cis"
        elsif d_flat_keys.include?([@key_sig_note, @key_sig_type])
          # This is Db
          return "des"
        else
          raise "Note #{ note_number } not in the key #{ @key_sig_note } #{ @key_sig_type }!"
        end
      when 3 # D# / Eb
        if d_sharp_keys.include?([@key_sig_note, @key_sig_type])
          # This is D#
          return "dis"
        elsif e_flat_keys.include?([@key_sig_note, @key_sig_type])
          # This is Eb
          return "ees"
        else
          raise "Note #{ note_number } not in the key #{ @key_sig_note } #{ @key_sig_type }!"
        end
      when 6 # F# / Gb
        if f_sharp_keys.include?([@key_sig_note, @key_sig_type])
          # This is F#
          return "fis"
        elsif g_flat_keys.include?([@key_sig_note, @key_sig_type])
          # This is Gb
          return "ges"
        else
          raise "Note #{ note_number } not in the key #{ @key_sig_note } #{ @key_sig_type }!"
        end
      when 8 # G# / Ab
        if g_sharp_keys.include?([@key_sig_note, @key_sig_type])
          # This is G#
          return "gis"
        elsif a_flat_keys.include?([@key_sig_note, @key_sig_type])
          # This is Ab
          return "aes"
        else
          raise "Note #{ note_number } not in the key #{ @key_sig_note } #{ @key_sig_type }!"
        end
      when 10 # A# / Bb
        if a_sharp_keys.include?([@key_sig_note, @key_sig_type])
          # This is A#
          return "ais"
        elsif b_flat_keys.include?([@key_sig_note, @key_sig_type])
          # This is Bb
          return "bes"
        else
          raise "Note #{ note_number } not in the key #{ @key_sig_note } #{ @key_sig_type }!"
        end
      else
        raise "Something went wrong finding the note for the note number #{ note_number } in key #{ @key_sig_note } #{ @key_sig_type }"
      end
    end

    # Find which octave the note belongs to
    def get_note_octave(note_number)
      return ((note_number / 12) - 1)
    end

    # Find the number of commas or apostrophes to be appended for that note
    def get_adjustment_string(octave)
      octave_adjustment = octave - 4 # Because Lilypond uses octave 4 as a reference
      octave_string = ""
      if octave_adjustment > 0
        for i in 1..octave_adjustment
          octave_string = octave_string + "\'"
        end
      elsif octave_adjustment < 0
        for i in 1..-octave_adjustment
          octave_string = octave_string + ","
        end
      end
      return octave_string
    end

    note_name = get_note_name(note_number)
    return note_name + get_adjustment_string(get_note_octave(note_number))
  end

  def export()

    def interpret_canon()
      for i in 0..@canon.get_canon_complete.length - 1
        add_bar(@canon.get_canon_complete[i])
      end
    end

    def add_bar(bar)
      for i in 0..bar.length - 1
        add_beat(bar[i])
      end
    end

    def add_beat(beat)
      # Deal with tuplets separately
      if beat[:rhythm] == [Rational(1,3), Rational(1,3), Rational(1,3)]
        note1 = get_lilypond_note(beat[:notes][0])
        note2 = get_lilypond_note(beat[:notes][1])
        note3 = get_lilypond_note(beat[:notes][2])
        lilypond_rep = "\\tuplet 3/2 { #{ note1 } #{ note2 } #{ note3 }}"
        @notes << lilypond_rep
      else
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
          @notes << lilypond_rep
        end
      end
    end

    def convert_to_lilypond()
      lp = "\\clef #{ @clef }\n\\time #{ @time_sig }\n\\key #{ @key_sig_note.to_s } \\#{ @key_sig_type.to_s }\n"
      @notes.map do |note|
        lp << "#{ note } "
      end
      return "{\n" + lp + "\n}"
    end

    # Find the lilypond representation and write out to file
    interpret_canon()
    f = File.open(@file_loc, "w")
    f.write(convert_to_lilypond())

  end

end
