\version "2.18.2"

\header {
title = "Untitled"
composer = "03"}
{
<<
\new Staff \with {
instrumentName = #"Saw"
}
{
 \tempo 4 = 60
\transpose c c {
 \clef bass
\time 4/4
\key c \major
c8 d8 e8 d16 e16 d8 c16 d16 e16 d8 d16 g8 gis8 gis8 c'4 f16 e16 d16 d16 c8 R1 }
 }\new Staff \with {
instrumentName = #"Pulse"
}
{
 \tempo 4 = 60
\transpose c c, {
 \clef bass
\time 4/4
\key c \major
R1 c8 d8 e8 d16 e16 d8 c16 d16 e16 d8 d16 g8 gis8 gis8 c'4 f16 e16 d16 d16 c8 }
 }>>
}
