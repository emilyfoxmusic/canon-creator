def play_melody(canon)
  for i in 0..canon[:num_bars] - 1
    for j in 0..canon[:bars][i][:num_notes] - 1
      play canon[:bars][i][:notes][j][:pitch]
      sleep canon[:bars][i][:notes][j][:duration]
    end
  end
end

def play_canon(canon, voices)
  for i in 0..voices - 1
    sleep i * canon[:time_sig][0]
    in_thread do
      play_melody(canon)
    end
  end
end
