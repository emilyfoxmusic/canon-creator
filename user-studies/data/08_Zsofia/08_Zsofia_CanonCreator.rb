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
use_random_seed 222
canon_play(canon.key_type(:minor).lowest_note(:c3).beats_per_bar(3).key_note(:e).type(:round).number_of_voices(2).sounds([:saw, :pulse]).highest_note(:c7).variation(30))
