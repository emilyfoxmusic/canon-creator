\version "2.18.2"

\header {
title = "Untitled"
composer = "09"}
{
<<
\new Staff \with {
instrumentName = #"Pulse"
}
{
 \tempo 4 = 70
\transpose c c, {
 \clef bass
\time 3/4
\key c \major
a16 b16 c8 b8 c8 c8 d8 c16 d16 e8 d8 e8 e8 f8 d16 e16 f8 e8 f8 f8 g8 R2. R2. }
 }\new Staff \with {
instrumentName = #"Prophet"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef bass
\time 3/4
\key c \major
R2. a16 b16 c8 b8 c8 c8 d8 c16 d16 e8 d8 e8 e8 f8 d16 e16 f8 e8 f8 f8 g8 R2. }
 }\new Staff \with {
instrumentName = #"Dpulse"
}
{
 \tempo 4 = 70
\transpose c c' {
 \clef treble
\time 3/4
\key c \major
R2. R2. a16 b16 c8 b8 c8 c8 d8 c16 d16 e8 d8 e8 e8 f8 d16 e16 f8 e8 f8 f8 g8 }
 }>>
}
