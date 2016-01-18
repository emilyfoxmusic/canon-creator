

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
  proportion_sustain = 0.7
  proportion_release = 0.3
  pairs = beat[:rhythm].zip(beat[:notes])
  pairs.map do |pair|
    # pair[0] = pair[0] == Rational(1,2) ? 0.5 : 1 # TODO: TEMP: uncomment if using copied and pasted canons
    play pair[1], attack: 0, sustain: pair[0] * proportion_sustain, release: pair[0] * proportion_release
    sleep pair[0].to_f
  end
end

def play_canon(canon, voices)
  if canon.length == 0 || canon[0].length == 0
    puts "Warning: empty canon given."
  else
    num_beats = canon[0][0].length
    voices.times do
      puts "new"
      in_thread do
        play_melody(canon)
      end
      sleep num_beats
    end
  end
end
