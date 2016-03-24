\version "2.18.2"

\header {
title = "Untitled"
composer = "05"}
{
<<
\new Staff \with {
instrumentName = #"Saw"
}
{
\tempo 4 = 70
\transpose g g {
\clef treble
\time 4/4
\key g \major
d'4 e'8 fis'8 d'8 d'8 c'16 b16 a16 b16 g4 e8 fis8 a16 d16 g16 d16 g16 fis16 g8 g8 fis16 g16 d16 g16 d16 a16 fis8 e8 g4 b16 a16 b16 c'16 d'8 d'8 fis'8 e'8 d'4 g'4 g'8 fis'8 a'8 a'8 g'16 g'16 e'16 g'16 d'4 e'8 a8 c'16 fis16 d16 fis16 b8 a16 b16 b16 a16 b8 fis16 d16 fis16 c'16 a8 e'8 d'4 g'16 e'16 g'16 g'16 a'8 a'8 fis'8 g'8 g'4 R1 R1 }
}
\new Staff \with {
instrumentName = #"Beep"
}
{
\tempo 4 = 70
\transpose g g {
\clef treble
\time 4/4
\key g \major
R1 R1 d'4 e'8 fis'8 d'8 d'8 c'16 b16 a16 b16 g4 e8 fis8 a16 d16 g16 d16 g16 fis16 g8 g8 fis16 g16 d16 g16 d16 a16 fis8 e8 g4 b16 a16 b16 c'16 d'8 d'8 fis'8 e'8 d'4 g'4 g'8 fis'8 a'8 a'8 g'16 g'16 e'16 g'16 d'4 e'8 a8 c'16 fis16 d16 fis16 b8 a16 b16 b16 a16 b8 fis16 d16 fis16 c'16 a8 e'8 d'4 g'16 e'16 g'16 g'16 a'8 a'8 fis'8 g'8 g'4 }
}

>>
}
