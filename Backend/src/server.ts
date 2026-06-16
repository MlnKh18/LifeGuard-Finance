import app from './app.js';
import { env } from '@shared/utils/env.js';

const port = env.PORT;

app.listen(port, () => {
  console.log(`🚀 LifeGuard Finance API running on port ${port}`);
  console.log(`📚 Swagger UI: http://localhost:${port}/api/docs`);
  console.log(`💚 Health: http://localhost:${port}/api/health`);
});
