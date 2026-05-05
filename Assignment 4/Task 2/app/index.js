const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', message: 'Service is healthy' });
});

app.get('/api/data', (req, res) => {
  res.status(200).json({ data: [1, 2, 3, 4, 5] });
});

function calculateSum(a, b) {
  return a + b;
}

function calculateDifference(a, b) {
  return a - b;
}

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
  });
}

module.exports = { app, calculateSum, calculateDifference };
