import './assets/main.css'
import axios from 'axios';

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// Set axios to send credentials (like cookies) with every request
axios.defaults.withCredentials = true;

const app = createApp(App)

// Add Axios interceptor to include XSRF token in all requests
axios.interceptors.request.use(config => {
    const xsrf_token = localStorage.getItem('xsrf_token'); // Retrieve XSRF token from localStorage
    if (xsrf_token) {
      config.headers['X-XSRF-TOKEN'] = xsrf_token; // Attach XSRF token to request headers
    }
    return config;
  }, error => {
    return Promise.reject(error);
  });

  // Check if the user is logged in before navigating to each route
router.beforeEach((to, from, next) => {
    const user = JSON.parse(localStorage.getItem('user'));
    const isAuthenticated = !!user;

    if (!isAuthenticated && to.path !== '/login' && to.path !== '/register') {
        next('/login');  // Redirect to login page if not authenticated
    } else {
        next();  // Proceed to the requested page if authenticated
    }
});

app.use(router)

app.mount('#app')
