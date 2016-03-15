##########################################
######## PART TWO: Canon Creator #########
##########################################

# Now you may use Canon Creator to compose some canons.

##########################################
###### INFORMATION ABOUT YOUR CANON ######
##########################################

# This is the tempo (speed) of the canon in beats per minute.
tempo = 70
use_bpm tempo # LEAVE this

# This is the title of your composition. Feel free to leave it as it is.
title = "An Untitled Canon."

# This is your name (composer). Feel free to leave it as it is.
composer = "Anon."

##########################################
############## YOUR CANON! ###############
##########################################
####### (Compose your canon here) ########
##########################################
use_random_seed 42
canon_play(canon.key_type(:major).key_note(:g).probabilities([0.1, 0.25, 0.25, 0.4]).variation(20).type(:crab))
