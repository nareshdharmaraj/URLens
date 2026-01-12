Product Requirements Document: URLens
Version: 1.0
Date: January 12, 2026
Author: NARESH D - Founder, PathMakers.

Description:
1. Vision & Mission
Project Name: URLens

Vision: To provide a simple, beautiful, and unified interface for users to download, view, and manage web media from any platform, on any device.

Mission: URLens is a cross-platform application that acts as a universal lens for web media. By simply providing a URL, users can identify, download, and preview videos and images from a vast array of internet sources, saving them directly to their local device storage for offline access.
_________________________________________________________________________

2. Target Audience
Social Media Managers & Content Creators: Professionals who need to quickly download assets for archiving, analysis, or repurposing (with permission).

Educators & Students: Individuals who need to save online educational videos or reference material for offline viewing and presentations.

General Users: Anyone who wants a reliable way to save a funny video, a beautiful image, or a memorable clip from the web onto their device.
_________________________________________________________________________

3. Core Features & Functionality (Epics)

Epic 1: URL Analysis & Media Identification
    User Story 1.1: As a user, I want to paste any URL into a text field so that the application can begin processing it.
        Acceptance Criteria:
            A prominent text input field is on the main screen.
            A "Paste" button automatically populates the field with the content of the device's clipboard.
            A "Clear" button removes all text from the field.
    
    User Story 1.2: As a user, after I input a URL and tap "Analyze," I want to see a preview of the content so I can confirm it's the correct media.
        Acceptance Criteria:
            The app displays a loading indicator while communicating with the backend.
            Upon a successful response, a preview card appears.
            The preview card must display:
            The media's thumbnail image.
            The media's title.
            An icon representing the source platform (YouTube, Instagram, etc.).

Epic 2: Download Options & File Acquisition
    User Story 2.1: As a user, after the media is analyzed, I want to see a list of available download formats and qualities so I can choose the best option for my needs.
        Acceptance Criteria:
            A "Download" button appears on the preview card.
            Tapping "Download" opens a modal or bottom sheet.
            This sheet lists all available formats (e.g., 1080p MP4, 720p MP4, Audio Only M4A).
            Each option displays its resolution, file extension, and estimated file size.
    
    User Story 2.2: As a user, when I select a download option, I want to see a clear progress indicator and have the ability to cancel the download.
        Acceptance Criteria:
            The download starts immediately upon selection.
            A persistent notification (on mobile) or an in-app progress bar shows the download percentage.
            A "Cancel" button is available next to the progress indicator.
            The app should handle background downloads on mobile platforms.

Epic 3: Local Storage & Gallery Management
    User Story 3.1: As a user, once a download is complete, I want the file to be saved in an easily accessible location on my device.
        Acceptance Criteria:
            On Mobile (iOS/Android): Files are saved to the device's public gallery (for videos/images) or Downloads folder.
            On Desktop (Windows/macOS/Linux): Files are saved to the user's default "Downloads" folder.
        A success notification is shown upon completion.
    
    User Story 3.2: As a user, I want an in-app gallery or "History" tab to view all the media I have downloaded with URLens.
        Acceptance Criteria:
            A dedicated "History" section in the app.
            Lists all previously downloaded files with their thumbnail, title, and date.
            Metadata is stored in the local SQLite database.
    
    User Story 3.3: As a user, from the in-app history, I want to be able to preview, share, or delete my downloaded files.
        Acceptance Criteria:
            Tapping a history item opens an in-app preview (video player for videos, image viewer for images).
            Each item has options to:
                Share: Opens the native OS share sheet.
                Delete: Deletes the file from local storage and removes the record from the database.
                Locate File: (Desktop only) Opens the file in the native file explorer.
_________________________________________________________________________

4. Technical Architecture & Stack
Frontend: Flutter (Dart)
Backend: Python with FastAPI
Downloader Engine: yt-dlp library (within the backend)
Device Database: SQLite (using the sqflite package in Flutter)
Communication Protocol: HTTPS
Backend Hosting: Render
Data Flow Diagram:
[User on Flutter App] -> Pastes URL -> Taps "Analyze"
[Flutter App] -> Sends POST /api/v1/analyze request with {"url": "..."} to Render Backend
[FastAPI Backend on Render] -> Receives request -> Uses yt-dlp to extract metadata (title, thumbnail, platform) -> Does NOT download the file.
[FastAPI Backend on Render] -> Sends 200 OK response with JSON: { "title": "...", "thumbnail": "...", "platform": "..." }
[Flutter App] -> Renders the preview card -> User taps "Download"
[Flutter App] -> Sends POST /api/v1/download-info request with {"url": "..."} to Render Backend
[FastAPI Backend on Render] -> Receives request -> Uses yt-dlp to get a list of direct, temporary download links for different formats.
[FastAPI Backend on Render] -> Sends 200 OK response with JSON: { "options": [{ "quality": "1080p", "url": "direct-link-1", "size": "..." }, ...] }
[Flutter App] -> Displays options to the user -> User selects one.
[Flutter App] -> Directly downloads the file from the direct-link-1 using dio or a similar package, showing progress.
[Flutter App] -> Saves the file to local storage -> Saves metadata (local path, title, etc.) into the local SQLite database.
________________________________________________________________________

