\version "2.18.2"

\header {
title = "Untitled"
composer = "07"}
{
<<
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef bass
\time 4/4
\key c \major
g4 g4 e4 f8 g8 a4 c'8 a8 a8 c16 a16 b8 c16 b16 c'8 c8 c4 r2 R1 R1 }
 }\new Staff \with {
instrumentName = #"Saw"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef bass
\time 4/4
\key c \major
R1 g4 g4 e4 f8 g8 a4 c'8 a8 a8 c16 a16 b8 c16 b16 c'8 c8 c4 r2 R1 }
 }\new Staff \with {
instrumentName = #"Tb303"
}
{
 \tempo 4 = 70
\transpose c c, {
 \clef bass
\time 4/4
\key c \major
R1 R1 g4 g4 e4 f8 g8 a4 c'8 a8 a8 c16 a16 b8 c16 b16 c'8 c8 c4 r2 }
 }>>
}
