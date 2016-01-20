# LyftTakeHome
Project Documentation by Tom Peng

Demo
A very short demo video is attached in this folder.

Project
This project is implemented using Xcode 7.2 with iOS 9.2

Console
Trip­logging associated events will be displayed in the console with “>>>” prefix.

View controllers
● Onboard View Controller s erves as an onboarding experience and asks user for location access permission.
● View Controller displays logging history and has a control for switching on/off trip logging.
● Trip Detail View Controller displays detailed information for each trip.

Trip Logging
● Logging Manager object takes care of location tracking, trip logging, and location access permission changes.
● GeoCoder object takes care for formatting each trip into readable data and visual images.

Other Functionalities
● Persistent storage using Core Data
● Visual representation of each trip using MKMapSnapshotter
● Handling cases where location authorization status is changed by user
● Image Caching
● Autolayout

Third Party Library
SDWebImage is used for caching map snapshot images.

Objective­c
Eventually I decided to go with objective­c because my familiarity with it enables me to deliver high quality assignment and implement more features within the time line.
