##########################################
###### PART ONE: DIY Canon Creation ######
##########################################

# This is where you create your canon manually. You have been provided with a template to modify
# as you wish.

##########################################
###### INFORMATION ABOUT YOUR CANON ######
##########################################

# This is the number of beats to wait before starting to play the melody again.
number_of_beats_per_bar = 3
number_of_bars_before_starting_the_next_voice = 1

# This is how many times you want the melody to play (how many parts/voices in the canon).
number_of_voices = 3

# This is the type of sound you want to use for each voice. See Buffer 3 for the options.
# **Make sure you type it correctly or it will be silent!**
sounds = [:pretty_bell, :saw, :hoover]
#sounds = [:pretty_bell, :saw, :tb303]
# :hoover

# This is the transpose you want to apply to each voice, in semitones. To have them all the same, just
# write zero in each. To put it up an octave use 12, down an octave use -12, up two octaves use 24 etc.
transpose = [0, -1, +2]

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
  #{pitch: :c4, length: 0.25}, {pitch: :d4, length: 0.25}, {pitch: :e4,  length: 0.5},
  #{pitch: :a3, length: 0.25}, {pitch: :c4, length: 0.25}, {pitch: :e4,  length: 0.5},
  {pitch: :c5,  length: 1},
  {pitch: :c4, length: 0.5}, {pitch: :d4,  length: 0.5},
  {pitch: :e4, length: 0.5}, {pitch: :f4, length: 0.5},
  {pitch: :g4,  length: 0.5}, {pitch: :g4,  length: 0.5},
  #  {pitch: :g4,  length: 0.5}, {pitch: :g4,  length: 0.5},

  {pitch: :e4, length: 0.25}, {pitch: :d4,  length: 0.25}, {pitch: :c4, length: 0.5},

  #  {pitch: :e4, length: 0.5}, {pitch: :e4, length: 0.5},

]

#############################
###### PLAY THE CANON #######
#############################

# Do NOT touch this part.

validate_canon(canon, number_of_beats_per_bar, number_of_bars_before_starting_the_next_voice, number_of_voices, sounds, transpose)
play_user_canon(canon, number_of_beats_per_bar, number_of_bars_before_starting_the_next_voice, number_of_voices, sounds, transpose)
