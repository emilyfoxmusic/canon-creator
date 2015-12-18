$: << '/home/emily/Software/SonicPi/sonic-pi/app/server/vendor/mini_kanren/lib'

require 'mini_kanren'

res = MiniKanren.exec do

  # Remove this when I can use the note within mini_kanren block
  def note(note)
  notes = {
    :c => 60,
    :d => 62,
    :e => 64,
    :f => 65,
    :g => 67,
    :a => 69,
    :b => 71
  }
  notes[note]
end

  # make a structure, 4 bars long

  struct = {type: "round", num_bars: 4, time_sig: [4,4],
            bars: [
              {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]},
              {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]},
              {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]},
  {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]}]}

  # add some basic constraints

  def in_key_of_c(x)
    conde(eq(x, note(:c)), eq(x, note(:d)), eq(x, note(:d)), eq(x, note(:e)), eq(x, note(:f)), eq(x, note(:g)), eq(x, note(:a)), eq(x, note(:b)))
  end

  def is_some_duration(x)
    conde(eq(x, 0.5), eq(x, 1), eq(x, 1.5), eq(x, 2), eq(x, 3), eq(x, 4))
  end

  def adds_up_to(current_bar, duration)
      project(current_bar, lambda { |x|
        sum = 0
        for k in 0..x[:num_notes] - 1
          sum += x[:notes][k][:duration]
        end
        eq(sum, duration) })
  end

  # note one is a grounded variable
  def is_next_to(note1, note2, window)
    options = [eq(note1, note2)]
    for i in 1..window
      options << project(note1, lambda { |x| eq(x + window, note2)})
      options << project(note1, lambda { |x| eq(x - window, note2)})
    end
    conde(*options)
  end

  def specific_note(canon, bar, note, value)
    eq(canon[:bars][bar][:notes][note][:pitch], value)
  end

# both contain variables
  def canon_round(bar1, bar2)
    # notes played together must have an interval of 3, 4, 5, 6, 7
    project(bar1, lambda { |bar1| project(bar2, lambda { |bar2|
      conde_clauses = []
      start_time = 0
      end_time = 0
      for i in 0..bar1[:num_notes] - 1
        start_time = end_time
        end_time += bar1[:notes][i][:duration]
        start_time_2 = 0
        for j in 0..bar2[:num_notes] - 1
          if (start_time_2 >= start_time && start_time_2 < end_time)
            # DOES overlap
            conde_clauses << conde(
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] + 3),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] - 3),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] + 4),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] - 4),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] + 5),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] - 5),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] + 6),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] - 6),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] + 7),
              eq(bar1[:notes][i][:pitch], bar2[:notes][j][:pitch] - 7)
              )
          end
          start_time_2 += bar2[:notes][j][:duration]
        end
      end
      all(*conde_clauses)
      }) })
  end

  # do the constraints

  constraints = []

  constraints << specific_note(struct, 0, 0, note(:c))
  constraints << specific_note(struct, 1, 1, note(:g))
  constraints << specific_note(struct, 2, 2, note(:a))

  for i in 0..struct[:num_bars] - 1
    current_bar = struct[:bars][i]
    for j in 0..current_bar[:num_notes] - 1
      constraints << in_key_of_c(current_bar[:notes][j][:pitch])
      constraints << is_some_duration(current_bar[:notes][j][:duration])
    end
  end

  constraints << canon_round(struct[:bars][0], struct[:bars][1])
  constraints << canon_round(struct[:bars][1], struct[:bars][2])
  constraints << canon_round(struct[:bars][2], struct[:bars][3])

  for i in 0..struct[:num_bars] - 1
    current_bar = struct[:bars][i]
    for j in 0..current_bar[:num_notes] - 2
      constraints << adds_up_to(current_bar, 4)
      constraints << is_next_to(current_bar[:notes][j][:pitch], current_bar[:notes][j + 1][:pitch], 5)
    end
  end

  # run it!
  q = fresh
  run(1, q, eq(q, struct), *constraints)

end

puts res
