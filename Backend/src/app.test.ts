import request from 'supertest';
import app from './app.js';

describe('GET /api/health', () => {
  it('should return 200 OK and health status', async () => {
    const response = await request(app).get('/api/health');
    expect(response.status).toBe(200);
    expect(response.body).toEqual(
      expect.objectContaining({
        success: true,
        message: 'LifeGuard Finance API is running',
      })
    );
  });
});
