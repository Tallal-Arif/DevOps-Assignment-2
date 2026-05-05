const request = require('supertest');
const { app } = require('../index');

describe('Integration Tests for API Endpoints', () => {
  test('GET /health returns 200 and healthy status', async () => {
    const response = await request(app).get('/health');
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ status: 'UP', message: 'Service is healthy' });
  });

  test('GET /api/data returns an array of numbers', async () => {
    const response = await request(app).get('/api/data');
    expect(response.statusCode).toBe(200);
    expect(response.body.data).toBeInstanceOf(Array);
    expect(response.body.data).toHaveLength(5);
  });
});
