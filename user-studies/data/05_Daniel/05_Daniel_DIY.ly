\version "2.18.2"

\header {
title = "Untitled"
composer = "05"}
{
<<
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef treble
\time 3/4
\key c \major
c'4 c8 d8 e8 f8 g8 g8 e16 d16 c8 r4 R2. R2. }
 }\new Staff \with {
instrumentName = #"Saw"
}
{
 \tempo 4 = 70
\transpose c c, {
 \clef bass
\time 3/4
\key c \major
R2. c'4 c8 d8 e8 f8 g8 g8 e16 d16 c8 r4 R2. }
 }\new Staff \with {
instrumentName = #"Hoover"
}
{
 \tempo 4 = 70
\transpose c c'' {
 \clef treble
\time 3/4
\key c \major
R2. R2. c'4 c8 d8 e8 f8 g8 g8 e16 d16 c8 r4 }
 }>>
}
