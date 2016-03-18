\version "2.18.2"

\header {
title = "Untitled"
composer = "02"}
{
<<
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
 \tempo 4 = 100
\transpose c c {
 \clef bass
\time 3/4
\key c \major
a8 g8 a8 a8 g8 a8 d'4 c'8 a4 a8 g8 a8 g4 f4 f8 d4 c8 d4 R2. R2. }
 }\new Staff \with {
instrumentName = #"Saw"
}
{
 \tempo 4 = 100
\transpose c c {
 \clef bass
\time 3/4
\key c \major
R2. a8 g8 a8 a8 g8 a8 d'4 c'8 a4 a8 g8 a8 g4 f4 f8 d4 c8 d4 R2. }
 }\new Staff \with {
instrumentName = #"Tb303"
}
{
 \tempo 4 = 100
\transpose c c, {
 \clef bass
\time 3/4
\key c \major
R2. R2. a8 g8 a8 a8 g8 a8 d'4 c'8 a4 a8 g8 a8 g4 f4 f8 d4 c8 d4 }
 }>>
}
