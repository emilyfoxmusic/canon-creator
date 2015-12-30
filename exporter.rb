# input = [[{root_note: _, rhythm: [_], notes: [_]}, beat2, beat3], [beat1, beat2, beat3], [beat1, beat2, beat3]]

input_canon = [[{:root_note=>:g, :rhythm=>[1], :notes=>[:g]}, {:root_note=>:c, :rhythm=>[1], :notes=>[:c]}, {:root_note=>:d, :rhythm=>[0.5, 0.25, 0.25], :notes=>[:d, :e, :d]}], [{:root_note=>:e, :rhythm=>[0.5, 0.5], :notes=>[:e, :g]}, {:root_note=>:f, :rhythm=>[1], :notes=>[:f]}, {:root_note=>:b, :rhythm=>[1], :notes=>[:b]}], [{:root_note=>:c, :rhythm=>[1], :notes=>[:c]}, {:root_note=>:f, :rhythm=>[0.25, 0.25, 0.5], :notes=>[:f, :e, :f]}, {:root_note=>:g, :rhythm=>[0.5, 0.25, 0.25], :notes=>[:g, :a, :g]}]]

$lilypond = {
  time_sig: nil,
  clef: nil,
  notes: []
}

def set_env(canon)
  $lilypond[:clef] = "bass"
  $lilypond[:time_sig] = canon[0].length == 3 ? "3/4" : "4/4"
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
