$: << '/home/emily/Software/SonicPi/sonic-pi/app/server/vendor/mini_kanren/lib'

require 'mini_kanren'

res = MiniKanren.exec do

  # make a structure, 4 bars long

  struct = {type: "round", num_bars: 4, time_sig: [4,4],
            bars: [
              {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]},
              {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]},
              {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]},
  {num_notes: 4, notes: [{pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}, {pitch: fresh, duration: fresh}]}]}

  # add some basic constraints

  def in_key_of_c(x)
    conde(eq(x, :c), eq(x, :d), eq(x, :d), eq(x, :e), eq(x, :f), eq(x, :g), eq(x, :a), eq(x, :b))
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

  # do the constraints

  constraints = []

  for i in 0..struct[:num_bars] - 1
    current_bar = struct[:bars][i]
    for j in 0..current_bar[:num_notes] - 1
      constraints << in_key_of_c(current_bar[:notes][j][:pitch])
      constraints << is_some_duration(current_bar[:notes][j][:duration])
    end
    for j in 0..current_bar[:num_notes] - 1
      constraints << adds_up_to(current_bar, 4)
    end
  end


  # run it!
  q = fresh
  run(1, q, eq(q, struct), *constraints)

end

puts res
