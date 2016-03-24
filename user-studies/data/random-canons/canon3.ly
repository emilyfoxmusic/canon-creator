\version "2.18.2"

\header {
title = "Canon Three"
composer = "Canon Creator: 71127165"}
{
<<
\new Staff \with {
instrumentName = #"Beep"
}
{
\tempo 4 = 60
\transpose d d {
\clef treble
\time 3/4
\key d \major
fis4 d4 g4 cis'8 fis'8 e'4 fis'4 d'4 g'16 b'16 g'16 a'16 d'4 a4 e4 a4 fis4 b4 g4 cis'16 cis'16 cis'8 e'4 d'4 R2. R2. }
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
R2. R2. fis4 d4 g4 cis'8 fis'8 e'4 fis'4 d'4 g'16 b'16 g'16 a'16 d'4 a4 e4 a4 fis4 b4 g4 cis'16 cis'16 cis'8 e'4 d'4 }
}

>>
}
