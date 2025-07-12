# Flutter Web - Fixed Port Configuration

This project is now configured to run consistently on **port 3000** instead of random ports.

## Available Methods to Run on Fixed Port

### 1. VS Code Debug Configuration (Recommended)
- Open the project in VS Code
- Go to the Debug panel (Ctrl+Shift+D)
- Select "Flutter Web (Fixed Port)" from the dropdown
- Click the green play button or press F5
- The app will run on http://localhost:3000

### 2. VS Code Tasks
- Open Command Palette (Ctrl+Shift+P)
- Type "Tasks: Run Task"
- Select "Flutter Web - Port 3000"
- The app will run on http://localhost:3000

### 3. Command Line
Run one of these commands in the terminal:

**PowerShell:**
```powershell
flutter run -d chrome --web-port=3000
```

**Or use the provided script:**
```powershell
.\start-web.ps1
```

**Command Prompt:**
```cmd
flutter run -d chrome --web-port=3000
```

**Or use the batch file:**
```cmd
start-web.bat
```

### 4. Package.json Scripts (Optional)
If you want npm-style scripts, you can create a `package.json` file with:
```json
{
  "name": "mobile-app-frontend",
  "scripts": {
    "dev": "flutter run -d chrome --web-port=3000",
    "build": "flutter build web",
    "test": "flutter test"
  }
}
```

## Port Configuration Details

### Default Port: 3000
- The app will always try to run on port 3000
- If port 3000 is busy, Flutter will show an error instead of switching ports
- To use a different port, change `--web-port=3000` to your preferred port

### Troubleshooting Port Issues

**If port 3000 is already in use:**
1. Check what's using the port:
   ```powershell
   netstat -ano | findstr :3000
   ```

2. Kill the process using the port:
   ```powershell
   taskkill /PID <process_id> /F
   ```

3. Or choose a different port by modifying the configuration files

### Files Modified

1. **`.vscode/launch.json`** - VS Code debug configurations
2. **`.vscode/tasks.json`** - VS Code task definitions  
3. **`start-web.bat`** - Windows batch script
4. **`start-web.ps1`** - PowerShell script

## Backend Integration

Make sure your backend API is configured to allow CORS from `http://localhost:3000`. If you're running the backend on a different port, update the API configuration in:
- `lib/core/config/api_config.dart`

## Development Workflow

1. **Start the app**: Use any of the methods above
2. **Access the app**: http://localhost:3000
3. **Hot reload**: Works automatically with all methods
4. **Stop the app**: Ctrl+C in terminal or stop button in VS Code

The app will now consistently run on port 3000, making it easier to:
- Bookmark the URL
- Configure backend CORS
- Share the development URL with team members
- Set up consistent development environment
