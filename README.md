# CAIS Android Application

CAIS (CB Instrument Attendance & Inventory System) is a mobile application developed to simplify employee attendance, inventory management, and daily work reporting.

## Features

* Employee attendance management
* Camera-based attendance support
* Inventory management
* Daily reporting system
* Mobile-friendly interface

## Getting Started

This project is built using Flutter.

Useful resources for Flutter development:

* https://docs.flutter.dev/get-started/codelab
* https://docs.flutter.dev/cookbook
* https://docs.flutter.dev/

---

# Privacy Policy

Effective Date: 2026

CAIS respects and protects user privacy. This Privacy Policy explains how the application uses device permissions and handles user data.

## Information We Collect

The application collects the following types of data:

* **Personal Information**: Name, email address, employee ID, and position.
* **Face Data / Biometric Data**: Facial images captured through the device camera for attendance verification using facial recognition technology.
* **Location Data**: GPS coordinates to verify attendance within designated zones.
* **Attendance Records**: Check-in and check-out times, attendance status, and absence history.
* **Device Information**: Camera, storage, and network state access for application functionality.

## Camera Permission

The camera permission is used for:

* Attendance photo capture
* Facial recognition-based attendance verification
* Supporting work documentation features
* Image upload functionality

The application does not access the camera without explicit user action.

## Face Detection & Biometric Data

This application uses facial recognition technology (Google ML Kit Face Detection) to verify employee identity during attendance check-in/check-out.

* **How it works**: A photo is captured and processed locally to detect a face, then sent to our server for verification against registered employee photos.
* **Data storage**: Facial images are stored securely on our server and are only used for identity verification purposes.
* **Retention period**: Face data is retained for the duration of employment and will be deleted upon account deletion request.
* **Third-party processing**: Face detection is performed using Google ML Kit on-device. Server-side recognition is powered by CompreFace (self-hosted).
* We do **not** share face data with any third party for marketing, advertising, or any purpose beyond attendance verification.

## Location Permission

The GPS location permission is used for:

* Verifying that attendance check-in/check-out occurs within the designated office zone (200-meter radius from office location)
* Field duty location validation

Location data is only collected during active attendance sessions and is not tracked in the background. Background location is not used.

## Data Usage

All collected data is used strictly for operational purposes:

* Employee attendance tracking and reporting
* Identity verification through facial recognition
* Inventory management
* Daily work reporting

Data is not sold, rented, or shared with third parties for marketing purposes.

## Data Security

We implement reasonable security measures to protect user data:

* Data transmission is encrypted via HTTPS
* Face data is stored securely on company-controlled servers
* Access to personal data is restricted to authorized personnel only
* Regular security reviews are conducted

## Data Retention & Deletion

* Personal data and attendance records are retained for the duration of employment.
* Users may request account and data deletion by contacting the developer via email @richardkumbang04@gmail.com
* Deletion requests are processed within 3–7 business days.
* Some records may be retained temporarily for legal or administrative obligations.

## Third-Party Services

The application uses the following third-party services:

* **Google Play Services**: For core Android functionality and updates.
* **Google ML Kit**: For on-device face detection (data is not sent to Google).
* **CompreFace**: Self-hosted face recognition server for attendance verification.
* **Flutter framework plugins**: Required for cross-platform functionality.

These services operate under their own privacy policies and are used only as necessary for application features.

## Changes to This Policy

This Privacy Policy may be updated from time to time. Users will be notified of any material changes through the application.

## Contact

If you have any questions regarding this Privacy Policy or wish to request data deletion, please contact:

richardkumbang04@gmail.com or richard@cbinstrument.com
