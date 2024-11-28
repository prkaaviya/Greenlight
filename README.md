# Greenlight: A Real-Time Urban Bus Tracking Application

Greenlight is a Swift-based application designed to enhance public transportation usability by providing real-time information on bus locations, estimated arrivals, and route preferences. This project integrates Firebase, Mapbox, and public APIs to deliver a seamless experience for commuters.

## Table of Contents
```
Overview
Features
Tech Stack
Setup Instructions
Usage
Code Attribution
License
```
## Overview

Greenlight aims to solve a common urban problem: the lack of accessible, real-time information about public transportation. The application allows users to:
	1.	Select a route to travel and find the nearest bus stop from their current location.
	2.	View arrival or departure delays for better travel planning.

This project was developed as part of an assignment for Trinity College Dublin’s Urban Computing module.

## Features

1. **Real-Time Bus Location Updates**:

     Displays current bus positions on an interactive map.
   
     Shows direction-specific buses with customizable annotations.

3. **Route Selection**:
   
    Allows users to save preferred routes and find nearby bus stops.

5. **Geospatial Data Visualization**:
   
    Combines bus and user location data for a dynamic map experience.
   
	  Provides route information with arrival/delay details.

## Tech Stack

Programming Language: Swift

Frameworks:
```
SwiftUI for UI design
 
Mapbox SDK for map visualization
 
Firebase for real-time database and authentication
```
APIs:
```
Transport for Ireland API for route data

CoreLocation for user GPS tracking
```

## Setup Instructions

### Prerequisites

1. Xcode 13 or higher.
2. A Firebase project with authentication and real-time database enabled.
3. A Mapbox access token.

### Steps

1.	Clone the Repository:
```
git clone https://github.com/your-username/greenlight.git

cd greenlight
```

2.	Install Dependencies: Ensure you have CocoaPods installed. Run:
```
pod install
```

3.	Configure Firebase:

	•	Add the GoogleService-Info.plist file from your Firebase project to the project root.

6.	Set Mapbox Token:
   
	•	Replace the placeholder token in MapView.swift with your Mapbox access token.

8.	Run the Project:
Open the project in Xcode, select a simulator or device, and run the app.

## Usage

1. Sign In/Sign Up: Create an account or log in using your credentials.
 
2.	Select Route: Save your favorite route for quick access.
 
3.	Real-Time Map: View buses and delays on an interactive map.
 
4.	Manual Refresh: Update data with a simple button press.

## Code Attribution
```
Firebase Integration: Developed specifically for this assignment, with guidance from Firebase Swift Documentation.
 
Reverse Geocoding: Implemented based on standard geocoding techniques for iOS.
 
Transport for Ireland API: Integrated using official documentation: https://developer.nationaltransport.ie/.
 
Mapbox Integration: Map visualization was built with references from Mapbox iOS Documentation.
```

## License
```
This project is not licensed currently.
```
