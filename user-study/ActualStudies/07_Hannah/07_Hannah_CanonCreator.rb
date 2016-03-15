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
use_random_seed 55556
canon_play(canon.key_type(:minor).key_note(:g).lowest_note(:g3).highest_note(:g6)
           .beats_per_bar(3).number_of_bars(6).variation(75).
           number_of_voices(3).voice_transpositions([0,1,0]).voice_offset(1).
           sounds([:pulse,:pretty_bell,:saw]))









#### LEAVE THIS PART ####
#canon_export(c, "/home/emily/Dropbox/Dissertation/UserStudies/05_Daniel/06_Peter_CanonCreator.ly", composer, title, false, tempo)
