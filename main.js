const { app, BrowserWindow } = require('electron');
const path = require('path');
const { exec, execSync } = require('child_process');

let railsServer;
const PORT = 3000;  // 使用するポートを指定

function createWindow(port) {
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  mainWindow.loadURL(`http://localhost:${port}`);
  mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    console.error(`Failed to load URL http://localhost:${port}: ${errorDescription}`);
  });

  mainWindow.on('closed', () => {
    if (railsServer) {
      railsServer.kill('SIGINT');
    }
  });
}

function startRailsServer(port) {
  console.log(`Starting Rails server on port ${port}...`);
  railsServer = exec(`PORT=${port} rails server`, { env: process.env }, (error) => {
    if (error) {
      console.error(`Failed to start Rails server: ${error}`);
      return;
    }
  });

  const checkInterval = setInterval(() => {
    try {
      execSync(`curl -s http://localhost:${port}`);
      clearInterval(checkInterval);
      createWindow(port);
    } catch (e) {
      console.log(`Waiting for Rails server to start on port ${port}...`);
    }
  }, 2000);

  setTimeout(() => {
    clearInterval(checkInterval);
    if (railsServer) railsServer.kill('SIGINT');
    console.error(`Failed to start Rails server on port ${port}`);
  }, 60000);
}

app.whenReady().then(() => {
  startRailsServer(PORT);

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow(PORT);
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
  if (railsServer) railsServer.kill('SIGINT');
});