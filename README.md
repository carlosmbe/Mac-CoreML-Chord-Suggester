# Mac-CoreML-Chord-Suggester
This is CoreML Project that predicts the most likely next chord based on the entered Chord Progression. This project is based on the following article https://medium.com/@huanlui/chordsuggester-i-3a1261d4ea9e

Note that the Model is a `.mlpackage` and GitHub does not like that. Hence why it is zipped. You can also use [Google Drive](https://drive.google.com/file/d/1TvkW57FigHKJ1O5EgQYFABUuXRphSu4A/view?usp=sharing) to preview the contents.

This repository contains the macOS app of the ChordSuggester project. This application predicts musical chord sequences using LSTMs, where the original model was converted to CoreML for optimal performance on macOS devices.

## Project Overview

ChordSuggester was originally created as a part of a Master's thesis, aiming to deliver a comprehensive experience of a DataScience project. The workflow of the project encompassed various stages such as:

- Data Acquisition: Scraping data from [ultimate-guitar.com](https://www.ultimate-guitar.com/) with Selenium and BeautifulSoup
- Data Cleaning and Preparation: Cleaning the acquired data using Pandas and music21
- Data Analysis: Analyzing the cleaned data with Pandas
- Modelling: Training an LSTM neural network using Keras
- Visualisation: Building a React Application that interfaces with the model via TensorFlow.js and presents the results using JavaScript musical libraries, Tone.js and Vexflow

This macOS app is built on top of the original project by converting the Keras-based LSTM model into CoreML, enabling efficient execution on macOS devices.

## CoreML Conversion

The Keras-based LSTM model was converted to CoreML using the coremltools Python package, which simplifies the process of converting models from popular machine learning tools into CoreML format.

I wrote an article describing how you can do that by yourself [here](https://medium.com/codex/how-to-convert-tensorflow-h5-models-to-core-ml-70a28bbd5c60).

## macOS App

The macOS app was built using Swift and the SwiftUI framework for the user interface. The app utilizes the CoreML model to predict the next musical chord sequence based on the user's input. 

Each chord is represented by a number. So it's an array of numbers which is equal to an array of chords. See the JSON files inside to get the logic.

