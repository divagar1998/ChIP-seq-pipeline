#! /bin/bash
ml homer
cd ./cMYC/
annotatePeaks.pl unique_H2171_cMYC_peaks.bed hg38 -annStats unique_H2171_cMYC_peaks_annstats.txt > unique_H2171_cMYC_peaks_annotated.bed
annotatePeaks.pl unique_H82_cMYC_peaks.bed hg38 -annStats unique_H82_cMYC_peaks_annstats.txt > unique_82_cMYC_peaks_annotated.bed
annotatePeaks.pl unique_H524_cMYC_peaks.bed hg38 -annStats unique_H524_cMYC_peaks_annstats.txt > unique_H524_cMYC_peaks_annotated.bed