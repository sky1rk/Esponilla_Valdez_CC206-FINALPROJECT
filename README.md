**Notiva – Turn Your Tasks into Adventures**

Notiva is a gamified mobile to-do application designed to make productivity engaging and fun. By framing your daily tasks within a fantasy-adventure theme, Notiva transforms your ordinary to-do list into a series of quests waiting to be completed.

**Features**
* User Authentication – Secure sign-up and login system for managing user accounts.
* Task Management – Create, view, and complete tasks through an intuitive interface.
* Gamified Experience – A custom fantasy theme that turns mundane tasks into exciting adventures.
* Progress Tracking – Level up and earn rewards as you complete quests, tracking your journey and accomplishments.

**Getting Started**
**Prerequisites**
* An Android device
* ngrok installed and authenticated
* A local backend server (e.g., json-server)

**Running the Packaged Application**

Notiva connects to a publicly accessible API endpoint generated through ngrok. This allows you to run the packaged app on your Android device from anywhere, as long as your backend and ngrok tunnel are active.

Follow these steps:

1. Start Your Local Backend
Run your backend service (e.g., json-server) on your computer.
Example:
json-server --watch db.json --port 3000

2. Expose Your Backend via ngrok
Open a new terminal and run:
ngrok http 3000
(Replace 3000 with your server’s port if different.)

3. Copy the Public URL
ngrok will display a Forwarding HTTPS URL
(e.g., https://random-string.ngrok.io).
Copy the HTTPS version.

4. Update the API URL in the App
Open: lib/screens/main.dart
Locate the constant:
const String _apiBase = 'https://your-ngrok-url.ngrok.io';
Replace its value with your newly generated ngrok URL.

5. Build and Install
Rebuild the application and install it on your Android device.
The app will now communicate with your backend through the ngrok tunnel.

**Important Note**:
ngrok URLs are temporary.
If you restart ngrok, a new URL will be generated. You must update:
* the _apiBase constant
* rebuild the app
before running it again.
