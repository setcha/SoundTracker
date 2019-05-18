# SoundTracker
By Seth Chatterton

An indoor localization system for iOS. Made for CSCI 2340, Databases, Bowdoin College.

Built off of TempiFFT by John Scalo.

To run the iPhone app, use Xcode to open and run TempiFFT.xcodeproj.
To run the sound system, set up an aggregate audio device (if on Mac, use Audio Midi Setup) with four output channels. Then the four channel audio can be played.


App:
The files I added from the original TempiFFT are SignalVector.swift and Localization.swift. I also added some things to SpectralViewController, like checking the location once every so often.

A SignalVector stores amplitude data of a specific sound frequency. The important method of this class is the risingEdge(), which gives the index of the SignalVector at which a beep is detected. The time at which the index is sampled is determined by the sample rate of the FFT.

Localization is based off of the distance in risingEdge() times. We can easily calculate the difference in time of the arriving beeps, and use this to calculate the difference in distances of pairs of speakers. We then try a number of points within our designated 3D space, to see which one minimizes the sum of squared errors between the actaul differences in distance vs the expected differences in distance at that point. This minimized error point is our location estimate. Since we are using a 0.5 meter grid in our space, we only need to check every 0.5 meters, rather than any finer resolution.


Audio:
Made with Audacity. Beeps for 0.2 seconds on a 1 second cyle at four different frequencies. Those frequencies, each on a separate channel, are 19500 Hz, 20100 Hz, 20750 Hz, and 21500 Hz.


To Do:

- Tons of debugging
- Make a Speaker class rather than having all of that information hard coded into Localization
- Improve rising edge detection to detect when a beep occurs
- Probably possible to not do an entire FFT, just the signals that we want to see in the 19 to 22 kHz range.
