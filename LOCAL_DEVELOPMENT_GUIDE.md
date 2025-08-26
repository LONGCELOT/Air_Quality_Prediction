# 🌐 Flutter App + Local FastAPI Connection Guide

## 📋 **Quick Setup Steps**

### **1. Start FastAPI Server**
```bash
# Option A: Use the startup script
cd "d:\CamTech\Y3T2\AI_and_its_application\FastAPI"
.\start_api_server.ps1

# Option B: Manual startup
cd "d:\CamTech\Y3T2\AI_and_its_application\FastAPI\aqi_prediction_api"
python main.py
```

### **2. Verify API is Running**
Open these URLs in your browser:
- **API Docs:** http://localhost:8000/docs
- **Health Check:** http://localhost:8000/health
- **Root Endpoint:** http://localhost:8000

### **3. Run Flutter App**
```bash
cd "d:\CamTech\Y3T2\AI_and_its_application\FastAPI\App_AQI"
flutter run
```

## 🔧 **Platform-Specific URLs**

The Flutter app now automatically uses the correct URLs:

| Platform | URL | Description |
|----------|-----|-------------|
| **Web (Chrome)** | `http://localhost:8000` | Direct localhost access |
| **Android Emulator** | `http://10.0.2.2:8000` | Android emulator localhost |
| **iOS Simulator** | `http://localhost:8000` | iOS simulator localhost |
| **Real Device** | `http://192.168.1.XXX:8000` | Your computer's local IP |

## 🧪 **Testing Connection**

1. **In the Flutter app**, you'll see a **"API Connection Test"** card at the top
2. **Click "Test"** to verify connectivity
3. **Check the status**:
   - ✅ **Green** = Connected successfully
   - ❌ **Red** = Connection failed

## 🔍 **Troubleshooting**

### **If Connection Fails:**

1. **Check FastAPI Server:**
   ```bash
   # Make sure it's running on port 8000
   netstat -an | findstr :8000
   ```

2. **Check Firewall:**
   - Windows may block the connection
   - Allow Python through Windows Firewall

3. **For Real Devices:**
   - Find your computer's IP: `ipconfig`
   - Update the IP in `aqi_api_service.dart`:
     ```dart
     return 'http://192.168.1.YOUR_IP:8000';
     ```

4. **Test API Manually:**
   ```bash
   # Test from command line
   curl http://localhost:8000/health
   ```

## 📱 **Device-Specific Setup**

### **Android Emulator:**
- ✅ Already configured with `10.0.2.2:8000`
- No additional setup needed

### **iOS Simulator:**
- ✅ Already configured with `localhost:8000`
- No additional setup needed

### **Real Android/iOS Device:**
1. Find your computer's IP address:
   ```bash
   ipconfig
   # Look for "IPv4 Address" under your network adapter
   ```

2. Update `lib/services/aqi_api_service.dart`:
   ```dart
   return 'http://YOUR_ACTUAL_IP:8000'; // e.g., http://192.168.1.105:8000
   ```

3. Ensure both devices are on the same WiFi network

## 🎯 **API Endpoints Available**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Server health check |
| `/live_data` | GET | Current air quality data |
| `/predict_live/xgboost` | GET | AQI predictions |
| `/docs` | GET | Interactive API documentation |

## ✅ **Success Indicators**

### **FastAPI Server:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

### **Flutter App:**
- Connection test shows ✅ green status
- Current AQI card displays real data
- No network errors in console

## 🚀 **Next Steps**

Once local connectivity is working:
1. Test all app features (current AQI, predictions, charts)
2. Add real device testing with IP configuration
3. Consider deploying to cloud (Render) for production use

## 📞 **Support**

If you encounter issues:
1. Check the connection test widget in the app
2. Review server logs for errors
3. Verify network connectivity between devices
