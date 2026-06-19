import { execSync } from 'child_process';

const pId = 'lifeguard-finance';
const cEmail = 'firebase-adminsdk-fbsvc@lifeguard-finance.iam.gserviceaccount.com';
const pKey = '-----BEGIN PRIVATE KEY-----\\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDAz5ooiw8PcUW+\\n6Bm36eal2y3jBHAH+9vsUIrVxusEClDyk4TjRkVNiKNEqeKBLOt4wxvJEmKCxROt\\n5l6jtFacwaE6ptbOz18ZDfrcNu/cDtAIdAeYuPoPKgWYIgYzlCWd7Na089r37Aeq\\nkb7lrrAmEJHozcC35GoEVUdAJwr0VsFezN6EI4e5yydwOPuvsZeqdX9CcSIAttDZ\\nVnn4UL/w8GYMZgW+TZW6FRGAMA+nmv85AfyEGi9IJmwdw8vNaGJmhyDDgdrIBN51\\nD1wm8Z9V/+LWkYKqxOPyB6JhLz3spWzcFhaJUcQEfETbW/Dj2RNn050TPtwjBoyd\\nypRO8mqJAgMBAAECggEASosYzSryICTJc8T1SIMAPshN5dKN47BOdv8upfbZXr8E\\nS7yX6Gx/F7pHcSEDJrDwusgoAmV+u5MpCBckKMNspv8/b9cX/m3zFNMwVRpSQrBh\\nYptFYpjFaL502jvxTNiucG+kFOKgmjBhSGM/vDn89UJ7vtdpdk8zY8h6mwVdOVhy\\nCUF/Zw/vC0lEkTN7yzYtA864fyGci65x9QCDc+L37r5uxVc279s7NWPQZWM0x1IO\\npv0X4nDRYXLDPNP3sK6DpWDFtMnPxTmBKPh3sN4sH1wvRhaEB5oU2SYaUtxwyUDb\\n1v7fuP/hOBIgWJ/BkQcYgdUjFSDlW0Wdr7Qh10CY/wKBgQD8dR7/x8Qq+0BlYLab\\nzcLqrtiKFCONtPtEqbBt9RxbcgMrFv5XwsFyzWPJXFawNyPiCcBg0XjPLMQDUhQt\\nnFBP2WDfb6T/SA356s+g8oySqVf7gQ2McO51RIFCpyUShBPn2UHkRauqBKs5wlED\\necdRtuxNDQX7Wlhto5vKv+A49wKBgQDDhDft2vKZ2o0VVv8t6H1oMVJMlWTgW5r/\\nWPZpU0lelUMV5ArHfQncJH/gmfGrmE4x10ggVRwBL52MhWSncfZO1zRhEUPAfM3k\\nu3UOcyzB5G4A7Hhv/kvFYSrcYA3r66f5UKjqVTutmSaAHX4GlFyEkeypzqmmSZO+\\n+Dl4sNkYfwKBgQCCg6YwA72VnujuwC4HpDtliljmIX0z8GGKYNOWNQag+/NJXozF\\nIClUSXySCAvE8+y4GeR76S80o+b99Hv8DHi0nyPmv1gkpcKb9lm60kn8NFII8vHn\\nLicJNw5AQBr5VJDZ5saa1a3mqp0+sgeh7V4vD4tgViBGjrFylQegrMulhwKBgQC2\\nRIR/USXpGD1+L2QkwCBpCdHXY05vefa9JYpSFjrH2g54Uedaoc6XU8+C6wDJH2uG\\nO1QaED3TPTh6z8BN+YfNaAKEmzu2LqMjIT63AdgvyWxjoA+HGGI616LFXyabUU1+\\ntxtBmcPQyn2B4fyi1ZyKWh9vDiJJyz3ZQj8RrIw2sQKBgQCr9RSE3pjt3WWAH/i8\\ng1fk2Te9gz3WsGscRgp1K0Uj6IWiEJj96vVapX+9YDLZD3degpmnqkINr1fgTjFG\\ntpBv1KxKJ+crCsTYKvKzmG+eYs6Du4C93qxUTFKBWFEaZS6rLnHQGJNHSrBOUInW\\n0gvGBYe9EODMPkvzb6UJlFoqPA==\\n-----END PRIVATE KEY-----\\n';

function updateEnv(key, value) {
  try {
    console.log(`Removing ${key}...`);
    execSync(`npx vercel env rm ${key} production -y`, { stdio: 'inherit' });
  } catch (e) {
    console.log(`${key} removal failed (might not exist yet)`);
  }
  
  console.log(`Adding ${key}...`);
  execSync(`npx vercel env add ${key} production`, {
    input: value,
    stdio: ['pipe', 'inherit', 'inherit']
  });
}

console.log('Updating Vercel Environment Variables...');
updateEnv('FIREBASE_PROJECT_ID', pId);
updateEnv('FIREBASE_CLIENT_EMAIL', cEmail);
updateEnv('FIREBASE_PRIVATE_KEY', pKey);
console.log('Environment Variables Updated Successfully.');
