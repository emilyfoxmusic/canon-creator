\version "2.18.2"

\header {
title = "Untitled"
composer = "06"}
{
<<
\new Staff \with {
instrumentName = #"Dpulse"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef treble
\time 4/4
\key c \major
c''''4 d''''4 e''''16 e''''16 e''''16 e''''16 d,,,8 d,,,8 c,4 e'''4 fis,16 bes''''16 fis,16 bes''''16 bes''''4 a,,8 d,,8 d,,4 cis4 c16 cis16 c16 cis16 e16 a16 g16 d16 a4 f4 d16 dis16 des16 c16 c4 c8 e''8 g'''4 g''''4 R1 R1 R1 R1 }
 }\new Staff \with {
instrumentName = #"Saw"
}
{
 \tempo 4 = 70
\transpose c c {
 \clef treble
\time 4/4
\key c \major
R1 c''''4 d''''4 e''''16 e''''16 e''''16 e''''16 d,,,8 d,,,8 c,4 e'''4 fis,16 bes''''16 fis,16 bes''''16 bes''''4 a,,8 d,,8 d,,4 cis4 c16 cis16 c16 cis16 e16 a16 g16 d16 a4 f4 d16 dis16 des16 c16 c4 c8 e''8 g'''4 g''''4 R1 R1 R1 }
 }\new Staff \with {
instrumentName = #"Tb303"
}
{
 \tempo 4 = 70
\transpose c c, {
 \clef bass
\time 4/4
\key c \major
R1 R1 c''''4 d''''4 e''''16 e''''16 e''''16 e''''16 d,,,8 d,,,8 c,4 e'''4 fis,16 bes''''16 fis,16 bes''''16 bes''''4 a,,8 d,,8 d,,4 cis4 c16 cis16 c16 cis16 e16 a16 g16 d16 a4 f4 d16 dis16 des16 c16 c4 c8 e''8 g'''4 g''''4 R1 R1 }
 }\new Staff \with {
instrumentName = #"Hoover"
}
{
 \tempo 4 = 70
\transpose c c' {
 \clef treble
\time 4/4
\key c \major
R1 R1 R1 c''''4 d''''4 e''''16 e''''16 e''''16 e''''16 d,,,8 d,,,8 c,4 e'''4 fis,16 bes''''16 fis,16 bes''''16 bes''''4 a,,8 d,,8 d,,4 cis4 c16 cis16 c16 cis16 e16 a16 g16 d16 a4 f4 d16 dis16 des16 c16 c4 c8 e''8 g'''4 g''''4 R1 }
 }\new Staff \with {
instrumentName = #"Pulse"
}
{
 \tempo 4 = 70
\transpose c c,, {
 \clef bass
\time 4/4
\key c \major
R1 R1 R1 R1 c''''4 d''''4 e''''16 e''''16 e''''16 e''''16 d,,,8 d,,,8 c,4 e'''4 fis,16 bes''''16 fis,16 bes''''16 bes''''4 a,,8 d,,8 d,,4 cis4 c16 cis16 c16 cis16 e16 a16 g16 d16 a4 f4 d16 dis16 des16 c16 c4 c8 e''8 g'''4 g''''4 }
 }>>
}
