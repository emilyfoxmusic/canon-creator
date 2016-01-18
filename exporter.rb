# input = [[{root_note: _, rhythm: [_], notes: [_]}, beat2, beat3], [beat1, beat2, beat3], [beat1, beat2, beat3]]
# TODO: make the canon structure containt the key in this form!
input_canon = {key: [:c, :minor], canon: [{:root_note=>67, :rhythm=>[Rational(1,1)], :notes=>[67]}, {:root_note=>65, :rhythm=>[Rational(1,1)], :notes=>[65]}, {:root_note=>67, :rhythm=>[Rational(1,1)], :notes=>[67]}, {:root_note=>72, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[72, 72]}], [{:root_note=>76, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[76, 76]}, {:root_note=>77, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[77, 77]}, {:root_note=>74, :rhythm=>[Rational(1,1)], :notes=>[74]}, {:root_note=>76, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[76, 76]}], [{:root_note=>72, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[72, 72]}, {:root_note=>69, :rhythm=>[Rational(1,1)], :notes=>[69]}, {:root_note=>71, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[71, 67]}, {:root_note=>67, :rhythm=>[Rational(1,1)], :notes=>[67]}], [{:root_note=>64, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[64, 64]}, {:root_note=>60, :rhythm=>[Rational(1,1)], :notes=>[60]}, {:root_note=>62, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[62, 60]}, {:root_note=>60, :rhythm=>[Rational(1,2), Rational(1,2)], :notes=>[60, 60]}]}

def get_lilypond_note(key, note_number)
  # Assume that key is between c4 and b4 and NO ACCIDENTALS and NO COMPLEX key signatures
  # Only MAJOR KEYS TODO: Implement minors

  def get_note_name(key, note_number)
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
      if [[:fs, :major],[:b, :major],[:e, :major],[:a, :major],[:d, :major]].include?(key)
        # This is C#
        return "cis"
      elsif [[:ab, :major], [:db, :major], [:gb, :major]].include?(key)
        # This is Db
        return "des"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 3 # D# / Eb
      if [[:fs, :major],[:b, :major],[:e, :major]].include?(key)
        # This is D#
        return "dis"
      elsif [[:bb, :major], [:eb, :major], [:ab, :major], [:db, :major], [:gb, :major]].include?(key)
        # This is Eb
        return "ees"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 6 # F# / Gb
      if [[:fs, :major],[:b, :major],[:e, :major],[:a, :major],[:d, :major], [:g, :major]].include?(key)
        # This is F#
        return "fis"
      elsif [[:db, :major], [:gb, :major]].include?(key)
        # This is Gb
        return "ges"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 8 # G# / Ab
      if [[:fs, :major],[:b, :major],[:e, :major],[:a, :major]].include?(key)
        # This is G#
        return "gis"
      elsif [[:eb, :major], [:ab, :major], [:db, :major], [:gb, :major]].include?(key)
        # This is Ab
        return "aes"
      else
        puts "Error: note #{ note_number } not in the key #{ key[0] } #{ key[1] }!"
      end
    when 10 # A# / Bb
      if [[:fs, :major],[:b, :major]].include?(key)
        # This is A#
        return "ais"
      elsif [[:f, :major], [:bb, :major], [:eb, :major], [:ab, :major], [:db, :major], [:gb, :major]].include?(key)
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
    return ((note_number / 12) + 1)
  end

  def get_lilypond_string(name, octave)
    octave_adjustment = octave - 4 # Because Lilypond uses octave 4 as a reference
    octave_string = ""
    if octave_adjustment > 0
      for i in 1..octave_adjustment
        octave_string + "\'"
      end
    elsif octave_adjustment < 0
      for i in 1..-octave_adjustment
        octave_string + ","
      end
    end
    return name + octave_string
  end

  note_name = get_note_name(input_canon[:key], note_number)
  octave = get_note_octave(note_number)
  return get_lilypond_string(note_name, octave)
end


$lilypond = {
  time_sig: nil,
  key_sig: nil,
  clef: nil,
  notes: []
}

def set_env(canon)
  $lilypond[:clef] = "treble"
  $lilypond[:time_sig] = canon[0].length == 3 ? "3/4" : "4/4"
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
  beat[:rhythm].zip(beat[:notes]) do |duration, pitch|
    lilypond_rep = pitch.to_s
    if duration == 0.25
      lilypond_rep << "16"
    elsif duration == 0.5
      lilypond_rep << "8"
    elsif duration == 1
      lilypond_rep << "4"
    end
    $lilypond[:notes] << lilypond_rep
  end
end

def convert_to_lilypond()
  lp = "\\clef #{ $lilypond[:clef] }\n\\time #{ $lilypond[:time_sig] }\n"
  $lilypond[:notes].map do |note|
    lp << "#{ note } "
  end
  return "{\n" + lp + "\n}"
end

set_env(input_canon)
interpret_canon(input_canon)
puts $lilypond
f = File.open("/home/emily/UniWork/3rdYear/Dissertation/GeneratedCanons/test.ly", "w")
f.write(convert_to_lilypond())
