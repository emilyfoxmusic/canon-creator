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


use_random_seed 9999999999999999999999999999999
canon_play(canon.key_type(:minor).key_note(:e).beats_per_bar(3).probabilities([0.4, 0.4, 0.1, 0.1]).number_of_bars(16).number_of_voices(3).type(:palindrome).max_jump(12).lowest_note(:e3).highest_note(:e6))
