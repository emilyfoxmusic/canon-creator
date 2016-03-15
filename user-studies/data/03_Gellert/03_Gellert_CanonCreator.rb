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

use_random_seed(324)
canon_play(canon.key_type(:minor).key_note(:c).lowest_note(:c3).voice_offset(1).probabilities([0.2, 0.1, 0.2, 0.5]).number_of_voices(3).number_of_bars(16))
