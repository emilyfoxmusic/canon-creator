# input = [[{root_note: _, rhythm: [_], notes: [_]}, beat2, beat3], [beat1, beat2, beat3], [beat1, beat2, beat3]]
# TODO: make the canon structure containt the key in this form!
input_canon = {key: [:c, :major], canon: [[{:root_note=>67, :rhythm=>[Rational(1,1)], :notes=>[67]}, {:root_note=>65, :rhythm=>[Rational(1,1)], :notes=>[65]}, {:root_note=>67, :rhythm=>[Rational(1,1)], :notes=>[67]}, {:root_note=>72, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[72, 72]}], [{:root_note=>76, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[76, 76]}, {:root_note=>77, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[77, 77]}, {:root_note=>74, :rhythm=>[Rational(1,1)], :notes=>[74]}, {:root_note=>76, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[76, 76]}], [{:root_note=>72, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[72, 72]}, {:root_note=>69, :rhythm=>[Rational(1,1)], :notes=>[69]}, {:root_note=>71, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[71, 67]}, {:root_note=>67, :rhythm=>[Rational(1,1)], :notes=>[67]}], [{:root_note=>64, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[64, 64]}, {:root_note=>60, :rhythm=>[Rational(1,1)], :notes=>[60]}, {:root_note=>62, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[62, 60]}, {:root_note=>60, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[48, 72]}]]}

def get_lilypond_note(key, note_number)
  # Assume that key is between c4 and b4 and NO ACCIDENTALS and NO COMPLEX key signatures
  # TODO: make the keys correct

  def get_note_name(key, note_number)
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
      if c_sharp_keys.include?(key)
        # This is C#
        return "cis"
      elsif d_flat_keys.include?(key)
        # This is Db
        return "des"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 3 # D# / Eb
      if d_sharp_keys.include?(key)
        # This is D#
        return "dis"
      elsif e_flat_keys.include?(key)
        # This is Eb
        return "ees"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 6 # F# / Gb
      if f_sharp_keys.include?(key)
        # This is F#
        return "fis"
      elsif g_flat_keys.include?(key)
        # This is Gb
        return "ges"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 8 # G# / Ab
      if g_sharp_keys.include?(key)
        # This is G#
        return "gis"
      elsif a_flat_keys.include?(key)
        # This is Ab
        return "aes"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 10 # A# / Bb
      if a_sharp_keys.include?(key)
        # This is A#
        return "ais"
      elsif b_flat_keys.include?(key)
        # This is Bb
        return "bes"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    else
      puts "Error: something went wrong finding the note for the note number #{ note_number } in key #{ key[0]} #{ key[1] }"
    end
  end

  def get_note_octave(note_number)
    return ((note_number / 12) - 1)
  end

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

  note_name = get_note_name(key, note_number)
  return note_name + get_adjustment_string(get_note_octave(note_number))
end


$lilypond = {
  time_sig: nil,
  key_sig: nil,
  clef: nil,
  notes: []
}

def set_env(canon)
  $lilypond[:clef] = "bass"
  $lilypond[:time_sig] = canon[:canon][0].length == 3 ? "3/4" : "4/4"
  $lilypond[:key_sig] = canon[:key]
end

def interpret_canon(canon)
  for i in 0..canon.length - 1
    add_bar(canon[i])
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
    note1 = get_lilypond_note($lilypond[:key_sig], beat[:notes][0])
    note2 = get_lilypond_note($lilypond[:key_sig], beat[:notes][1])
    note3 = get_lilypond_note($lilypond[:key_sig], beat[:notes][2])
    lilypond_rep = "\\tuplet 3/2 { #{ note1 } #{ note2 } #{ note3 }}"
    $lilypond[:notes] << lilypond_rep
  else
    beat[:rhythm].zip(beat[:notes]) do |duration, pitch|
      lilypond_rep = get_lilypond_note($lilypond[:key_sig], pitch)
      if duration == Rational(1, 4)
        lilypond_rep << "16"
      elsif duration == Rational(1, 2)
        lilypond_rep << "8"
      elsif duration == 1
        lilypond_rep << "4"
      else
        puts "Error: unknown duration #{ duration }"
      end
      $lilypond[:notes] << lilypond_rep
    end
  end
end

def convert_to_lilypond()
  lp = "\\clef #{ $lilypond[:clef] }\n\\time #{ $lilypond[:time_sig] }\n\\key #{ $lilypond[:key_sig][0].to_s } \\#{ $lilypond[:key_sig][1].to_s }\n"
  $lilypond[:notes].map do |note|
    lp << "#{ note } "
  end
  return "{\n" + lp + "\n}"
end

set_env(input_canon)
interpret_canon(input_canon[:canon])
puts $lilypond
f = File.open("/home/emily/UniWork/3rdYear/Dissertation/GeneratedCanons/test2.ly", "w")
f.write(convert_to_lilypond())
