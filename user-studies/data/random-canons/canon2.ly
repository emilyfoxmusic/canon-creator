\version "2.18.2"

\header {
title = "Canon Two"
composer = "Canon Creator: 49958387"}
{
<<
\new Staff \with {
instrumentName = #"Saw"
}
{
\tempo 4 = 60
\transpose d d {
\clef treble
\time 3/4
\key d \major
a'4 fis'4 g'4 d'16 d'16 d'16 cis'16 cis'4 d'4 fis'8 a'8 d'8 e'8 b4 a4 e16 d16 e16 a16 a4 d'4 a16 b16 a8 g4 fis8 g8 cis16 cis16 cis8 d4 R2. R2. }
}
\new Staff \with {
instrumentName = #"Beep"
}
{
\tempo 4 = 60
\transpose d d {
\clef treble
\time 3/4
\key d \major
R2. R2. a'4 fis'4 g'4 d'16 d'16 d'16 cis'16 cis'4 d'4 fis'8 a'8 d'8 e'8 b4 a4 e16 d16 e16 a16 a4 d'4 a16 b16 a8 g4 fis8 g8 cis16 cis16 cis8 d4 }
}

>>
}
