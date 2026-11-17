const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('evan', {
  dragStart: () => ipcRenderer.send('pet:drag-start'),
  dragMove: () => ipcRenderer.send('pet:drag-move'),
  dragEnd: () => ipcRenderer.send('pet:drag-end'),
  setPassthrough: (value) => ipcRenderer.send('pet:passthrough', value),
  menu: () => ipcRenderer.send('pet:menu'),
  step: (delta, walking) => ipcRenderer.invoke('pet:step', delta, walking),
  stop: () => ipcRenderer.send('pet:stop'),
  onSettings: (callback) => ipcRenderer.on('pet:settings', (_event, value) => callback(value)),
  onAction: (callback) => ipcRenderer.on('pet:action', (_event, value) => callback(value))
});
