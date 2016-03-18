\version "2.18.2"

\header {
title = "Untitled"
composer = "08"}
{
<<
\new Staff \with {
instrumentName = #"Hoover"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef bass
\time 4/4
\key c \major
c4 e4 c4 e4 g4 a16 c'16 d8 f4 e4 c8 e8 d8 c8 a16 c'16 b16 a16 c4 R1 R1 }
 }\new Staff \with {
instrumentName = #"Beep"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef bass
\time 4/4
\key c \major
R1 c4 e4 c4 e4 g4 a16 c'16 d8 f4 e4 c8 e8 d8 c8 a16 c'16 b16 a16 c4 R1 }
 }\new Staff \with {
instrumentName = #"Dpulse"
}
{
 \tempo 4 = 70
\transpose c c, {
 \clef bass
\time 4/4
\key c \major
R1 R1 c4 e4 c4 e4 g4 a16 c'16 d8 f4 e4 c8 e8 d8 c8 a16 c'16 b16 a16 c4 }
 }>>
}