5. API Specification (Version 1)
Base URL: https://<your-render-app-name>.onrender.com
Endpoint 1: Analyze URL
Route: POST /api/v1/analyze
Description: Takes a URL and returns its basic metadata for previewing.
Request Body (JSON):
code
JSON
{
  "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
Success Response (200 OK):
code
JSON
{
  "platform": "youtube",
  "title": "Rick Astley - Never Gonna Give You Up (Official Music Video)",
  "thumbnail_url": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
}
Error Response (400 Bad Request):
code
JSON
{
  "detail": "Error processing URL: Unsupported URL or Private Video"
}
Endpoint 2: Get Download Information
Route: POST /api/v1/download-info
Description: Takes a URL and returns a list of direct, downloadable links in various formats.
Request Body (JSON):
code
JSON
{
  "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
Success Response (200 OK):
code
JSON
{
  "download_options": [
    {
      "quality_label": "1080p",
      "extension": "mp4",
      "file_size_approx": 45582999,
      "download_url": "https://direct-expiring-link-to-1080p-video..."
    },
    {
      "quality_label": "720p",
      "extension": "mp4",
      "file_size_approx": 25165824,
      "download_url": "https://direct-expiring-link-to-720p-video..."
    },
    {
      "quality_label": "Audio Only",
      "extension": "m4a",
      "file_size_approx": 5293488,
      "download_url": "https://direct-expiring-link-to-audio..."
    }
  ]
}
_________________________________________________________________________

6. Local Database Schema (SQLite)
Table Name: download_history
Column Name	Data Type	Constraints	Description
id	INTEGER	PRIMARY KEY, AUTOINCREMENT	Unique identifier for the record.
original_url	TEXT	NOT NULL	The source URL provided by the user.
title	TEXT	NOT NULL	Title of the downloaded media.
thumbnail_url	TEXT		URL of the thumbnail for display in history.
platform	TEXT		e.g., 'youtube', 'instagram'.
local_file_path	TEXT	NOT NULL	The absolute path to the file on the device.
file_size	INTEGER		The size of the file in bytes.
download_date	TEXT	NOT NULL	ISO 8601 formatted timestamp of download completion.
_________________________________________________________________________

7. Non-Functional Requirements
Performance:
    API response time for /analyze should be < 2 seconds.
    The app UI must remain responsive during downloads.

Error Handling: The app must gracefully handle and inform the user of common errors:
    No internet connection.
    Invalid or malformed URL.
    Unsupported website.
    Private or geographically restricted content.
    Backend server is down.
    Insufficient device storage.

Security:
    All communication between the app and the backend must use HTTPS.
    The backend must not log sensitive user data.

Legal & Ethical:
    The app must display a clear Disclaimer and Terms of Service on first launch and in the settings menu.
    The disclaimer must state that the user is responsible for ensuring they have the legal right to download the content and that the app should not be used for copyright infringement.
_________________________________________________________________________

8. Deployment & Infrastructure Plan
Backend (FastAPI):
    Create a project on Render.
    Link to a GitHub repository containing the Python code.
    The repository must include a requirements.txt file (with fastapi, uvicorn, yt-dlp).
    Set the startup command in Render to: uvicorn main:app --host 0.0.0.0 --port $PORT
    Render will automatically build and deploy the application, providing a public HTTPS URL.

Frontend (Flutter):
    Develop the Flutter application, pointing the API service to the Render URL.
    Follow standard procedures to build and sign release versions for:
    Google Play Store (Android)
    Apple App Store (iOS)
    Create installers for Windows (.exe), macOS (.dmg), and Linux (.AppImage or .deb).
_________________________________________________________________________

9. Future Scope (Roadmap V1.1+)

Playlist/Album Downloads: Allow users to input a playlist URL and download all items.

In-app Subscriptions: Allow users to "subscribe" to channels or profiles and be notified of new content.

Format Conversion: Offer to convert downloaded videos to other formats (e.g., MP3, GIF) on the device.

Cloud Sync: Allow users to link a cloud storage account (Google Drive, Dropbox) to save files directly to the cloud.

Browser Extension: A companion browser extension to send URLs directly to the URLens desktop app.

Peer-to-Peer sharing: Share local media to another URLens user via app far away.