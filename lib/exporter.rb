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
    # Assuming NO ACCIDENTALS and NO COMPLEX key signatures

    # Find the name of the note in this key
    def get_note_name(note_number)
      # Arrays with the keys that contain that note.
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

      # Return the right note for the key.
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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
          # Minor
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

    def convert_key_note_to_lilypond(note)
      lp_note = note.to_s
      if lp_note[0,1] == "b"
        # Deal separately- can't just do a blind replace.
        case lp_note
        when "b"
          return "b"
        when "bb"
          return "bes"
        when "bs"
          return "bs"
        else
          raise "Unknown note #{ note }"
        end
      else
        lp_note.sub!(/s/, "is")
        lp_note.sub!(/b/, "es")
      end
    end

    def convert_to_lilypond()
      lp = "\\clef #{ @clef }\n\\time #{ @time_sig }\n\\key #{ convert_key_note_to_lilypond(@key_sig_note) } \\#{ @key_sig_type.to_s }\n"
      @notes.map do |note|
        lp << "#{ note } "
      end
      return "{\n" + lp + "\n}"
    end

    # Find the lilypond representation and write out to file
    interpret_canon()
    f = File.open(@file_loc, "w")
    f.write(convert_to_lilypond())
    f.close

  end

end
