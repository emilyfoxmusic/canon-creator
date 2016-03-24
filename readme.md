# Canon Creator (canon-creator)
Copyright Emily Fox (c) 2016, MIT License.

*This work has been undertaken as part of my Part II project at Cambridge University.*

### What is Canon Creator?
Canon Creator is some code that you can use within Sonic Pi (https://github.com/samaaron/sonic-pi) in order to generate and play canons.

### What is a canon?
See https://en.wikipedia.org/wiki/Canon_%28music%29 for detailed information about canons. Currently this software only supports the creation of rounds, palindromes and a form of crab canons, which are specialist types of canon.

### Installation
Copy the canon-creator folder into the vendor file of your Sonic Pi installation (*sonic-pi/app/server/vendor/*). When you want to use the functionality you will have to copy and paste the contents of the *interface.rb* file into a workspace within Sonic Pi and run it. (You must do this every time you start Sonic Pi.) Then you are able to use it wherever you want within that session.

### Use
Canons may be created using the function canon(). You may then chain options to constrain what canons will be generated. A complete list of options is given below.

* key_type(*type*) where *type* is *:major* or *:minor*.
* key_note(*note*) where *note* is the tonic of the scale you wish to use. Keys with between 0 and 7 sharps or flats are supported.
* beats_per_bar(*beats*) where *beats* is either 3 or 4.
* lowest_note(*note*) where *note* is the lowest note you want the canon to use (as a name, e.g. *:c* or *:f5*).
* highest_note(*note*) where *note* is the highest note you want the canon to use (as a name, e.g. *:f* or *:as7*).
* probabilities(*prob*) where *prob* is an array of length 4, containing the probability that each beat is split into a certain number of notes. For example an array of [0.5, 0.25, 0.25, 0] will split a beat into a single note with probability 0.5, into a double or triple note with probability 0.25, and will never split a note into 4. The probabilities must add up to one.
* max_jump(*jmp*) where *jmp* is the number of semitones allowed between consecutive root notes. In general, a large value here means that there is more local variation in a tune.
* number_of_bars(*num*) where *num* is the number of bars you want in the piece.
* number_of_voices(*num*) where *num* is the number of voices you want in the piece.
* type(*type*) where *type* is the type of canon you want to create. This can be *:round*, *:crab* or *:palindrome*. A crab has the same melody playing with itself in reverse at some points, palindrome sounds the same forwards as backwards and the round has no such restrictions on the melody.
* variation(*var*) where *var* is the percentage variation. 100 means that every bar could theoretically have a different rhythm and 1 means that they will all transform in the same way.
* voice_offset(*offset*) where *offset* is the number of bars before the next voice starts to play.
* voice_transpositions(*trans*) where *trans* is an array containing -2, -1, 0, 1, or 2 as the entries where that number is the number of octaves that voice will be transposed.
* sounds(*snds*) where *snds* is an array containing Sonic Pi synth voices to specify which to use for each voice.


### Example code

#### Playing a canon with no constraints specified

``canon_play(canon)``

This will pick random values for all the properties of the canon and play it.

#### Playing a canon with some properties specified

``canon_play(canon.key_type(:major).key_note(:g).beats_per_bar(3).max_jump(8).probabilities([0.5, 0.25, 0.2, 0.05]))``

This will play a canon in G Major, with a time signature of 3/4, with a maximum gap between root notes (a rough measure of how much the melody moves around) of 8 semitones, and a rough distribution of half the beats being crotchets, a quarter being two quavers, a fifth of them being some combination of three notes (a quaver and two semiquavers, or a triplet) and only a twentieth being four semiquavers.

#### Exporting canons

``canon_export(canon, file path, title, composer, to play, bpm)``

To export the canon use the above method. The arguments from 'title' to 'bpm' will be assigned default values if there are none specified.

For example...

##### Exporting and playing a canon with no constraints specified

``canon_export(canon, "/some/file/location/lilypond_file_name.lp")``

This will generate and export the canon to the file specified in a format that can be compiled by Lilypond (Lilypond v2.18 or later needed). It will have the default title: *"Untitled"*, composer: *"Anon."* and it will also play the canon since the default value is true for this. The bpm will be *nil* so will not appear in the Lilypond file.

##### Exporting (without playing) a canon with one constraint specified

``canon_export(canon.key_note(:c), "some/file/location/lilypond_file_name.lp", "My Canon", "A. M. Person", false, 60)``

This will generate and export the canon to the file specified in a format that can be compiled by Lilypond (Lilypond v2.18 or later needed) with the given title, composer and tempo. The 'false' specifies that we do not want to play the melody (default is true).
