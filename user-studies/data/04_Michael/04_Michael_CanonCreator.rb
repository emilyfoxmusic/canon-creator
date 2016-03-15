##########################################

# Now you may use Canon Creator to compose some canons.

##########################################
###### INFORMATION ABOUT YOUR CANON ######
##########################################

# This is the tempo (speed) of the canon in beats per minute.
tempo = 200
use_bpm tempo # LEAVE this

# This is the title of your composition. Feel free to leave it as it is.
title = "Mah mooosick."

# This is your name (composer). Feel free to leave it as it is.
composer = "M Dizzle."

##########################################
############## YOUR CANON! ###############
##########################################
####### (Compose your canon here) ########
##########################################

use_random_seed 100
#canon_play(canon.probabilities([0.2, 0.2, 0.1, 0.5]).number_of_voices(4).key_note(:c))
canon_play(canon)
