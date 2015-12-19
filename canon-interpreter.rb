def play_melody(mel)
  num_bars = mel.length
  for i in 0..num_bars - 1
    play_bar(mel[i])
  end
end

def play_bar(bar)
  num_beats = bar.length
  for i in 0..num_beats - 1
    play_beat(bar[i])
  end
end

def play_beat(beat)
  pairs = beat[:rhythm].zip(beat[:notes])
  pairs.map do |pair|
    play pair[1]
    sleep pair[0]
  end
end

def play_canon(canon, voices)
  if canon.length == 0 || canon[0].length == 0
    puts "Warning: empty canon given."
  else
    num_beats = canon[0][0].length
    for i in 0..voices - 1
      sleep i * num_beats
      in_thread do
        play_melody(canon)
      end
    end
  end
end
