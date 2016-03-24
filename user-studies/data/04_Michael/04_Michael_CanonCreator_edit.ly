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
\tempo 4 = 200
\transpose a a {
\clef treble
\time 4/4
\key a \major
e'4 a'4 fis'4 a'4 gis'4 e'8 gis'8 gis'4 e'4 cis'16 a16 cis'16 a'16 fis'16 gis'16 fis'16 fis'16 cis'4 a4 gis8 cis16 gis16 e4 gis8 d8 e4 a4 cis'4 fis'4 a'4 gis'4 a'8 e'8 gis'4 e'4 cis'16 e'16 cis'16 e'16 a16 cis'16 a16 b16 fis4 e4 gis8 b16 gis16 e4 gis8 a8 a4 R1 R1 }
}
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
\tempo 4 = 200
\transpose a a {
\clef treble
\time 4/4
\key a \major
R1 R1 e'4 a'4 fis'4 a'4 gis'4 e'8 gis'8 gis'4 e'4 cis'16 a16 cis'16 a'16 fis'16 gis'16 fis'16 fis'16 cis'4 a4 gis8 cis16 gis16 e4 gis8 d8 e4 a4 cis'4 fis'4 a'4 gis'4 a'8 e'8 gis'4 e'4 cis'16 e'16 cis'16 e'16 a16 cis'16 a16 b16 fis4 e4 gis8 b16 gis16 e4 gis8 a8 a4 }
}

>>
}
