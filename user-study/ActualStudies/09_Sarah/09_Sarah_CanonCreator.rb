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
composer = "Sarah Metcalf"

##########################################
############## YOUR CANON! ###############
##########################################
####### (Compose your canon here)

use_random_seed 17

canon_play(canon.key_type(:major).key_note(:d).number_of_bars(16).number_of_voices(3).type(:palindrome).voice_offset(2).sounds([:pretty_bell, :pulse, :dpulse]))





########
##########################################
