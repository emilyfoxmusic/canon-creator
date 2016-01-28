# Canon Creator (canon-creator)
Copyright Emily Fox (c) 2016, MIT License.

*This work has been undertaken as part of my Part II project at Cambridge University.*

### What is Canon Creator?
Canon Creator is some code that you can use within Sonic Pi (https://github.com/samaaron/sonic-pi) in order to generate and play canons.

### What is a canon?
See https://en.wikipedia.org/wiki/Canon_%28music%29 for detailed information about canons. Currently this software only supports the creation of rounds, which are a specialist type of canon.

### Installation
Copy the canon-creator folder into the vendor file of your Sonic Pi installation. When you want to use the functionality you will have to copy and paste the contents of the *interface.rb* file into a workspace within Sonic Pi and run it. (You must do this every time you start Sonic Pi.) Then you are able to use it wherever you want within that session.

### Use
Canons may be created using the function canon(). You may then chain options to constrain what canons will be generated. A complete list of options is given below.

* key_type(*type*) where *type* is *:major* or *:minor*.
* key_note(*note*) where *note* is the tonic of the scale you wish to use. Keys with between 0 and 7 sharps or flats are supported.
* time_signature(*time_sig*) where *time_sig* is either "3/4" or "4/4".
* lowest_note(*note*) where *note* is the lowest note you want the canon to use (as a name, e.g. *:c* or *:f5*).
* highest_note(*note*) where *note* is the highest note you want the canon to use (as a name, e.g. *:f* or *:as7*).
* probabilities(*prob*) where *prob* is an array of length 4, containing the probability that each beat is split into a certain number of notes. For example an array of [0.5, 0.25, 0.25, 0] will split a beat into a single note with probability 0.5, into a double or triple note with probability 0.25, and will never split a note into 4. The probabilities must add up to one.
* chord_progression(*chord_prog*) where *chord_prog* is an array (with the same length as the number of beats in a bar, i.e. 3 or 4) containing the chord progression you want to use for the canon. The chord will change to the next one in the array each beat. The available chords are *:I*, *:IV*, *:V*, and *:VI*.
* max_jump(*jmp*) where *jmp* is the number of semitones allowed between consecutive root notes. In general, a large value here means that there is more local variation in a tune.


### Example code

#### Playing a canon with no constraints specified

``canon_play(canon)``

This will pick random values for all the properties of the canon and play it.

#### Playing a canon with some properties specified

``canon_play(canon.key_type(:major).key_note(:g).time_signature("3/4").max_jump(8).probabilities([0.5, 0.25, 0.2, 0.05]))``

This will play a canon in G Major, with a time signature of 3/4, with a maximum gap between root notes (a rough measure of how much the melody moves around) of 8 semitones, and a rough distribution of half the beats being crotchets, a quarter being two quavers, a fifth of them being some combination of three notes (a quaver and two semiquavers, or a triplet) and only a twentieth being four semiquavers.

#### Exporting and playing a canon with no constraints specified

``canon_export(canon, "/some/file/location/lilypond_file_name.lp")`` or
``canon_export(canon, "/some/file/location/lilypond_file_name.lp", true)``

This will generate and export the canon to the file specified in a format that can be compiled by Lilypond (Lilypond v2.18 or later needed). The 'true' specifies that we also want to play the melody (default is true).

#### Exporting (without playing) a canon with one constraint specified

``canon_export(canon.key_note(:c), "some/file/loaction/lilypond_file_name.lp", false)``

This will generate and export the canon to the file specified in a format that can be compiled by Lilypond (Lilypond v2.18 or later needed). The 'false' specifies that we do not want to play the melody (default is true).
