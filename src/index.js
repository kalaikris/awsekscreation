import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

// Measure and send React app load time to backend
const measureAppLoadTime = () => {
  if (window.performance && window.performance.timing) {
    const timing = window.performance.timing;
    const loadTime = timing.loadEventEnd - timing.navigationStart;
    const domReadyTime = timing.domContentLoadedEventEnd - timing.navigationStart;
    const firstPaint = performance.getEntriesByType('paint')[0]?.startTime || 0;

    // Send metrics to backend
    fetch('http://localhost:5000/metrics/frontend', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        metric: 'react_load_time',
        value: loadTime / 1000, // Convert to seconds
        labels: {
          dom_ready: domReadyTime / 1000,
          first_paint: firstPaint / 1000
        }
      })
    }).catch(() => {}); // Fail silently if backend unavailable
  }
};

// Report metrics after load
window.addEventListener('load', () => {
  setTimeout(measureAppLoadTime, 0);
});

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
