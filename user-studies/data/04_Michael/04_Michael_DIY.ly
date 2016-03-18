\version "2.18.2"

\header {
title = "Untitled"
composer = "04"}
{
<<
\new Staff \with {
instrumentName = #"Prophet"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef bass
\time 4/4
\key c \major
c16 e16 g8 f16 a16 c'8 d16 f16 a8 c16 e16 g8 e16 g16 b8 a16 c'16 e'8 f16 a16 c'8 e16 g16 b8 c16 e16 g8 d16 f16 a8 b16 d'16 f'8 c16 e16 g8 R1 R1 }
 }\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef bass
\time 4/4
\key c \major
R1 c16 e16 g8 f16 a16 c'8 d16 f16 a8 c16 e16 g8 e16 g16 b8 a16 c'16 e'8 f16 a16 c'8 e16 g16 b8 c16 e16 g8 d16 f16 a8 b16 d'16 f'8 c16 e16 g8 R1 }
 }\new Staff \with {
instrumentName = #"Tb303"
}
{
 \tempo 4 = 70
\transpose c c, {
 \clef bass
\time 4/4
\key c \major
R1 R1 c16 e16 g8 f16 a16 c'8 d16 f16 a8 c16 e16 g8 e16 g16 b8 a16 c'16 e'8 f16 a16 c'8 e16 g16 b8 c16 e16 g8 d16 f16 a8 b16 d'16 f'8 c16 e16 g8 }
 }>>
}
