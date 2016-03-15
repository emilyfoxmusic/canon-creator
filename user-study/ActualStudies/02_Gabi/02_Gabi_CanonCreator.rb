##########################################
######## PART TWO: Canon Creator #########
##########################################

# Now you may use Canon Creator to compose some canons.

##########################################
###### INFORMATION ABOUT YOUR CANON ######
##########################################

# This is the tempo (speed) of the canon in beats per minute.
tempo = 80

# This is the title of your composition. Feel free to leave it as it is.
title = "An Untitled Canon."

# This is your name (composer). Feel free to leave it as it is.
composer = "Anon."

##########################################
############## YOUR CANON! ###############
##########################################
####### (Compose your canon here) ########
##########################################

# use_random_seed 101
#canon.key_type(:major).lowest_note(:c4).beats_per_bar(3).probabilities([0.2, 0.25, 0.35, 0.2])
#canon_play(canon)

use_random_seed 101
canon.key_type(:major).lowest_note(:c4).beats_per_bar(3).probabilities([0.2, 0.25, 0.35, 0.2]).number_of_voices(4).type(:crab).voice_transpositions([0, 1, -1, 0])
canon_play(canon)
