# Diary Of A Canon
## The learning process...

This document aims to show the progress that I have made so far and the course of development. What was learned at each stage? Why have I made certain design choices? etc.

#### Date: 18th December 2015

Today I have come up against the bane that is program complexity. I *think* I have a working canon generator, but unfortunately, it's not going to terminate any time soon... The durations get resolved pretty quickly (quickly enough anyway) but the pitches do not. I think so far it's been running a good half hour, and this is only a simple example.

Is suspect that the problem is that I am doing a generate and test type paradigm, but what I really need is something a little quicker- the solution space is vast!

##### Current solution:

Broadly this involves setting the options of what each note can be, then adding constraints that they are next to each other, then finally adding the canon constraints on each bar. This turns out to be infeasible (!).

##### Proposed solution:

Randomly set more things at the start. The structure will generate the timings first and then have them set before going into setting the pitches.

Find a better way to check which notes overlap. There are a few ways to do this:

1. We know that if one note comes after the other, none that follow it can overlap either.
2. On the next go round the loop, ones that were before the first one that overlapped with the last note cannot overlap with this one either.

I should also try the method of choosing a few notes at a time to constrain to set intervals from each other. This might make constraints more explicit and therefore faster. It also gets rid of the problem of having all the notes the same, as well as making this easier to specify.

Advantages:
* Hopefully it will be able to run is reasonable time! (Yay!)

Disadvanatges:
* Lose some options in flexibility- we assume we only want one solution back from the function and not multiple ones. I think however, this is a reasonable design choice in this case.

##### Revised plan:

Add constraints to each bar in sequence so that backtracking is not looking at the whole thing at once. i.e.

1. Generate one bar of music
2. Generate the next, based on the previous one
3. Repeat

This could be done durations first, then pitches afterwards, or all at the same time. The former would imply there is no relation between the durations and the pitches, the latter might mean I am able to do more compex things.
