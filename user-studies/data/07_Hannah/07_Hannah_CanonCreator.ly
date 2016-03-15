\version "2.18.2"

\header {
title = "An Untitled Canon."
composer = "Anon."}
{
<<
\new Staff \with {
instrumentName = #"Pulse"
}
{
\tempo 4 = 70
\transpose g g {
\clef treble
\time 3/4
\key g \minor
ees8 c8 d4 g4 bes4 d'4 g'4 bes'16 f''16 bes'8 d''16 bes'16 d''16 g'16 bes'4 g'4 f'4 d'4 bes4 f8 d'8 bes4 ees'8 c'8 d'4 g'4 R2. R2. }
}
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
\tempo 4 = 70
\transpose g g' {
\clef treble
\time 3/4
\key g \minor
R2. ees8 c8 d4 g4 bes4 d'4 g'4 bes'16 f''16 bes'8 d''16 bes'16 d''16 g'16 bes'4 g'4 f'4 d'4 bes4 f8 d'8 bes4 ees'8 c'8 d'4 g'4 R2. }
}
\new Staff \with {
instrumentName = #"Saw"
}
{
\tempo 4 = 70
\transpose g g {
\clef treble
\time 3/4
\key g \minor
R2. R2. ees8 c8 d4 g4 bes4 d'4 g'4 bes'16 f''16 bes'8 d''16 bes'16 d''16 g'16 bes'4 g'4 f'4 d'4 bes4 f8 d'8 bes4 ees'8 c'8 d'4 g'4 }
}

>>
}