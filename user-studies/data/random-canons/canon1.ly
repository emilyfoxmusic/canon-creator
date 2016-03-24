\version "2.18.2"

\header {
title = "Canon One"
composer = "Canon Creator: 30615591"}
{
<<
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
\tempo 4 = 60
\transpose d d {
\clef treble
\time 4/4
\key d \minor
d'4 a4 c'16 a16 c'8 d'4 f'16 d'16 f'16 bes16 d'4 a8 bes8 f4 d8 a8 f4 c4 d4 f4 a4 c'4 d'4 f'8 e'8 d'8 d'8 a4 f4 d4 f4 c16 f16 c8 d4 f4 a4 c'4 d'4 a8 a16 a16 f16 g16 f8 c16 d16 c8 d4 R1 }
}
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
\tempo 4 = 60
\transpose d d {
\clef treble
\time 4/4
\key d \minor
R1 d'4 a4 c'16 a16 c'8 d'4 f'16 d'16 f'16 bes16 d'4 a8 bes8 f4 d8 a8 f4 c4 d4 f4 a4 c'4 d'4 f'8 e'8 d'8 d'8 a4 f4 d4 f4 c16 f16 c8 d4 f4 a4 c'4 d'4 a8 a16 a16 f16 g16 f8 c16 d16 c8 d4 }
}

>>
}
