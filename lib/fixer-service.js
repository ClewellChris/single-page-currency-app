require('dotenv').config();
const axios = require('axios');
//const apikey = proccess.env.API_KEY;
const symbols = process.env.SYMBOLS || 'EUR,USD,GBP';

// Axios Client declaration
const api = axios.create({
  baseURL: 'https://api.apilayer.com/fixer',
  timeout: process.env.TIMEOUT || 5000,
  headers: {
      'apikey': 'BvGIUvMMIodSsc1Gs3PpXgaK6pcnDZkb'
  }
  
});

// Generic GET request function
const get = async (url) => {
  const response = await api.get(url);
  const { data } = response;
  if (data.success) {
    return data;
  }
  throw new Error(data.error.type);
};

module.exports = {
  getRates: () => get(`/latest&symbols=${symbols}&base=EUR`),
  getSymbols: () => get(`/symbols`),
  getHistoricalRate: date => get(`/${date}&symbols=${symbols}&base=EUR`),
};