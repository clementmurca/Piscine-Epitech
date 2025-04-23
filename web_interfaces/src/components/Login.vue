<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-800">
    
    <div class="flex flex-col lg:flex-row bg-white p-10 rounded-lg shadow-lg w-11/12 max-w-5xl">
     
      <img src="@/image/login.png" class="w-full lg:w-1/2 object-cover mb-6 lg:mb-0" alt="Login Image">

      <!-- Login Form -->
      <div class="w-full lg:w-1/2 flex flex-col justify-center px-6 lg:px-10">
        <h2 class="text-3xl font-bold text-gray-800 mb-8 text-center">Login</h2>
        <form @submit.prevent="Login" class="space-y-6">
          <div>
            <label for="username" class="block text-sm font-medium text-gray-700">Username</label>
            <input
              v-model="formLoginData.username"
              type="text"
              name="username"
              id="username"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              placeholder="Username"
              required
            />
          </div>
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
            <input
              v-model="formLoginData.password"
              type="password"
              name="password"
              id="password"
              class="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              placeholder="Password"
              required
            />
          </div>
          <button
            type="submit"
            class="w-full py-2 px-4 bg-indigo-600 text-white font-semibold rounded-lg shadow-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
          >
            Login
          </button>
        </form>
        <p v-if="error" class="mt-4 text-sm text-red-500">{{ error }}</p>
        <p class="mt-4 text-sm text-gray-500">
          Don't have an account? 
          <router-link to="/register" class="text-indigo-600 hover:text-indigo-800">Register</router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios';
import Toastify from 'toastify-js';
import "toastify-js/src/toastify.css";
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const API_URL = process.env.TIME_MANAGER_APP_URL || 'http://localhost:4000/api';
const error = ref('');

const showToast = (message, type = 'success') => {
  Toastify({
    text: message,
    duration: 3000,
    close: true,
    gravity: "top",
    position: "right",
    background: type === 'success' ? "#4CAF50" : "#F44336",
  }).showToast();
};

const formLoginData = ref({
  username: '',
  password: ''
});

const Login = async () => {
  try {
    const data = {
      username: formLoginData.value.username.trim(),
      password: formLoginData.value.password.trim()
    };
    const response = await axios.post(`${API_URL}/login`, data);
    console.log('Login successful:', response.data);

    localStorage.setItem('user', JSON.stringify(response.data.user));
    localStorage.setItem('xsrf_token', response.data.xsrf_token);
    const user = JSON.parse(localStorage.getItem('user'));
    const userId = ref(user.id);
  
    showToast('Login successful');
    router.push(`/clock/${userId}`);
  } catch (error) {
    console.error('Error login:', error.response ? error.response.data : error);
    showToast('Login failed.', 'error');
  }
};
</script>
