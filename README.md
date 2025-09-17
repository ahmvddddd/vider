# Vider

**Vider** is a freelancer app that connects clients with service providers within their location.  
This app allows users to:

1. Search for service providers nearby using maps.  
2. View service provider portfolios and details of the services they render.  
3. Exchange text messages with service providers.  
4. Send job requests to service providers.  
5. Make crypto payments after completing each job.  

The app is built with **Flutter** for the frontend, **Node.js** for the backend, and **MongoDB** for data storage.  

---

## 🏗 Architecture

The app follows a **Model–View–Controller (MVC)** software architecture:

- **Models**  
  Represent the data and business logic of the application.  
  Examples:  
  - `user_model` (username, lastname, etc.)  
  - `job_model` (duration, status, etc.)  

- **Views**  
  Represent the **UI elements** visible to the user.  
  Examples: Login screen, Dashboard, Job listings.  

- **Controllers**  
  Handle user input, process requests, and decide what data from the Model goes to the View.  
  Example: `transaction_controller` fetches transactions from the backend and displays transaction details in the transaction history screen using the `transaction_model`.  

👉 All **state management** logic is handled with **flutter_riverpod**.  

---

## 📱 Screenshots & Features

### 🔑 Authentication
- Sign In and Sign Up screens with all required form fields.  
- Input values are validated before submission.  
- Authentication tokens are stored securely.

<p align="center">
<img src="assets/screenshots/sign_in.png" alt="Sign In" width="220" height="500"/>
<img src="assets/screenshots/sign_up.png" alt="Sign Up" width="220" height="500"/>
</p>

### 📊 Home Screen
- Displayed after login.  
- Shows the **total amount earned** by the provider since joining.  
- Includes a **job heatmap** and **average job duration** statistics.

<img src="assets/screenshots/home.png" alt="Home" width="220" height="500"/>

### 🔔 Map Screen 
- Shows current location of the user.  
- Displays locations of all available service provdier.  
- A search box that allows users to search for locations by name.  

<img src="assets/screenshots/map.png" alt="Map" width="220" height="500"/>

### 🔔 Notifications Screen 
- Shows a list of notifications including transactions, job updates, and other events.  
- Unread notifications are marked with colored indicators.  
- Notification badges are displayed on the home screen to alert users of new notifications.  

<img src="assets/screenshots/notifications.png" alt="Notifications" width="220" height="500"/>

### 🛠 Jobs
- Displays all jobs, with **active jobs pinned at the top**.  
- Includes a **timer indicator** to show remaining time for active jobs.  
- The hire screen allows users to specify job details before sending a request.

<p align="center">
<img src="assets/screenshots/jobs.png" alt="Jobs" width="220" height="500"/>
<img src="assets/screenshots/hire.png" alt="Hire Provider" width="220" height="500"/>
</p>

### 💬 Chat & Messaging
- Chat screen lists all client conversations with **unread indicators**.  
- Instant messaging powered by **WebSockets**.  
- Integrated with **Firebase Cloud Messaging (FCM)** so providers never miss messages or job updates.  

<p align="center">
<img src="assets/screenshots/chats.png" alt="Chats" width="220" height="500"/>
<img src="assets/screenshots/message.gif" alt="Message" width="220" height="500"/>
</p>

### 👤 Settings
- Settings screen provides access to:  
  - Wallet (balance + token deposits).  
  - App and profile customization options.  

<img src="assets/screenshots/settings.png" alt="Settings" width="220" height="500"/>

---

## 🛠 Tech Stack
- **Frontend:** Flutter  
- **Backend:** Node.js  
- **Database:** MongoDB  
- **State Management:** Riverpod  
- **Messaging/Notifications:** WebSockets & Firebase Cloud Messaging  
- **Payments:** Crypto-based payments  

---
