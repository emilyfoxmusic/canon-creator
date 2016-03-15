##########################################
###### PART ONE: DIY Canon Creation ######
##########################################

# This is where you create your canon manually. You have been provided with a template to modify
# as you wish.

##########################################
###### INFORMATION ABOUT YOUR CANON ######
##########################################

# This is the number of beats to wait before starting to play the melody again.
number_of_beats_per_bar = 4
number_of_bars_before_starting_the_next_voice = 1

# This is how many times you want the melody to play (how many parts/voices in the canon).
number_of_voices = 5

# This is the type of sound you want to use for each voice. See Buffer 3 for the options.
# **Make sure you type it correctly or it will be silent!**
sounds = [:dpulse, :saw, :tb303, :hoover, :pulse]

# This is the transpose you want to apply to each voice, in octaves. To have them all the same, just
# write zero in each. To put it up an octave use 1, down an octave use -1, up two octaves use 2 etc.
transpose = [0, 0, -1, +1, -2]

# This is the tempo (speed) of the piece, in beats per minute.
tempo = 70

##########################################
############## YOUR CANON! ###############
##########################################

use_bpm tempo

# This is your canon. The whole piece goes inside square brackets ([]) and each note goes inside
# curly brakets ({}). Each note needs a pitch and a length and separate each note with a
# comma. e.g. [{pitch: :c, length: 1}, {pitch: :d, length: 0.5}]

canon = [
  {pitch: :c8, length: 1},
  {pitch: :d8, length: 1},
  {pitch: :e8, length: 0.25},{pitch: :e8, length: 0.25},{pitch: :e8, length: 0.25},{pitch: :e8, length: 0.25},
  {pitch: :d1, length: 0.5},{pitch: :d1, length: 0.5},
  {pitch: :c3, length: 1},
  {pitch: :e7, length: 1},
  {pitch: :fs3, length: 0.25},{pitch: :bb8, length: 0.25},{pitch: :fs3, length: 0.25},{pitch: :bb8, length: 0.25},
  {pitch: :bb8, length: 1},
  {pitch: :a2, length: 0.5},{pitch: :d2, length: 0.5},
  {pitch: :d2, length: 1},
  {pitch: :cs, length: 1},
  {pitch: :c, length: 0.25},{pitch: :cs, length: 0.25},{pitch: :c, length: 0.25},{pitch: :cs, length: 0.25},
  {pitch: :e4, length: 0.25},{pitch: :a4, length: 0.25},{pitch: :g4, length: 0.25},{pitch: :d4, length: 0.25},
  {pitch: :a4, length: 1},
  {pitch: :f4, length: 1},
  {pitch: :d4, length: 0.25},{pitch: :ds4, length: 0.25},{pitch: :db4, length: 0.25},{pitch: :c, length: 0.25},
  {pitch: :c, length: 1},
  {pitch: :c, length: 0.5},{pitch: :e6, length: 0.5},
  {pitch: :g7, length: 1},
  {pitch: :g8, length: 1}
]

#############################
###### PLAY THE CANON #######
#############################

# Do NOT touch this part.

validate_canon(canon, number_of_beats_per_bar, number_of_bars_before_starting_the_next_voice, number_of_voices, sounds, transpose)
play_user_canon(canon, number_of_beats_per_bar, number_of_bars_before_starting_the_next_voice, number_of_voices, sounds, transpose)
